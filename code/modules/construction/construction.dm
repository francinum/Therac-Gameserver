/datum/construction
	/// The object this belongs to. Use set_parent().
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

/datum/construction/New(obj/new_parent)
	if(QDELETED(new_parent))
		return

	// Set parent object
	set_parent(new_parent)

	// New all sequences and set us as parent
	var/list/sequence_instances = list()
	for(var/datum/construction_sequence/sequence as anything in sequences)
		sequence = new sequence(src)
		sequence_instances += sequence
	sequences = sequence_instances

	// Setup the default state.
	setup_default_state()

/datum/construction/Destroy(force, ...)
	SHOULD_CALL_PARENT(FALSE)
	parent = null
	QDEL_LIST(sequences)
	contained_items = null
	return QDEL_HINT_IWILLGC

/// Sets the initial states of all steps and sequences.
/datum/construction/proc/setup_default_state()
	PRIVATE_PROC(TRUE)

	for(var/datum/construction_sequence/sequence as anything in sequences)
		for(var/datum/construction_step/step as anything in sequence.steps)
			if(step.has_default_state)
				step.default_state()

		sequence.update_completion()

/// Sets the parent.
/datum/construction/proc/set_parent(obj/new_parent)
	PRIVATE_PROC(TRUE)
	parent = new_parent

/// Transfer parent status to another object.
/datum/construction/proc/transfer_parent(obj/new_parent, qdel_old = TRUE)
	. = parent
	set_parent(new_parent)
	qdel(.)
	//SEND_SIGNAL(src, COMSIG_CONSTRUCTION_TRANSFER_PARENT, new_parent, .)

/// Each step has been completed, what now?
/datum/construction/proc/constructed(mob/user)
	return

/// Each step has been completed, what now?
/datum/construction/proc/deconstructed(mob/user)
	if(qdel_on_deconstruct)
		qdel(parent)
	return

/// Completely disassemble the object.
/datum/construction/proc/fully_deconstruct()
	for(var/datum/construction_sequence/sequence as anything in sequences)
		sequence.fully_deconstruct()

/// Called by sequence/proc/update_completion().
/datum/construction/proc/completion_changed(mob/living/user)
	var/completed_sequences = 0
	var/empty_sequences = 0
	for(var/datum/construction_sequence/sequence as anything in sequences)
		switch(sequence.check_completion())
			if(SEQUENCE_FINISHED)
				completed_sequences++
			if(SEQUENCE_NOT_STARTED)
				empty_sequences++

	if(completed_sequences == length(sequences))
		constructed(user)
		return

	if(empty_sequences == length(sequences))
		deconstructed(user)
		return

/datum/construction/proc/interact_with(mob/living/user, obj/item/I)
	var/list/available_interactions = list()
	for(var/datum/construction_sequence/sequence as anything in sequences)
		available_interactions += sequence.get_available_steps(user, I)

	if(!length(available_interactions))
		return FALSE

	var/datum/construction_step/step
	if(length(available_interactions) != 1)
		disambiguate_list(available_interactions)

		var/choice = tgui_input_list(user, "Select an action", "Construction", available_interactions)
		if(!choice)
			return FALSE

		if(!user.canUseTopic(parent, USE_CLOSE|USE_DEXTERITY))
			return FALSE

		if(!user.is_holding(I))
			return FALSE

		step = available_interactions[choice]
		if(!step?.can_do_action(user, I))
			return FALSE
	else
		step = available_interactions[available_interactions[1]]
		if(isnull(step)) // Steps can insert nulls as noop options.
			return

	step.sequence.attempt_step(step, user, I)
	return TRUE

/datum/construction/proc/disambiguate_list(list/L)
	var/list/tally = list()
	var/list/out = list()

	for(var/entry in L)
		var/existing = tally[entry]
		if(existing && existing != "Do Nothing")
			out["[entry] ([existing + 1])"] = L[entry]
		else
			out[entry] = L[entry]

	. = L = out
