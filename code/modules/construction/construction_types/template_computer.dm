/datum/construction/template_computer
	sequences = list(
		/datum/construction_sequence/test
	)

/datum/construction/template_computer/constructed(mob/living/user)
	if(istype(parent, /obj/machinery/computer/template))
		return

	var/obj/machinery/computer/template/C = new /obj/machinery/computer/template(parent.drop_location())
	C.construction = src
	transfer_parent(C)

/datum/construction_sequence/test
	steps = list(
		/datum/construction_step/insert_item/stack/iron_sheet,
		/datum/construction_step/use_tool/wrench
	)

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

/obj/item/wrench/test/Initialize(mapload)
	. = ..()
	construction = new /datum/construction/template_computer(src)
