/datum/construction/proc/parent_deconstructed(datum/source, disassembled)
	SIGNAL_HANDLER

	if(disassembled)
		fully_deconstruct()

/datum/construction/proc/parent_attack_hand_secondary(datum/source, mob/user)
	SIGNAL_HANDLER
	if(interact_with(user, null, TRUE))
		return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/construction/proc/parent_attackby(datum/source, obj/item/I, mob/living/user)
	SIGNAL_HANDLER
	if(interact_with(user, I, FALSE))
		return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/construction/proc/parent_attackby_secondary(datum/source, obj/item/I, mob/living/user)
	SIGNAL_HANDLER
	if(interact_with(user, I, TRUE))
		return COMPONENT_CANCEL_ATTACK_CHAIN
