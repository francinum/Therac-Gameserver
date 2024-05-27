/obj/machinery/manufacturing/apply_item
	name = "pneumatic applicator"
	ui_name = "Pneumatic Applicator"

	var/item_input_dir = NORTH
	/// The item we're attacking with.
	var/obj/item/item_to_use

/obj/machinery/manufacturing/apply_item/set_state(new_state)
	. = ..()
	if(isnull(.))
		return

	if(item_to_use && operating_state != M_WORKING)
		var/obj/item/cache = item_to_use
		unregister_item_to_use()
		cache.forceMove(get_step(src, item_input_dir))

/obj/machinery/manufacturing/apply_item/attempt_create_assembly(obj/item/item)
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
		var/list/pretend_list = new /list(length(recipe.steps))
		pretend_list[1] = TRUE

		var/list/possible_steps = recipe.get_possible_next_steps(pretend_list)
		if(locate(/datum/slapcraft_step/item) in possible_steps)
			recipes += recipe

	var/datum/slapcraft_recipe/target_recipe
	switch(length(recipes))
		if(0)
			return
		else
			target_recipe = recipes[1]

	var/obj/item/slapcraft_assembly/assembly = new(proxy)
	assembly.set_recipe(target_recipe)

	var/datum/slapcraft_step/step_one = SLAPCRAFT_STEP(target_recipe.steps[1])
	if(!step_one.perform(null, item, assembly, instant = TRUE, silent = TRUE))
		assembly.disassemble(dump_loc_override = proxy)
		return

	return assembly

/obj/machinery/manufacturing/apply_item/process_item(obj/item/item)
	var/obj/item/slapcraft_assembly/assembly = item

	if(!grab_item_from_input())
		return

	// The item that will be used on the assembly
	var/obj/item/other_item = item_to_use
	if(!istype(assembly))
		assembly = attempt_create_assembly(item)
		// Try to invert the inputs
		if(!assembly)
			assembly = attempt_create_assembly(item_to_use)
			other_item = item

		if(!assembly)
			jam()
			return

	var/time_to_perform = null
	var/step_to_perform = locate(/datum/slapcraft_step/item) in assembly.get_possible_next_steps()

	if(isnull(step_to_perform))
		if(length(assembly.recipe.steps) < 2)
			assembly.disassemble(dump_loc_override = src)
		jam()
		return

	do_work(CALLBACK(src, PROC_REF(complete_step), assembly, SLAPCRAFT_STEP(step_to_perform), other_item), time_to_perform)

/obj/machinery/manufacturing/apply_item/proc/complete_step(obj/item/slapcraft_assembly/assembly, datum/slapcraft_step/step_to_perform, obj/item/other_item)
	step_to_perform.perform(null, other_item, assembly, TRUE, TRUE)
	eject_item(assembly)
	set_state(M_IDLE)
	run_queue()

/// Grab an item from the input turf, returns TRUE on sucess
/obj/machinery/manufacturing/apply_item/proc/grab_item_from_input()
	item_to_use = locate() in get_step(src, item_input_dir)
	if(!item_to_use)
		return FALSE

	item_to_use.forceMove(src)

	// Some items will aggressively not want to be moved, or will qdel on moving.
	if(item_to_use.loc != src)
		return FALSE

	RegisterSignal(item_to_use, list(COMSIG_PARENT_QDELETING, COMSIG_MOVABLE_MOVED), PROC_REF(item_to_use_del))
	return TRUE

/// Called by qdeletion OR movement
/obj/machinery/manufacturing/apply_item/proc/item_to_use_del(datum/source)
	SIGNAL_HANDLER

	if(item_to_use.loc != src)
		unregister_item_to_use()

/obj/machinery/manufacturing/apply_item/proc/unregister_item_to_use()
	UnregisterSignal(item_to_use, list(COMSIG_PARENT_QDELETING, COMSIG_MOVABLE_MOVED))
	item_to_use = null
