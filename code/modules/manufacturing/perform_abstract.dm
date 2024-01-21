/// Machinery for performing steps without actually using a resource
/obj/machinery/manufacturing/perform_abstract_step
	/// A k:v list of step_path : time to complete. step_path becomes a typecache during init.
	var/list/steps

	/// The current item being worked on, incase this machine performs multiple steps.
	var/datum/weakref/working_on

	/// The typecache of steps to perform next.
	var/list/next_step

/obj/machinery/manufacturing/perform_abstract_step/Initialize(mapload)
	. = ..()
	var/idx
	for(var/path in steps)
		idx++
		var/old_value = steps[path]
		steps[idx] = typecacheof(path)
		steps[steps[idx]] = old_value

/obj/machinery/manufacturing/perform_abstract_step/play_work_sound()
	if(islist(work_sound))
		playsound(src, pick(work_sound))
	else
		playsound(src, work_sound)

/obj/machinery/manufacturing/perform_abstract_step/attempt_create_assembly(obj/item/item)
	var/list/available_recipes = slapcraft_recipes_for_type(item.type)
	if(!available_recipes)
		return

	var/list/recipes = list()
	for(var/datum/slapcraft_recipe/recipe in available_recipes)
		//Always start from step one.
		var/datum/slapcraft_step/step_one = SLAPCRAFT_STEP(recipe.steps[1])
		if(!step_one.perform_check(null, item, null))
			continue

		// Get next suitable step that is available after the first one would be performed.
		var/list/pretend_list = list()
		pretend_list[step_one.type] = TRUE

		var/list/next_recipe_steps = recipe.get_possible_next_steps(pretend_list)

		var/found_step_we_can_do = FALSE
		for(var/step in next_recipe_steps)
			if(next_step[step])
				found_step_we_can_do = TRUE
				break

		if(!found_step_we_can_do)
			continue
		recipes += recipe

	var/datum/slapcraft_recipe/target_recipe
	switch(length(recipes))
		if(0)
			return
		else
			target_recipe = recipes[1]

	var/obj/item/slapcraft_assembly/assembly = new(src)
	assembly.set_recipe(target_recipe)

	var/datum/slapcraft_step/step_one = SLAPCRAFT_STEP(target_recipe.steps[1])
	if(!step_one.perform(null, item, assembly, instant = TRUE, silent = TRUE))
		assembly.disassemble()
		return

	return assembly

/obj/machinery/manufacturing/perform_abstract_step/process_item(obj/item/item)
	var/obj/item/slapcraft_assembly/assembly = item

	next_step ||= steps[1]

	if(!istype(assembly))
		assembly = attempt_create_assembly(item)
		if(!assembly)
			jam()
			return


	var/list/possible_steps = assembly.get_possible_next_steps()

	var/time_to_perform = null
	var/step_to_perform = null

	for(var/step_type in possible_steps)
		if(next_step[step_type])
			time_to_perform = steps[next_step]
			step_to_perform = step_type
			break

	if(isnull(time_to_perform))
		next_step = null
		if(length(assembly.recipe.steps) < 2)
			assembly.disassemble(dump_loc_override = src)
		jam()
		return

	set_state(M_WORKING)

	play_work_sound()
	work_timer = addtimer(CALLBACK(src, PROC_REF(complete_step), assembly, step_to_perform), time_to_perform, TIMER_STOPPABLE|TIMER_DELETE_ME)

/obj/machinery/manufacturing/perform_abstract_step/proc/complete_step(obj/item/slapcraft_assembly/assembly, datum/slapcraft_step/step_to_perform)
	assembly.finished_step(null, SLAPCRAFT_STEP(step_to_perform))

	var/step_index = steps.Find(next_step)
	// If this is the last step, spit it out and be done with it
	if(step_index == length(steps))
		next_step = null
		eject_item(assembly)
		set_state(M_IDLE)
		run_queue()
		return

	// TOO SOON, EXECUTUS! YOU HAVE COMPLETED ME TOO SOON!
	if(assembly.being_finished)
		eject_item(assembly)
		jam()
		return

	next_step = steps[step_index + 1]
	working_on = WEAKREF(assembly)
	process_item(assembly)

/obj/machinery/manufacturing/perform_abstract_step/test
	out_direction = EAST
	steps = list(/datum/slapcraft_step/tool/welder = 10 SECONDS)
	work_sound = list('sound/items/welder.ogg', 'sound/items/welder2.ogg')

/obj/machinery/manufacturing/perform_abstract_step/stamp
	out_direction = EAST
	steps = list(/datum/slapcraft_step/attack/bludgeon = 2 SECONDS)
