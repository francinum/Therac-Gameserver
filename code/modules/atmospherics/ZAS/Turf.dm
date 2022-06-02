/turf
	var/zone/zone
	var/open_directions

/turf
	var/needs_air_update = 0
	var/datum/gas_mixture/air
	var/heat_capacity = 1
	var/thermal_conductivity = 0.05
	var/list/initial_gas
	var/planetary_atmos //Let's just let this exist for now.
#ifdef ZASDBG
	///Set to TRUE during debugging to get chat output on the atmos status of this turf
	var/verbose = FALSE
#endif

/turf/proc/update_graphic(list/graphic_add = null, list/graphic_remove = null)
	if(graphic_add && graphic_add.len)
		vis_contents += graphic_add
	if(graphic_remove && graphic_remove.len)
		vis_contents -= graphic_remove

/turf/proc/update_air_properties()
	var/self_block
	ATMOS_CANPASS_TURF(self_block, src, src)
	if(self_block & AIR_BLOCKED)
		src.dbg(zasdbgovl_blocked)
		return TRUE

	#ifdef MULTIZAS
	for(var/d = 1, d < 64, d *= 2)
	#else
	for(var/d = 1, d < 16, d *= 2)
	#endif

		var/turf/target = get_step(src, d)

		if(!target)
			continue
		var/us_blocks_target
		ATMOS_CANPASS_TURF(us_blocks_target, src, target)

		if(us_blocks_target & AIR_BLOCKED)
			continue

		var/target_blocks_us
		ATMOS_CANPASS_TURF(target_blocks_us, target, src)
		if(target_blocks_us & AIR_BLOCKED)
			#ifdef ZASDBG
			target.dbg(ZAS_DIRECTIONAL_BLOCKER(turn(d, 180)))
			#endif
			continue

		if(target.simulated)
			if(TURF_HAS_VALID_ZONE(target))
				SSzas.connect(target, src)

// Helper for can_safely_remove_from_zone().
#define GET_ZONE_NEIGHBOURS(T, ret) \
	ret = 0; \
	if (T.zone) { \
		for (var/_gzn_dir in gzn_check) { \
			var/turf/other = get_step(T, _gzn_dir); \
			if (other.simulated && other.zone == T.zone) { \
				var/block; \
				ATMOS_CANPASS_TURF(block, other, T); \
				if (!(block & AIR_BLOCKED)) { \
					ret |= _gzn_dir; \
				} \
			} \
		} \
	}

/*
	Simple heuristic for determining if removing the turf from it's zone will not partition the zone (A very bad thing).
	Instead of analyzing the entire zone, we only check the nearest 3x3 turfs surrounding the src turf.
	This implementation may produce false negatives but it (hopefully) will not produce any false postiives.
*/

/turf/proc/can_safely_remove_from_zone()
	if(!zone)
		return 1

	var/check_dirs
	GET_ZONE_NEIGHBOURS(src, check_dirs)
	. = check_dirs
	for(var/dir in csrfz_check)
		//for each pair of "adjacent" cardinals (e.g. NORTH and WEST, but not NORTH and SOUTH)
		if((dir & check_dirs) == dir)
			//check that they are connected by the corner turf
			var/turf/T = get_step(src, dir)
			if (!T.simulated)
				. &= ~dir
				continue

			var/connected_dirs
			GET_ZONE_NEIGHBOURS(T, connected_dirs)
			if(connected_dirs && (dir & GLOB.reverse_dir[connected_dirs]) == dir)
				. &= ~dir //they are, so unflag the cardinals in question

	//it is safe to remove src from the zone if all cardinals are connected by corner turfs
	. = !.

