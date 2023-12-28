SUBSYSTEM_DEF(nightshift)
	name = "Night Shift"
	wait = 10 MINUTES

	var/nightshift_active = FALSE
	var/nightshift_start_time = 19 HOURS + 30 MINUTES //7:30 PM, station time
	var/nightshift_end_time = 7 HOURS + 30 MINUTES //7:30 AM, station time
	var/nightshift_first_check = 30 SECONDS

	var/high_security_mode = FALSE
	var/list/currentrun

/datum/controller/subsystem/nightshift/Initialize()
	if(!CONFIG_GET(flag/enable_night_shifts))
		can_fire = FALSE
	return ..()

/datum/controller/subsystem/nightshift/fire(resumed = FALSE)
	if(resumed)
		update_nightshift(resumed = TRUE)
		return
	if(world.time - SSticker.round_start_time < nightshift_first_check)
		return
	check_nightshift()

/datum/controller/subsystem/nightshift/proc/announce(message)
	priority_announce(message, sub_title = "Automated Lighting System", do_not_modify = TRUE)

/datum/controller/subsystem/nightshift/proc/check_nightshift()
	var/emergency = SSsecurity_level.current_level >= SEC_LEVEL_BLUE
	var/announcing = TRUE
	var/time = station_time()
	var/night_time = (time < nightshift_end_time) || (time > nightshift_start_time)
	if(high_security_mode != emergency)
		high_security_mode = emergency
		if(night_time)
			announcing = FALSE
			if(!emergency)
				announce("Restoring night lighting configuration to normal operation.")
			else
				announce("Disabling night lighting: Station is in a state of emergency.")
	if(emergency)
		night_time = FALSE
	if(nightshift_active != night_time)
		update_nightshift(night_time, announcing)

/datum/controller/subsystem/nightshift/proc/update_nightshift(active, announce = TRUE, resumed = FALSE)
	set waitfor = FALSE
	if(!resumed)
		currentrun = INSTANCES_OF_COPY(/obj/machinery/power/apc)
		nightshift_active = active
		if(announce)
			if (active)
				announce("Good evening, crew. To reduce power consumption and stimulate the circadian rhythms of some species, all of the lights aboard the station have been dimmed for the night.")
			else
				announce("Good morning, crew. As it is now day time, all of the lights aboard the station have been restored to their former brightness.")
	for(var/obj/machinery/power/apc/APC as anything in currentrun)
		currentrun -= APC
		if (APC.area && (APC.area.type in GLOB.the_station_areas))
			APC.set_nightshift(active)
		CHECK_TICK
