#define CABLE_VAR var/obj/structure/cable

/*
 *
 * Wires operate functionally as a set of quater-tile-vertex aligned nodes. Tests will thusly be named according to the node, and directionalities.
 *
 * [NW ] -(NW/N)- [ N ] -(N/NE)- [NE ]
 *   |   \          |          /   |
 * (NW/W) (NW/C)  (N/C)  (NE/C) (NE/E)
 *   |          \   |   /          |
 * [ W ] -( W/C)- [ C ] -( C/E)- [ E ]
 *   |          /   |   \          |
 * (SW/W) (SW/C)  (S/C)  (SE/C) (SE/E)
 *   |   /          |          \   |
 * [SW ] -(SW/S)- [ S ] -(S/SE)- [SE ]
 *
 * Thusly, per each node, we must care about 8 cables, and ensure all 8 share a powernet.
*/


/datum/unit_test/cables_must_connect_accurately/proc/prepare_cable(turf/T, cable_dirs, list/active_cables)
	// I'm splitting this because this is horrible boilerplate. Returns a ref of the cable.
	// Consider this a wrapper to allocate()
	var/obj/structure/cable/creating = allocate(/obj/structure/cable, T)
	var/datum/powernet/PN = new()
	PN.add_cable(creating)

	creating.set_directions(cable_dirs)
	return creating

/datum/unit_test/cables_must_connect_accurately/Run()
	// Collect references to the turfs we'll be paying attention to.
	var/turf/indexing_point = run_loc_floor_bottom_left
	var/turf/t_southwest = get_step(run_loc_floor_bottom_left, NORTHEAST)
	var/turf/t_center = get_step(t_southwest, NORTHEAST)

	var/turf/t_north = get_step(t_center, NORTH)
	var/turf/t_south = get_step(t_center, SOUTH)
	var/turf/t_east = get_step(t_center, EAST)
	var/turf/t_west = get_step(t_center, WEST)

	var/turf/t_northeast = get_step(t_center, NORTHEAST)
	var/turf/t_southeast = get_step(t_center, SOUTHEAST)
	var/turf/t_northwest = get_step(t_center, NORTHWEST)
	// var/turf/t_southwest - Already acquired.

	// Define a list of active cables, pass that to prepare_cables to store the new ones in it.
	var/list/obj/structure/cable/active_cables = list()

	// ----
	// CARDINALS SHALL CONNECT SANELY
	// ----

	// Connect between t_north and t_center via edge.
	// Create a node facing north from the center.
	CABLE_VAR/ = prepare_cable(t_center, CABLE_NORTH, active_cables)
	CABLE_VAR/ = prepare_cable(t_north, CABLE_SOUTH, active_cables)

	TEST_ASSERT(TARGET_CONNECTS_SOURCE, "C1: Node on North Tile Facing South, did not see Node on Center Tile Facing North")
	TEST_ASSERT(SOURCE_CONNECTS_TARGET, "C1: Node on North Tile Facing North, did not see Node on Center Tile Facing South")

	QDEL_LIST(active_cables)


#undef CABLE_VAR
