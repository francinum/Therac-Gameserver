/// Generic screwdriver step
/datum/construction_step/use_tool/screwdriver
	tool_type = TOOL_SCREWDRIVER

/// Secure/unsecure bolts
/datum/construction_step/use_tool/screwdriver/secure_bolts
	name = "Set Bolts"
	decon_name = "Unset Bolts"
	feedback_construct = "$USER$ screws in the bolts on $OBJECT$."
	feedback_deconstruct = "$USER$ unscrews the bolts on $OBJECT$."
