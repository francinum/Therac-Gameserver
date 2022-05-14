#define RANDOM_GRAFFITI "Random Graffiti"
#define RANDOM_LETTER "Random Letter"
#define RANDOM_PUNCTUATION "Random Punctuation"
#define RANDOM_NUMBER "Random Number"
#define RANDOM_SYMBOL "Random Symbol"
#define RANDOM_DRAWING "Random Drawing"
#define RANDOM_ORIENTED "Random Oriented"
#define RANDOM_RUNE "Random Rune"
#define RANDOM_ANY "Random Anything"

#define PAINT_NORMAL	1
#define PAINT_LARGE_HORIZONTAL	2
#define PAINT_LARGE_HORIZONTAL_ICON	'icons/effects/96x32.dmi'

/*
 * Crayons
 */

/obj/item/toy/crayon
	name = "crayon"
	desc = "A colourful crayon. Looks tasty. Mmmm..."
	icon = 'icons/obj/crayons.dmi'
	icon_state = "crayonred"

	var/icon_capped
	var/icon_uncapped
	var/use_overlays = FALSE

	var/crayon_color = "red"
	w_class = WEIGHT_CLASS_TINY
	attack_verb = list("attacked", "coloured")
	grind_results = list()
	var/paint_color = "#FF0000" //RGB

	var/drawtype
	var/text_buffer = ""

	var/static/list/graffiti = list("amyjon","face","matt","revolution","engie","guy","end","dwarf","uboa","body","cyka","star","poseur tag","prolizard","antilizard", "tile")
	var/static/list/symbols = list("danger","firedanger","electricdanger","biohazard","radiation","safe","evac","space","med","trade","shop","food","peace","like","skull","nay","heart","credit")
	var/static/list/drawings = list("smallbrush","brush","largebrush","splatter","snake","stickman","carp","ghost","clown","taser","disk","fireaxe","toolbox","corgi","cat","toilet","blueprint","beepsky","scroll","bottle","shotgun")
	var/static/list/oriented = list("arrow","line","thinline","shortline","body","chevron","footprint","clawprint","pawprint") // These turn to face the same way as the drawer
	var/static/list/runes = list("rune1","rune2","rune3","rune4","rune5","rune6")
	var/static/list/randoms = list(RANDOM_ANY, RANDOM_RUNE, RANDOM_ORIENTED,
		RANDOM_NUMBER, RANDOM_GRAFFITI, RANDOM_LETTER, RANDOM_SYMBOL, RANDOM_PUNCTUATION, RANDOM_DRAWING)
	var/static/list/graffiti_large_h = list("yiffhell", "secborg", "paint")

	var/static/list/all_drawables = graffiti + symbols + drawings + oriented + runes + graffiti_large_h

	var/paint_mode = PAINT_NORMAL

	var/charges = 30 //-1 or less for unlimited uses
	var/charges_left
	var/volume_multiplier = 1 // Increases reagent effect

	var/actually_paints = TRUE

	var/instant = FALSE
	var/self_contained = TRUE // If it deletes itself when it is empty

	var/edible = TRUE // That doesn't mean eating it is a good idea

	var/list/reagent_contents = list(/datum/reagent/consumable/nutriment = 0.1)
	// If the user can toggle the colour, a la vanilla spraycan
	var/can_change_colour = FALSE

	var/has_cap = FALSE
	var/is_capped = FALSE

	var/pre_noise = FALSE
	var/post_noise = FALSE

	var/datum/team/gang/gang //For marking territory.
	var/gang_tag_delay = 30 //this is the delay for gang mode tag applications on anything that gang = true on.

	var/precision_mode = FALSE
	var/precision_x = 0
	var/precision_y = 0

/obj/item/toy/crayon/proc/isValidSurface(surface)
	return istype(surface, /turf/open/floor)

/obj/item/toy/crayon/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is jamming [src] up [user.p_their()] nose and into [user.p_their()] brain. It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return (BRUTELOSS|OXYLOSS)

/obj/item/toy/crayon/Initialize(mapload)
	. = ..()
	// Makes crayons identifiable in things like grinders
	if(name == "crayon")
		name = "[crayon_color] crayon"

	dye_color = crayon_color

	drawtype = pick(all_drawables)

	refill()

