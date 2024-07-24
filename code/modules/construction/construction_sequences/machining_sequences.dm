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

/datum/construction_step/sequence/mount_nuts
	name = "Mount Nuts"
	steps = list(
		/datum/construction_step/insert_item/stack/nuts,
		/datum/construction_step/use_tool/wrench/secure_nuts
	)
