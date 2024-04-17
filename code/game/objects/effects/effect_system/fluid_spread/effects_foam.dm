/// The minimum foam range required to start diluting the reagents past the minimum dilution rate.
#define MINIMUM_FOAM_DILUTION_RANGE 3
/// The minumum foam-area based divisor used to decrease foam exposure volume.
#define MINIMUM_FOAM_DILUTION DIAMOND_AREA(MINIMUM_FOAM_DILUTION_RANGE)
///	The effective scaling of the reagents in the foam. (Total delivered at or below [MINIMUM_FOAM_DILUTION])
#define FOAM_REAGENT_SCALE 3.2

/**
 * ## Foam
 *
 * Similar to smoke, but slower and mobs absorb its reagent through their exposed skin.
 */
/obj/effect/particle_effect/fluid/foam
	name = "foam"
	icon_state = "foam"
	opacity = FALSE
	anchored = TRUE
	density = FALSE
	layer = EDGED_TURF_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	animate_movement = NO_STEPS
	/// The types of turfs that this foam cannot spread to.
	var/static/list/blacklisted_turfs = typecacheof(list(
		/turf/open/space/transit,
		/turf/open/chasm,
		/turf/open/lava,
	))
	/// The typepath for what this foam leaves behind when it dissipates.
	var/atom/movable/result_type = null
	/// Whether or not this foam can produce a remnant movable if something of the same type is already on its turf.
	var/allow_duplicate_results = TRUE
	/// The amount of time this foam stick around for before it dissipates.
	var/lifetime = 8 SECONDS
	/// Whether or not this foam should be slippery.
	var/slippery_foam = TRUE


/obj/effect/particle_effect/fluid/foam/Initialize(mapload)
	. = ..()
	if(slippery_foam)
		AddComponent(/datum/component/slippery, 100)
	create_reagents(1000, REAGENT_HOLDER_INSTANT_REACT)
	playsound(src, 'sound/effects/bubbles2.ogg', 80, TRUE, -3)
	become_atmos_sensitive()
	SSfoam.start_processing(src)

/obj/effect/particle_effect/fluid/foam/Destroy()
	lose_atmos_sensitivity()
	SSfoam.stop_processing(src)
	if (spread_bucket)
		SSfoam.cancel_spread(src)
	return ..()

/**
 * Makes the foam dissipate and create whatever remnants it must.
 */
/obj/effect/particle_effect/fluid/foam/proc/kill_foam()
	SSfoam.stop_processing(src)
	if (spread_bucket)
		SSfoam.cancel_spread(src)
	make_result()
	flick("[icon_state]-disolve", src)
	QDEL_IN(src, 0.5 SECONDS)

/**
 * Makes the foam leave behind something when it dissipates.
 *
 * Returns the thing the foam leaves behind for further modification by subtypes.
 */
/obj/effect/particle_effect/fluid/foam/proc/make_result()
	if(isnull(result_type))
		return null

	var/atom/location = loc
	var/atom/movable/result = (!allow_duplicate_results && (locate(result_type) in location)) || (new result_type(location))
	transfer_fingerprints_to(result)
	return result

/obj/effect/particle_effect/fluid/foam/process(seconds_per_tick)
	var/ds_seconds_per_tick = seconds_per_tick SECONDS
	lifetime -= ds_seconds_per_tick
	if(lifetime <= 0)
		kill_foam()
		return

	if(ismob(loc))
		stack_trace("A foam effect ([type]) was created within a mob! (Actual location: [loc] ([loc.type]))")
		qdel(src)
		return

	var/fraction = (ds_seconds_per_tick * MINIMUM_FOAM_DILUTION) / (initial(lifetime) * max(MINIMUM_FOAM_DILUTION, group.total_size))

	if(isturf(loc))
		var/turf/turf_location = loc
		for(var/obj/object in turf_location)
			if(object == src)
				continue
			if(turf_location.underfloor_accessibility < UNDERFLOOR_INTERACTABLE && HAS_TRAIT(object, TRAIT_T_RAY_VISIBLE))
				continue
			reagents.expose(object, VAPOR, fraction)

	var/hit = 0
	for(var/mob/living/foamer in loc)
		hit += foam_mob(foamer, seconds_per_tick)
	if(hit)
		lifetime += ds_seconds_per_tick //this is so the decrease from mobs hit and the natural decrease don't cumulate.

	reagents.expose(loc, VAPOR, fraction)