/obj/item/toy/crayon/examine(mob/user)
	. = ..()
	if(can_change_colour)
		. += "<span class='notice'>Ctrl-click [src] while it's on your person to quickly recolour it.</span>"

/obj/item/toy/crayon/proc/refill()
	if(charges == -1)
		charges_left = 100
	else
		charges_left = charges

	if(!reagents)
		create_reagents(charges_left * volume_multiplier, NONE, NO_REAGENTS_VALUE)
	reagents.clear_reagents()

	var/total_weight = 0
	for(var/key in reagent_contents)
		total_weight += reagent_contents[key]

	var/units_per_weight = reagents.maximum_volume / total_weight
	for(var/reagent in reagent_contents)
		var/weight = reagent_contents[reagent]
		var/amount = weight * units_per_weight
		reagents.add_reagent(reagent, amount)

/obj/item/toy/crayon/proc/use_charges(mob/user, amount = 1, requires_full = TRUE)
	// Returns number of charges actually used
	if(charges == -1)
		. = amount
		refill()
	else
		if(check_empty(user, amount, requires_full))
			return 0
		else
			. = min(charges_left, amount)
			charges_left -= .

/obj/item/toy/crayon/proc/check_empty(mob/user, amount = 1, requires_full = TRUE)
	// When eating a crayon, check_empty() can be called twice producing
	// two messages unless we check for being deleted first
	if(QDELETED(src))
		return TRUE

	. = FALSE
	// -1 is unlimited charges
	if(charges == -1)
		. = FALSE
	else if(!charges_left)
		to_chat(user, "<span class='warning'>There is no more of [src] left!</span>")
		if(self_contained)
			qdel(src)
		. = TRUE
	else if(charges_left < amount && requires_full)
		to_chat(user, "<span class='warning'>There is not enough of [src] left!</span>")
		. = TRUE

/obj/item/toy/crayon/ui_state(mob/user)
	return GLOB.hands_state

/obj/item/toy/crayon/ui_interact(mob/user, datum/tgui/ui)
	// tgui is a plague upon this codebase
	// no u
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Crayon", name)
		ui.open()

/obj/item/toy/crayon/spraycan/AltClick(mob/user)
	if(user.canUseTopic(src, BE_CLOSE, ismonkey(user)))
		if(has_cap)
			is_capped = !is_capped
			to_chat(user, "<span class='notice'>The cap on [src] is now [is_capped ? "on" : "off"].</span>")
			update_icon()

/obj/item/toy/crayon/CtrlClick(mob/user)
	if(can_change_colour && !isturf(loc) && user.canUseTopic(src, BE_CLOSE, ismonkey(user)))
		select_colour(user)
	else
		return ..()

/obj/item/toy/crayon/proc/staticDrawables()

	. = list()

	var/list/g_items = list()
	. += list(list("name" = "Graffiti", "items" = g_items))
	for(var/g in graffiti)
		g_items += list(list("item" = g))

	var/list/glh_items = list()
	. += list(list("name" = "Graffiti Large Horizontal", "items" = glh_items))
	for(var/glh in graffiti_large_h)
		glh_items += list(list("item" = glh))

	var/list/S_items = list()
	. += list(list("name" = "Symbols", "items" = S_items))
	for(var/S in symbols)
		S_items += list(list("item" = S))

	var/list/D_items = list()
	. += list(list("name" = "Drawings", "items" = D_items))
	for(var/D in drawings)
		D_items += list(list("item" = D))

	var/list/O_items = list()
	. += list(list(name = "Oriented", "items" = O_items))
	for(var/O in oriented)
		O_items += list(list("item" = O))

	var/list/R_items = list()
	. += list(list(name = "Runes", "items" = R_items))
	for(var/R in runes)
		R_items += list(list("item" = R))

	var/list/rand_items = list()
	. += list(list(name = "Random", "items" = rand_items))
	for(var/i in randoms)
		rand_items += list(list("item" = i))


