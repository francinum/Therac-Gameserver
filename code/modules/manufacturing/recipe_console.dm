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
			recipes[++recipes.len] = list(
				"name" = R.name,
				"desc" = R.desc,
			)
	return data

/obj/machinery/computer/recipe/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RecipeConsole", name)
		ui.open()