/turf/open/update_air_properties()
	if(!simulated)
		return ..()

	if(zone && zone.invalid) //this turf's zone is in the process of being rebuilt
		c_copy_air() //not very efficient :(
		zone = null //Easier than iterating through the list at the zone.

	var/self_block
	ATMOS_CANPASS_TURF(self_block, src, src)
	if(self_block & AIR_BLOCKED)
		#ifdef ZASDBG
		if(verbose)
			zas_log("Self-blocked.")
		src.dbg(zasdbgovl_blocked)
		#endif
		if(zone)
			var/zone/z = zone

			if(can_safely_remove_from_zone()) //Helps normal airlocks avoid rebuilding zones all the time
				c_copy_air() //we aren't rebuilding, but hold onto the old air so it can be readded
				z.remove(src)
			else
				z.rebuild()

		return 1

	var/previously_open = open_directions
	open_directions = 0

	var/list/postponed

	#ifdef MULTIZAS
	for(var/d = 1, d < 64, d *= 2)
	#else
	for(var/d = 1, d < 16, d *= 2)
	#endif
		var/turf/target = get_step(src, d)

		if(!target) //edge of map
			continue

		///The air mobility of target >> src
		var/target_to_us
		ATMOS_CANPASS_TURF(target_to_us, src, target)
		if(target_to_us & AIR_BLOCKED)
			#ifdef ZASDBG
			if(verbose)
				zas_log("[dir2text(d)] is blocked.")
			src.dbg(ZAS_DIRECTIONAL_BLOCKER(d))
			#endif

			continue

		///The air mobility of src >> target
		var/us_to_target
		ATMOS_CANPASS_TURF(us_to_target, target, src)
		if(us_to_target & AIR_BLOCKED)
			#ifdef ZASDBG
			if(verbose)
				log_admin("[dir2text(d)] is blocked.")
			target.dbg(ZAS_DIRECTIONAL_BLOCKER(turn(d, 180)))
			#endif

			//Check that our zone hasn't been cut off recently.
			//This happens when windows move or are constructed. We need to rebuild.
			if((previously_open & d) && target.simulated)
				var/turf/sim_target = target
				if(zone && sim_target.zone == zone)
					zone.rebuild()
					return
			continue

		open_directions |= d

		if(target.simulated)
			var/turf/sim_target = target
			sim_target.open_directions |= GLOB.reverse_dir[d]

			if(TURF_HAS_VALID_ZONE(sim_target))
				//Might have assigned a zone, since this happens for each direction.
				if(!zone)
					//We do not merge if
					//    they are blocking us and we are not blocking them, or if
					//    we are blocking them and not blocking ourselves - this prevents tiny zones from forming on doorways.
					if(((target_to_us & ZONE_BLOCKED) && !(us_to_target & ZONE_BLOCKED)) || ((us_to_target & ZONE_BLOCKED) && !(self_block & ZONE_BLOCKED)))
						#ifdef ZASDBG
						if(verbose)
							zas_log("[dir2text(d)] is zone blocked.")
						dbg(ZAS_ZONE_BLOCKER(d))
						#endif

						//Postpone this tile rather than exit, since a connection can still be made.
						if(!postponed)
							postponed = list()
						postponed.Add(sim_target)

					else
						sim_target.zone.add(src)

						#ifdef ZASDBG
						dbg(zasdbgovl_assigned)
						if(verbose)
							zas_log("Added to [zone]")
						#endif

				else if(sim_target.zone != zone)
					#ifdef ZASDBG
					if(verbose)
						zas_log("Connecting to [sim_target.zone]")
					#endif

					SSzas.connect(src, sim_target)

			#ifdef ZASDBG
				else if(verbose)
					zas_log("[dir2text(d)] has same zone.")

			else if(verbose)
				zas_log("[dir2text(d)] has invalid or rebuilding zone.")
			#endif
		else
			//Postponing connections to tiles until a zone is assured.
			if(!postponed)
				postponed = list()
			postponed.Add(target)

	if(!TURF_HAS_VALID_ZONE(src)) //Still no zone, make a new one.
		var/zone/newzone = new/zone()
		newzone.add(src)

	#ifdef ZASDBG
		dbg(zasdbgovl_created)

	ASSERT(zone)
	#endif

	//At this point, a zone should have happened. If it hasn't, don't add more checks, fix the bug.

	for(var/turf/T in postponed)
		if(T.zone == src.zone)
			#ifdef ZASDBG
			zas_log("This turf tried to merge into itself! Current type: [src.type]")
			#endif
			CRASH("Turf in the postponed turflist shares a zone with src, aborting merge!") //Yes yes this is not a fix but atleast it keeps the warning
		SSzas.connect(src, T)