/obj/item/toy/crayon/ui_data()

	var/static/list/crayon_drawables

	if (!crayon_drawables)
		crayon_drawables = staticDrawables()

	. = list()
	.["drawables"] = crayon_drawables
	.["selected_stencil"] = drawtype
	.["text_buffer"] = text_buffer

	.["has_cap"] = has_cap
	.["is_capped"] = is_capped
	.["can_change_colour"] = can_change_colour
	.["current_colour"] = paint_color

	.["precision_mode"] = precision_mode
	.["x"] = precision_x
	.["y"] = precision_y
	.["min_offset"] = -world.icon_size/2
	.["max_offset"] = world.icon_size/2

/obj/item/toy/crayon/ui_act(action, list/params)
	if(..())
		return
	switch(action)
		if("toggle_cap")
			if(has_cap)
				is_capped = !is_capped
				. = TRUE
		if("select_stencil")
			var/stencil = params["item"]
			if(stencil in all_drawables + randoms)
				drawtype = stencil
				. = TRUE
				text_buffer = ""
			if(stencil in graffiti_large_h)
				paint_mode = PAINT_LARGE_HORIZONTAL
				text_buffer = ""
			else
				paint_mode = PAINT_NORMAL
		if("select_colour")
			. = can_change_colour && select_colour(usr)
		if("enter_text")
			var/txt = stripped_input(usr,"Choose what to write.",
				"Scribbles",default = text_buffer)
			text_buffer = crayon_text_strip(txt)
			. = TRUE
			paint_mode = PAINT_NORMAL
			drawtype = "a"
		if("toggle_precision")
			precision_mode = !precision_mode
			. = TRUE
		if("set_precision_x")
			var/x = text2num(params["x"])
			precision_x = x
			. = TRUE
		if("set_precision_y")
			var/y = text2num(params["y"])
			precision_y = y
			. = TRUE
	update_icon()

/obj/item/toy/crayon/proc/select_colour(mob/user)
	var/chosen_colour = input(user, "", "Choose Color", paint_color) as color|null
	if (!isnull(chosen_colour) && user.canUseTopic(src, BE_CLOSE, ismonkey(user)))
		paint_color = chosen_colour
		return TRUE
	return FALSE

/obj/item/toy/crayon/proc/crayon_text_strip(text)
	var/static/regex/crayon_r = new /regex(@"[^\w!?,.=%#&+\/\-]")
	return replacetext(lowertext(text), crayon_r, "")

/obj/item/toy/crayon/afterattack(atom/target, mob/user, proximity, params)
	. = ..()
	if(!proximity || !check_allowed_items(target))
		return
	draw_on(target, user, proximity, params)

