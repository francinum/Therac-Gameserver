/datum/construction_sequence
	var/name = "NO NAME SEQUENCE"
	/// The construction datum this belongs to.
	var/datum/construction_template/parent
	/// A list of steps to complete, in order.
	var/list/steps = list()

	/// An array of values corresponding to the step indexes. Each index where an optional sequence is present is 1.
	var/list/optional_step_indexes
	/// An array of values corresponding to optional step completion. Optional steps are only complete here if they are
	/// actually complete, whereas check_completion() considers them complete no matter what due to being optional.
	/// Set by update_completion()
	var/list/optional_completion_cache

	/// Either SEQUENCE_IN_PROGRESS, SEQUENCE_FINISHED, or SEQUENCE_NOT_STARTED. Set by update_completion()
	var/complete = SEQUENCE_NOT_STARTED
	var/optional = FALSE

/datum/construction_sequence/New(datum/construction_template/new_parent)
	optional_step_indexes = new /list(length(steps))
	optional_completion_cache = new /list(length(steps))

	parent = new_parent

	var/list/step_instances = list()
	var/i = 0
	for(var/step in steps)
		i++
		if(ispath(step, /datum/construction_step))
			step = new step(src)
			step_instances += step
		else
			var/datum/construction_sequence/sequence = step
			sequence = new sequence(parent)
			step_instances += sequence
			RegisterSignal(sequence, COMSIG_CONSTRUCTION_SEQUENCE_COMPLETION_CHANGED, PROC_REF(child_sequence_completion_changed))
			if(sequence.optional)
				optional_step_indexes[i] = TRUE



	steps = step_instances

/datum/construction_sequence/Destroy(force, ...)
	SHOULD_CALL_PARENT(FALSE)
	if(!QDELETED(parent))
		return QDEL_HINT_LETMELIVE

	QDEL_LIST(steps)
	return QDEL_HINT_IWILLGC

/datum/construction_sequence/proc/default_state()
	for(var/step in steps)
		if(istype(step, /datum/construction_step))
			var/datum/construction_step/child_step = step
			if(child_step.has_default_state)
				child_step.default_state()
		else
			var/datum/construction_sequence/child_sequence = step
			child_sequence.default_state()

	update_completion()


/// Called by /datum/component/construction/proc/fully_deconstruct
/datum/construction_sequence/proc/fully_deconstruct(atom/drop_loc)
	if(check_completion() == SEQUENCE_NOT_STARTED)
		return

	for(var/step in steps)
		if(istype(step, /datum/construction_step))
			var/datum/construction_step/child_step = step
			if(!child_step.complete)
				continue

			child_step.deconstruct(drop_loc)

		else
			var/datum/construction_sequence/child_sequence = step
			child_sequence.fully_deconstruct()

	update_completion()

/// Returns the level of completion.
/datum/construction_sequence/proc/check_completion()
	return complete

/// Returns a list of steps that can be performed with the given arguments.
/datum/construction_sequence/proc/try_get_steps_for(mob/living/user, obj/item/I, deconstructing = FALSE)
	var/datum/construction_step/child_step
	var/datum/construction_sequence/child_sequence

	var/list/possible_steps = get_possible_steps(deconstructing)
	for(var/possible_step in possible_steps)
		if(istype(possible_step, /datum/construction_step))
			child_step = possible_step
			if(child_step.can_do_action(user, I, deconstructing))
				. += list("[deconstructing ? child_step.decon_name : child_step.name] ([name])" = child_step)

		else
			child_sequence = possible_step
			. += child_sequence.try_get_steps_for(arglist(args))

