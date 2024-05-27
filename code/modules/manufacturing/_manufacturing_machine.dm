/obj/machinery/manufacturing
	name = "manufacturing machine"
	desc = "You shouldn't see this!"
	icon_state = "mechfab1"
	density = TRUE

	/// Name to display in the UI
	var/ui_name = "Manufacturing Machine"

	/// We really only want storage to manage interactions with contained items.
	/// We can't use straight up storage because machines store things like disks in their contens
	var/obj/storage_proxy/proxy

	var/in_direction = WEST
	var/out_direction = EAST

	/// Sound to play on work, can be a list or single sound.
	var/list/work_sound
	/// A list of items contained within us.
	var/list/obj/item/contained

	/// The state of the machine
	var/operating_state = M_IDLE

	/// If TRUE, this machine will process every second.
	var/needs_processing = FALSE

	/// Timer ID for the work timer
	var/work_end_timer = null

/obj/machinery/manufacturing/Initialize(mapload)
	. = ..()

	proxy = new
	proxy.create_storage(5, WEIGHT_CLASS_GIGANTIC, WEIGHT_CLASS_BULKY * 5)
	proxy.atom_storage.silent = TRUE
	proxy.atom_storage.animated = FALSE
	proxy.atom_storage.attack_hand_interact = FALSE
	// This one is going to bite me in the ass later, I just know it.
	// This is done so that you can interact with items inside of the storage stored inside the machine.
	proxy.flags_1 |= HAS_DISASSOCIATED_STORAGE_1

/obj/machinery/manufacturing/Destroy()
	QDEL_NULL(proxy)
	return ..()

/obj/machinery/manufacturing/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(href_list["restart"])
		if(operating_state != M_WORKING)
			set_state(M_IDLE)
			playsound(src.loc, 'sound/machines/terminal_off.ogg', 50, FALSE)
			run_queue()
		return TRUE

/obj/machinery/manufacturing/on_deconstruction()
	. = ..()
	var/atom/drop_loc = drop_location()
	for(var/obj/item/I as anything in proxy)
		I.forceMove(drop_loc)

/obj/machinery/manufacturing/set_is_operational(new_value)
	. = ..()
	if(isnull(.))
		return

	if(!is_operational)
		set_state(M_IDLE)
		if(needs_processing)
			STOP_PROCESSING(SSmachines, src)

	else if(needs_processing)
		START_PROCESSING(SSmachines, src)

/obj/machinery/manufacturing/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()

	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return

	if(operating_state == M_WORKING && isliving(user))
		liveleak(user)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	proxy.atom_storage.show_contents(user)

/obj/machinery/manufacturing/BumpedBy(atom/movable/bumped_atom)
	. = ..()
	if(isitem(bumped_atom))
		var/insertion_direction = get_dir(src, bumped_atom)
		if(!(insertion_direction & in_direction))
			return

		if(proxy.atom_storage.attempt_insert(bumped_atom))
			proxy.contained += bumped_atom // Back of the queue
			run_queue()

/obj/machinery/manufacturing/drop_location()
	if(operating_state == M_WORKING)
		return get_step(src, out_direction)
	return ..()

/obj/machinery/manufacturing/process()
	if(operating_state != M_IDLE)
		return

	run_queue()

/// Change the operating state of the machine. Returns the old state.
/obj/machinery/manufacturing/proc/set_state(new_state)
	if(operating_state == new_state)
		return

	. = operating_state

	if(new_state == M_WORKING)
		proxy.atom_storage.close_all()

	else if(work_end_timer)
		deltimer(work_end_timer)
		work_end_timer = null

	operating_state = new_state
	update_appearance(UPDATE_OVERLAYS|UPDATE_ICON)
	updateUsrDialog()

	switch(operating_state)
		if(M_WORKING)
			color = "#00FF00"
		if(M_IDLE)
			color = null
		if(M_JAMMED)
			color = "#FF0000"

/// The core loop of the machine. Goes through proxy contents and attempts to run process_item() on them.
/obj/machinery/manufacturing/proc/run_queue()
	if(operating_state != M_IDLE || !length(proxy.contained))
		return

	var/obj/item/item_to_work = proxy.contained[1]

	/// If it's not something we can work on, JAM!
	if(!check_item_type(item_to_work))
		jam()
		return

	process_item(item_to_work)

/// Schedules a job to be performed, setting state and playing the work sound
/obj/machinery/manufacturing/proc/do_work(callback, duration)
	set_state(M_WORKING)
	play_work_sound()
	work_end_timer = addtimer(callback, duration, TIMER_DELETE_ME|TIMER_STOPPABLE)

/// Returns TRUE if this machine can process this item.
/obj/machinery/manufacturing/proc/check_item_type(obj/item/item)
	return isitem(item)

/// Perform our shit on this item.
/obj/machinery/manufacturing/proc/process_item(obj/item/item)
	return

/obj/machinery/manufacturing/proc/eject_item(obj/item/item)
	if(istype(item, /obj/item/slapcraft_assembly))
		var/obj/item/slapcraft_assembly/assembly = item
		if(assembly.being_finished)
			var/drop_loc = drop_location()
			for(var/atom/movable/AM in assembly.finished_items)
				AM.forceMove(drop_loc)

	if(!QDELETED(item))
		item.forceMove(drop_location())
		return

/obj/machinery/manufacturing/proc/play_work_sound()
	if(islist(work_sound))
		playsound(src, pick(work_sound), 100)
	else
		playsound(src, work_sound, 100)

/// Attempts to create an assembly out of an item. Returns the assembly if successful, null on failure.
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