/obj/item/toy/crayon/proc/draw_on(atom/target, mob/user, proximity, params)
	var/static/list/punctuation = list("!","?",".",",","/","+","-","=","%","#","&")
	var/istagger = HAS_TRAIT(user, TRAIT_TAGGER)
	var/cost = 1
	if(paint_mode == PAINT_LARGE_HORIZONTAL)
		cost = 5
	if(istype(target, /obj/item/canvas))
		cost = 0
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if (HAS_TRAIT(H, TRAIT_TAGGER))
			cost *= 0.5
	var/charges_used = use_charges(user, cost)
	if(!charges_used)
		return
	. = charges_used

	if(istype(target, /obj/effect/decal/cleanable))
		target = target.loc

	if(!isValidSurface(target))
		return

	var/drawing = drawtype
	switch(drawtype)
		if(RANDOM_LETTER)
			drawing = ascii2text(rand(97, 122)) // a-z
		if(RANDOM_PUNCTUATION)
			drawing = pick(punctuation)
		if(RANDOM_SYMBOL)
			drawing = pick(symbols)
		if(RANDOM_DRAWING)
			drawing = pick(drawings)
		if(RANDOM_GRAFFITI)
			drawing = pick(graffiti)
		if(RANDOM_RUNE)
			drawing = pick(runes)
		if(RANDOM_ORIENTED)
			drawing = pick(oriented)
		if(RANDOM_NUMBER)
			drawing = ascii2text(rand(48, 57)) // 0-9
		if(RANDOM_ANY)
			drawing = pick(all_drawables)

	var/temp = "rune"
	var/ascii = (length(drawing) == 1) ? TRUE : FALSE
	if(ascii && is_alpha(drawing))
		temp = "letter"
	else if(ascii && is_digit(drawing))
		temp = "number"
	else if(drawing in punctuation)
		temp = "punctuation mark"
	else if(drawing in symbols)
		temp = "symbol"
	else if(drawing in drawings)
		temp = "drawing"
	else if(drawing in graffiti|oriented)
		temp = "graffiti"

	var/gang_mode
	if(user.mind)
		gang_mode = user.mind.has_antag_datum(/datum/antagonist/gang)

	if(gang_mode && (!can_claim_for_gang(user, target)))
		return


	var/graf_rot
	if(drawing in oriented)
		switch(user.dir)
			if(EAST)
				graf_rot = 90
			if(SOUTH)
				graf_rot = 180
			if(WEST)
				graf_rot = 270
			else
				graf_rot = 0

	var/list/click_params = params2list(params)
	var/clickx
	var/clicky

	if(click_params && click_params["icon-x"] && click_params["icon-y"])
		clickx = clamp(text2num(click_params["icon-x"]) - 16, -(world.icon_size/2), world.icon_size/2)
		clicky = clamp(text2num(click_params["icon-y"]) - 16, -(world.icon_size/2), world.icon_size/2)

	if(!instant)
		to_chat(user, "<span class='notice'>You start drawing a [temp] on the [target.name]...</span>")

	if(pre_noise)
		audible_message("<span class='notice'>You hear spraying.</span>")
		playsound(user.loc, 'sound/effects/spray.ogg', 5, 1, 5)

	var/wait_time = 50
	if(paint_mode == PAINT_LARGE_HORIZONTAL)
		wait_time *= 3

	if(gang_mode || !instant)
		if(!do_after(user, 50, target = target))
			return

	if(length(text_buffer))
		drawing = text_buffer[1]


	var/list/turf/affected_turfs = list()


	if(actually_paints)
		var/obj/effect/decal/cleanable/crayon/C = new(target, paint_color, drawing, temp, graf_rot)
		if(gang_mode)
			if(!can_claim_for_gang(user, target))
				return
			tag_for_gang(user, target, gang_mode)
			affected_turfs += target
		else
			switch(paint_mode)
				if(PAINT_NORMAL)
					C.add_hiddenprint(user)
					if(precision_mode)
						C.pixel_x = clamp(precision_x, -(world.icon_size/2), world.icon_size/2)
						C.pixel_y = clamp(precision_y, -(world.icon_size/2), world.icon_size/2)
					else
						C.pixel_x = clickx
						C.pixel_y = clicky
					affected_turfs += target
				if(PAINT_LARGE_HORIZONTAL)
					var/turf/left = locate(target.x-1,target.y,target.z)
					var/turf/right = locate(target.x+1,target.y,target.z)
					if(isValidSurface(left) && isValidSurface(right))
						C = new(left, paint_color, drawing, temp, graf_rot, PAINT_LARGE_HORIZONTAL_ICON)
						affected_turfs += left
						affected_turfs += right
						affected_turfs += target
					else
						to_chat(user, "<span class='warning'>There isn't enough space to paint!</span>")
						return
			C.add_hiddenprint(user)
			if(istagger)
				C.AddComponent(/datum/element/art, GOOD_ART)
			else
				C.AddComponent(/datum/element/art, BAD_ART)

	if(!instant)
		to_chat(user, "<span class='notice'>You finish drawing \the [temp].</span>")
	else
		to_chat(user, "<span class='notice'>You spray a [temp] on \the [target.name]</span>")

	if(length(text_buffer) > 1)
		text_buffer = copytext(text_buffer, length(text_buffer[1]) + 1)
		SStgui.update_uis(src)

	if(post_noise)
		audible_message("<span class='notice'>You hear spraying.</span>")
		playsound(user.loc, 'sound/effects/spray.ogg', 5, 1, 5)

	var/fraction = min(1, . / reagents.maximum_volume)
	if(affected_turfs.len)
		fraction /= affected_turfs.len
	for(var/t in affected_turfs)
		reagents.reaction(t, TOUCH, fraction * volume_multiplier)
		reagents.trans_to(t, ., volume_multiplier)
	check_empty(user)

