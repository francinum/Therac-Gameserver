/datum/slapcraft_recipe
	abstract_type = /datum/slapcraft_recipe
	/// Name of the recipe. Will use the resulting atom's name if not specified
	var/name
	/// Description of the recipe. May be displayed as additional info in the handbook.
	var/desc
	/// Hint displayed to the user which examines the item required for the first step.
	var/examine_hint

	/// List of all steps to finish this recipe.
	var/list/steps

	/// A list of overrides for examine text. Indexed the same as steps. Null and null entries are A-okay.
	var/list/examine_overrides

	/// Type of the item that will be yielded as the result.
	var/result_type
	/// Amount of how many resulting types will be crafted.
	var/result_amount = 1
	/// Instead of result type you can use this as associative list of types to amounts for a more varied output
	var/list/result_list

	/// Weight class of the assemblies for this recipe.
	var/assembly_weight_class = WEIGHT_CLASS_NORMAL
	/// Suffix for the assembly name.
	var/assembly_name_suffix = "assembly"

	/// Category this recipe is in the handbook.
	var/category = SLAP_CAT_MISC
	/// Subcategory this recipe is in the handbook.
	var/subcategory = SLAP_SUBCAT_MISC

	/// Appearance in the radial menu for the user to choose from if there are recipe collisions.
	var/image/radial_appearance
	/// Order in which the steps should be performed.
	var/step_order = SLAP_ORDER_STEP_BY_STEP
	// Can this assembly be taken apart before it's finished?
	var/can_disassemble = TRUE

	/// Should we print text when we finish? Mostly used to de-bloat chat.
	var/show_finish_text = FALSE

/datum/slapcraft_recipe/New()
	. = ..()

	// Set the name from the resulting atom if the name is missing and resulting type is present.
	if(!name)
		var/atom/movable/result_cast
		if(result_list)
			for(var/path in result_list)
				// First association it can get, then break.
				result_cast = path
				break
		else if(result_type)
			result_cast = result_type
		if(result_cast)
			name = initial(result_cast.name)

/datum/slapcraft_recipe/proc/get_radial_image()
	if(!radial_appearance)
		radial_appearance = make_radial_image()
	return radial_appearance

/// Returns the next suitable step to be performed with the item by the user with such step_states
/datum/slapcraft_recipe/proc/next_suitable_step(mob/living/user, obj/item/item, list/step_states, check_type_only)
	var/datum/slapcraft_step/chosen_step
	for(var/step_type in steps)
		if(!check_correct_step(step_type, step_states))
			continue

		var/datum/slapcraft_step/iterated_step = SLAPCRAFT_STEP(step_type)
		if(!iterated_step.perform_check(user, item, null, check_type_only = check_type_only))
			continue

		chosen_step = iterated_step
		break

	return chosen_step

/// Check if a recipe is finished. If add_step is supplied, it checks if the recipe *would* be finished, given the additional step.
/datum/slapcraft_recipe/proc/is_finished(list/step_states, add_step)
	// Adds step checks if the recipe would be finished with the added step
	if(add_step)
		step_states = step_states.Copy()
		mark_step_complete(step_states, steps, add_step)

	switch(step_order)
		if(SLAP_ORDER_STEP_BY_STEP, SLAP_ORDER_FIRST_AND_LAST)
			//See if the last step was finished.
			if(step_states[length(step_states)])
				return TRUE

		if(SLAP_ORDER_FIRST_THEN_FREEFORM)
			var/any_missing = FALSE
			for(var/i in length(step_states) to 1 step -1)
				if(!i)
					any_missing = TRUE

			if(!any_missing)
				return TRUE

	return FALSE

/// Returns a list of steps that can be completed presently.
/datum/slapcraft_recipe/proc/get_possible_next_steps(list/step_states)
	RETURN_TYPE(/list)
	var/list/possible = list()

	// Optimize for a very simple operation.
	if(step_order == SLAP_ORDER_STEP_BY_STEP)
		for(var/i in 1 to length(step_states))
			if(step_states[i]) // Ignore completed steps
				continue

			var/datum/slapcraft_step/step_type = steps[i]
			possible += step_type

			// Get all optional steps up to and including the next non optional step.
			if(!initial(step_type.optional))
				break

		return possible

	for(var/step_type in steps)
		if(!check_correct_step(step_type, step_states))
			continue
		possible += step_type

	return possible

