/obj/machinery/computer/template
	name = "template console"
	desc = "Used to order supplies, approve requests, and control the shuttle."
	icon_screen = "supply"
	circuit = /obj/item/circuitboard/computer/cargo
	light_color = COLOR_BRIGHT_ORANGE
	has_disk_slot = TRUE

/obj/machinery/computer/template/ui_static_data(mob/user)
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

	for(var/category_name as anything in data["recipe_index"])
		if(!length(data["recipe_index"][category_name]["recipes"]))
			data["recipe_index"] -= category_name

	return data

/obj/machinery/computer/template/ui_data(mob/user)
	var/list/data = list()
	data["disk_loaded"] = !!inserted_disk
	return data

/obj/machinery/computer/template/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TemplateConsole", name)
		ui.open()

/obj/machinery/computer/template/ui_act(action, list/params)
	. = ..()

	switch(action)
		if("load")
			var/datum/slapcraft_recipe/recipe = SLAPCRAFT_RECIPE(params["path"])
			if(!istype(recipe) || !recipe.can_be_machined)
				message_admins("Potential href abuse: [key_name_admin(usr)], invalid recipe typepath given to template console.")
				return TRUE

			if(inserted_disk)
				inserted_disk.set_data(DATA_IDX_DESIGNS, list(recipe))
				#warn playsound
			return TRUE

// /obj/machinery/computer/template/insert_disk(mob/user, obj/item/disk/data/disk)
// 	. = ..()
// 	if(!.)
// 		return

// 	ui_interact(user)

// /obj/machinery/computer/template/eject_disk(mob/user)
// 	. = ..()
// 	if(!.)
// 		return

// 	ui_interact(user)