/obj/item/toy/crayon/attack(mob/M, mob/user)
	if(edible && (M == user))
		to_chat(user, "You take a bite of the [src.name]. Delicious!")
		var/eaten = use_charges(user, 5, FALSE)
		if(check_empty(user)) //Prevents divsion by zero
			return
		var/fraction = min(eaten / reagents.total_volume, 1)
		reagents.reaction(M, INGEST, fraction * volume_multiplier)
		reagents.trans_to(M, eaten, volume_multiplier)
		// check_empty() is called during afterattack
	else
		..()

//////////////Gang mode stuff/////////////////
/obj/item/toy/crayon/proc/can_claim_for_gang(mob/user, atom/target)
	var/area/A = get_area(target)
	if(!A || (!is_station_level(A.z)))
		to_chat(user, "<span class='warning'>[A] is unsuitable for tagging.</span>")
		return FALSE

	var/spraying_over = FALSE
	for(var/obj/effect/decal/cleanable/crayon/gang/G in target)
		spraying_over = TRUE

	for(var/obj/machinery/power/apc in target)
		to_chat(user, "<span class='warning'>You can't tag an APC.</span>")
		return FALSE

	var/occupying_gang = territory_claimed(A, user)
	if(occupying_gang && !spraying_over)
		to_chat(user, "<span class='danger'>[A] has already been tagged by a gang! You must find and spray over the old tag first!</span>")
		return FALSE

	// stolen from oldgang lmao
	return TRUE

/obj/item/toy/crayon/proc/tag_for_gang(mob/user, atom/target, datum/antagonist/gang/user_gang)
	for(var/obj/effect/decal/cleanable/crayon/old_marking in target)
		qdel(old_marking)

	var/area/territory = get_area(target)

	var/obj/effect/decal/cleanable/crayon/gang/tag = new /obj/effect/decal/cleanable/crayon/gang(target)
	tag.my_gang = user_gang.my_gang
	tag.icon_state = "[user_gang.gang_id]_tag"
	tag.name = "[tag.my_gang.name] gang tag"
	tag.desc = "Looks like someone's claimed this area for [tag.my_gang.name]."
	to_chat(user, "<span class='notice'>You tagged [territory] for [tag.my_gang.name]!</span>")

/obj/item/toy/crayon/proc/territory_claimed(area/territory, mob/user)
	for(var/obj/effect/decal/cleanable/crayon/gang/G in GLOB.gang_tags)
		if(get_area(G) == territory)
			return G

/////////////////Gang end////////////////////

/obj/item/toy/crayon/red
	icon_state = "crayonred"
	paint_color = "#DA0000"
	crayon_color = "red"
	reagent_contents = list(/datum/reagent/consumable/nutriment = 0.1, /datum/reagent/colorful_reagent/crayonpowder/red = 0.9)
	dye_color = DYE_RED

/obj/item/toy/crayon/orange
	icon_state = "crayonorange"
	paint_color = "#FF9300"
	crayon_color = "orange"
	reagent_contents = list(/datum/reagent/consumable/nutriment = 0.1, /datum/reagent/colorful_reagent/crayonpowder/orange = 0.9)
	dye_color = DYE_ORANGE

/obj/item/toy/crayon/yellow
	icon_state = "crayonyellow"
	paint_color = "#FFF200"
	crayon_color = "yellow"
	reagent_contents = list(/datum/reagent/consumable/nutriment = 0.1, /datum/reagent/colorful_reagent/crayonpowder/yellow = 0.9)
	dye_color = DYE_YELLOW

/obj/item/toy/crayon/green
	icon_state = "crayongreen"
	paint_color = "#A8E61D"
	crayon_color = "green"
	reagent_contents = list(/datum/reagent/consumable/nutriment = 0.1, /datum/reagent/colorful_reagent/crayonpowder/green = 0.9)
	dye_color = DYE_GREEN

/obj/item/toy/crayon/blue
	icon_state = "crayonblue"
	paint_color = "#00B7EF"
	crayon_color = "blue"
	reagent_contents = list(/datum/reagent/consumable/nutriment = 0.1, /datum/reagent/colorful_reagent/crayonpowder/blue = 0.9)
	dye_color = DYE_BLUE

/obj/item/toy/crayon/purple
	icon_state = "crayonpurple"
	paint_color = "#DA00FF"
	crayon_color = "purple"
	reagent_contents = list(/datum/reagent/consumable/nutriment = 0.1, /datum/reagent/colorful_reagent/crayonpowder/purple = 0.9)
	dye_color = DYE_PURPLE

