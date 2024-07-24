/datum/construction_step/insert_item/stack/iron_sheet
	name = "Attach sheet"
	decon_name = "Remove sheet"
	accepted_types = list(/obj/item/stack/sheet/iron)
	amount_to_use = 1
	feedback_construct = "$USER$ puts $ITEM$ onto $OBJECT$, for some reason."
	feedback_deconstruct = "$USER$ removes $ITEM$ from $OBJECT$."

/datum/construction_step/use_tool/wrench
	name = "Wrench"
	decon_name = "Unwrench"
	tool_type = TOOL_WRENCH
	feedback_construct = "$USER$ wrenches something to $OBJECT$."
	feedback_deconstruct = "$USER$ unwrenches something from $OBJECT$."

/datum/construction_template/basic/computer
	result_path = /obj/machinery/computer/template
	sequences = list(
		/datum/construction_step/sequence/finish_frame,
		/datum/construction_step/sequence/insert_electronics,
	)

/datum/construction_step/sequence/finish_frame
	name = "Finish Frame"
	steps = list(
		/datum/construction_step/sequence/weld_panels,
		/datum/construction_step/sequence/mount_bolts,
		/datum/construction_step/sequence/mount_nuts,
	)

/datum/construction_step/sequence/insert_electronics
	name = "Insert Electronics"
	steps = list(
		/datum/construction_step/insert_item/stack/wires,
		/datum/construction_step/use_tool/wirecutters/secure_wires,
	)

/datum/construction_step/sequence/weld_panels
	name = "Weld Panels"
	steps = list(
		/datum/construction_step/insert_item/stack/iron_sheet,
		/datum/construction_step/use_tool/welder/weld_panels,
	)

/datum/construction_step/sequence/mount_bolts
	name = "Mount Bolts"
	steps = list(
		/datum/construction_step/insert_item/stack/bolts,
		/datum/construction_step/use_tool/screwdriver/secure_bolts,
	)
	optional = TRUE

/datum/construction_step/sequence/mount_nuts
	name = "Mount Nuts"
	steps = list(
		/datum/construction_step/insert_item/stack/nuts,
		/datum/construction_step/use_tool/wrench/secure_nuts
	)
	optional = TRUE

/datum/construction_step/use_tool/welder/weld_panels
	name = "Weld Panels"
	decon_name = "Unweld Panels"
	feedback_construct = "$USER$ welds the panels to $OBJECT$."
	feedback_deconstruct = "$USER$ unwelds the panels from $OBJECT$."

	tool_type = TOOL_WELDER
	amount_to_use = 1

/datum/construction_step/insert_item/stack/bolts
	name = "Place Bolts"
	decon_name = "Remove Bolts"
	accepted_types = list(/obj/item/stack/fastener/bolts)
	amount_to_use = 1
	feedback_construct = "$USER$ sets $ITEM$ into $OBJECT$."
	feedback_deconstruct = "$USER$ removes $ITEM$ from $OBJECT$."

/datum/construction_step/use_tool/screwdriver/secure_bolts
	name = "Set Bolts"
	decon_name = "Unset Bolts"
	feedback_construct = "$USER$ screws in the bolts on $OBJECT$."
	feedback_deconstruct = "$USER$ unscrews the bolts on $OBJECT$."

/datum/construction_step/insert_item/stack/nuts
	name = "Place Nuts"
	decon_name = "Remove Nuts"
	accepted_types = list(/obj/item/stack/fastener/nuts)
	amount_to_use = 1
	feedback_construct = "$USER$ sets $ITEM$ into $OBJECT$."
	feedback_deconstruct = "$USER$ removes $ITEM$ from $OBJECT$."

/datum/construction_step/use_tool/wrench/secure_nuts
	name = "Secure Nuts"
	decon_name = "Unsecure Nuts"
	feedback_construct = "$USER$ tightens the bolts on $OBJECT$."
	feedback_deconstruct = "$USER$ loosens the bolts on $OBJECT$."

/datum/construction_step/insert_item/stack/wires
	name = "Insert Wires"
	decon_name = "Remove Wires"
	feedback_construct = "$USER$ places wires into $OBJECT$."
	feedback_deconstruct = "$USER$ removes wires from $OBJECT$."

	accepted_types = list(/obj/item/stack/cable_coil)
	amount_to_use = 1

/datum/construction_step/use_tool/wirecutters/secure_wires
	name = "Secure Wires"
	decon_name = "Cut Wires"
	feedback_construct = "$USER$ secures the wires inside of $OBJECT$."
	feedback_deconstruct = "$USER$ cuts the wires inside of $OBJECT$."

