//these are items that don't fit in a category, and don't justify adding a new category.
//Try to avoid adding to this if you can so it's easier to find recipes.

/datum/slapcraft_recipe/mousetrap
	name = "Mouse Trap"
	examine_hint = "You could add a metal rod to make a mouse trap..."
	category = SLAP_CAT_MISC
	steps = list(
		/datum/slapcraft_step/item/stack/cardboard/one,
		/datum/slapcraft_step/item/stack/rod/one
	)
	result_type = /obj/item/assembly/mousetrap

//paper
/datum/slapcraft_recipe/papersack
	name = "Paper Sack"
	examine_hint = "With a cutting tool and more paper, you could make a bag..."
	category = SLAP_CAT_MISC
	steps = list(
		/datum/slapcraft_step/item/paper,
		/datum/slapcraft_step/attack/sharp,
		/datum/slapcraft_step/item/paper/second
	)
	result_type = /obj/item/storage/box/papersack

/datum/slapcraft_recipe/papercup
	name = "Paper Cup"
	examine_hint = "If you cut this and add a second sheet of paper, you could make a cup..."
	category = SLAP_CAT_MISC
	steps = list(
		/datum/slapcraft_step/item/paper,
		/datum/slapcraft_step/attack/sharp,
	)
	result_type = /obj/item/reagent_containers/food/drinks/sillycup

/datum/slapcraft_recipe/paperframe
	name = "Paper Frame"
	examine_hint = "With a plank of wood and some paper, you could make a paper frame for a wall or window..."
	category = SLAP_CAT_MISC
	steps = list(
		/datum/slapcraft_step/item/stack/wood/one,
		/datum/slapcraft_step/item/paper,
		/datum/slapcraft_step/item/paper,
		/datum/slapcraft_step/item/paper,
		/datum/slapcraft_step/item/paper,
		/datum/slapcraft_step/item/paper
	)
	result_type = /obj/item/stack/sheet/paperframes