/**
 * Applies the effect of this foam to a mob.
 *
 * Arguments:
 * - [foaming][/mob/living]: The mob that this foam is acting on.
 * - seconds_per_tick: The amount of time that this foam is acting on them over.
 *
 * Returns:
 * - [TRUE]: If the foam was successfully applied to the mob. Used to scale how quickly foam dissipates according to the number of mobs it is applied to.
 * - [FALSE]: Otherwise.
 */
/obj/effect/particle_effect/fluid/foam/proc/foam_mob(mob/living/foaming, seconds_per_tick)
	if(lifetime <= 0)
		return FALSE
	if(!istype(foaming))
		return FALSE

	seconds_per_tick = min(seconds_per_tick SECONDS, lifetime)
	var/fraction = (seconds_per_tick * MINIMUM_FOAM_DILUTION) / (initial(lifetime) * max(MINIMUM_FOAM_DILUTION, group.total_size))
	reagents.expose(foaming, VAPOR, fraction)
	lifetime -= seconds_per_tick
	return TRUE

/obj/effect/particle_effect/fluid/foam/spread(seconds_per_tick = 0.2 SECONDS)
	if(group.total_size > group.target_size)
		return
	var/turf/location = get_turf(src)
	if(!istype(location))
		return FALSE

	for(var/iter_dir in GLOB.cardinals)
		var/turf/spread_turf = get_step(src, iter_dir)
		if(spread_turf?.density || spread_turf.LinkBlockedWithAccess(spread_turf, no_id = TRUE))
			continue

		var/obj/effect/particle_effect/fluid/foam/foundfoam = locate() in spread_turf //Don't spread foam where there's already foam!
		if(foundfoam)
			continue
		if(is_type_in_typecache(spread_turf, blacklisted_turfs))
			continue

		for(var/mob/living/foaming in spread_turf)
			foam_mob(foaming, seconds_per_tick)

		var/obj/effect/particle_effect/fluid/foam/spread_foam = new type(spread_turf, group, src)
		reagents.copy_to(spread_foam, (reagents.total_volume))
		spread_foam.add_atom_colour(color, FIXED_COLOUR_PRIORITY)
		spread_foam.result_type = result_type
		SSfoam.queue_spread(spread_foam)

/obj/effect/particle_effect/fluid/foam/atmos_expose(datum/gas_mixture/air, exposed_temperature)
	if(prob(max(0, exposed_temperature - 475)))   //foam dissolves when heated
		kill_foam()

/// A factory for foam fluid floods.
/datum/effect_system/fluid_spread/foam
	effect_type = /obj/effect/particle_effect/fluid/foam
	/// A container for all of the chemicals we distribute through the foam.
	var/datum/reagents/chemholder
	/// The amount that
	var/reagent_scale = FOAM_REAGENT_SCALE
	/// What type of thing the foam should leave behind when it dissipates.
	var/atom/movable/result_type = null


/datum/effect_system/fluid_spread/foam/New()
	..()
	chemholder = new(1000, NO_REACT)

/datum/effect_system/fluid_spread/foam/Destroy()
	QDEL_NULL(chemholder)
	return ..()

/datum/effect_system/fluid_spread/foam/set_up(range = 1, amount = DIAMOND_AREA(range), atom/holder, atom/location = null, datum/reagents/carry = null, result_type = null, stop_reactions = FALSE)
	. = ..()
	carry?.copy_to(chemholder, carry.total_volume, no_react = stop_reactions)
	if(!isnull(result_type))
		src.result_type = result_type

/datum/effect_system/fluid_spread/foam/start(log = FALSE)
	var/obj/effect/particle_effect/fluid/foam/foam = new effect_type(location, new /datum/fluid_group(amount))
	var/foamcolor = mix_color_from_reagents(chemholder.reagent_list)
	if(reagent_scale > 1) // Make room in case we were created by a particularly stuffed payload.
		foam.reagents.maximum_volume *= reagent_scale
	chemholder.copy_to(foam, chemholder.total_volume, reagent_scale) // Foam has an amplifying effect on the reagents it is supplied with. This is balanced by the reagents being diluted as the area the foam covers increases.
	foam.add_atom_colour(foamcolor, FIXED_COLOUR_PRIORITY)
	if(!isnull(result_type))
		foam.result_type = result_type
	if (log)
		help_out_the_admins(foam, holder, location)
	SSfoam.queue_spread(foam)


// Short-lived foam
/// A foam variant which dissipates quickly.
/obj/effect/particle_effect/fluid/foam/short_life
	lifetime = 1 SECONDS

/datum/effect_system/fluid_spread/foam/short
	effect_type = /obj/effect/particle_effect/fluid/foam/short_life