/// Checks if a step of type `step_type` can be performed with the given `step_states` state.
/datum/slapcraft_recipe/proc/check_correct_step(step_type, list/step_states)
	// Already finished this step.
	if(!find_uncompleted_step(step_states, steps, step_type))
		return FALSE

	// We are missing the first step being done, only allow it until we allow something else
	if(!step_states[1])
		if(step_type == steps[1])
			return TRUE
		else
			return FALSE

	switch(step_order)
		if(SLAP_ORDER_STEP_BY_STEP)
			// Just in case any step is optional we need to figure out which is the furthest step performed.
			var/furthest_step_index = 0
			for(var/state_index in length(step_states) to 1 step -1)
				if(step_states[state_index])
					furthest_step_index = state_index
					break

			for(var/state_index in 1 to length(step_states))
				// Step is done, continue
				if(step_states[state_index])
					continue

				// This step is before one we have already completed, continue
				// (essentially when skipping an optional step, we dont want to allow that step to be performed)
				if(state_index <= furthest_step_index)
					continue

				//We reach a step that isn't done. Check if the checked step is the one
				if(steps[state_index] == step_type)
					return TRUE

				// If the step is optional, perhaps the next one will be eligible.
				var/datum/slapcraft_step/iterated_step_datum = SLAPCRAFT_STEP(steps[state_index])
				if(iterated_step_datum.optional)
					continue

				// It wasn't it, return FALSE
				return FALSE

		if(SLAP_ORDER_FIRST_AND_LAST)
			var/last_step = steps[length(steps)]

			// If we are trying to do the last step, make sure all the rest ones are finished
			if(step_type == last_step)
				for(var/step_index in 1 to length(step_states))
					if(step_states[step_index])
						continue

					// If the step is optional, we don't mind.
					var/datum/slapcraft_step/iterated_step_datum = SLAPCRAFT_STEP(steps[step_index])
					if(iterated_step_datum.optional)
						continue

					return FALSE

			// Middle step, with the last step not being finished, and the first step being finished
			return TRUE

		if(SLAP_ORDER_FIRST_THEN_FREEFORM)
			// We have the first one and we are not repeating a step.
			return TRUE

	return FALSE

/datum/slapcraft_recipe/proc/make_radial_image()
	// If we make an explicit result type, use its icon and icon state in the radial menu to display it.
	var/atom/movable/result_cast = result_type
	if(result_list)
		for(var/path in result_list)
			// First association it can get, then break.
			result_cast = path
			break
	else if(result_type)
		result_cast = result_type
	if(result_cast)
		return image(icon = initial(result_cast.icon), icon_state = initial(result_cast.icon_state))
	//Fallback image idk what to put here.
	return image(icon = 'icons/hud/radial.dmi', icon_state = "radial_rotate")

/// User has finished the recipe in an assembly.
/datum/slapcraft_recipe/proc/finish_recipe(mob/living/user, obj/item/slapcraft_assembly/assembly)
	if(show_finish_text && user)
		to_chat(user, span_notice("You finish \the [name]."))

	assembly.being_finished = TRUE
	var/list/results = list()
	create_products(assembly, results)

	// Move items which wanted to go to the resulted item into it. Only supports for the first created item.
	var/atom/movable/first_item = results[1]

	for(var/obj/item/item as anything in assembly.items_to_place_in_result)
		item.forceMove(first_item)

	for(var/atom/movable/product as anything in (results - assembly.items_to_place_in_result))
		assembly.finished_items += product

	after_create_products(results, assembly)
	dispose_assembly(assembly)

	//Finally, CheckParts on the resulting items.
	for(var/atom/movable/result_item as anything in results)
		result_item.CheckParts()

/// Runs when the last step tries to be performed and cancels the step if it returns FALSE. Could be used to validate location in structure construction via slap crafting.
/datum/slapcraft_recipe/proc/can_finish(mob/living/user, obj/item/slapcraft_assembly/assembly)
	return TRUE

/// The proc that creates the resulted item(s). Make sure to add them to the passed `results` list.
/datum/slapcraft_recipe/proc/create_products(obj/item/slapcraft_assembly/assembly, list/results)
	/// Check if we want to craft multiple items, if yes then populate the list passed by the argument with them.
	var/list/multi_to_craft
	if(result_list)
		multi_to_craft = result_list
	else if (result_amount)
		multi_to_craft = list()
		multi_to_craft[result_type] = result_amount

	if(multi_to_craft.len)
		for(var/path in multi_to_craft)
			var/amount = multi_to_craft[path]
			var/shift_pixels = (amount > 1)

			for(var/i in 1 to amount)
				var/atom/movable/new_thing = create_product(path, assembly)

				if(shift_pixels)
					new_thing.pixel_x += rand(-4,4)
					new_thing.pixel_y += rand(-4,4)
				results += new_thing

/// Creates and returns a new item. This gets called for every item that is supposed to be created in the recipe.
/datum/slapcraft_recipe/proc/create_product(product_path, obj/item/slapcraft_assembly/assembly)
	return new product_path()

/// Behaviour after the item is created, and before the slapcrafting assembly is disposed.
/// Here you can move the components into the item if you wish, or do other stuff with them.
/datum/slapcraft_recipe/proc/after_create_products(list/products_list, obj/item/slapcraft_assembly/assembly)
	return

/// Here is the proc to get rid of the assembly, should one want to override it to handle that differently.
/datum/slapcraft_recipe/proc/dispose_assembly(obj/item/slapcraft_assembly/assembly)
	qdel(assembly)

/// Type used for constructing machines
/datum/slapcraft_recipe/machine
	abstract_type = /datum/slapcraft_recipe/machine
