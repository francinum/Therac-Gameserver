/obj/item/stack/fastener
	name = "ERROR"
	desc = "ERROR"

	gender = NEUTER // "a pile of screws"

	icon_state = "sheet-metal"
	#warn needs sprite
	lefthand_file = 'icons/mob/inhands/misc/sheets_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/sheets_righthand.dmi'

	w_class = WEIGHT_CLASS_TINY
	force = 0

	stamina_cost = 5
	stamina_damage = 0
	stamina_critical_chance = 0

	throwforce = 1
	throw_range = 3
	throw_speed = 1

	max_amount = 10
	amount = 10

/obj/item/stack/fastener/Initialize(mapload, new_amount, merge, list/mat_override, mat_amt, absorption_capacity)
	. = ..()
	#warn temp
	var/list/split = splittext(name, " ")
	maptext = split[length(split)]

/obj/item/stack/fastener/bolts
	name = "pile of bolts"
	singular_name = "bolt"
	desc = "A pile of metal bolts."
	mats_per_unit = list(
		/datum/material/iron = MINERAL_MATERIAL_AMOUNT / 20
	)

/obj/item/stack/fastener/nuts
	name = "pile of nuts"
	singular_name = "nut"
	desc = "A pile of metal nuts."
	mats_per_unit = list(
		/datum/material/iron = MINERAL_MATERIAL_AMOUNT / 20
	)
