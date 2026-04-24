/obj/machinery/phone_equipment/end_device_test
	name = "End Test Device"
	icon_state = "holopad0"

	var/off_hook = FALSE

/obj/machinery/phone_equipment/end_device_test/test_hook()
	return off_hook

/obj/machinery/phone_equipment/end_device_test/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	off_hook = !off_hook
	say("[off_hook ? "Off Hook" : "On Hook"]")
	return

/obj/machinery/phone_equipment/end_device_test/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()

