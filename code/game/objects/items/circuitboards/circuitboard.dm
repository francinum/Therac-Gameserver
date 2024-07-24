//File with the circuitboard and circuitboard/machine class definitions and procs


// Circuitboard

/obj/item/circuitboard
	name = "circuit board"
	icon = 'icons/obj/module.dmi'
	icon_state = "circuit_map"
	inhand_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	custom_materials = list(/datum/material/glass = 1000)
	w_class = WEIGHT_CLASS_SMALL
	grind_results = list(/datum/reagent/silicon = 20)
	greyscale_colors = CIRCUIT_COLOR_GENERIC

	var/obj/machinery/parent
	var/datum/construction_template/construction

	/// Simple circuitboards work using the construction component
	var/simple = FALSE

	var/build_path = null
	///determines if the circuit board originated from a vendor off station or not.
	var/onstation = TRUE

	var/list/req_components // Components required by the machine.
							// Example: list(/obj/item/stock_parts/matter_bin = 5)

	var/list/def_components // Default replacements for req_components, to be used in apply_default_parts instead of req_components types
							// Example: list(/obj/item/stock_parts/matter_bin = /obj/item/stock_parts/matter_bin/super)

/obj/item/circuitboard/Initialize(mapload)
	set_greyscale(new_config = /datum/greyscale_config/circuit)

	construction = new construction(src)
	return ..()

/obj/item/circuitboard/Destroy(force)
	set_parent(null)
	return ..()

/obj/item/circuitboard/examine(mob/user)
	. = ..()
	if(!LAZYLEN(req_components))
		. += span_info("It requires no components.")
		return .

	var/list/nice_list = list()
	for(var/atom/component_path as anything in req_components)
		if(!ispath(component_path))
			continue

		var/component_name = initial(component_path.name)
		var/component_amount = req_components[component_path]

		if(ispath(component_path, /obj/item/stack))
			var/obj/item/stack/stack_path = component_path
			if(initial(stack_path.singular_name))
				component_name = initial(stack_path.singular_name) //e.g. "glass sheet" vs. "glass"

		else if(ispath(component_path, /obj/item/stock_parts))
			var/obj/item/stock_parts/stock_part = component_path
			if(initial(stock_part.base_name))
				component_name = initial(stock_part.base_name)

		nice_list += list("[component_amount] [component_name]\s")

	. += span_info("It requires [english_list(nice_list)].")

/obj/item/circuitboard/proc/set_parent(obj/machinery/machine)
	var/obj/machinery/old_parent = parent
	parent = machine
	construction.set_parent(parent, !QDELING(old_parent))

/**
 * Used to allow the circuitboard to configure a machine in some way, shape or form.
 *
 * Arguments:
 * * machine - The machine to attempt to configure.
 */
/obj/item/circuitboard/proc/configure_machine(obj/machinery/machine)
	return

// Circuitboard/machine
/*Common Parts: Parts List: Ignitor, Timer, Infra-red laser, Infra-red sensor, t_scanner, Capacitor, Valve, sensor unit,
micro-manipulator, console screen, beaker, Microlaser, matter bin, power cells.
*/

/obj/item/circuitboard/machine
	var/needs_anchored = TRUE // Whether this machine must be anchored to be constructed.
