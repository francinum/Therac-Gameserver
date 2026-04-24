/datum/phone_segment
	/// Directly connected virtual segments
	var/list/datum/phone_segment/connected_segments
	/// Directly connected powernets, for connecting to phones.
	var/list/datum/powernet/connected_powernets

/// Query connected segments to determine hook state.
/// Any single device off-hook will take the entire wireline off-hook.
/datum/phone_segment/proc/test_hook(var/list/passed_segments)
	if(passed_segments && (src in passed_segments))
		return FALSE //Effectively on-hook, we've looped somewhere.
	LAZYADD(passed_segments, src)
	var/effective_state = FALSE //On-Hook
	if(length(connected_powernets))
		effective_state = test_hook_powernets()
	if(effective_state)
		return TRUE
	for(var/datum/phone_segment/next_segment in connected_segments)
		if(effective_state)
			return TRUE
		effective_state = next_segment.test_hook(passed_segments)
	return FALSE

/datum/phone_segment/proc/test_hook_powernets()
	. = FALSE
	for(var/datum/powernet/pnet in connected_powernets)
		for(var/obj/machinery/phone_equipment/device in pnet.phone_nodes)
			if(device.test_hook())
				return TRUE
