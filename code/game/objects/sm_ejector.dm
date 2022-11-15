GLOBAL_VAR(sm_ejector)

/obj/sm_ejector
	anchored = TRUE
	var/list/registered_turfs

/obj/sm_ejector/Initialize()
	. = ..()
	GLOB.sm_ejector ||= src

/obj/sm_ejector/proc/trigger()
	set waitfor = FALSE

	var/list/registered_turfs = list()

	switch(dir)
		if(EAST)
			registered_turfs = block(locate(x, y-1, z), locate(x+2, y+1, z))
		if(NORTH)
			registered_turfs = block(locate(x-1, y, z), locate(x+1, y+2, z))
		if(WEST)
			registered_turfs = block(locate(x-2, y-1, z), locate(x, y+1, z))
		if(SOUTH)
			registered_turfs = block(locate(x-1, y-2, z), locate(x+1, y, z))

	src = null

	for(var/turf/T as anything in registered_turfs)

		var/obj/effect/abstract/turf_mimic = new(T)
		turf_mimic.appearance = T.appearance
		turf_mimic.layer = UNDER_FLOOR_ABOVE_SPACE_LAYER
		var/animatetime = 2 SECONDS * (rand(8, 12) / 10)
		animate(turf_mimic, time = animatetime, pixel_x =  turf_mimic.pixel_x + rand(-24, 24),  pixel_y = turf_mimic.pixel_y + rand(-24, 24))
		so_long_gay_bowser(turf_mimic, 2 SECONDS)
		turf_mimic = null
		T.ChangeTurf(/turf/open/space)

		for(var/atom/movable/AM as anything in T)
			if(istype(AM, /obj/effect/abstract) || \
				isobserver(AM) || \
				iscameramob(AM) || \
				istype(AM, /obj/effect/dummy/phased_mob)
			)
				CHECK_TICK
				continue

			if(AM.layer in DISPOSAL_PIPE_LAYER to GAS_PUMP_LAYER)
				qdel(AM)
				CHECK_TICK
				continue

			if(ismob(AM))
				AM:notransform = TRUE
			so_long_gay_bowser(AM, 2 SECONDS * (rand(8, 12) / 10))

		CHECK_TICK

/proc/so_long_gay_bowser(atom/target, _time = 2 SECONDS)
	set waitfor = FALSE

	animate(target, transform = matrix()*0.01, time = _time, flags = ANIMATION_PARALLEL)
	target.SpinAnimation(_time + rand(0.5, 2.5) SECONDS, 1, rand(50))
	sleep(_time SECONDS)
	qdel(target)
