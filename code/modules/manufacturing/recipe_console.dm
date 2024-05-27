/obj/machinery/computer/recipe
	name = "recipe console"
	desc = "Used to order supplies, approve requests, and control the shuttle."
	icon_screen = "supply"
	circuit = /obj/item/circuitboard/computer/cargo
	light_color = COLOR_BRIGHT_ORANGE

/obj/machinery/computer/recipe/ui_static_data(mob/user)
	var/list/data = list()
	data["recipe_index"] = list()

	for(var/category in GLOB.slapcraft_categorized_recipes)
		var/list/recipes = list()
		data["recipe_index"][category] = list(
			"name" = category,
			"recipes" = recipes
		)

		for(var/datum/slapcraft_recipe/R as anything in GLOB.slapcraft_categorized_recipes[category])
			if(!R.can_be_machined)
				continue

			recipes[++recipes.len] = list(
				"name" = R.name,
				"desc" = R.desc,
				"path" = R.type,
			)

	for(var/list/category as anything in data)
		if(!length(category))
			data -= category

	return data

/obj/machinery/computer/recipe/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RecipeConsole", name)
		ui.open()

/obj/machinery/computer/recipe/ui_act(action, list/params)
	. = ..()

	switch(action)
		if("load")
			var/datum/slapcraft_recipe/recipe = SLAPCRAFT_RECIPE(params["path"])
			if(!istype(recipe) || !recipe.can_be_machined)
				message_admins("Potential HREF abuse: [key_name_admin(usr)], invalid recipe typepath given to recipe console.")
				return TRUE

			if(inserted_disk)
				inserted_disk.set_data(DATA_IDX_DESIGNS, list(recipe))
				#warn playsound
			return TRUE
