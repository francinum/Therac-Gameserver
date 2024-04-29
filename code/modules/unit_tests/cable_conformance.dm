/datum/unit_test/cables_must_connect_accurately/prepare_cable(turf/T, cable_dirs)
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

	// ----
	// CARDINALS SHALL CONNECT SANELY
	// ----

	// Connect between t_north and t_center via edge.
	// Create a node facing north from the center.
	var/obj/structure/cable/node_north_from_center = prepare_cable(t_center, (CABLE_NORTH))
	var/obj/structure/cable/node_south_from_north = prepare_cable(t_north, CABLE_SOUTH)

	TEST_ASSERT((node_south_from_north in node_north_from_center.get_cable_connections()), "C1: Node on North Tile Facing South, did not see Node on Center Tile Facing North")
	TEST_ASSERT((node_north_from_center in node_south_from_north.get_cable_connections()), "C1: Node on North Tile Facing South, did not see Node on Center Tile Facing North")
