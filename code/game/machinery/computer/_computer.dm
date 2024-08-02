DEFINE_INTERACTABLE(/obj/machinery/computer)
/obj/machinery/computer
	name = "computer"
	icon = 'icons/obj/computer.dmi'
	icon_state = "computer"
	density = TRUE
	max_integrity = 200
	integrity_failure = 0.5
	armor = list(BLUNT = 0, PUNCTURE = 0, SLASH = 90, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 40, ACID = 20)
	zmm_flags = ZMM_MANGLE_PLANES

	light_inner_range = 0.1
	light_outer_range = 2
	light_power = 0.8

	var/icon_keyboard = "generic_key"
	var/icon_screen = "generic"
	var/time_to_screwdrive = 20
	var/authenticated = 0

/obj/machinery/computer/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()

	power_change()

/obj/machinery/computer/Destroy()
	. = ..()

/obj/machinery/computer/process()
	if(machine_stat & (NOPOWER|BROKEN))
		return FALSE
	return TRUE

/obj/machinery/computer/update_overlays()
	. = ..()
	if(icon_keyboard)
		if(machine_stat & NOPOWER)
			. += "[icon_keyboard]_off"
		else
			. += icon_keyboard

	// This whole block lets screens ignore lighting and be visible even in the darkest room
	if(machine_stat & BROKEN)
		. += mutable_appearance(icon, "[icon_state]_broken")
		return // If we don't do this broken computers glow in the dark.

	if(machine_stat & NOPOWER) // Your screen can't be on if you've got no damn charge
		return

	. += mutable_appearance(icon, icon_screen)
	. += emissive_appearance(icon, icon_screen)

/obj/machinery/computer/power_change()
	. = ..()
	if(machine_stat & NOPOWER)
		set_light(l_on = FALSE)
	else
		set_light(l_on = TRUE)

/obj/machinery/computer/screwdriver_act(mob/living/user, obj/item/I)
	if(..())
		return TRUE
	if(circuit && !(flags_1&NODECONSTRUCT_1))
		to_chat(user, span_notice("You start to disconnect the monitor..."))
		if(I.use_tool(src, user, time_to_screwdrive, volume=50))
			deconstruct(TRUE, user)
	return TRUE

/obj/machinery/computer/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(machine_stat & BROKEN)
				playsound(src.loc, 'sound/effects/hit_on_shattered_glass.ogg', 70, TRUE)
			else
				playsound(src.loc, 'sound/effects/glasshit.ogg', 75, TRUE)
		if(BURN)
			playsound(src.loc, 'sound/items/welder.ogg', 100, TRUE)

/obj/machinery/computer/atom_break(damage_flag)
	if(!circuit) //no circuit, no breaking
		return
	. = ..()
	if(.)
		playsound(loc, 'sound/effects/glassbr3.ogg', 100, TRUE)
		set_light(0)

/obj/machinery/computer/emp_act(severity)
	. = ..()
	if (!(. & EMP_PROTECT_SELF))
		switch(severity)
			if(1)
				if(prob(50))
					atom_break(ENERGY)
			if(2)
				if(prob(10))
					atom_break(ENERGY)

/obj/machinery/computer/deconstruct(disassembled = TRUE, mob/user)
	on_deconstruction()
	return ..()

/obj/machinery/computer/AltClick(mob/user)
	. = ..()
	if(!can_interact(user))
		return
	if(!user.canUseTopic(src, USE_CLOSE|USE_SILICON_REACH) || !is_operational)
		return

/obj/machinery/computer/ui_interact(mob/user, datum/tgui/ui)
	SHOULD_CALL_PARENT(TRUE)
	. = ..()
	update_use_power(ACTIVE_POWER_USE)

/obj/machinery/computer/ui_close(mob/user)
	SHOULD_CALL_PARENT(TRUE)
	. = ..()
	update_use_power(IDLE_POWER_USE)
