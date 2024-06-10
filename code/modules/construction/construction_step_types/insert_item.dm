/datum/construction_step/insert_item
	name = "BAD STEP: INSERT_ITEM"

	/// A reference to the item used
	var/obj/item/used_item
	/// A typecache of valid item paths
	var/list/accepted_types
	/// An optional blacklist of item paths
	var/list/blacklisted_types

	/// Optional default path for default_state()
	var/default_item_path

/datum/construction_step/insert_item/New()
	. = ..()
	var/static/list/typecache_cache = list()
	var/static/list/blacklist_cache = list()

	if(typecache_cache[type])
		accepted_types = typecache_cache[type]
	else
		accepted_types = typecacheof(accepted_types)
		typecache_cache[type] = accepted_types

	if(blacklisted_types)
		if(blacklist_cache[type])
			blacklisted_types = typecache_cache[type]
		else
			blacklisted_types = typecacheof(blacklisted_types)
			blacklist_cache[type] = blacklisted_types

/datum/construction_step/insert_item/Destroy(force, ...)
	. = ..()
	if(. == QDEL_HINT_LETMELIVE)
		return

	set_used_item(null)

/datum/construction_step/insert_item/default_state()
	if(!ispath(default_item_path))
		CRASH("Construction step [type] has no default item path!")

	set_used_item(new default_item_path)

/datum/construction_step/insert_item/can_do_action(mob/living/user, obj/item/I, deconstructing)
	. = ..()
	if(!.)
		return

	if(isnull(I)) // attack_hand
		return complete && deconstructing

	if(!accepted_types[I.type])
		return FALSE

	if(blacklisted_types?[I.type])
		return FALSE

	if(!user.canUnequipItem(I))
		return FALSE

	return TRUE

/datum/construction_step/insert_item/attempt_action(mob/living/user, obj/item/I)
	if(!complete)
		if(!user.temporarilyRemoveItemFromInventory(I))
			return STEP_FAIL

		complete = SEQUENCE_FINISHED
		set_used_item(I)
		provide_feedback(user, I)
		return STEP_FORWARD

	else
		var/used_item = src.used_item
		deconstruct(user)
		provide_feedback(user, used_item)
		return STEP_BACKWARD

/datum/construction_step/insert_item/deconstruct(mob/living/user)
	. = ..()
	if(user?.put_in_hands(used_item))
		used_item = null
		return

	used_item.forceMove(parent_template.parent.drop_location())

/datum/construction_step/insert_item/proc/set_used_item(obj/item/new_item)
	if(isnull(new_item))
		parent_template?.contained_items -= new_item
		used_item = null
		return

	used_item = new_item
	parent_template.contained_items += used_item
	used_item.moveToNullspace()

//* STACKS!! *//
/datum/construction_step/insert_item/stack
	var/amount_to_use = 0

/datum/construction_step/insert_item/stack/can_do_action(mob/living/user, obj/item/I, deconstructing)
	. = ..()
	if(!.)
		return

	if(!complete && !I.can_use(amount_to_use))
		return FALSE

/datum/construction_step/insert_item/stack/attempt_action(mob/living/user, obj/item/I)
	if(!complete)
		var/obj/item/stack/S = I
		I = S.split_stack(user, amount_to_use, null)
		complete = SEQUENCE_FINISHED
		set_used_item(I)
		provide_feedback(user, I)
		return STEP_FORWARD

	else
		var/used_item = src.used_item
		deconstruct(user)
		provide_feedback(user, used_item)
		return STEP_BACKWARD

/datum/construction_step/insert_item/stack/parse_text(text, mob/living/user, obj/item/I)
	var/obj/item/stack/S = I

	var/the_user = "[user]"
	var/the_item = amount_to_use == 1 ? "\the [S.singular_name]" : "\the [S]"
	var/the_object = "\the [parent_template.parent]"

	text = replacetext(text, "$USER$", the_user)
	text = replacetext(text, "$ITEM$", the_item)
	text = replacetext(text, "$OBJECT$", the_object)
	return text
