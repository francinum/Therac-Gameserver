
/obj/machinery/manufacturing/abstract_step/welder
	name = "arc welder"
	ui_name = "Arc Welder"
	steps = list(/datum/slapcraft_step/tool/welder = 10 SECONDS)
	work_sound = list('sound/items/welder.ogg', 'sound/items/welder2.ogg')

/datum/construction_template/manufacturing_welder
	sequences = list(
		/datum/construction_step/sequence/insert_welder_pcb,
		/datum/construction_step/sequence/attach_vfd_display,
		/datum/construction_step/sequence/welder_assembly,
		/datum/construction_step/sequence/insert_electronics,
	)

/datum/construction_step/sequence/welder_assembly
	name = "Assemble Welding Arm"
	steps = list(
		/datum/construction_step/insert_item/servo,
		/datum/construction_step/use_tool/wrench,
		/datum/construction_step/insert_item/electrode,
		/datum/construction_step/use_tool/wrench,
	)

/datum/construction_step/sequence/insert_welder_pcb
	name = "Insert PCB"
	steps = list(
		/datum/construction_step/insert_item/welder_pcb,
		/datum/construction_step/use_tool/screwdriver,
	)

/datum/construction_step/sequence/attach_vfd_display
	name = "Attach display"
	steps = list(
		/datum/construction_step/insert_item/vfd_display,
		/datum/construction_step/use_tool/screwdriver,
	)

/datum/construction_step/insert_item/welder_pcb
	name = "Insert PCB (Welder)"
	accepted_types = list(/obj/item/pcb/welder)

/datum/construction_step/insert_item/vf_display
	name = "V.F Display"
	accepted_types = list(/obj/item/vf_display)

/datum/construction_step/insert_item/electrode
	name = "Tungsten Electrode"
	accepted_types = list(/obj/item/electrode)

/datum/construction_step/insert_item/servo
	name = "Pneumatic Servo"
	accepted_types = list(/obj/item/servo)
