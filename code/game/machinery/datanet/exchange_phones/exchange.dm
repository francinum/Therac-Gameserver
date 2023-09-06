/* We need some special logic here
 * We are between two powernets, so we need to know which network a packet came in on
 * We can do this by telling our terminal to call a *different* receive_signal proc
 *
 * Like SMES units, the grid side is the terminal
 * We allow phones to connect only from the private side.
 *
 * https://file.house/9Jfm.png
 *
 */
/obj/machinery/telephone_exchange
	name = "telephone exchange"
	desc = "Used to allow phones to communicate across network boundaries."

	net_class = NETCLASS_TEL_EXCHANGE
	network_flags = NETWORK_FLAGS_STANDARD_CONNECTION

	/// Grid-side network terminal. Use this to discover other offices to exchange with.
	var/obj/machinery/power/terminal/datanet/grid_term
	//netjack

	/// Mapping of subscriber line to seized trunk
	var/list/sub_to_trunk
	/// Mapping of seized trunks to subscriber lines
	var/list/trunk_to_sub

	/// Mapping of line numbers to a subscriber info bundle, (netaddr, caller_id)
	/// "0001" = list("f03c41", "Medical Desk")
	var/list/subscribers



/obj/machinery/telephone_exchange/Initialize(mapload)
	. = ..()
	//Find the first existing data terminal and claim it
	dir_loop:
		for(var/d in GLOB.cardinals)
			var/turf/T = get_step(src, d)
			for(var/obj/machinery/power/terminal/datanet/term in T)
				if(term && term.dir == turn(d, 180))
					grid_term = term
					break dir_loop

// Subscriber side
/obj/machinery/telephone_exchange/receive_signal(datum/signal/signal)
	. = ..()
	if(.)
		return RECEIVE_SIGNAL_FINISHED
	var/list/sig_data = signal.data //Cakgmforsumniscpeeed
	switch(sig_data[PACKET_CMD])
		// Process ping replies to find unassigned stations
		if(NET_COMMAND_PING_REPLY)
			if(signal.data["netclass"] != "PNET_SIPSERVER")
				noop()


// Trunk Side
/obj/machinery/telephone_exchange/receive_signal_aux(datum/signal/signal)
	if(isnull(signal))
		return
	if(!grid_term)
		CRASH("Received aux signal with no grid term.")
	var/sigdat = signal.data //cache for sanic speed this joke is getting old.
	if(sigdat[PACKET_DESTINATION_ADDRESS] != src.net_id)//This packet doesn't belong to us directly
		var/datum/signal/ping_check = handle_ping(signal, FALSE) //Will automatically be flushed out the main interface.
		if(ping_check)
			grid_term.post_signal(ping_check)
		return RECEIVE_SIGNAL_FINISHED//regardless, return 1 so that machines don't process packets not intended for them.
	// Boilerplate over. Signal is verified and ours to deal with, and not a ping.

	var/list/sig_data = signal.data //Cakgmforsumniscpeeed
	switch(sig_data[PACKET_CMD])
		// 'Seize' a trunk, setting it up for communication
		if("trunk_seize")
			noop()
		// receive a message over an active trunk
		if("trunk_message")
			noop()
		// Release a trunk
		if("trunk_release")
			noop()