/obj/item/toy/crayon/black
	icon_state = "crayonblack"
	paint_color = "#1C1C1C" //Not completely black because total black looks bad. So Mostly Black.
	crayon_color = "black"
	reagent_contents = list(/datum/reagent/consumable/nutriment = 0.1, /datum/reagent/colorful_reagent/crayonpowder/black = 0.9)
	dye_color = DYE_BLACK

/obj/item/toy/crayon/white
	icon_state = "crayonwhite"
	paint_color = "#FFFFFF"
	crayon_color = "white"
	reagent_contents = list(/datum/reagent/consumable/nutriment = 0.1, /datum/reagent/colorful_reagent/crayonpowder/white = 0.9)
	dye_color = DYE_WHITE

/obj/item/toy/crayon/mime
	icon_state = "crayonmime"
	desc = "A very sad-looking crayon."
	paint_color = "#FFFFFF"
	crayon_color = "mime"
	reagent_contents = list(/datum/reagent/consumable/nutriment = 0.1, /datum/reagent/colorful_reagent/crayonpowder/invisible = 0.9)
	charges = -1
	dye_color = DYE_MIME

/obj/item/toy/crayon/rainbow
	icon_state = "crayonrainbow"
	paint_color = "#FFF000"
	crayon_color = "rainbow"
	reagent_contents = list(/datum/reagent/consumable/nutriment = 0.1, /datum/reagent/colorful_reagent = 0.9)
	drawtype = RANDOM_ANY // just the default starter.
	dye_color = DYE_RAINBOW
	charges = -1

/obj/item/toy/crayon/rainbow/draw_on(atom/target, mob/user, proximity, params)
	paint_color = rgb(rand(0,255), rand(0,255), rand(0,255))
	return ..()

/*
 * Crayon Box
 */

/obj/item/storage/crayons
	name = "box of crayons"
	desc = "A box of crayons for all your rune drawing needs."
	icon = 'icons/obj/crayons.dmi'
	icon_state = "crayonbox"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/storage/crayons/Initialize(mapload)
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 7
	STR.can_hold = typecacheof(list(/obj/item/toy/crayon))

/obj/item/storage/crayons/PopulateContents()
	new /obj/item/toy/crayon/red(src)
	new /obj/item/toy/crayon/orange(src)
	new /obj/item/toy/crayon/yellow(src)
	new /obj/item/toy/crayon/green(src)
	new /obj/item/toy/crayon/blue(src)
	new /obj/item/toy/crayon/purple(src)
	new /obj/item/toy/crayon/black(src)
	update_icon()

/obj/item/storage/crayons/update_overlays()
	. = ..()
	for(var/obj/item/toy/crayon/crayon in contents)
		add_overlay(mutable_appearance('icons/obj/crayons.dmi', crayon.crayon_color))

/obj/item/storage/crayons/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/toy/crayon))
		var/obj/item/toy/crayon/C = W
		switch(C.crayon_color)
			if("mime")
				to_chat(usr, "This crayon is too sad to be contained in this box.")
				return
			if("rainbow")
				to_chat(usr, "This crayon is too powerful to be contained in this box.")
				return
		if(istype(W, /obj/item/toy/crayon/spraycan))
			to_chat(user, "Spraycans are not crayons.")
			return
	return ..()

//Spraycan stuff

/obj/item/toy/crayon/spraycan
	name = "spray can"
	icon_state = "spraycan"

	icon_capped = "spraycan_cap"
	icon_uncapped = "spraycan"
	use_overlays = TRUE
	paint_color = null

	item_state = "spraycan"
	lefthand_file = 'icons/mob/inhands/equipment/hydroponics_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/hydroponics_righthand.dmi'
	desc = "A metallic container containing tasty paint."

	instant = TRUE
	edible = FALSE
	has_cap = TRUE
	is_capped = TRUE
	self_contained = FALSE // Don't disappear when they're empty
	can_change_colour = TRUE

	reagent_contents = list(/datum/reagent/fuel = 1, /datum/reagent/consumable/ethanol = 1)

	pre_noise = TRUE
	post_noise = FALSE

	var/stun_delay = 0 // how long it takes for you to be able to stun someone with the spraycan again
	var/last_stun_time = 0