/turf/proc/post_update_air_properties()
	if(connections)
		connections.update_all()

/atom/movable/proc/block_superconductivity()
	return

/turf/return_air()
	RETURN_TYPE(/datum/gas_mixture)
	//Create gas mixture to hold data for passing
	if(zone)
		if(!zone.invalid)
			SSzas.mark_zone_update(zone)
			return zone.air
		else
			if(!air)
				make_air()
			c_copy_air()
			return air
	else
		if(!air)
			make_air()
		return air

/turf/remove_air(amount as num)
	var/datum/gas_mixture/GM = return_air()
	return GM.remove(amount)

/turf/assume_air(datum/gas_mixture/giver)
	if(!simulated)
		return
	var/datum/gas_mixture/my_air = return_air()
	my_air.merge(giver)

///Basically adjustGasWithTemp() but a turf proc.
/turf/proc/assume_gas(gasid, moles, temp = null)
	if(!simulated)
		return

	var/datum/gas_mixture/my_air = return_air()

	if(isnull(temp))
		my_air.adjustGas(gasid, moles)
	else
		my_air.adjustGasWithTemp(gasid, moles, temp)

	return 1

/turf/return_air()
	RETURN_TYPE(/datum/gas_mixture)
	if(!simulated)
		if(air)
			return air
		var/datum/gas_mixture/GM = new

		if(initial_gas)
			GM.gas = initial_gas.Copy()
		GM.temperature = temperature
		AIR_UPDATE_VALUES(GM)
		air = GM

	if(zone)
		if(!zone.invalid)
			SSzas.mark_zone_update(zone)
			return zone.air
		else
			if(!air)
				make_air()
			c_copy_air()
			return air
	else
		if(!air)
			make_air()
		return air

/turf/proc/make_air()
	air = new/datum/gas_mixture
	air.temperature = temperature
	if(initial_gas)
		air.gas = initial_gas.Copy()
	AIR_UPDATE_VALUES(air)

/turf/proc/c_copy_air()
	if(!air)
		air = new/datum/gas_mixture
	air.copyFrom(zone.air)
	air.group_multiplier = 1


/turf/proc/atmos_spawn_air(gas_id, amount, initial_temperature)
	if(!simulated)
		return
	var/datum/gas_mixture/new_gas = new
	var/datum/gas_mixture/existing_gas = return_air()
	if(isnull(initial_temperature))
		new_gas.adjustGas(gas_id, amount)
	else
		new_gas.adjustGasWithTemp(gas_id, amount, initial_temperature)
	existing_gas.merge(new_gas)

/turf/open/space/atmos_spawn_air()
	return

/proc/turf_contains_dense_objects(turf/T)
	return T.contains_dense_objects()

/turf/proc/contains_dense_objects()
	if(density)
		return 1
	for(var/atom/movable/A as anything in src)
		if(A.density && !(A.flags_1 & ON_BORDER_1))
			return 1
	return 0

///I literally don't know where this proc came from.
/turf/proc/TryGetNonDenseNeighbour()
	for(var/d in GLOB.cardinals)
		var/turf/T = get_step(src, d)
		if (T && !turf_contains_dense_objects(T))
			return T

/turf/proc/get_atmos_adjacent_turfs()
	var/list/adjacent_turfs = list()
	for(var/dir in GLOB.cardinals)
		if(open_directions & dir)
			adjacent_turfs += get_step(src, dir)
	return length(adjacent_turfs) ? adjacent_turfs : null

/turf/open/return_analyzable_air()
	return return_air()
