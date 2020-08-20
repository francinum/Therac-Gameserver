/obj/item/toy/plush/nekoplushie
	name = "Shiro Neko plushie"
	desc = "combat neko deployed."
	icon = 'modular_nostration/icons/obj/plushes.dmi'
	icon_state = "Shiro"
	attack_verb = list("clawed")
	var/stuffed = TRUE //If the plushie has stuffing in it
	var/obj/item/grenade/grenade //You can remove the stuffing from a plushie and add a grenade to it for *nefarious uses*
	gender = FEMALE
	squeak_override = list('modular_citadel/sound/voice/nya.ogg' = 1)
	var/can_random_spawn = TRUE			//if this is FALSE, don't spawn this for random plushies.

/obj/item/toy/plush/vergashplushie
	name = "Vergash plushie"
	desc = "the wonders of a horned lizard with more than just horns."
	icon = 'modular_nostration/icons/obj/plushes.dmi'
	icon_state = "Vergash"
	attack_verb = list("sucked")
	gender = FEMALE
	squeak_override = list('modular_nostration/sound/interactions/moan_f1.ogg' = 1)

/obj/item/toy/plush/rpgsnek
	name = "RPGsnek plushie"
	desc = "a snake ,just a sake."
	icon = 'modular_nostration/icons/obj/plushes.dmi'
	icon_state = "RPGSnek"
	attack_verb = list("Licked")
	gender = MALE
	squeak_override = list('modular_nostration/sound/interactions/under_moan_f2.ogg' = 1)

/obj/item/toy/plush/mothplushie
	name = "insect plushie"
	desc = "An adorable stuffed toy that resembles some kind of insect."
	icon = 'modular_nostration/icons/obj/plushes.dmi'
	icon_state = "LampAddict"
	gender = MALE
	squeak_override = list('modular_citadel/sound/voice/scream_moth.ogg' = 1)
	var/can_random_spawn = TRUE

/obj/item/toy/plush/derpyslimeplushie
	name = "derpy slime plushie"
	desc = "Squish UwU"
	icon = 'modular_nostration/icons/obj/plushes64.dmi'
	icon_state = "DerpySlime"
	attack_verb = list("Squished")
	gender = FEMALE
	squeak_override = list('sound/vore/pred/squish_02.ogg' = 1)

/obj/item/toy/plush/kittyinacrystalbox	
	name = "kitty in a crystal box plushie"
	desc = "A cute toy that resembles an even cuter bee."
	icon = 'modular_nostration/icons/obj/plushes64.dmi'
	icon_state = "Kitty"
	attack_verb = list("stung")
	gender = FEMALE
	squeak_override = list('modular_citadel/sound/voice/weh.ogg' = 1)
