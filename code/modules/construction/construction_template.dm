/datum/construction_template
	/// The component this belong to
	var/datum/component/construction/component
	/// The object this belongs to.
	var/obj/parent

	/// The list of construction sequences.
	var/list/sequences = list()
	/// A list of items inside us that were used for construction.
	var/list/obj/item/contained_items = list()
	/// If TRUE, call setup_default_state
	var/default_state = TRUE
	/// If TRUE, this construction is reversible. Undoing every step will run on_deconstruct()
	var/reversible = TRUE
	/// If TRUE, will qdel the parent during deconstructed()
	var/qdel_on_deconstruct = TRUE

	/// If TRUE, a step is currently being performed, and a new one cannot be started.
	var/performing_step = FALSE

	var/constructed = FALSE

/datum/construction_template/New(component_owner, obj_owner)
	component = component_owner
	parent = obj_owner

	// New all sequences and set us as parent
	var/list/sequence_instances = list()
	for(var/datum/construction_sequence/sequence as anything in sequences)
		sequence = new sequence(src)
		RegisterSignal(sequence, COMSIG_CONSTRUCTION_SEQUENCE_COMPLETION_CHANGED, PROC_REF(completion_changed))
		sequence_instances += sequence
	sequences = sequence_instances

	// Setup the default state.
	setup_default_state()

/datum/construction_template/Destroy(force, ...)
	contained_items = null
	QDEL_LIST(sequences)
	component = null
	parent = null
	return ..()

/// Sets the initial states of all steps and sequences.
/datum/construction_template/proc/setup_default_state()
	PRIVATE_PROC(TRUE)

	for(var/datum/construction_sequence/sequence as anything in sequences)
		sequence.default_state()

/// Transfer parent status to another object.
/datum/construction_template/proc/transfer_parent(obj/new_parent, qdel_old = TRUE)
	. = parent
	new_parent.TakeComponent(component)
	if(qdel_old)
		qdel(.)

/// Each step has been completed, what now?
/datum/construction_template/proc/constructed(mob/user)
	return

/// Each step has been completed, what now?
/datum/construction_template/proc/deconstructed(mob/user)
	if(qdel_on_deconstruct)
		qdel(parent)

/// Completely disassemble the object.
/datum/construction_template/proc/fully_deconstruct()
	var/atom/drop_loc = parent.drop_location()
	for(var/datum/construction_sequence/sequence as anything in sequences)
		sequence.fully_deconstruct(drop_loc)

/// Called by sequence/proc/update_completion().
/datum/construction_template/proc/completion_changed(datum/source, mob/living/user, old_state)
	SIGNAL_HANDLER

	var/completed_sequences = 0
	var/empty_sequences = 0
	for(var/datum/construction_sequence/sequence as anything in sequences)
		switch(sequence.check_completion())
			if(SEQUENCE_FINISHED)
				completed_sequences++
			if(SEQUENCE_NOT_STARTED)
				empty_sequences++

	if(completed_sequences == length(sequences))
		constructed = TRUE
		constructed(user)
		return

	if(empty_sequences == length(sequences))
		constructed = FALSE
		deconstructed(user)
		return

/datum/construction_template/proc/interact_with(mob/living/user, obj/item/I, deconstructing)
	set waitfor = FALSE

	var/list/available_interactions = list()
	for(var/datum/construction_sequence/sequence as anything in sequences)
		available_interactions += sequence.try_get_steps_for(user, I, deconstructing)

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

	step.sequence.attempt_step(step, user, I)
	return TRUE

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

	for(var/datum/construction_sequence/sequence as anything in sequences)
		. += sequence.examine(user, "")
