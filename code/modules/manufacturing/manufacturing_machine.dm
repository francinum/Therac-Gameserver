/obj/machinery/manufacturing
	name = "manufacturing machine"
	desc = "You shouldn't see this!"
	icon_state = "mechfab1"
	density = TRUE

	var/in_directions = ALL_CARDINALS
	var/out_direction = SOUTH

	/// Sound to play on work, can be a list or single sound.
	var/list/work_sound

	var/list/datum/weakref/contained = list()
	/// The state of the machine
	var/state = M_IDLE

	/// Timer ID for active work
	var/work_timer

/obj/machinery/manufacturing/Initialize(mapload)
	. = ..()
	create_storage(5, WEIGHT_CLASS_GIGANTIC, WEIGHT_CLASS_BULKY * 5)
	atom_storage.silent = TRUE
	atom_storage.animated = FALSE
	atom_storage.attack_hand_interact = FALSE

/obj/machinery/manufacturing/Destroy()
	contained = null
	return ..()

/obj/machinery/manufacturing/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()

	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return

	if(state == M_WORKING && isliving(user))
		liveleak(user)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	atom_storage.show_contents(user)

/obj/machinery/manufacturing/BumpedBy(atom/movable/bumped_atom)
	. = ..()
	if(isitem(bumped_atom))
		var/insertion_direction = get_dir(bumped_atom, src)
		if(!(insertion_direction & in_directions))
			return

		if(atom_storage.attempt_insert(bumped_atom))
			contained[WEAKREF(bumped_atom)] = insertion_direction
			run_queue()

/obj/machinery/manufacturing/Exited(atom/movable/gone, direction)
	. = ..()
	contained -= gone.weak_reference

/obj/machinery/manufacturing/drop_location()
	if(state == M_WORKING)
		return get_step(src, out_direction)
	return ..()

/// Change the operating state of the machine.
/obj/machinery/manufacturing/proc/set_state(new_state)
	if(state == new_state)
		return

	if(new_state == M_WORKING)
		atom_storage.close_all()
	else if(work_timer)
		deltimer(work_timer)

	state = new_state
	update_appearance(UPDATE_OVERLAYS|UPDATE_ICON)

/obj/machinery/manufacturing/proc/run_queue()
	if(state != M_IDLE || !length(contained))
		update_appearance(UPDATE_ICON|UPDATE_OVERLAYS)
		return

	var/obj/item/item_to_work = contained[1].resolve()

	if(isnull(item_to_work))
		contained.Cut(1, 2)
		return .()

	if(!isitem(item_to_work))
		jam()
		return

	if(!check_item_type(item_to_work))
		jam()
		return

	process_item(item_to_work)

/obj/machinery/manufacturing/proc/check_item_type(obj/item/item)
	return TRUE

/// Perform our shit on this item.
/obj/machinery/manufacturing/proc/process_item(obj/item/item)
	return

/obj/machinery/manufacturing/proc/eject_item(obj/item/item)
	if(istype(item, /obj/item/slapcraft_assembly))
		var/obj/item/slapcraft_assembly/assembly = item
		if(!assembly.being_finished)
			return

		var/drop_loc = drop_location()
		for(var/atom/movable/AM in assembly.finished_items)
			AM.forceMove(drop_loc)

	if(!QDELETED(item))
		item.forceMove(drop_location())
		return

/obj/machinery/manufacturing/proc/play_work_sound()
	return

/obj/machinery/manufacturing/proc/attempt_create_assembly(obj/item/item)
	RETURN_TYPE(/obj/item/slapcraft_assembly)
	return

/obj/machinery/manufacturing/proc/jam()
	set_state(M_JAMMED)
	visible_message(span_warning("[src] emits a metallic shriek, before grinding to a halt."), blind_message = span_hear("You hear metal shearing apart."))
	playsound(src, 'sound/machines/danger_alarm.ogg', 50)

/// Called when a user attempts to interact with the inventory of the machine while it is operating.
/obj/machinery/manufacturing/proc/liveleak(mob/living/user)
	set waitfor = FALSE

	var/obj/item/bodypart/BP = user.get_active_hand()
	visible_message(
		span_warning("[user] reaches [user.p_their()] [BP.plaintext_zone] inside of [src]!")
	)

	jam()
	user.Stun(5 SECONDS, TRUE)
	user.do_jitter_animation()
	ADD_TRAIT(user, TRAIT_FORCED_STANDING, REF(src))

	sleep(5 SECONDS)

	REMOVE_TRAIT(user, TRAIT_FORCED_STANDING, REF(src))
	BP.dismember(DROPLIMB_BLUNT)
	user.Paralyze(3 SECONDS)
