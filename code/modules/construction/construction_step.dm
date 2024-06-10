/datum/construction_step
	var/name = ""
	var/decon_name = ""

	/// See parse_text
	var/feedback_construct = ""
	/// See parse_text
	var/feedback_deconstruct = ""

	/// If TRUE, will call default_state()
	var/has_default_state = FALSE

	/// If TRUE, this step can be deconstructed
	var/reversible = TRUE

	/// Parent sequence datum.
	var/datum/construction_step/sequence/parent_sequence
	/// The construction datum this belongs to.
	var/datum/construction_template/parent_template

	/// A boolean value if this step has been performed or not.
	var/complete = SEQUENCE_NOT_STARTED

/datum/construction_step/New(datum/construction_step/sequence/parent_sequence, datum/construction_template/parent_template)
	src.parent_sequence = parent_sequence
	src.parent_template = parent_template

/datum/construction_step/Destroy(force, ...)
	. = ..()
	if(!QDELETED(parent_template))
		return QDEL_HINT_LETMELIVE

	parent_sequence = null
	parent_template = null

	return QDEL_HINT_IWILLGC

/// Initializes this step's default state, spawning any items or setting vars.
/datum/construction_step/proc/default_state()
	return

/// Returns TRUE if the action can be attempted with the given item.
/datum/construction_step/proc/can_do_action(mob/living/user, obj/item/I, deconstructing)
	SHOULD_CALL_PARENT(TRUE)

	// Non-reversible recipes cannot regress.
	if(deconstructing)
		return parent_sequence.reversible && (complete != SEQUENCE_NOT_STARTED)
	return TRUE

/// Attempt to perform an action on this step. This can be construction or deconstruction.
/datum/construction_step/proc/attempt_action(mob/living/user, obj/item/I)
	return STEP_FAIL

/// Called during attempt_action to deconstruct this step. User is nullable.
/datum/construction_step/proc/deconstruct(mob/living/user, atom/drop_loc)
	SHOULD_CALL_PARENT(TRUE)
	complete = SEQUENCE_NOT_STARTED

/// Returns a k:v list of [step_name : step] that can be completed with the given parameters.
/datum/construction_step/proc/try_get_steps_for(mob/living/user, obj/item/I, deconstructing = FALSE) as /list
	if(can_do_action(user, I, deconstructing))
		. += list("[deconstructing ? decon_name : name] ([parent_sequence.name])" = src)

/// Provides feedback to the user based on the completion status of the step.
/datum/construction_step/proc/provide_feedback(mob/living/user, obj/item/I)
	var/text = ""
	if(complete == SEQUENCE_FINISHED)
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
	var/the_object = "\the [parent_template]"

	text = replacetext(text, "$USER$", the_user)
	text = replacetext(text, "$ITEM$", the_item)
	text = replacetext(text, "$OBJECT$", the_object)

	return text
