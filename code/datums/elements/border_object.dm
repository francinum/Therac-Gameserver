/datum/element/border_object

/datum/element/border_object/Attach(datum/target)
	. = ..()
	if(!isobj(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))

	on_moved(target)

/datum/element/border_object/Detach(datum/source, ...)
	. = ..()
	if(isturf(source:loc))
		var/turf/T = source:loc
		LAZYREMOVE(T.border_objects, source)

/datum/element/border_object/proc/on_moved(atom/movable/source, atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	SIGNAL_HANDLER

	if(isturf(source.loc))
		var/turf/T = source.loc
		LAZYADD(T.border_objects, source)

	if(isturf(old_loc))
		var/turf/T = old_loc
		LAZYREMOVE(T.border_objects, source)
