/obj/item/mcobject/messaging/radio
	name = "radio component"
	icon_state = "comp_radiosig"
	base_icon_state = "comp_radiosig"

	var/datum/radio_frequency/frequency
	var/net_id
	var/filter = FALSE

/obj/item/mcobject/messaging/radio/Initialize(mapload)
	. = ..()
	MC_ADD_INPUT("send radio signal", send)
	MC_ADD_INPUT("set frequency", set_frequency)
	MC_ADD_CONFIG("Set Frequency", set_frequency_manual)
	MC_ADD_CONFIG("Toggle NetID Filtering", toggle_net_filtering)
	net_id = SSnetworks.get_next_HID()
	frequency = SSpackets.add_object(src, FREQ_SIGNALER)

/obj/item/mcobject/messaging/radio/proc/_set_frequency(new_frequency)
	new_frequency = sanitize_frequency(new_frequency, TRUE)
	if(new_frequency == frequency.frequency) //lol
		return

	SSpackets.remove_object(src, frequency.frequency)
	frequency = SSpackets.add_object(src, new_frequency)

/obj/item/mcobject/messaging/radio/proc/set_frequency(datum/mcmessage/input)
	var/value = text2num(input.cmd)
	if(!IS_NUM_SAFE(value))
		return
	_set_frequency(value)

/obj/item/mcobject/messaging/radio/proc/set_frequency_manual(mob/user, obj/item/tool)
	var/value = input(user, "Set Frequency ([MIN_FREE_FREQ] - [MAX_FREE_FREQ])", "Configure Component", frequency?.frequency) as null|num
	if(!isnum(value))
		return
	_set_frequency(value)

/obj/item/mcobject/messaging/radio/proc/toggle_net_filtering(mob/user, obj/item/tool)
	filter = !filter
	to_chat(user, span_notice("[src] will now [filter ? "ignore" : "no longer ignore"] signals that do not target it."))

/obj/item/mcobject/messaging/radio/proc/send(datum/mcmessage/input)
	var/list/data = params2list(input.cmd)
	var/datum/signal/signal = new(src, data)
	data["s_addr"] = net_id
	frequency.post_signal(signal, range = -1)

/obj/item/mcobject/messaging/radio/receive_signal(datum/signal/signal)
	. = ..()
	var/list/data = signal.data
	if(data["command"] == "ping")
		var/list/reply_data = list()
		var/datum/signal/reply = new(src, reply_data)
		reply_data["s_addr"] = net_id
		reply_data["d_addr"] = data["s_addr"]
		reply_data["command"] = "ping_reply"
		frequency.post_signal(reply, range = -1)
		return TRUE

	if(filter && (data["d_addr"] != net_id))
		return

	fire(list2params(signal.frequency + data))



