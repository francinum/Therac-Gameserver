/*
 *
 * Pluggable Flow Control module bases for SSroundflow
 *
 */

/// Pluggable Flow Module for Evacuation, Think the Escape Shuttle.
/datum/round_flow_module/evacuation


///Pluggable Flow Module for latejoin,
/// You can specify a latejoin module in place of a Roundstart module, but not the other way around.
/datum/round_flow_module/join

/// Pluggable Flow Module for Roundstart Joining
/// Ex: Starting at jobstart waypoints. If the behaviour would make sense for latejoining players,
/// make it a [/datum/roundflow_module/latejoin]
/datum/round_flow_module/join/start