/obj/item/toy/crayon/spraycan/isValidSurface(surface)
	return (istype(surface, /turf/open/floor) || istype(surface, /turf/closed/wall))

/obj/item/toy/crayon/spraycan/suicide_act(mob/user)
	var/mob/living/carbon/human/H = user
	if(is_capped || !actually_paints)
		user.visible_message("<span class='suicide'>[user] shakes up [src] with a rattle and lifts it to [user.p_their()] mouth, but nothing happens!</span>")
		user.say("MEDIOCRE!!", forced="spraycan suicide")
		return SHAME
	else
		user.visible_message("<span class='suicide'>[user] shakes up [src] with a rattle and lifts it to [user.p_their()] mouth, spraying paint across [user.p_their()] teeth!</span>")
		user.say("WITNESS ME!!", forced="spraycan suicide")
		if(pre_noise || post_noise)
			playsound(loc, 'sound/effects/spray.ogg', 5, 1, 5)
		if(can_change_colour)
			paint_color = "#C0C0C0"
		update_icon()
		if(actually_paints)
			H.lip_style = "spray_face"
			H.lip_color = paint_color
			H.update_body()
		var/used = use_charges(user, 10, FALSE)
		var/fraction = min(1, used / reagents.maximum_volume)
		reagents.reaction(user, VAPOR, fraction * volume_multiplier)
		reagents.trans_to(user, used, volume_multiplier)

		return (OXYLOSS)

/obj/item/toy/crayon/spraycan/Initialize(mapload)
	. = ..()
	// If default crayon red colour, pick a more fun spraycan colour
	if(!paint_color)
		paint_color = pick("#DA0000","#FF9300","#FFF200","#A8E61D","#00B7EF",
		"#DA00FF")
	refill()
	update_icon()


/obj/item/toy/crayon/spraycan/examine(mob/user)
	. = ..()
	if(charges_left)
		. += "It has [charges_left] use\s left."
	else
		. += "It is empty."
	. += "<span class='notice'>Alt-click [src] to [ is_capped ? "take the cap off" : "put the cap on"].</span>"

/obj/item/toy/crayon/spraycan/draw_on(atom/target, mob/user, proximity, params)
	if(!proximity)
		return

	if(is_capped)
		to_chat(user, "<span class='warning'>Take the cap off first!</span>")
		return

	if(check_empty(user))
		return

	if(iscarbon(target))
		if(pre_noise || post_noise)
			playsound(user.loc, 'sound/effects/spray.ogg', 25, 1, 5)

		var/mob/living/carbon/C = target
		C.visible_message("<span class='danger'>[user] sprays [src] into the face of [C]!</span>", "<span class='userdanger'>[user] sprays [src] into your face!</span>")

		if(C.client)
			C.blur_eyes(3)
			C.blind_eyes(1)
		if(C.get_eye_protection() <= 0 && (last_stun_time + stun_delay) <= world.time) // no eye protection? ARGH IT BURNS.
			last_stun_time = world.time
			C.confused = max(C.confused, 3)
			C.DefaultCombatKnockdown(60)
		if(ishuman(C) && actually_paints)
			var/mob/living/carbon/human/H = C
			H.lip_style = "spray_face"
			H.lip_color = paint_color
			H.update_body()

		// Caution, spray cans contain inflammable substances
		. = use_charges(user, 10, FALSE)
		var/fraction = min(1, . / reagents.maximum_volume)
		reagents.reaction(C, VAPOR, fraction * volume_multiplier)

		return

	if(isobj(target) && !istype(target, /obj/effect/decal/cleanable/crayon/gang))
		if(actually_paints)
			if(istype(target, /obj/item/canvas)) //dont color our canvas neon green when im trying to paint please
				return
			var/list/hsl = rgb2hsl(hex2num(copytext(paint_color,2,4)),hex2num(copytext(paint_color,4,6)),hex2num(copytext(paint_color,6,8)))
			var/static/whitelisted = typecacheof(list(/obj/structure/window,
										/obj/effect/decal/cleanable/crayon,
										/obj/machinery/door/window)
									)
			if(hsl[3] < 0.05 && !whitelisted[target]) //Colors too dark are rejected //Nostra change 0.25 to 0.05
				to_chat(usr, "<span class='warning'>A color that dark on an object like this? Surely not...</span>")
				return FALSE

			target.add_atom_colour(paint_color, WASHABLE_COLOUR_PRIORITY)

		. = use_charges(user, 2)
		var/fraction = min(1, . / reagents.maximum_volume)
		reagents.reaction(target, TOUCH, fraction * volume_multiplier)
		reagents.trans_to(target, ., volume_multiplier)

		if(pre_noise || post_noise)
			playsound(user.loc, 'sound/effects/spray.ogg', 5, 1, 5)
		user.visible_message("[user] coats [target] with spray paint!", "<span class='notice'>You coat [target] with spray paint.</span>")
		return

	. = ..()