// Long lasting foam
/// A foam variant which lasts for an extended amount of time.
/obj/effect/particle_effect/fluid/foam/long_life
	lifetime = 30 SECONDS

/// A factory which produces foam with an extended lifespan.
/datum/effect_system/fluid_spread/foam/long
	effect_type = /obj/effect/particle_effect/fluid/foam/long_life
	reagent_scale = FOAM_REAGENT_SCALE * (30 / 8)


// Firefighting foam
/// A variant of foam which absorbs plasma in the air if there is a fire.
/obj/effect/particle_effect/fluid/foam/firefighting
	name = "firefighting foam"
	lifetime = 20 //doesn't last as long as normal foam
	result_type = /obj/effect/decal/cleanable/plasma
	allow_duplicate_results = FALSE
	slippery_foam = FALSE
	/// The amount of plasma gas this foam has absorbed. To be deposited when the foam dissipates.
	var/absorbed_plasma = 0

/obj/effect/particle_effect/fluid/foam/firefighting/Initialize(mapload)
	. = ..()
	lose_atmos_sensitivity()

/obj/effect/particle_effect/fluid/foam/firefighting/process()
	..()

	var/turf/open/T = get_turf(src)
	if(!istype(T))
		return

	var/obj/effect/hotspot/hotspot = T.active_hotspot
	if(hotspot)
		qdel(hotspot)

	if(T.zone)
		var/datum/gas_mixture/G = T.return_air()
		if(G.getGroupGas(GAS_PLASMA))
			var/plas_amt = min(30, G.gas[GAS_PLASMA]) //Absorb some plasma
			G.adjustGas(GAS_PLASMA, -plas_amt)
			absorbed_plasma += plas_amt
		if(G.temperature > T20C)
			G.temperature = max(G.temperature/2,T20C)

/obj/effect/particle_effect/fluid/foam/firefighting/make_result()
	var/atom/movable/deposit = ..()
	if(istype(deposit) && deposit.reagents && absorbed_plasma > 0)
		deposit.reagents.add_reagent(/datum/reagent/stable_plasma, absorbed_plasma)
		absorbed_plasma = 0
	return deposit

/obj/effect/particle_effect/fluid/foam/firefighting/foam_mob(mob/living/foaming, seconds_per_tick)
	if(!istype(foaming))
		return
	foaming.adjust_wet_stacks(2)

/// A factory which produces firefighting foam
/datum/effect_system/fluid_spread/foam/firefighting
	effect_type = /obj/effect/particle_effect/fluid/foam/firefighting

// Metal foam

/// A foam variant which
/obj/effect/particle_effect/fluid/foam/metal
	name = "aluminium foam"
	result_type = /obj/structure/foamedmetal
	icon_state = "mfoam"
	slippery_foam = FALSE

/// A factory which produces aluminium metal foam.
/datum/effect_system/fluid_spread/foam/metal
	effect_type = /obj/effect/particle_effect/fluid/foam/metal

/// FOAM STRUCTURE. Formed by metal foams. Dense and opaque, but easy to break
/obj/structure/foamedmetal
	icon = 'icons/effects/effects.dmi'
	icon_state = "metalfoam"
	density = TRUE
	opacity = TRUE // changed in New()
	anchored = TRUE
	layer = EDGED_TURF_LAYER
	resistance_flags = FIRE_PROOF | ACID_PROOF
	name = "foamed metal"
	desc = "A lightweight foamed metal wall that can be used as base to construct a wall."
	gender = PLURAL
	max_integrity = 20
	can_atmos_pass = CANPASS_DENSITY
	obj_flags = CAN_BE_HIT | BLOCK_Z_IN_DOWN | BLOCK_Z_IN_UP
	///Var used to prevent spamming of the construction sound
	var/next_beep = 0

/obj/structure/foamedmetal/Initialize(mapload)
	. = ..()
	zas_update_loc()

/obj/structure/foamedmetal/Destroy()
	zas_update_loc()
	return ..()

/obj/structure/foamedmetal/Move()
	var/turf/T = loc
	. = ..()
	zas_update_loc()
	T?.zas_update_loc()

/obj/structure/foamedmetal/attack_paw(mob/user, list/modifiers)
	return attack_hand(user, modifiers)

/obj/structure/foamedmetal/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	playsound(src.loc, 'sound/weapons/tap.ogg', 100, TRUE)

/obj/structure/foamedmetal/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src, ATTACK_EFFECT_PUNCH)
	to_chat(user, span_warning("You hit [src] but bounce off it!"))
	playsound(src.loc, 'sound/weapons/tap.ogg', 100, TRUE)

