/*
 *
 * This subsystem holds and controls "Pluggable Round Flow Modules"
 * A concept I am shamelessly stealing from bay, for both my own usage
 * and the fact that DS13 might want to have more choice than just
 * the emergency shuttle.
 *
 */

SUBSYSTEM_DEF(roundflow)
	name = "Round Flow"
	// Default Init Order
	// Default Priority
	// Default Wait
	flags = SS_NO_FIRE


	/// Active RFM for Roundstart Joins
	var/datum/round_flow_module/join/roundstart_join
	/// Active RFM for Late Joins
	var/datum/round_flow_module/join/late_join
	/// Active RFM for Evacuation
	var/datum/round_flow_module/evacuation/evac

