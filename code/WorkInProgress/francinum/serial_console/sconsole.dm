/*
 *
 * 'Serial' (More like telnet really) interactive terminal. Incredibly basic work here gentlemen.
 *
 */

/obj/machinery/computer/terminal
	name = "DT-100 Terminal"
	desc = "The venerable terminal, powering electronic interfaces since the 1950s."

	net_class = NETCLASS_TERMINAL
	network_flags = NETWORK_FLAGS_STANDARD_CONNECTION

	/// NetID of seized device
	var/connected_destination
	/// Open 'TGUI' Windows
	var/list/datum/tgui_window/tgui_windows

/obj/machinery/computer/terminal/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Terminal", title)
		ui.open()

/obj/machinery/computer/terminal/ui_static_data(mob/user)
	// This doesn't use a whole lot of the UI's systems, since it's designed for full fat machines
	// This thing barely exists, so we can just load a bunch of nonsense.
	. = ..()


// Boilerplate out of the way...

/obj/machinery/computer/terminal/proc/on_message(type, payload)
	switch(type)
		if ("command_sent")
			noop()
			// Handle incoming command
		if ("connect_jack")
			switch(link_to_jack())
				if(NETJACK_CONNECT_CONFLICT)
					noop()
			// Reconnect data terminal
		if ("flash_reset")
			noop()
			// Reset state entirely.

/obj/machinery/computer/terminal/receive_signal(datum/signal/signal)
	. = ..()

/// Returns the 80 character 'status line'
/obj/machinery/computer/terminal/proc/get_statline()
