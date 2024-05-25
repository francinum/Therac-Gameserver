/obj/storage_proxy
	name = "WHY CAN YOU SEE THIS"
	obj_flags = INDESTRUCTIBLE

	/// A k:v list of item : inserted_direction. This list can contain non-items, beware!
	var/list/contained

/obj/storage_proxy/Initialize(mapload)
	. = ..()
	contained = list()

/obj/storage_proxy/Destroy(force)
	contained = null
	return ..()

/obj/storage_proxy/Exited(atom/movable/gone, direction)
	. = ..()
	contained -= gone
