/obj/machinery/manufacturing
	name = "manufacturing machine"
	desc = "You shouldn't see this!"
	icon_state = "mechfab1"
	density = TRUE

	var/in_directions = ALL_CARDINALS
	var/out_direction = SOUTH

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
	return FALSE

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

/// Machinery for performing steps without actually using a resource
/obj/machinery/manufacturing/perform_abstract_step
	/// A k:v list of step_path : time to complete. step_path becomes a typecache during init.
	var/list/steps

	/// The current item being worked on, incase this machine performs multiple steps.
	var/datum/weakref/working_on

	/// The typecache of steps to perform next.
	var/list/next_step

/obj/machinery/manufacturing/perform_abstract_step/Initialize(mapload)
	. = ..()
	var/idx
	for(var/path in steps)
		idx++
		var/old_value = steps[path]
		steps[idx] = typecacheof(path)
		steps[steps[idx]] = old_value

/obj/machinery/manufacturing/perform_abstract_step/check_item_type(obj/item/item)
	if(istype(item, /obj/item/slapcraft_assembly))
		return TRUE
	return FALSE

/obj/machinery/manufacturing/perform_abstract_step/process_item(obj/item/item)
	var/obj/item/slapcraft_assembly/assembly = item
	var/list/possible_steps = assembly.get_possible_next_steps()

	next_step ||= steps[1]

	var/time_to_perform = null
	var/step_to_perform = null

	for(var/step_type in possible_steps)
		if(next_step[step_type])
			time_to_perform = steps[next_step]
			step_to_perform = step_type
			break

	if(isnull(time_to_perform))
		next_step = null
		jam()
		return

	set_state(M_WORKING)

	work_timer = addtimer(CALLBACK(src, PROC_REF(complete_step), item, step_to_perform), time_to_perform, TIMER_STOPPABLE|TIMER_DELETE_ME)

/obj/machinery/manufacturing/perform_abstract_step/proc/complete_step(obj/item/slapcraft_assembly/assembly, datum/slapcraft_step/step_to_perform)
	assembly.finished_step(null, SLAPCRAFT_STEP(step_to_perform))

	var/step_index = steps.Find(next_step)
	// If this is the last step, spit it out and be done with it
	if(step_index == length(steps))
		next_step = null
		eject_item(assembly)
		set_state(M_IDLE)
		run_queue()
		return

	// TOO SOON, EXECUTUS! YOU HAVE COMPLETED ME TOO SOON!
	if(assembly.being_finished)
		eject_item(assembly)
		jam()
		return

	next_step = steps[step_index + 1]
	working_on = WEAKREF(assembly)
	process_item(assembly)

/obj/machinery/manufacturing/perform_abstract_step/test
	out_direction = EAST
	steps = list(/datum/slapcraft_step/tool/welder = 10 SECONDS)
