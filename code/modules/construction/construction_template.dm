/datum/construction_template
	/// The component this belong to
	var/obj/item/circuitboard/circuit_parent
	/// The object this belongs to.
	var/obj/machinery/parent

	/// The list of construction sequences.
	var/list/sequences = list()
	/// If TRUE, call setup_default_state
	var/default_state = TRUE
	/// If TRUE, this construction is reversible. Undoing every step will run on_deconstruct()
	var/reversible = TRUE
	/// If TRUE, will qdel the parent during deconstructed()
	var/qdel_on_deconstruct = TRUE

	/// If TRUE, a step is currently being performed, and a new one cannot be started.
	var/performing_step = FALSE

	var/constructed = FALSE

/datum/construction_template/New(circuit)
	circuit_parent = circuit

	// New all sequences and set us as parent
	var/list/sequence_instances = list()
	for(var/datum/construction_step/sequence/sequence as anything in sequences)
		sequence = new sequence(null, src)
		RegisterSignal(sequence, COMSIG_CONSTRUCTION_SEQUENCE_COMPLETION_CHANGED, PROC_REF(completion_changed))
		sequence_instances += sequence
	sequences = sequence_instances

/datum/construction_template/Destroy(force, ...)
	QDEL_LIST(sequences)
	circuit_parent = null
	return ..()

/// Sets the initial states of all steps and sequences.
/datum/construction_template/proc/setup_default_state()
	for(var/datum/construction_step/sequence/sequence as anything in sequences)
		sequence.default_state()

/// Transfer parent status to another object.
/datum/construction_template/proc/set_parent(obj/machinery/new_parent, qdel_old = TRUE)
	var/obj/machinery/old_parent = parent
	if(old_parent)
		UnregisterSignal(
			parent,
			list(
				COMSIG_OBJ_DECONSTRUCT,
				COMSIG_ATOM_ATTACK_HAND_SECONDARY,
				COMSIG_PARENT_ATTACKBY,
				COMSIG_PARENT_ATTACKBY_SECONDARY,
				COMSIG_PARENT_EXAMINE,
			)
		)

	if(isnull(new_parent))
		if(qdel_old)
			qdel(old_parent)
		return old_parent

	parent = new_parent

	RegisterSignal(parent, COMSIG_OBJ_DECONSTRUCT, PROC_REF(parent_deconstructed))
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND_SECONDARY, PROC_REF(parent_attack_hand_secondary))
	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, PROC_REF(parent_attackby))
	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY_SECONDARY, PROC_REF(parent_attackby_secondary))
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(parent_examine))

	if(old_parent)
		new_parent.component_parts = old_parent.component_parts
		for(var/obj/item/I in new_parent.component_parts)
			I.forceMove(new_parent)

		old_parent.component_parts = null

	new_parent.RefreshParts()

	if(old_parent && qdel_old)
		qdel(old_parent)
	return old_parent

/// Each step has been completed, what now?
/datum/construction_template/proc/constructed(mob/user)
	return

/// Going from fully complete to missing any number of steps.
/datum/construction_template/proc/partially_deconstructed(mob/user)
	return

/// Each step has been completed, what now?
/datum/construction_template/proc/deconstructed(mob/user)
	if(qdel_on_deconstruct)
		qdel(parent)

/// Completely disassemble the object.
/datum/construction_template/proc/fully_deconstruct()
	var/atom/drop_loc = parent.drop_location()
	for(var/datum/construction_step/sequence/sequence as anything in sequences)
		sequence.deconstruct(drop_loc)

/// Called by sequence/proc/update_completion().
/datum/construction_template/proc/completion_changed(datum/source, mob/living/user, old_state)
	SIGNAL_HANDLER

	var/completed_sequences = 0
	var/empty_sequences = 0
	for(var/datum/construction_step/sequence/sequence as anything in sequences)
		switch(sequence.complete)
			if(SEQUENCE_FINISHED)
				completed_sequences++
			if(SEQUENCE_NOT_STARTED)
				empty_sequences++

	if(completed_sequences == length(sequences))
		constructed = TRUE
		constructed(user)

	if(empty_sequences == length(sequences))
		constructed = FALSE
		deconstructed(user)

	else
		if(constructed)
			partially_deconstructed(user)


/datum/construction_template/proc/interact_with(mob/living/user, obj/item/I, deconstructing)
	set waitfor = FALSE

	var/list/available_interactions = list()
	for(var/datum/construction_step/sequence/sequence as anything in sequences)
		available_interactions += sequence.try_get_steps_for(user, I, deconstructing)

	list_clear_nulls(available_interactions)

	if(!length(available_interactions))
		return FALSE

	// Passed this point, all interactions are blocking
	. = TRUE

	var/datum/construction_step/step
	if(length(available_interactions) != 1)
		disambiguate_list(available_interactions)

		var/choice = tgui_input_list(user, "Select an action", "Construction", available_interactions)
		if(!choice)
			return

		if(!user.canUseTopic(parent, USE_CLOSE|USE_DEXTERITY))
			return

		if(!user.is_holding(I))
			return

		step = available_interactions[choice]
		if(!step?.can_do_action(user, I, deconstructing))
			return
	else
		step = available_interactions[available_interactions[1]]
		if(isnull(step)) // Steps can insert nulls as noop options.
			return

	step.parent_sequence.attempt_step(step, user, I)
	return TRUE

/datum/construction_template/proc/remove_atom_from_parts(atom/movable/AM)
	for(var/datum/construction_step/sequence/sequence as anything in sequences)
		if(sequence.remove_atom_from_parts(AM))
			return

/datum/construction_template/proc/disambiguate_list(list/L)
	var/list/tally = list()
	var/list/out = list()

	for(var/entry in L)
		var/existing = tally[entry]
		if(existing && existing != "Do Nothing")
			out["[entry] ([existing + 1])"] = L[entry]
		else
			out[entry] = L[entry]

	. = L = out

/datum/construction_template/proc/examine(mob/user) as /list
	. = list()
	if(constructed)
		return

	for(var/datum/construction_step/sequence/sequence as anything in sequences)
		. += sequence.examine(user, "")

/datum/construction_template/proc/parent_deconstructed(datum/source, disassembled)
	SIGNAL_HANDLER

	if(disassembled)
		fully_deconstruct()

/datum/construction_template/proc/parent_attack_hand_secondary(datum/source, mob/user)
	SIGNAL_HANDLER
	if(interact_with(user, null, TRUE))
		return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/construction_template/proc/parent_attackby(datum/source, obj/item/I, mob/living/user)
	SIGNAL_HANDLER
	if(interact_with(user, I, FALSE))
		return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/construction_template/proc/parent_attackby_secondary(datum/source, obj/item/I, mob/living/user)
	SIGNAL_HANDLER
	if(interact_with(user, I, TRUE))
		return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/construction_template/proc/parent_examine(atom/source, mob/user, list/examine_text)
	SIGNAL_HANDLER
	examine_text += examine(user)

// Basic templates hold a machinery path to produce.
/datum/construction_template/basic
	var/obj/machinery/result_path

/datum/construction_template/basic/partially_deconstructed(mob/user)
	if(istype(parent, /obj/structure/frame))
		return

	parent.set_machine_stat(parent.machine_stat | NOT_FULLY_CONSTRUCTED)

/datum/construction_template/basic/constructed(mob/user)
	if(istype(parent, /obj/structure/frame))
		var/obj/machinery/result = new result_path(parent.loc, FALSE)
		return

	parent.set_machine_stat(parent.machine_stat & ~NOT_FULLY_CONSTRUCTED)
	parent.RefreshParts()
