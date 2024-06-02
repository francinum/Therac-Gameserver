/datum/construction_step
	var/name = ""
	var/decon_name = ""

	/// See parse_text
	var/feedback_construct = ""
	/// See parse_text
	var/feedback_deconstruct = ""

	/// If TRUE, will call default_state()
	var/has_default_state = FALSE

	/// Parent sequence datum.
	var/datum/construction_sequence/sequence

	/// A boolean value if this step has been performed or not.
	var/complete = FALSE

/datum/construction_step/New(datum/construction_sequence/parent)
	sequence = parent

/datum/construction_step/Destroy(force, ...)
	. = ..()
	if(!QDELETED(sequence))
		return QDEL_HINT_LETMELIVE

	return QDEL_HINT_IWILLGC

/// Initializes this step's default state, spawning any items or setting vars.
/datum/construction_step/proc/default_state()
	return

/// Returns TRUE if the action can be attempted with the given item.
/datum/construction_step/proc/can_do_action(mob/living/user, obj/item/I, deconstructing)
	SHOULD_CALL_PARENT(TRUE)

	// Non-reversible recipes cannot regress.
	if(deconstructing)
		return sequence.parent.reversible && complete
	return TRUE

/// Attempt to perform an action on this step. This can be construction or deconstruction.
/datum/construction_step/proc/attempt_action(mob/living/user, obj/item/I)
	return STEP_FAIL

/// Called during attempt_action to deconstruct this step. User is nullable.
/datum/construction_step/proc/deconstruct(mob/living/user, atom/drop_loc)
	complete = FALSE

/// Provides feedback to the user based on the completion status of the step.
/datum/construction_step/proc/provide_feedback(mob/living/user, obj/item/I)
	var/text = ""
	if(complete)
		if(feedback_construct)
			text = parse_text(feedback_construct, user, I)
		else
			return FALSE
	else
		if(feedback_deconstruct)
			text = parse_text(feedback_deconstruct, user, I)
		else
			return FALSE

	if(!text)
		return FALSE

	user.visible_message(text)
	return TRUE

/datum/construction_step/proc/parse_text(text, mob/living/user, obj/item/I)
	var/the_user = "[user]"
	var/the_item = "\the [I]"
	var/the_object = "\the [sequence.parent.parent]"

	text = replacetext(text, "$USER$", the_user)
	text = replacetext(text, "$ITEM$", the_item)
	text = replacetext(text, "$OBJECT$", the_object)

	return text
