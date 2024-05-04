/**
 * Bare TGUI UI Holder. Allows classical HTML-style UIs to benefit from TGUI's infrastructure.
 */
/datum/tgui/html

	/// Assets to load at window creation.
	var/list/datum/asset/load_assets
	/// File handle to the HTML file holding the UI to load.
	/// Can be either a string or (ideally) a file on disk referencing the interface.
	var/load_template

/datum/tgui/html/New(mob/user, datum/src_object, load_template, initial_assets, title)
	log_tgui(user,
		"new / type:html",
		src_object = src_object)
	src.user = user
	src.src_object = src_object
	src.load_template = load_template
	//If they specify no custom assets, load the common CSS.
	if(!initial_assets)
		src.load_assets = list(get_asset_datum(/datum/asset/simple/namespaced/common))
	if(title)
		src.title = title
	src.state = src_object.ui_state(user)


// /datum/tgui/html/get_payload(custom_data, with_data, with_static_data)
// 	. = ..()

#warn NOTE: Basic API requires support for pings, as implimented in /datum/tgui/process

/datum/tgui/html/open()
	if(!user.client)
		return FALSE
	if(window)
		return FALSE
	process_status()
	if(status < UI_UPDATE)
		return FALSE
	window = new(user.client, "[REF(user)]-[REF(src_object)]")
	if(!window)
		return FALSE
	opened_at = world.time
	window.acquire_lock(src)
	if(!window.is_ready())
		if(!rustg_file_exists(load_template))
			CRASH("HTML TGUI Attempted to load nonexistent file: [load_template || "null"]")
		window.initialize(
			strict_mode = TRUE,
			fancy = FALSE,
			extended_api = TRUE,
			assets = load_assets,
			inline_html = rustg_file_read(load_template))
	else
		window.send_message("ping")

/**
 * private
 *
 * Callback for handling incoming tgui messages.
 *
 * ..() == TRUE means that a ui_act message has been passed to the source object.
 *
 */
/datum/tgui/html/on_message(type, list/payload, list/href_list)
	if(!..())
		return
	switch(type)

		if("ready")
			// Send a full update when the user manually refreshes the UI
			if(initialized)
				send_full_update()
			initialized = TRUE
		if("ping/reply")
			initialized = TRUE
		if("close")
			close(can_be_suspended = FALSE)
