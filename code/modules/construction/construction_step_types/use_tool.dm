/datum/construction_step/use_tool
	name = "BAD STEP: USE TOOL"

	/// The tool type to complete this step.
	var/tool_type
	/// The amount of usage to subtract. Doesnt do anything if the tool doesn't have a resource.
	var/amount_to_use = 0
	/// The duration of the action.
	var/action_duration = 0 SECONDS

/datum/construction_step/use_tool/can_do_action(mob/living/user, obj/item/I, deconstructing)
	. = ..()
	if(!.)
		return

	if(isnull(I)) // attack_hand
		return FALSE

	if(I.tool_behaviour != tool_type)
		return FALSE

	if(!I.can_use(amt = amount_to_use))
		return FALSE

	return TRUE

/datum/construction_step/use_tool/attempt_action(mob/living/user, obj/item/I)
	if(!I.use_tool(parent_template.parent, user, action_duration))
		return STEP_FAIL

	complete = !complete
	provide_feedback(user, I)

	if(complete)
		return STEP_FORWARD
	else
		return STEP_BACKWARD

/datum/construction_step/use_tool/screwdriver
	tool_type = TOOL_SCREWDRIVER

/datum/construction_step/use_tool/wrench
	tool_type = TOOL_WRENCH

/datum/construction_step/use_tool/wirecutters
	tool_type = TOOL_WIRECUTTER

/datum/construction_step/use_tool/welder
	tool_type = TOOL_WELDER
	amount_to_use = 1
