/obj/machinery/phone_equipment
	network_flags = NETWORK_FLAG_POWERNET_PHONENODE
	var/datum/powernet/powernet = null

/obj/machinery/phone_equipment/Destroy()
	disconnect_from_network()
	return ..()

/obj/machinery/phone_equipment/proc/test_hook()
	return FALSE