/obj/structure/foamedmetal/attackby(obj/item/W, mob/user, params)
	. = ..()
	if(.)
		return

	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src, ATTACK_EFFECT_PUNCH)
	to_chat(user, span_warning("You hit [src] but bounce off it!"))
	playsound(src.loc, 'sound/weapons/tap.ogg', 100, TRUE)

/// A metal foam variant which produces slightly sturdier walls.
/obj/effect/particle_effect/fluid/foam/metal/iron
	name = "iron foam"
	result_type = /obj/structure/foamedmetal/iron

/// A factory which produces iron metal foam.
/datum/effect_system/fluid_spread/foam/metal/iron
	effect_type = /obj/effect/particle_effect/fluid/foam/metal/iron

/// A variant of metal foam walls with higher durability.
/obj/structure/foamedmetal/iron
	max_integrity = 50
	icon_state = "ironfoam"

/// A variant of metal foam which only produces walls at area boundaries.
/obj/effect/particle_effect/fluid/foam/metal/smart
	name = "smart foam"

/// A factory which produces smart aluminium metal foam.
/datum/effect_system/fluid_spread/foam/metal/smart
	effect_type = /obj/effect/particle_effect/fluid/foam/metal/smart

/obj/effect/particle_effect/fluid/foam/metal/smart/make_result() //Smart foam adheres to area borders for walls
	var/turf/open/location = loc
	if(isspaceturf(location))
		location.PlaceOnTop(/turf/open/floor/plating/foam)

	for(var/cardinal in GLOB.cardinals)
		var/turf/cardinal_turf = get_step(location, cardinal)
		if(get_area(cardinal_turf) != get_area(location))
			return ..()
	return null

/datum/effect_system/fluid_spread/foam/metal/resin
	effect_type = /obj/effect/particle_effect/fluid/foam/metal/resin

/// A foam variant which produces atmos resin walls.
/obj/effect/particle_effect/fluid/foam/metal/resin
	name = "resin foam"
	result_type = /obj/structure/foamedmetal/resin

/// Atmos Backpack Resin, transparent, prevents atmos and filters the air
/obj/structure/foamedmetal/resin
	name = "\improper ATMOS Resin"
	desc = "A lightweight, transparent resin used to suffocate fires, scrub the air of toxins, and restore the air to a safe temperature. It can be used as base to construct a wall."
	opacity = FALSE
	icon_state = "atmos_resin"
	alpha = 120
	max_integrity = 10
	pass_flags_self = PASSGLASS

/obj/structure/foamedmetal/resin/Initialize(mapload)
	. = ..()
	var/turf/open/location = loc
	if(!istype(location))
		return

	location.ClearWet()
	QDEL_NULL(location.active_hotspot)
	if(location.zone)
		var/datum/gas_mixture/G = location.return_air()
		var/datum/gas_mixture/new_gas = G.removeVolume(CELL_VOLUME)
		G.temperature = T20C
		var/list/G_gases = G.gas
		for(var/I in G_gases)
			if(I == GAS_OXYGEN || I == GAS_NITROGEN)
				continue
			G_gases[I] = 0
		AIR_UPDATE_VALUES(G)
		G.merge(new_gas)

	for(var/obj/machinery/atmospherics/components/unary/comp in location)
		if(!comp.welded)
			comp.welded = TRUE
			comp.update_appearance()
			comp.visible_message(span_danger("[comp] sealed shut!"))

	for(var/mob/living/potential_tinder in location)
		potential_tinder.extinguish_mob()
	for(var/obj/item/potential_tinder in location)
		potential_tinder.extinguish()

/datum/effect_system/fluid_spread/foam/dirty
	effect_type = /obj/effect/particle_effect/fluid/foam/dirty

/obj/effect/particle_effect/fluid/foam/dirty
	name = "dirty foam"
	allow_duplicate_results = FALSE
	result_type = /obj/effect/decal/cleanable/dirt

/obj/effect/spawner/foam_starter
	var/datum/effect_system/fluid_spread/foam/foam_type = /datum/effect_system/fluid_spread/foam
	var/foam_size = 4

/obj/effect/spawner/foam_starter/Initialize(mapload)
	. = ..()

	var/datum/effect_system/fluid_spread/foam/foam = new foam_type()
	foam.set_up(foam_size, holder = src, location = loc)
	foam.start()

/obj/effect/spawner/foam_starter/small
	foam_size = 2

#undef MINIMUM_FOAM_DILUTION_RANGE
#undef MINIMUM_FOAM_DILUTION
#undef FOAM_REAGENT_SCALE
