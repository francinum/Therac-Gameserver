/obj/item/scanner/gas
	name = "gas analyzer"
	desc = "A hand-held environmental scanner which reports current gas levels."
	custom_price = PAYCHECK_ASSISTANT * 0.9
	icon_state = "analyzer"
	inhand_icon_state = "analyzer"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	flags_1 = CONDUCT_1
	item_flags = NOBLUDGEON
	slot_flags = ITEM_SLOT_BELT
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	tool_behaviour = TOOL_ANALYZER
	custom_materials = list(/datum/material/iron=30, /datum/material/glass=20)
	grind_results = list(/datum/reagent/mercury = 5, /datum/reagent/iron = 5, /datum/reagent/silicon = 5)

	var/barometer_cooldown = FALSE
	var/barometer_cooldown_time = 250


/obj/item/scanner/gas/get_header()
	return ..() + "<a href='?src=\ref[src];barometer=1' [barometer_cooldown ? "class='linkOff' disabled" : null]>Read Barometer</a>"

/obj/item/scanner/Topic(href, list/href_list)
	var/mob/living/user = usr
	. = ..()
	if(!.)//Parent does our checks.
		return
	if(href_list["barometer"])
		scan_barometer(user) //fuck you lavaland fuck you lavaland fuck you-

/obj/item/scanner/gas/scan()



/obj/item/scanner/gas/can_scan(atom/target)
	if(target.return_analyzable_air())
		return TRUE
	if()

/obj/item/scanner/gas/proc/scan_barometer(mob/user)
	if(!user.canUseTopic(src, BE_CLOSE))
		return

	if(barometer_cooldown)
		to_chat(user, span_warning("[src]'s barometer function is preparing itself."))
		return

	var/turf/T = get_turf(user)
	if(!T)
		return

	playsound(src, 'sound/effects/pop.ogg', 100)
	var/area/user_area = T.loc
	var/datum/weather/ongoing_weather = null

	scan_title = "Barometer Report - [gameTimestamp()]"
	if(!user_area.outdoors)
		to_chat(user, span_warning("[src]'s barometer function won't work indoors!"))
		scan_data = "ERROR, Invalid Environment: Enclosed space."
		return

	for(var/V in SSweather.processing)
		var/datum/weather/W = V
		if(W.barometer_predictable && (T.z in W.impacted_z_levels) && W.area_type == user_area.type && !(W.stage == END_STAGE))
			ongoing_weather = W
			break

	if(ongoing_weather)
		if((ongoing_weather.stage == MAIN_STAGE) || (ongoing_weather.stage == WIND_DOWN_STAGE))
			to_chat(user, span_warning("[src]'s barometer function can't trace anything while the storm is [ongoing_weather.stage == MAIN_STAGE ? "already here!" : "winding down."]"))
			scan_data = "ERROR, Unable to determine pressure floor, Storm already in progress?"
			return

		to_chat(user, span_notice("The next [ongoing_weather] will hit in [butchertime(ongoing_weather.next_hit_time - world.time)]."))
		scan_data = "Next weather event: [ongoing_weather] <br>\
			Estimated Time until Occurrence: [butchertime(ongoing_weather.next_hit_time - world.time)]"
		if(ongoing_weather.aesthetic)
			to_chat(user, span_warning("[src]'s barometer function says that the next storm will breeze on by."))
			scan_data += "<br>Scan does not indicate severe weather."
		else
			scan_data += "<br>Severe weather detected. Take appropriate precautions."
	else
		var/next_hit = SSweather.next_hit_by_zlevel["[T.z]"]
		var/fixed = next_hit ? timeleft(next_hit) : -1
		if(fixed < 0)
			to_chat(user, span_warning("[src]'s barometer function was unable to trace any weather patterns."))
			scan_data = "Next weather event: NONE <br>\
				Estimated Time until Occurrence: N/A."
		else
			to_chat(user, span_warning("[src]'s barometer function says a storm will land in approximately [butchertime(fixed)]."))
			scan_data = "Next weather event: UNKNOWN <br>\
				Estimated Time until Occurrence: [butchertime(fixed)]"

	cooldown = TRUE
	addtimer(CALLBACK(src,/obj/item/scanner/gas/proc/ping), barometer_cooldown_time)
	updateUsrDialog()


/obj/item/scanner/gas/proc/ping()
	if(isliving(loc))
		var/mob/living/L = loc
		to_chat(L, span_notice("[src]'s barometer function is ready!"))
	playsound(src, 'sound/machines/click.ogg', 100)
	barometer_cooldown = FALSE
	updateUsrDialog() // If it's still open.
