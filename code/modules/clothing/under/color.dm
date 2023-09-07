/obj/item/clothing/under/color
	desc = "A standard issue colored jumpsuit. Variety is the spice of life!"
	dying_key = DYE_REGISTRY_UNDER
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION | CLOTHING_TESHARI_VARIATION | CLOTHING_VOX_VARIATION
	icon = 'icons/obj/clothing/under/color.dmi'
	icon_state = "jumpsuit"
	inhand_icon_state = "jumpsuit"
	worn_icon_state = "jumpsuit"
	worn_icon = 'icons/mob/clothing/under/color.dmi'
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/under/color/jumpskirt
	body_parts_covered = CHEST|GROIN|ARMS
	dying_key = DYE_REGISTRY_JUMPSKIRT
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	icon_state = "jumpskirt"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON | CLOTHING_TESHARI_VARIATION | CLOTHING_VOX_VARIATION

/obj/item/clothing/under/color/Initialize(mapload)
	. = ..()
	update_appearance(UPDATE_OVERLAYS)

/obj/item/clothing/under/color/worn_overlays(mob/living/carbon/human/wearer, mutable_appearance/standing, isinhands, icon_file)
	. = ..()
	var/image/I = image(icon_file, "[icon_state]_accessories")
	I.appearance_flags = RESET_COLOR
	. += I

/obj/item/clothing/under/color/update_overlays()
	. = ..()
	var/image/I = image(icon, "[icon_state]_accessories")
	I.appearance_flags = RESET_COLOR
	. += I

/// Returns a random, acceptable jumpsuit typepath
/proc/get_random_jumpsuit()
	return pick(
		subtypesof(/obj/item/clothing/under/color) \
			- typesof(/obj/item/clothing/under/color/jumpskirt) \
			- /obj/item/clothing/under/color/random \
			- /obj/item/clothing/under/color/grey/ancient \
			- /obj/item/clothing/under/color/black/ghost \
			- /obj/item/clothing/under/rank/prisoner \
	)

/obj/item/clothing/under/color/random
	icon_state = "random_jumpsuit"

/obj/item/clothing/under/color/random/Initialize(mapload)
	..()
	var/obj/item/clothing/under/color/C = get_random_jumpsuit()
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		H.equip_to_slot_or_del(new C(H), ITEM_SLOT_ICLOTHING, initial=TRUE) //or else you end up with naked assistants running around everywhere...
	else
		new C(loc)
	return INITIALIZE_HINT_QDEL

/// Returns a random, acceptable jumpskirt typepath
/proc/get_random_jumpskirt()
	return pick(
		subtypesof(/obj/item/clothing/under/color/jumpskirt) \
			- /obj/item/clothing/under/color/jumpskirt/random \
			- /obj/item/clothing/under/rank/prisoner/skirt \
	)

/obj/item/clothing/under/color/jumpskirt/random
	icon_state = "random_jumpsuit" //Skirt variant needed

/obj/item/clothing/under/color/jumpskirt/random/Initialize(mapload)
	..()
	var/obj/item/clothing/under/color/jumpskirt/C = get_random_jumpskirt()
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		H.equip_to_slot_or_del(new C(H), ITEM_SLOT_ICLOTHING, initial=TRUE)
	else
		new C(loc)
	return INITIALIZE_HINT_QDEL

/obj/item/clothing/under/color/black
	name = "black jumpsuit"
	resistance_flags = NONE

/obj/item/clothing/under/color/jumpskirt/black
	name = "black jumpskirt"

/obj/item/clothing/under/color/black/ghost
	item_flags = DROPDEL

/obj/item/clothing/under/color/black/ghost/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CULT_TRAIT)

/obj/item/clothing/under/color/grey
	name = "grey jumpsuit"
	desc = "A tasteful grey jumpsuit that reminds you of the good old days."
	color = "#b3b3b3"

/obj/item/clothing/under/color/jumpskirt/grey
	name = "grey jumpskirt"
	desc = "A tasteful grey jumpskirt that reminds you of the good old days."
	color = "#b3b3b3"

