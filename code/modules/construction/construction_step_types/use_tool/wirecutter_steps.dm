/// Geneirc wirecutter step
/datum/construction_step/use_tool/wirecutters
	tool_type = TOOL_WIRECUTTER

/// Secure/Cut wires
/datum/construction_step/use_tool/wirecutters/secure_wires
	name = "Secure Wires"
	decon_name = "Cut Wires"
	feedback_construct = "$USER$ secures the wires inside of $OBJECT$."
	feedback_deconstruct = "$USER$ cuts the wires inside of $OBJECT$."

