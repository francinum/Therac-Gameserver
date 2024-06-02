/datum/component/construction
	dupe_mode = COMPONENT_DUPE_HIGHLANDER
	can_transfer = TRUE

	/// Contains all of the behaviors
	var/datum/construction_template/template

/datum/component/construction/Initialize(template_type)
	if(QDELETED(parent) || !isobj(parent) || !ispath(template_type, /datum/construction_template))
		return COMPONENT_INCOMPATIBLE

	template = new template_type(src, parent)

/datum/component/construction/RegisterWithParent()
	RegisterSignal(parent, COMSIG_OBJ_DECONSTRUCT, PROC_REF(parent_deconstructed))
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND_SECONDARY, PROC_REF(parent_attack_hand_secondary))
	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, PROC_REF(parent_attackby))
	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY_SECONDARY, PROC_REF(parent_attackby_secondary))

/datum/component/construction/UnregisterFromParent()
	template.parent = null

	UnregisterSignal(
		parent,
		list(
			COMSIG_OBJ_DECONSTRUCT,
			COMSIG_ATOM_ATTACK_HAND_SECONDARY,
			COMSIG_PARENT_ATTACKBY,
			COMSIG_PARENT_ATTACKBY_SECONDARY,
		)
	)

/datum/component/construction/Destroy(force, silent)
	QDEL_NULL(template)
	return ..()

// Parent sets this to COMPONENT_INCOMPATIBLE for some reason, so we need to not do that.
/datum/component/construction/TransferComponent()
	if(QDELETED(parent) || !isobj(parent))
		return COMPONENT_INCOMPATIBLE

	template.parent = parent

/datum/component/construction/proc/parent_deconstructed(datum/source, disassembled)
	SIGNAL_HANDLER

	if(disassembled)
		template.fully_deconstruct()

/datum/component/construction/proc/parent_attack_hand_secondary(datum/source, mob/user)
	SIGNAL_HANDLER
	if(template.interact_with(user, null, TRUE))
		return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/component/construction/proc/parent_attackby(datum/source, obj/item/I, mob/living/user)
	SIGNAL_HANDLER
	if(template.interact_with(user, I, FALSE))
		return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/component/construction/proc/parent_attackby_secondary(datum/source, obj/item/I, mob/living/user)
	SIGNAL_HANDLER
	if(template.interact_with(user, I, TRUE))
		return COMPONENT_CANCEL_ATTACK_CHAIN
