/// Generic wrench step
/datum/construction_step/use_tool/wrench
	name = "Wrench"
	decon_name = "Unwrench"
	tool_type = TOOL_WRENCH
	feedback_construct = "$USER$ wrenches something to $OBJECT$."
	feedback_deconstruct = "$USER$ unwrenches something from $OBJECT$."

/// Secure/unsecure nuts
/datum/construction_step/use_tool/wrench/secure_nuts
	name = "Secure Nuts"
	decon_name = "Unsecure Nuts"
	feedback_construct = "$USER$ tightens the bolts on $OBJECT$."
	feedback_deconstruct = "$USER$ loosens the bolts on $OBJECT$."

