/obj/effect/fusion_particle_catcher
	density = TRUE
	anchored = TRUE
	invisibility = 101
	light_color = COLOR_BLUE
	///Typecache of particles that can interact with this field.
	var/static/list/particle_cache = typecacheof(/obj/projectile/energy/nuclear_particle)
	var/obj/effect/reactor_em_field/parent
	var/mysize = 0

/obj/effect/fusion_particle_catcher/Destroy()
	parent?.particle_catchers -= src //This should never actually exist outside of the R-UST, but, unit tests.
	parent = null
	return ..()

/obj/effect/fusion_particle_catcher/proc/set_size(newsize)
	name = "collector [newsize]"
	mysize = newsize
	update_size()

/obj/effect/fusion_particle_catcher/proc/add_particles(name, quantity = 1)
	if(parent && parent.size >= mysize)
		parent.add_particles(name, quantity)
		return 1
	return 0

/obj/effect/fusion_particle_catcher/proc/update_size()
	if(parent.size >= mysize)
		set_density(1)
		name = "collector [mysize] ON"
	else
		set_density(0)
		name = "collector [mysize] OFF"

/obj/effect/fusion_particle_catcher/bullet_act(obj/projectile/Proj)
	if(istype(proj, /obj/projectile/energy/nuclear_particle))
		var/obj/projectile/energy/nuclear_particle/particle = proj
		if(proj.particle_type && proj.particle_type != "neutron")
			if(parent.owned_core.AddParticles(particle_type, 1 + additional_particles))
				parent.owned_core.plasma_temperature += mega_energy
				parent.owned_core.energy += energy
				qdel(proj)
		return BULLET_ACT_BLOCK

	parent.add_energy(Proj.damage)
	return BULLET_ACT_BLOCK

/obj/effect/fusion_particle_catcher/CanAllowThrough(atom/movable/mover, border_dir)
	..()
	return !particle_cache[mover.type]
