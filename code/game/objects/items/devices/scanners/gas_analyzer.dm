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

	output_results = FALSE
	printout_color = "#d1d1ff"

	var/barometer_cooldown = FALSE
	var/barometer_cooldown_time = 250


/obj/item/scanner/gas/get_header()
	return ..() + "<a href='?src=\ref[src];barometer=1' [barometer_cooldown ? "class='linkOff' disabled" : null]>Read Barometer</a>"

/obj/item/scanner/gas/Topic(href, list/href_list)
	var/mob/living/user = usr
	. = ..()
	if(href_list["barometer"])
		scan_barometer(user) //fuck you lavaland fuck you lavaland fuck you-
		return TRUE

/obj/item/scanner/gas/scan(mob/user, atom/target)
	atmos_scan(user, target, src, TRUE) //I'd rip out the fucking message part but I don't want to break shit.


/obj/item/scanner/gas/can_scan(atom/target)
	if(target.return_analyzable_air())
		return TRUE

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
		updateSelfDialog()
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

		to_chat(user, span_notice("The next [ongoing_weather] will hit in [DisplayTimeText(ongoing_weather.next_hit_time - world.time)]."))
		scan_data = "Next weather event: [ongoing_weather] <br>\
			Estimated Time until Occurrence: [DisplayTimeText(ongoing_weather.next_hit_time - world.time)]"
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
			to_chat(user, span_warning("[src]'s barometer function says a storm will land in approximately [DisplayTimeText(fixed)]."))
			scan_data = "Next weather event: UNKNOWN <br>\
				Estimated Time until Occurrence: [DisplayTimeText(fixed)]"

	barometer_cooldown = TRUE
	addtimer(CALLBACK(src,/obj/item/scanner/gas/proc/ping), barometer_cooldown_time)
	updateSelfDialog()


/obj/item/scanner/gas/proc/ping()
	if(isliving(loc))
		var/mob/living/L = loc
		to_chat(L, span_notice("[src]'s barometer function is ready!"))
	playsound(src, 'sound/machines/click.ogg', 100)
	barometer_cooldown = FALSE
	updateSelfDialog() // If it's still open.

//This should not be here but it was in the old file, fuck you.
//The way this is laid out is ugly because the *logic* is suicidally coupled with *output*
//TODO: Make this not the case. For now, fuck you. It works. It's essentially how the old system did it. Eat shit.

/**
 * Outputs a message to the user describing the target's gasmixes.
 *
 * Gets called by analyzer_act, which in turn is called by tool_act.
 * Also used in other chat-based gas scans.
 */
/proc/atmos_scan(mob/user, atom/target, obj/item/scanner/gas/tool, silent=FALSE)
	var/mixture = target.return_analyzable_air()
	if(!mixture)
		return FALSE

	var/icon = target
	var/message = list()
	if(!silent && isliving(user))
		user.visible_message(span_notice("[user] uses the analyzer on [icon2html(icon, viewers(user))] [target]."), span_notice("You use the analyzer on [icon2html(icon, user)] [target]."))
	message += span_boldnotice("Results of analysis of [icon2html(icon, user)] [target].")

	var/list/gasmix_data = list()

	var/list/airs = islist(mixture) ? mixture : list(mixture)
	for(var/datum/gas_mixture/air as anything in airs)
		var/mix_name = capitalize(lowertext(target.name))
		if(airs.len > 1) //not a unary gas mixture
			var/mix_number = airs.Find(air)
			message += span_boldnotice("Node [mix_number]")
			mix_name += " - Node [mix_number]"
		gasmix_data += "<b>[mix_name]</b><ul>"

		var/total_moles = air.total_moles
		var/pressure = air.returnPressure()
		var/volume = air.get_volume() //could just do mixture.volume... but safety, I guess?
		var/temperature = air.temperature

		if(total_moles > 0)
			message += span_notice("Moles: [round(total_moles, 0.01)] mol")
			gasmix_data += "<li>Moles: [round(total_moles, 0.01)] mol</li>"

			var/list/cached_gases = air.gas
			for(var/id in cached_gases)
				var/gas_concentration = cached_gases[id]/total_moles
				var/amount = round(air.gas[id], 0.01)
				message += span_notice("[xgm_gas_data.name[id]]: [amount >= 0.01 ? "[amount] mol" : "Trace amounts." ] ([round(gas_concentration*100, 0.01)] %)")
				gasmix_data += "<li>[xgm_gas_data.name[id]]: [amount >= 0.01 ? "[amount] mol" : "Trace amounts." ] ([round(gas_concentration*100, 0.01)] %)</li>"
			message += span_notice("Temperature: [round(temperature - T0C,0.01)] &deg;C ([round(temperature, 0.01)] K)")
			gasmix_data += "<li>Temperature: [round(temperature - T0C,0.01)] &deg;C ([round(temperature, 0.01)] K)</li>"
			message += span_notice("Volume: [volume] L")
			gasmix_data += "<li>Volume: [volume] L</li>"
			message += span_notice("Pressure: [round(pressure, 0.01)] kPa")
			gasmix_data += "<li>Pressure: [round(pressure, 0.01)] kPa</li></ul>"
		else
			var/fallthrough_message = airs.len > 1 ? span_notice("This node is empty!") : span_notice("[target] is empty!")
			message += fallthrough_message
			gasmix_data += fallthrough_message+"</ul>"



	if(istype(tool))
		tool.scan_title = "Atmospheric Scan - [target]"
		tool.scan_data = gasmix_data.Join("<br>")

	// we let the join apply newlines so we do need handholding
	to_chat(user, jointext(message, "\n"), type = MESSAGE_TYPE_INFO)
	return TRUE
