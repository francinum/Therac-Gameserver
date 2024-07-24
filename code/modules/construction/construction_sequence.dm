/datum/construction_step/sequence
	/// A list of steps to complete, in order.
	var/list/steps = list()

	/// An array of values corresponding to the step indexes. Each index where an optional sequence is present is 1.
	var/list/optional_step_indexes
	/// An array of values corresponding to optional step completion. Optional steps are only complete here if they are
	/// actually complete, whereas check_completion() considers them complete no matter what due to being optional.
	/// Set by update_completion()
	var/list/optional_completion_cache

	var/optional = FALSE

/datum/construction_step/sequence/New(datum/construction_step/sequence/parent_sequence, datum/construction_template/parent_template)
	..()

	optional_step_indexes = new /list(length(steps))
	optional_completion_cache = new /list(length(steps))

	var/list/step_instances = list()
	var/i = 0
	for(var/datum/construction_step/step as anything in steps)
		i++
		step = new step(src, parent_template)
		step_instances += step

		if(istype(step, /datum/construction_step/sequence))
			var/datum/construction_step/sequence/sequence = step
			RegisterSignal(sequence, COMSIG_CONSTRUCTION_SEQUENCE_COMPLETION_CHANGED, PROC_REF(child_sequence_completion_changed))
			if(sequence:optional)
				optional_step_indexes[i] = TRUE

	steps = step_instances

/datum/construction_step/sequence/Destroy(force, ...)
	. = ..()
	if(. == QDEL_HINT_LETMELIVE)
		return

	QDEL_LIST(steps)
	return QDEL_HINT_IWILLGC

/datum/construction_step/sequence/default_state()
	for(var/datum/construction_step/step as anything in steps)
		step.default_state()

/// Called by /datum/component/construction/proc/fully_deconstruct
/datum/construction_step/sequence/deconstruct(atom/drop_loc)
	SHOULD_CALL_PARENT(FALSE)

	if(complete == SEQUENCE_NOT_STARTED)
		return

	for(var/datum/construction_step/step as anything in steps)
		if(step.complete == SEQUENCE_NOT_STARTED)
			continue

			step.deconstruct()

	update_completion()

/// Returns a list of steps that can be performed with the given arguments.
/datum/construction_step/sequence/try_get_steps_for(mob/living/user, obj/item/I, deconstructing = FALSE)
	var/list/possible_steps = get_possible_steps(deconstructing)
	for(var/datum/construction_step/step as anything in possible_steps)
		var/list/step_struct = step.try_get_steps_for(arglist(args))
		if(step_struct)
			. += step_struct

/datum/construction_step/sequence/proc/get_possible_steps(deconstructing) as /list
	PRIVATE_PROC(TRUE)

	. = list()
	if(!deconstructing)
		for(var/i in 1 to length(steps))
			var/datum/construction_step/step = steps[i]

			if(!istype(step, /datum/construction_step/sequence))
				if(step.complete != SEQUENCE_FINISHED)
					. += step
					return .
				continue

			var/datum/construction_step/sequence/sequence = step
			if(sequence.complete == SEQUENCE_FINISHED)
				continue

			if(!sequence.optional)
				. += sequence.get_possible_steps(deconstructing)
				return .

			// The step is optional. So we are going to peek ahead to grab
			// every optional step up to and including the next non-optional one.
			for(var/j in i to length(steps))
				sequence = steps[j]
				if(!optional_step_indexes[j])
					if(istype(sequence))
						. += sequence.get_possible_steps(deconstructing)
					else
						. += sequence
					return .

				if(sequence.complete != SEQUENCE_FINISHED)
					. += sequence.get_possible_steps(deconstructing)
		return .

	// Deconstruction
	for(var/i in length(steps) to 1 step -1)
		var/datum/construction_step/step = steps[i]

		if(!istype(step, /datum/construction_step/sequence))
			if(step.complete != SEQUENCE_NOT_STARTED)
				. += step
				return .
			continue

		var/datum/construction_step/sequence/sequence = step
		if(sequence.complete == SEQUENCE_NOT_STARTED)
			continue

		if(!sequence.optional)
			. += sequence.get_possible_steps(deconstructing)
			return .

		// The step is optional. So we are going to peek ahead to grab
		// every optional step up to and including the next non-optional one.
		for(var/j in i to 1 step -1)
			sequence = steps[j]
			if(!optional_step_indexes[j])
				if(istype(sequence))
					. += sequence.get_possible_steps(deconstructing)
				else
					. += sequence
				return .

			if(sequence.complete != SEQUENCE_NOT_STARTED)
				. += sequence.get_possible_steps(deconstructing)

/// Attempt an action in this sequence. Returns TRUE if one was performed.
/datum/construction_step/sequence/proc/attempt_step(datum/construction_step/step, mob/living/user, obj/item/I)
	if(step.attempt_action(user, I) != STEP_FAIL)
		update_completion(user)
		return TRUE

/datum/construction_step/sequence/proc/examine(mob/user, tree_depth_string = "") as /list
	. = list()

	if(complete == SEQUENCE_FINISHED)
		. += span_info("[tree_depth_string][name]")

	else if(optional)
		. += span_notice("[tree_depth_string][name]")
	else
		. += span_alert("[tree_depth_string][name]")

	if(tree_depth_string == "")
		tree_depth_string = "&rdsh; "

	tree_depth_string = "[FOURSPACES][tree_depth_string]"

	for(var/datum/construction_step/step as anything in steps)
		if(istype(step, /datum/construction_step/sequence))
			var/datum/construction_step/sequence/sequence = step
			. += sequence.examine(user, tree_depth_string)
			continue

		if(step.complete == SEQUENCE_FINISHED)
			. += span_info("[tree_depth_string][step.name]")
		else
			. += span_alert("[tree_depth_string][step.name]")


/// Updates the completion status of this sequence.
/datum/construction_step/sequence/proc/update_completion(mob/living/user)
	var/old_state = complete
	var/num_complete = 0

	var/i = 0
	for(var/datum/construction_step/step as anything in steps)
		i++

		if(istype(step, /datum/construction_step/sequence))
			var/datum/construction_step/sequence/child_sequence = step
			var/child_completion = child_sequence.complete
			if(child_sequence.optional || (child_completion == SEQUENCE_FINISHED))
				num_complete++
				if(child_completion == SEQUENCE_FINISHED)
					optional_completion_cache[i] = TRUE
			continue

		if(step.complete != SEQUENCE_FINISHED)
			optional_completion_cache[i] = FALSE
			continue

		num_complete++
		optional_completion_cache[i] = TRUE

	if(num_complete == 0)
		complete = SEQUENCE_NOT_STARTED

	else if(num_complete == length(steps))
		complete = SEQUENCE_FINISHED

	else
		complete = SEQUENCE_IN_PROGRESS

	if(old_state != complete)
		SEND_SIGNAL(src, COMSIG_CONSTRUCTION_SEQUENCE_COMPLETION_CHANGED, user, old_state)

/datum/construction_step/sequence/remove_atom_from_parts(atom/movable/AM)
	for(var/datum/construction_step/step as anything in steps)
		if(step.remove_atom_from_parts(AM))
			return TRUE

/datum/construction_step/sequence/proc/child_sequence_completion_changed(datum/source, mob/user, old_state)
	SIGNAL_HANDLER

	update_completion(user)