/obj/item/toy/crayon/spraycan/update_icon_state()
	icon_state = is_capped ? icon_capped : icon_uncapped

/obj/item/toy/crayon/spraycan/update_overlays()
	. = ..()
	if(use_overlays)
		var/mutable_appearance/spray_overlay = mutable_appearance('icons/obj/crayons.dmi', "[is_capped ? "spraycan_cap_colors" : "spraycan_colors"]")
		spray_overlay.color = paint_color
		. += spray_overlay

/obj/item/toy/crayon/spraycan/borg
	name = "cyborg spraycan"
	desc = "A metallic container containing shiny synthesised paint."
	charges = -1
	stun_delay = 5 SECONDS

/obj/item/toy/crayon/spraycan/borg/draw_on(atom/target,mob/user,proximity, params)
	var/diff = ..()
	if(!iscyborg(user))
		to_chat(user, "<span class='notice'>How did you get this?</span>")
		qdel(src)
		return FALSE

	var/mob/living/silicon/robot/borgy = user

	if(!diff)
		return
	// 25 is our cost per unit of paint, making it cost 25 energy per
	// normal tag, 50 per window, and 250 per attack
	var/cost = diff * 25
	// Cyborgs shouldn't be able to use modules without a cell. But if they do
	// it's free.
	if(borgy.cell)
		borgy.cell.use(cost)

/obj/item/toy/crayon/spraycan/hellcan
	name = "hellcan"
	desc = "This spraycan doesn't seem to be filled with paint..."
	icon_state = "deathcan2_cap"
	icon_capped = "deathcan2_cap"
	icon_uncapped = "deathcan2"
	use_overlays = FALSE

	volume_multiplier = 25
	charges = 100
	reagent_contents = list(/datum/reagent/clf3 = 1)
	actually_paints = FALSE
	paint_color = "#000000"

/obj/item/toy/crayon/spraycan/lubecan
	name = "slippery spraycan"
	desc = "You can barely keep hold of this thing."
	icon_state = "clowncan2_cap"
	icon_capped = "clowncan2_cap"
	icon_uncapped = "clowncan2"
	use_overlays = FALSE

	reagent_contents = list(/datum/reagent/lube = 1, /datum/reagent/consumable/banana = 1)
	volume_multiplier = 5

/obj/item/toy/crayon/spraycan/lubecan/isValidSurface(surface)
	return istype(surface, /turf/open/floor)

/obj/item/toy/crayon/spraycan/mimecan
	name = "silent spraycan"
	desc = "Art is best seen, not heard."
	icon_state = "mimecan_cap"
	icon_capped = "mimecan_cap"
	icon_uncapped = "mimecan"
	use_overlays = FALSE

	can_change_colour = FALSE
	paint_color = "#FFFFFF" //RGB

	pre_noise = FALSE
	post_noise = FALSE
	reagent_contents = list(/datum/reagent/consumable/nothing = 1, /datum/reagent/toxin/mutetoxin = 1)

/obj/item/toy/crayon/spraycan/infinite
	name = "infinite spraycan"
	charges = -1
	desc = "Now with 30% more bluespace technology."

#undef RANDOM_GRAFFITI
#undef RANDOM_LETTER
#undef RANDOM_PUNCTUATION
#undef RANDOM_SYMBOL
#undef RANDOM_DRAWING
#undef RANDOM_NUMBER
#undef RANDOM_ORIENTED
#undef RANDOM_RUNE
#undef RANDOM_ANY
