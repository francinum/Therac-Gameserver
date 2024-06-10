/datum/construction_template/test
	sequences = list(
		/datum/construction_step/sequence/test
	)
	qdel_on_deconstruct = FALSE

/datum/construction_step/sequence/test
	name = "TEST"
	steps = list(
		/datum/construction_step/insert_item/stack/bolts,
		/datum/construction_step/use_tool/wrench
	)

/datum/construction_template/test/constructed(mob/living/user)
	if(istype(parent, /obj/machinery/computer/template))
		return

	var/obj/machinery/computer/template/C = new /obj/machinery/computer/template(parent.drop_location())
	transfer_parent(C)
