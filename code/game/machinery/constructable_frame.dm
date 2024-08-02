/obj/structure/frame
	name = "frame"
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "box_0"
	density = TRUE
	max_integrity = 250

	var/obj/item/circuitboard/circuit = null
	var/list/component_parts

/obj/structure/frame/examine(user)
	. = ..()
	if(circuit)
		. += "It has \a [circuit] installed."

/obj/structure/frame/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		new /obj/item/stack/sheet/iron(loc, 5)
		if(circuit)
			circuit.set_parent(null, FALSE)
			circuit.forceMove(loc)
			circuit = null

	return ..()

/obj/structure/frame/attackby(obj/item/P, mob/living/user, params)
	. = ..()
	if(.)
		return

	if(!circuit)
		if(istype(P, /obj/item/circuitboard))
			if(user.transferItemToLoc(P, src))
				circuit = P
				circuit.set_parent(src)
				visible_message("[user] sets [P] inside of [src].")
				return TRUE
		return


/obj/structure/frame/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return

	if(!circuit)
		return

	if(circuit.construction.constructed == SEQUENCE_NOT_STARTED)
		if(user.put_in_hands(circuit))
			circuit.set_parent(null, FALSE)
			visible_message("[user] removes [circuit] from [src].")
			circuit = null
			return TRUE

/obj/structure/frame/computer
#warn TODO: computer frame handling
