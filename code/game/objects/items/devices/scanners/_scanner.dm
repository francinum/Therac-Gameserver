/obj/item/scanner
	name = "Abstract Handheld Scanning Device"
	desc = "A handheld scanner. Call a priest?"
	icon_state = "analyzer"
	inhand_icon_state = "analyzer"
	icon = 'icons/obj/device.dmi'
	w_class = WEIGHT_CLASS_SMALL
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	item_flags = NOBLUDGEON
	actions_types = list(/datum/action/item_action/print_scanner_report)

	/// General 'Title' of the report. Health Scan - $targetname, etc.
	var/scan_title = ""
	/// Scan contents. Printed and displayed with the native CSS classes.
	var/scan_data = ""
	/// Dump the scan_data to the chat?
	var/output_results = FALSE
	/// Allow distant scans?
	var/allow_nonadjacent_scans = FALSE

	//Scan display window default size
	var/window_width = 450
	var/window_height = 600

	/// Optional scan delay.
	var/scan_delay
	/// Optional scan sound.
	var/scan_sound
	/// Color the paper so people can tell them apart easier
	var/printout_color = "" //This is fine to be null as set_atom_color returns by default, and this code is hardly super hot.


	COOLDOWN_DECLARE(report_print_cooldown)

/obj/item/scanner/proc/get_header()
	return "<a href='?src=\ref[src];print=1'>Print Report</a><a href='?src=\ref[src];clear=1'>Clear data</a>"

/obj/item/scanner/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	user.set_machine(src)
	var/datum/browser/popup = new(user, "Scanner", scan_title, window_width, window_height)
	popup.set_content("[get_header()]<hr>[scan_data]")
	popup.open()

/obj/item/scanner/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!(proximity_flag || allow_nonadjacent_scans))
		return //Not adjacent and distant scans illegal.
	if(!can_scan(target)) //Just don't have notices, that fixes the problem.
		return

	user.visible_message(
		span_notice("[user] runs [src] over [target]"),
		span_notice("You run [src] over [target]"),
		vision_distance = COMBAT_MESSAGE_RANGE
	)

	if(scan_sound)
		playsound(src, scan_sound, 30)

	//If we have a scan delay and fail a do_after...
	//(Used to not check scan_delay first resulting in a flashed progress bar for instant actions.)
	if(scan_delay && !do_after(user, src, scan_delay))
		to_chat(user, span_warning("You stop scanning [target] with [src]"))
		return

	scan(user, target)
	updateSelfDialog() //Update our dialog.
	// Give it a default name if they didn't set one.
	if(!scan_title)
		scan_title = "[capitalize(name)] scan - [target]"
	if(output_results) //Are we outputting results by default?
		scan_output(user)


/// Handles the actual scanning work.
/obj/item/scanner/proc/scan(mob/user, atom/target)
	CRASH("Scanner has unimplimented scan()")


/obj/item/scanner/proc/scan_output(mob/user)
	CRASH("Unimplimented scan_output()")

/obj/item/scanner/proc/can_scan(atom/target)
	return FALSE

/// Print out the paper copy of the report. Does not inherently clear memory!
/obj/item/scanner/proc/print_report(mob/user)
	if(!COOLDOWN_FINISHED(src, report_print_cooldown))
		to_chat(span_warning("[src]'s printer is still cooling off!"))
		return
	if(!scan_data)
		to_chat(user, span_notice("There is no scan data to print."))
		return
	var/obj/item/paper/P = new(drop_location())
	P.name = "paper - [scan_title]"
	P.info = scan_data
	P.add_atom_colour(printout_color, FIXED_COLOUR_PRIORITY)
	P.update_appearance()
	user.put_in_hands(P)
	user.visible_message("[src] prints out a piece of paper.")
	playsound(src, "sound/machines/dotprinter.ogg", 30, TRUE)
	// This can technically manufacture infinite atoms. It needs to be choked out. Consider an internal paper tray?
	COOLDOWN_START(src, report_print_cooldown, 10 SECONDS)

/obj/item/scanner/Topic(href, list/href_list)
	var/mob/living/user = usr
	. = ..()
	if(!((src in user.contents) || (isturf(loc) && in_range(src, user))))
		return FALSE
	if(href_list["print"])
		print_report(user)
		return TRUE
	if(href_list["clear"])
		to_chat(user, span_notice("You clear [src]'s data buffer."))
		scan_data = null
		scan_title = null
		updateSelfDialog() //Cleared the report, need to refresh the dialog.
		return TRUE

/obj/item/scanner/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] begins to analyze [user.p_them()]self with [src]! The display shows that [user.p_theyre()] dead!"))
	scan_title = "Suicide Confirmation Receipt - [user]"
	scan_data = {"
	This receipt confirms the intended self-termination of [user] effective [stationdate2text()] [gameTimestamp()].</br>
	Please dispose of the body via the nearest available trash receptacle.
	"}
	return BRUTELOSS

// evil action garbage

/datum/action/item_action/print_scanner_report
	name = "Print Scanner Report"

// If you need to add a second action... Why?
/obj/item/scanner/ui_action_click(mob/user, actiontype)
	print_report()
