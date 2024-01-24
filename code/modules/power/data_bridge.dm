/// Address communicates on the 'Outside' interface,
#define DESTINATION_OUT "out"
/// Address communicates on the 'Inside' interface.
#define DESTINATION_IN "in"
/// Message is a control plane data unit.
#define DESTINATION_CONTROL "control"

/// Bridge itself is looped, both interfaces are on the same powernet.
#define SWITCHING_STATE_LOOPED -1
/// Bridge is not fully up
#define SWITCHING_STATE_INIT 0
/// Bridge is forwarding packets
#define SWITCHING_STATE_FORWARDING 1

/**
 *
 * These bridges impliment a slightly brain-damaged version of ("rapid") spanning tree protocol.
 *
 * This uses a concept of a "Bridge (Data) Protocol Unit", which communicates topology information to the various bridges in a larger network
 *
 * BPUs contain the following information
 *
 */
/obj/machinery/power/data_bridge
	name = "network bridge" //todo come up with some flavorful bullshit
	desc = "A device that sits between two data networks, relaying packets between them."
	// We are a direct media access device.
	network_flags = NETWORK_FLAG_GEN_ID | NETWORK_FLAG_POWERNET_DATANODE
	processing_flags = START_PROCESSING_MANUALLY

	//temp appearance
	icon_state = "smes"
	color = "#bbbbff"
	#warn Bodge a new icon for this.

	/// 'Outside' network access terminal, usually connected to the main distribution grid.
	var/obj/machinery/power/terminal/datanet/input_terminal

	/// What state are we in?
	var/switching_state = SWITCHING_STATE_INIT

	/// Antispam timer for the self-loop alarm.
	COOLDOWN_DECLARE(loop_alarm)

/obj/machinery/power/data_bridge/Initialize(mapload)
	. = ..()
	dir_loop:
		for(var/d in GLOB.cardinals)
			var/turf/T = get_step(src, d)
			for(var/obj/machinery/power/terminal/datanet/term in T)
				if(term && term.dir == turn(d, 180))
					input_terminal = term
					break dir_loop

	if(!input_terminal)
		atom_break()
		return
	input_terminal.master = src
	update_appearance()
	if(is_operational)
		begin_processing()

/obj/machinery/power/data_bridge/Destroy()
	if(SSticker.IsRoundInProgress()) //These are semi-major objects.
		var/turf/T = get_turf(src)
		message_admins("[src] deleted at [ADMIN_VERBOSEJMP(T)]")
		log_game("[src] deleted at [AREACOORD(T)]")
	disconnect_terminal()
	. = ..()

// -------------------
// Terminal management
// -------------------
// a lot of this is copied right out of SMES units. Not my fault.

/obj/machinery/power/data_bridge/attackby(obj/item/I, mob/user, params)
	//opening using screwdriver
	if(default_deconstruction_screwdriver(user, "[initial(icon_state)]-o", initial(icon_state), I))
		update_appearance()
		return

	//changing direction using wrench
	if(default_change_direction_wrench(user, I))
		input_terminal = null
		var/turf/T = get_step(src, dir)
		for(var/obj/machinery/power/terminal/datanet/term in T)
			if(term && term.dir == turn(dir, 180))
				input_terminal = term
				input_terminal.master = src
				to_chat(user, span_notice("Terminal found."))
				break
		if(!input_terminal)
			to_chat(user, span_alert("No power terminal found."))
			return
		set_machine_stat(machine_stat & ~BROKEN)
		update_appearance()
		return

	//building and linking a terminal
	if(istype(I, /obj/item/stack/cable_coil))
		var/dir = get_dir(user,src)
		if(dir & (dir-1))//we don't want diagonal click
			return

		if(input_terminal) //is there already a terminal ?
			to_chat(user, span_warning("This bridge already has a terminal!"))
			return

		if(!panel_open) //is the panel open ?
			to_chat(user, span_warning("You must open the maintenance panel first!"))
			return

		var/turf/T = get_turf(user)
		if (T.underfloor_accessibility < UNDERFLOOR_INTERACTABLE) //can we get to the underfloor?
			to_chat(user, span_warning("You must first remove the floor plating!"))
			return


		var/obj/item/stack/cable_coil/C = I
		if(C.get_amount() < 10)
			to_chat(user, span_warning("You need more wires!"))
			return

		to_chat(user, span_notice("You start building the power terminal..."))
		playsound(src.loc, 'sound/items/deconstruct.ogg', 50, TRUE)

		if(do_after(user, src, 20))
			if(C.get_amount() < 10 || !C)
				return
			var/obj/structure/cable/N = T.get_cable_node() //get the connecting node cable, if there's one
			if (prob(50) && electrocute_mob(usr, N, N, 1, TRUE)) //animate the electrocution if uncautious and unlucky
				do_sparks(5, TRUE, src)
				return
			if(!input_terminal)
				C.use(10)
				user.visible_message(span_notice("[user.name] builds a terminal."),\
					span_notice("You build the terminal."))

				//build the terminal and link it to the network
				make_terminal(T)
				input_terminal.connect_to_network()
				connect_to_network()
		return

	//crowbarring it !
	var/turf/T = get_turf(src)
	if(default_deconstruction_crowbar(I))
		message_admins("[src] has been deconstructed by [ADMIN_LOOKUPFLW(user)] in [ADMIN_VERBOSEJMP(T)]")
		log_game("[src] has been deconstructed by [key_name(user)] at [AREACOORD(src)]")
		return
	else if(panel_open && I.tool_behaviour == TOOL_CROWBAR)
		return

	return ..()