/obj/item/clothing/under/color/grey/ancient
	name = "ancient jumpsuit"
	desc = "A terribly ragged and frayed grey jumpsuit. It looks like it hasn't been washed in over a decade."
	icon_state = "grey_ancient"
	inhand_icon_state = "gy_suit"
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_worn = null
	can_adjust = FALSE

/obj/item/clothing/under/color/blue
	name = "blue jumpsuit"
	color = "#52aecc"

/obj/item/clothing/under/color/jumpskirt/blue
	name = "blue jumpskirt"
	color = "#52aecc"

/obj/item/clothing/under/color/green
	name = "green jumpsuit"
	color = "#9ed63a"

/obj/item/clothing/under/color/jumpskirt/green
	name = "green jumpskirt"
	color = "#9ed63a"

/obj/item/clothing/under/color/orange
	name = "orange jumpsuit"
	desc = "Don't wear this near paranoid security officers."
	color = "#ff8c19"

/obj/item/clothing/under/color/jumpskirt/orange
	name = "orange jumpskirt"
	color = "#ff8c19"

/obj/item/clothing/under/color/pink
	name = "pink jumpsuit"
	desc = "Just looking at this makes you feel <i>fabulous</i>."
	color = "#ffa69b"

/obj/item/clothing/under/color/jumpskirt/pink
	name = "pink jumpskirt"
	color = "#ffa69b"

/obj/item/clothing/under/color/red
	name = "red jumpsuit"
	color = "#eb0c07"

/obj/item/clothing/under/color/jumpskirt/red
	name = "red jumpskirt"
	color = "#eb0c07"

/obj/item/clothing/under/color/white
	name = "white jumpsuit"
	color = "#ffffff"

/obj/item/clothing/under/color/jumpskirt/white
	name = "white jumpskirt"
	color = "#ffffff"

/obj/item/clothing/under/color/yellow
	name = "yellow jumpsuit"
	color = "#ffe14d"

/obj/item/clothing/under/color/jumpskirt/yellow
	name = "yellow jumpskirt"
	color = "#ffe14d"

/obj/item/clothing/under/color/darkblue
	name = "dark blue jumpsuit"
	color = "#3285ba"

/obj/item/clothing/under/color/jumpskirt/darkblue
	name = "dark blue jumpskirt"
	color = "#3285ba"

/obj/item/clothing/under/color/teal
	name = "teal jumpsuit"
	color = "#77f3b7"

/obj/item/clothing/under/color/jumpskirt/teal
	name = "teal jumpskirt"
	color = "#77f3b7"

/obj/item/clothing/under/color/lightpurple
	name = "light purple jumpsuit"
	color = "#9f70cc"

/obj/item/clothing/under/color/jumpskirt/lightpurple
	name = "light purple jumpskirt"
	color = "#9f70cc"

/obj/item/clothing/under/color/darkgreen
	name = "dark green jumpsuit"
	color = "#6fbc22"

/obj/item/clothing/under/color/jumpskirt/darkgreen
	name = "dark green jumpskirt"
	color = "#6fbc22"

/obj/item/clothing/under/color/lightbrown
	name = "light brown jumpsuit"
	color = "#c59431"

/obj/item/clothing/under/color/jumpskirt/lightbrown
	name = "light brown jumpskirt"
	color = "#c59431"

/obj/item/clothing/under/color/brown
	name = "brown jumpsuit"
	color = "#a17229"

/obj/item/clothing/under/color/jumpskirt/brown
	name = "brown jumpskirt"
	color = "#a17229"

/obj/item/clothing/under/color/maroon
	name = "maroon jumpsuit"
	color = "#cc295f"

/obj/item/clothing/under/color/jumpskirt/maroon
	name = "maroon jumpskirt"
	color = "#cc295f"

/obj/item/clothing/under/color/rainbow
	name = "rainbow jumpsuit"
	desc = "A multi-colored jumpsuit!"
	icon_state = "rainbow"
	inhand_icon_state = "rainbow"
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_worn = null
	can_adjust = FALSE
	flags_1 = NONE

/obj/item/clothing/under/color/jumpskirt/rainbow
	name = "rainbow jumpskirt"
	desc = "A multi-colored jumpskirt!"
	icon_state = "rainbow_skirt"
	inhand_icon_state = "rainbow"
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_worn = null
	can_adjust = FALSE
	flags_1 = NONE
