/// Generic welder step
/datum/construction_step/use_tool/welder
	tool_type = TOOL_WELDER
	amount_to_use = 1

/// Weld Panels
/datum/construction_step/use_tool/welder/weld_panels
	name = "Weld Panels"
	decon_name = "Unweld Panels"
	feedback_construct = "$USER$ welds the panels to $OBJECT$."
	feedback_deconstruct = "$USER$ unwelds the panels from $OBJECT$."

	tool_type = TOOL_WELDER
	amount_to_use = 1
