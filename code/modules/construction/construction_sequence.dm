/datum/construction_sequence
	var/name = "NO NAME SEQUENCE"
	/// The construction datum this belongs to.
	var/datum/construction/parent
	/// A list of steps to complete, in order.
	var/list/steps = list()
	/// Current index
	var/step_index = 1

	/// Either SEQUENCE_IN_PROGRESS, SEQUENCE_FINISHED, or SEQUENCE_NOT_STARTED. Set by update_completion()
	var/complete = SEQUENCE_NOT_STARTED

/datum/construction_sequence/New(datum/construction/new_parent)
	parent = new_parent
	var/list/step_instances = list()
	for(var/datum/construction_step/step as anything in steps)
		step = new step(src)
		step_instances += step

	steps = step_instances

/datum/construction_sequence/Destroy(force, ...)
	SHOULD_CALL_PARENT(FALSE)
	if(!QDELETED(parent))
		return QDEL_HINT_LETMELIVE

	QDEL_LIST(steps)
	return QDEL_HINT_IWILLGC

/// Called by /datum/construction/proc/fully_deconstruct
/datum/construction_sequence/proc/fully_deconstruct(atom/drop_loc)
	if(check_completion() == SEQUENCE_NOT_STARTED)
		return

	for(var/datum/construction_step/step as anything in steps)
		if(!step.complete)
			continue

		step.deconstruct(drop_loc)

	update_completion()

/// Returns the level of completion.
/datum/construction_sequence/proc/check_completion()
	return complete

/// Returns a list of steps that can be performed.
/datum/construction_sequence/proc/get_available_steps(mob/living/user, obj/item/I, deconstructing = FALSE)
	var/datum/construction_step/step
	if(deconstructing)
		if(step_index == 1)
			return
		step = steps[step_index - 1]
		if(step.can_do_action(user, I))
			return list("[step.decon_name] ([name])" = step)

	else
		step = steps[step_index]
		if(step.can_do_action(user, I))
			return list("[step.name] ([name])" = step)

/// Attempt an action in this sequence. Returns TRUE if one was performed.
/datum/construction_sequence/proc/attempt_step(datum/construction_step/step, mob/living/user, obj/item/I)
	switch(step.attempt_action(user, I))
		if(STEP_FORWARD)
			. = TRUE
			step_index = min(step_index + 1, length(steps))

		if(STEP_BACKWARD)
			. = TRUE
			step_index = max(1, step_index - 1)
		else
			. = FALSE

	if(.)
		update_completion(user)

/// Updates the completion status of this sequence.
/datum/construction_sequence/proc/update_completion(mob/living/user)
	var/old_state = complete
	var/num_complete = 0
	for(var/datum/construction_step/step as anything in steps)
		if(step.complete)
			num_complete++

	if(num_complete == 0)
		complete = SEQUENCE_NOT_STARTED

	else if(num_complete == length(steps))
		complete = SEQUENCE_FINISHED

	else
		complete = SEQUENCE_IN_PROGRESS

	if(old_state != complete)
		parent.completion_changed(user)
