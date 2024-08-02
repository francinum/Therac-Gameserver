//* STACKS!! *//
/datum/construction_step/insert_item/stack
	var/amount_to_use = 1

/datum/construction_step/insert_item/stack/can_do_action(mob/living/user, obj/item/I, deconstructing)
	. = ..()
	if(!.)
		return

	if((complete != SEQUENCE_FINISHED) && !I.can_use(amount_to_use))
		return FALSE

/datum/construction_step/insert_item/stack/attempt_action(mob/living/user, obj/item/I)
	if(complete != SEQUENCE_FINISHED)
		var/obj/item/stack/S = I
		S = S.split_stack(user, amount_to_use, null)
		complete = SEQUENCE_FINISHED
		set_used_item(S)
		provide_feedback(user, S)
		return STEP_FORWARD

	else
		var/used_item = src.used_item
		deconstruct(user)
		provide_feedback(user, used_item)
		return STEP_BACKWARD

/datum/construction_step/insert_item/stack/create_default_item()
	var/obj/item/stack/S = new default_item_path
	S.amount = amount_to_use
	return S

/datum/construction_step/insert_item/stack/parse_text(text, mob/living/user, obj/item/I)
	var/obj/item/stack/S = I

	var/the_user = "[user]"
	var/the_item = amount_to_use == 1 ? "\the [S.singular_name]" : "\the [S]"
	var/the_object = "\the [parent_template.parent]"

	text = replacetext(text, "$USER$", the_user)
	text = replacetext(text, "$ITEM$", the_item)
	text = replacetext(text, "$OBJECT$", the_object)
	return text

/// Use 1 iron sheet
/datum/construction_step/insert_item/stack/iron_sheet
	name = "Attach sheet"
	decon_name = "Remove sheet"
	accepted_types = list(/obj/item/stack/sheet/iron)
	amount_to_use = 1
	feedback_construct = "$USER$ puts $ITEM$ onto $OBJECT$, for some reason."
	feedback_deconstruct = "$USER$ removes $ITEM$ from $OBJECT$."

	default_item_path = /obj/item/stack/sheet/iron

/// Use 1 cable
/datum/construction_step/insert_item/stack/wires
	name = "Insert Wires"
	decon_name = "Remove Wires"
	feedback_construct = "$USER$ places wires into $OBJECT$."
	feedback_deconstruct = "$USER$ removes wires from $OBJECT$."

	accepted_types = list(/obj/item/stack/cable_coil)
	amount_to_use = 1

	default_item_path = /obj/item/stack/cable_coil

/// Use 1 nut
/datum/construction_step/insert_item/stack/nuts
	name = "Place Nuts"
	decon_name = "Remove Nuts"
	accepted_types = list(/obj/item/stack/fastener/nuts)
	amount_to_use = 1
	feedback_construct = "$USER$ sets $ITEM$ into $OBJECT$."
	feedback_deconstruct = "$USER$ removes $ITEM$ from $OBJECT$."

	default_item_path = /obj/item/stack/fastener/nuts

/// Use 1 bolt
/datum/construction_step/insert_item/stack/bolts
	name = "Place Bolts"
	decon_name = "Remove Bolts"
	accepted_types = list(/obj/item/stack/fastener/bolts)
	amount_to_use = 1
	feedback_construct = "$USER$ sets $ITEM$ into $OBJECT$."
	feedback_deconstruct = "$USER$ removes $ITEM$ from $OBJECT$."

	default_item_path = /obj/item/stack/fastener/bolts
