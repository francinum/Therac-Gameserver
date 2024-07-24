/datum/construction_template/computer
	sequences = list(
		/datum/construction_step/sequence/finish_frame,
		/datum/construction_step/sequence/insert_electronics,
	)

/datum/construction_template/computer/partially_deconstructed(mob/user)
	if(istype(parent, /obj/structure/frame))
		return

	parent.set_machine_stat(parent.machine_stat | NOT_FULLY_CONSTRUCTED)

/datum/construction_template/computer/constructed(mob/user)
	if(istype(parent, /obj/structure/frame))
		var/result_path = circuit_parent.build_path
		var/obj/machinery/result = new result_path(parent.loc, FALSE)
		transfer_to(result)
		return

	parent.set_machine_stat(parent.machine_stat & ~NOT_FULLY_CONSTRUCTED)
	parent.RefreshParts()