/datum/construction_sequence/proc/get_possible_steps(deconstructing) as /list
	PRIVATE_PROC(TRUE)

	. = list()
	var/datum/construction_step/child_step
	var/datum/construction_sequence/child_sequence
	var/_step

	if(!deconstructing)
		for(var/i in 1 to length(steps))
			_step = steps[i]
			child_sequence = null
			child_step = null
			if(istype(_step, /datum/construction_step))
				child_step = _step
			else
				child_sequence = _step

			if(child_step)
				if(!child_step.complete)
					. += child_step
					return .

			else
				if(child_sequence.check_completion() != SEQUENCE_FINISHED)
					if(!child_sequence.optional)
						. += child_sequence
						return .

					// The step is optional. So we are going to peek ahead to grab
					// every optional step up to and including the next non-optional one.
					for(var/j in i to length(steps))
						child_sequence = steps[j]
						if(!optional_step_indexes[j])
							if(istype(child_sequence))
								. += child_sequence.get_possible_steps(deconstructing)
							else
								. += child_sequence
							return .

						if(child_sequence.check_completion() != SEQUENCE_FINISHED)
							. += child_sequence.get_possible_steps(deconstructing)
		return .

	// Deconstruction
	for(var/i in length(steps) to 1 step -1)
		_step = steps[i]
		child_sequence = null
		child_step = null
		if(istype(_step, /datum/construction_step))
			child_step = _step
		else
			child_sequence = _step

		if(child_step)
			if(child_step.complete)
				. += child_step
				return .

		else
			if(child_sequence.check_completion() == SEQUENCE_FINISHED)
				if(!child_sequence.optional)
					. += child_sequence
					return .

				// The step is optional. So we are going to peek ahead to grab
				// every optional step up to and including the next non-optional one.
				for(var/j in i to 1 step -1)
					child_sequence = steps[j]
					if(!optional_step_indexes[j])
						if(istype(child_sequence))
							. += child_sequence.get_possible_steps(deconstructing)
						else
							. += child_sequence
						return .

					if(child_sequence.check_completion() == SEQUENCE_FINISHED)
						. += child_sequence.get_possible_steps(deconstructing)
		return .

/// Attempt an action in this sequence. Returns TRUE if one was performed.
/datum/construction_sequence/proc/attempt_step(datum/construction_step/step, mob/living/user, obj/item/I)
	if(step.attempt_action(user, I) != STEP_FAIL)
		update_completion(user)
		return TRUE

/datum/construction_sequence/proc/examine(mob/user, tree_depth_string = "") as /list
	. = list()
	var/datum/construction_step/child_step
	var/datum/construction_sequence/child_sequence

	if(complete == SEQUENCE_FINISHED)
		. += span_info("[tree_depth_string][name]")

	else if(optional)
		. += span_notice("[tree_depth_string][name]")
	else
		. += span_alert("[tree_depth_string][name]")

	if(tree_depth_string == "")
		tree_depth_string = "&rdsh; "

	tree_depth_string = "[FOURSPACES][tree_depth_string]"

	for(var/_step in steps)
		child_sequence = null
		child_step = null
		if(istype(_step, /datum/construction_step))
			child_step = _step
			if(child_step.complete)
				. += span_info("[tree_depth_string][child_step.name]")
			else
				. += span_alert("[tree_depth_string][child_step.name]")

		else
			child_sequence = _step
			. += child_sequence.examine(user, tree_depth_string)

/// Updates the completion status of this sequence.
/datum/construction_sequence/proc/update_completion(mob/living/user)
	var/old_state = complete
	var/num_complete = 0

	var/i = 0
	for(var/step in steps)
		i++
		if(istype(step, /datum/construction_step))
			var/datum/construction_step/child_step = step
			if(!child_step.complete)
				optional_completion_cache[i] = FALSE
				continue

			num_complete++
			optional_completion_cache[i] = TRUE

		else
			var/datum/construction_sequence/child_sequence = step
			var/child_completion = child_sequence.check_completion()
			if(child_sequence.optional || (child_completion == SEQUENCE_FINISHED))
				num_complete++
				if(child_completion == SEQUENCE_FINISHED)
					optional_completion_cache[i] = TRUE
				continue

			optional_completion_cache[i] = FALSE

	if(num_complete == 0)
		complete = SEQUENCE_NOT_STARTED

	else if(num_complete == length(steps))
		complete = SEQUENCE_FINISHED

	else
		complete = SEQUENCE_IN_PROGRESS

	if(old_state != complete)
		SEND_SIGNAL(src, COMSIG_CONSTRUCTION_SEQUENCE_COMPLETION_CHANGED, user, old_state)

/datum/construction_sequence/proc/child_sequence_completion_changed(datum/source, mob/user, old_state)
	SIGNAL_HANDLER

	update_completion(user)