/obj/machinery/power/data_bridge/wirecutter_act(mob/living/user, obj/item/I)
	//disassembling the terminal
	. = ..()
	if(input_terminal && panel_open)
		input_terminal.dismantle(user, I)
		return TRUE

/obj/machinery/power/data_bridge/proc/make_terminal(turf/T)
	input_terminal = new/obj/machinery/power/terminal/datanet(T)
	input_terminal.setDir(get_dir(T,src))
	input_terminal.master = src
	set_machine_stat(machine_stat & ~BROKEN)

/obj/machinery/power/data_bridge/disconnect_terminal()
	if(input_terminal)
		input_terminal.master = null
		input_terminal = null
		atom_break()

/obj/machinery/power/data_bridge/default_deconstruction_crowbar(obj/item/crowbar/C)
	if(istype(C) && input_terminal)
		to_chat(usr, span_warning("You must first remove the terminal!"))
		return FALSE

	return ..()

/obj/machinery/power/data_bridge/on_set_is_operational(old_value)
	if(old_value)
		end_processing()
		// Reset the hello time to
		COOLDOWN_START(src, hello_time, 2 SECONDS + rand(1 SECOND, 2 SECONDS))
	else
		begin_processing()

// -------------------

// We need to process so we can reconcile network state.
/obj/machinery/power/data_bridge/process()
	if(!input_terminal)
		stack_trace("Network Bridge Somehow processing without a terminal? Not okay.")
		atom_break()
		return PROCESS_KILL
	if(!is_operational || !COOLDOWN_FINISHED(src,loop_alarm))
		return PROCESS_KILL
	// 'Continuity check', make sure we aren't dead shorting a network, if so we can just deadlock.
	if(powernet.number == input_terminal.powernet.number)
		//We're straight across a single powernet, Complain.
		if(COOLDOWN_FINISHED(src,loop_alarm))
			playsound(src, 'sound/machines/defib_saftyOff.ogg', 50, FALSE)
			COOLDOWN_START(src, loop_alarm, 10 SECONDS)
		change_switching_state(SWITCHING_STATE_LOOPED)
		return



/obj/machinery/power/data_bridge/examine(mob/user)
	. = ..()
	if(!input_terminal)
		. += span_warning("This unit is missing a terminal!")


/// Transition between switching states.
/obj/machinery/power/data_bridge/proc/change_switching_state(new_state)
	if(switching_state == new_state)
		return //Shut up.
	switch(new_state)
		if(SWITCHING_STATE_DISCARDING)
			// We're a redundant device, No need to learn anything. We need to keep responding
			// to bridge control messages, so we can't *fully* go to sleep.
			// If the main link fails we have to take over. But we also don't need to learn things right now.
			learning_addresses = FALSE
			dump_address_table()

		if(SWITCHING_STATE_INIT)
			// We've clearly lost the plot.
			noop()

		if(SWITCHING_STATE_LOOPED)
			// Routing loop between our own interfaces.
			noop()

		if(SWITCHING_STATE_FORWARDING)
			// Passing packets normally.
			noop()

	switching_state = new_state
	update_icon(UPDATE_OVERLAYS)

#warn Bodge a new icon for this.
/obj/machinery/power/data_bridge/update_overlays()
	. = ..()
	if(!is_operational || panel_open)
		return

	switch(switching_state)
		if(SWITCHING_STATE_DISCARDING)
			. += "smes-oc1" // Lower Blinking
		if(SWITCHING_STATE_LEARNING)
			. += "smes-0c0" // Both Blinking
		if(SWITCHING_STATE_LOOPED)
			. += "smes-op0" // Lower Red
		if(SWITCHING_STATE_FORWARDING)
			. += "smes-op1" // Upper Green

// -------------------
// The Meat

/obj/machinery/power/data_bridge/proc/record_address(incoming_address, origin)
	if(!learning_addresses)
		return // You serve zero purpose.
	var/record
	switch(origin)
		if(ORIGIN_POWERLINE)
			record = DESTINATION_IN
		if(ORIGIN_DATA_ENABLED_TERMINAL)
			record = DESTINATION_OUT
		else
			CRASH("Invalid origin provided to record_address, [origin]")
	address_table[incoming_address] = record

/obj/machinery/power/data_bridge/receive_signal(datum/signal/signal, origin)
	SHOULD_CALL_PARENT(FALSE) //We are a specialized level 2 device, not a client.
	if(!is_operational)
		return
	var/incoming_address = signal.data[PACKET_SOURCE_ADDRESS]
	var/outgoing_address = signal.data[PACKET_DESTINATION_ADDRESS]
	switch(origin)
		//'Inside' network
		if(ORIGIN_POWERLINE)
			if(!(switching_state == SWITCHING_STATE_FORWARDING))
				return
			var/datum/signal/cloned_signal = signal.Copy(src)
			cloned_signal.data[]

		//'Outside' network
		if(ORIGIN_DATA_ENABLED_TERMINAL)
			if(!(switching_state == SWITCHING_STATE_FORWARDING))
				return
			var/datum/signal/cloned_signal = signal.Copy(src)


		else //Weird Origin.
			CRASH("Packet with martian origin [origin] from author [signal.author.resolve() || "!NULL or qdeleted!"]")


/**
 * Handle Bridge Protocol Data Units.
 *
 */
/obj/machinery/power/data_bridge/proc/handle_control_plane(/datum/signal/signal, origin)

#undef DESTINATION_IN
#undef DESTINATION_OUT
