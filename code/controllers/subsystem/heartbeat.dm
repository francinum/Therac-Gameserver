SUBSYSTEM_DEF(heartbeat)
	name = "HABSORA"
	wait = 30 SECONDS

	var/datum/ss13lib/the_lib //The datum is general protected. it *SHOULD* be fine?


/datum/controller/subsystem/heartbeat/Initialize(start_timeofday)
	the_lib = SS13LIB
	return ..()

/datum/controller/subsystem/heartbeat/fire(resumed)
	the_lib.perform_heartbeat()
