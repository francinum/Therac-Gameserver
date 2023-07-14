//Procedures in this file: internal organ surgery, removal, transplants
//////////////////////////////////////////////////////////////////
//						INTERNAL ORGANS							//
//////////////////////////////////////////////////////////////////
/datum/surgery_step/internal
	can_infect = 1
	blood_level = 1
	shock_level = 40
	delicate = 1
	surgery_candidate_flags = SURGERY_NO_ROBOTIC | SURGERY_NO_STUMP | SURGERY_NEEDS_DEENCASEMENT
	abstract_type = /datum/surgery_step/internal

//////////////////////////////////////////////////////////////////
//	Organ mending surgery step
//////////////////////////////////////////////////////////////////
/datum/surgery_step/internal/fix_organ
	name = "Repair internal organ"
	allowed_tools = list(
		/obj/item/stack/medical/bruise_pack = 100,
		/obj/item/stack/sticky_tape = 20
	)
	min_duration = 70
	max_duration = 90
	surgery_candidate_flags =  SURGERY_NO_ROBOTIC | SURGERY_NO_STUMP

/datum/surgery_step/internal/fix_organ/assess_bodypart(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/affected = ..()
	if(!affected)
		return

	for(var/obj/item/organ/I in affected.contained_organs)
		if(I.damage > 0)
			return TRUE

/datum/surgery_step/internal/fix_organ/pre_surgery_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/list/organs = list()
	var/obj/item/bodypart/affected = target.get_bodypart(target_zone)
	for(var/obj/item/organ/I in affected.contained_organs)
		if(I.damage > 0)
			organs[I.name] = I.slot

	var/organ_to_replace = input(user, "Which organ do you want to reattach?") as null|anything in organs
	if(organ_to_replace)
		return list(organ_to_replace, organs[organ_to_replace])

/datum/surgery_step/internal/fix_organ/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/tool_name = "\the [tool]"
	if (istype(tool, /obj/item/stack/medical/bruise_pack))
		tool_name = "the bandaid"

	user.visible_message(span_notice("[user] starts treating damage to [target]'s [(LAZYACCESS(target.surgeries_in_progress, target_zone))[1]] with [tool_name]."))
	..()

/datum/surgery_step/internal/fix_organ/succeed_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/tool_name = "\the [tool]"
	if (istype(tool, /obj/item/stack/medical/bruise_pack))
		tool_name = "the bandaid"

	var/obj/item/organ/O = target.getorganslot((LAZYACCESS(target.surgeries_in_progress, target_zone))[2])
	if(!O)
		return
	O.applyOrganDamage(-O.damage)
	user.visible_message(span_notice("[user] finishes treating damage to [target]'s [(LAZYACCESS(target.surgeries_in_progress, target_zone))[1]] with [tool_name]."))

/datum/surgery_step/internal/fix_organ/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/affected = target.get_bodypart(target_zone)
	user.visible_message(span_warning("[user]'s hand slips, getting mess and tearing the inside of [target]'s [affected.name] with \the [tool]!"))
	var/dam_amt = 2

	dam_amt = 5
	target.adjustToxLoss(10)
	affected.receive_damage(dam_amt, sharpness = SHARP_EDGED|SHARP_POINTY)

	for(var/obj/item/organ/I in affected.contained_organs)
		if(I.damage > 0 && !(I.status & ORGAN_ROBOTIC) && (affected.how_open() >= (affected.encased ? SURGERY_DEENCASED : SURGERY_RETRACTED)))
			I.applyOrganDamage(dam_amt)

//////////////////////////////////////////////////////////////////
//	 Organ detatchment surgery step
//////////////////////////////////////////////////////////////////
/datum/surgery_step/internal/detach_organ
	name = "Detach organ"
	allowed_tools = list(
		TOOL_SCALPEL = 100,
		/obj/item/shard = 50
	)
	min_duration = 90
	max_duration = 110
	surgery_candidate_flags = SURGERY_NO_ROBOTIC | SURGERY_NO_STUMP | SURGERY_NEEDS_DEENCASEMENT

/datum/surgery_step/internal/detach_organ/pre_surgery_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/affected = target.get_bodypart(target_zone)
	var/list/attached_organs = list()

	for(var/obj/item/organ/I in affected.contained_organs)
		if(!(I.status & ORGAN_ROBOTIC))
			attached_organs[I.name] = I.slot

	if(!length(attached_organs))
		to_chat(user, span_warning("There are no appropriate internal components to decouple."))
		return FALSE

	var/organ_to_remove = input(user, "Which organ do you want to prepare for removal?") as null|anything in attached_organs
	if(organ_to_remove)
		return list(organ_to_remove,attached_organs[organ_to_remove])

/datum/surgery_step/internal/detach_organ/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message(span_notice("[user] starts to separate [target]'s [(LAZYACCESS(target.surgeries_in_progress, target_zone))[1]] with [tool]."))
	..()

/datum/surgery_step/internal/detach_organ/succeed_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message(span_notice("[user] has separated [target]'s [(LAZYACCESS(target.surgeries_in_progress, target_zone))[1]] with [tool]."))

	var/obj/item/organ/I = target.getorganslot((LAZYACCESS(target.surgeries_in_progress, target_zone))[2])
	if(istype(I))
		I.cut_away()

/datum/surgery_step/internal/detatch_organ/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/affected = target.get_bodypart(target_zone)
	if(affected.check_artery() & CHECKARTERY_OK)
		user.visible_message(span_warning("[user]'s hand slips, slicing an artery inside [target]'s [affected.plaintext_zone] with \the [tool]!"))
		affected.set_sever_artery(TRUE)
		affected.receive_damage(rand(10,15), sharpness = SHARP_EDGED|SHARP_POINTY)
	else
		user.visible_message(span_warning("[user]'s hand slips, slicing up inside [target]'s [affected.plaintext_zone] with \the [tool]!"))
		affected.receive_damage(rand(15, 25), sharpness = SHARP_EDGED|SHARP_POINTY)

//////////////////////////////////////////////////////////////////
//	 Organ removal surgery step
//////////////////////////////////////////////////////////////////
/datum/surgery_step/internal/remove_organ
	name = "Remove internal organ"
	allowed_tools = list(
		TOOL_HEMOSTAT = 100,
		/obj/item/wirecutters = 75,
		/obj/item/knife = 75,
		/obj/item/kitchen/fork = 20
	)
	min_duration = 60
	max_duration = 80

/datum/surgery_step/internal/remove_organ/pre_surgery_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/list/removable_organs = list()
	var/obj/item/bodypart/affected = target.get_bodypart(target_zone)
	for(var/obj/item/organ/I in affected.cavity_items)
		if (I.organ_flags & ORGAN_CUT_AWAY)
			removable_organs[I.name] = REF(I)

	if(!length(removable_organs))
		to_chat(user, span_warning("You cannot find any organs to remove."))
		return

	var/organ_to_remove= input(user, "Which organ do you want to remove?") as null|anything in removable_organs
	if(organ_to_remove)
		return list(organ_to_remove, removable_organs[organ_to_remove])

/datum/surgery_step/internal/remove_organ/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message(span_notice("\The [user] starts removing [target]'s [LAZYACCESS(target.surgeries_in_progress, target_zone)[1]] with \the [tool]."))
	..()

/datum/surgery_step/internal/remove_organ/succeed_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/affected = target.get_bodypart(target_zone)
	var/obj/item/organ/O = locate((LAZYACCESS(target.surgeries_in_progress, target_zone))[2]) in affected.cavity_items
	if(!O)
		return

	user.visible_message(span_notice("[user] has removed [target]'s [O.name] with [tool]."))

	if(istype(O) && istype(affected))
		affected.remove_cavity_item(O)
		if(!user.put_in_hands(O))
			O.forceMove(target.drop_location())

		if(IS_ORGANIC_LIMB(affected))
			playsound(target.loc, 'sound/effects/squelch1.ogg', 15, 1)
		else
			playsound(target.loc, 'sound/items/Ratchet.ogg', 50, 1)

/datum/surgery_step/internal/remove_organ/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/affected = target.get_bodypart(target_zone)
	user.visible_message(span_warning("[user]'s hand slips, damaging [target]'s [affected.plaintext_zone] with [tool]!"))
	affected.receive_damage(20, sharpness = tool.sharpness)

//////////////////////////////////////////////////////////////////
//	 Organ inserting surgery step
//////////////////////////////////////////////////////////////////
/datum/surgery_step/internal/replace_organ
	name = "Replace internal organ"
	allowed_tools = list(
		/obj/item/organ = 100
	)
	min_duration = 60
	max_duration = 80
	var/robotic_surgery = FALSE

/datum/surgery_step/internal/replace_organ/pre_surgery_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	. = FALSE
	var/obj/item/organ/O = tool
	var/obj/item/bodypart/affected = target.get_bodypart(target_zone)

	if(istype(O) && istype(affected))
		var/o_is = (O.gender == PLURAL) ? "are" : "is"
		var/o_a =  (O.gender == PLURAL) ? "" : "a "
		if(O.w_class > affected.cavity_storage_max_weight)
			to_chat(user, span_warning("\The [O.name] [o_is] too big for [affected.cavity_name] cavity!"))
		else
			var/obj/item/organ/I = target.getorganslot(O.slot)
			if(I)
				to_chat(user, span_warning("\The [target] already has [o_a][O.name]."))
			else
				. = TRUE

/datum/surgery_step/internal/replace_organ/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/affected = target.get_bodypart(target_zone)
	user.visible_message(span_notice("[user] starts [robotic_surgery ? "reinstalling" : "transplanting"] [tool] into [target]'s [affected.plaintext_zone]."))
	..()

/datum/surgery_step/internal/replace_organ/succeed_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/affected = target.get_bodypart(target_zone)
	user.visible_message(span_notice("\The [user] has [robotic_surgery ? "reinstalled" : "transplanted"] [tool] into [target]'s [affected.plaintext_zone]."))

	var/obj/item/organ/O = tool
	if(istype(O) && user.temporarilyRemoveItemFromInventory(O, target))
		affected.add_cavity_item(O) //move the organ into the patient. The organ is properly reattached in the next step

		if(!(O.status & ORGAN_CUT_AWAY))
			stack_trace("[user] ([user.ckey]) replaced organ [O.type], which didn't have ORGAN_CUT_AWAY set, in [target] ([target.ckey])")
			O.status |= ORGAN_CUT_AWAY

		playsound(target.loc, 'sound/effects/squelch1.ogg', 15, 1)

/datum/surgery_step/internal/replace_organ/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message(span_warning("[user]'s hand slips, damaging \the [tool]!"))
	var/obj/item/organ/I = tool
	if(istype(I))
		I.applyOrganDamage(rand(3,5))



//////////////////////////////////////////////////////////////////
//	 Organ attachment surgery step
//////////////////////////////////////////////////////////////////
/datum/surgery_step/internal/attach_organ
	name = "Attach internal organ"
	allowed_tools = list(
		/obj/item/fixovein = 100,
		/obj/item/stack/cable_coil = 75,
		/obj/item/stack/sticky_tape = 50
	)
	min_duration = 100
	max_duration = 120
	surgery_candidate_flags = SURGERY_NO_ROBOTIC | SURGERY_NO_STUMP | SURGERY_NEEDS_DEENCASEMENT

/datum/surgery_step/internal/attach_organ/pre_surgery_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

	var/list/attachable_organs = list()
	var/obj/item/bodypart/affected = target.get_bodypart(target_zone)
	var/obj/item/organ/O
	for(var/obj/item/organ/I in affected.cavity_items)
		if((I.organ_flags & ORGAN_CUT_AWAY))
			attachable_organs[I.name] = REF(I)

	if(!length(attachable_organs))
		return FALSE

	var/obj/item/organ/organ_to_replace = input(user, "Which organ do you want to reattach?") as null|anything in attachable_organs
	if(!organ_to_replace)
		return FALSE

	organ_to_replace = locate(attachable_organs[organ_to_replace]) in affected.cavity_items

	if((deprecise_zone(organ_to_replace.zone) != affected.body_zone))
		to_chat(user, span_warning("You can't find anywhere to attach \the [organ_to_replace] to!"))
		return FALSE

	O = locate(attachable_organs[organ_to_replace]) in affected.cavity_items
	if(O)
		to_chat(user, span_warning("\The [target] already has \a [O]."))
		return FALSE
	return list(organ_to_replace, attachable_organs[organ_to_replace])

/datum/surgery_step/internal/attach_organ/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message(span_warning("[user] begins reattaching [target]'s [LAZYACCESS(target.surgeries_in_progress, target_zone)[1]] with \the [tool]."))
	..()

/datum/surgery_step/internal/attach_organ/succeed_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/affected = target.get_bodypart(target_zone)
	var/obj/item/organ/I = locate(LAZYACCESS(target.surgeries_in_progress, target_zone)[2]) in affected.cavity_items
	if(!I)
		return

	user.visible_message(span_notice("[user] has reattached [target]'s [LAZYACCESS(target.surgeries_in_progress, target_zone)[1]] with [tool]."))

	if(istype(I) && affected && deprecise_zone(I.zone) == affected.body_zone && (I in affected.cavity_items))
		I.status &= ~ORGAN_CUT_AWAY //apply fixovein
		affected.remove_cavity_item(I)
		I.Insert(target)

/datum/surgery_step/internal/attach_organ/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/affected = target.get_bodypart(target_zone)
	user.visible_message(span_warning("[user]'s hand slips, damaging the flesh in [target]'s [affected.plaintext_zone] with [tool]!"))
