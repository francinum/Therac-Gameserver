/obj/storage_proxy
	name = "WHY CAN YOU SEE THIS"
	obj_flags = INDESTRUCTIBLE

	/// A FIFO list of contained objects.
	var/list/contained

/obj/storage_proxy/Initialize(mapload)
	. = ..()
	contained = list()

/obj/storage_proxy/Destroy(force)
	contained = null
	return ..()

/obj/storage_proxy/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	var/obj/item/I = arrived
	if(I.item_flags & IN_STORAGE) // attempt_insert() sets this prior to moving it into us
		return

	contained.Insert(1, arrived)

/obj/storage_proxy/Exited(atom/movable/gone, direction)
	. = ..()
	contained -= gone
