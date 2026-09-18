/// if the game appears on the hub or not
/datum/config_entry/flag/hub

/datum/config_entry/keyed_list/hub_auth_type
	key_mode = KEY_MODE_TEXT
	value_mode = VALUE_MODE_FLAG
	protection = CONFIG_ENTRY_LOCKED

/// BYOND Hub subtitle
/datum/config_entry/string/legacy_hub_subtitle

/// SS13Lib Hub description
/datum/config_entry/string/ss13_hub_description

/datum/config_entry/string/ss13hub_landingsite
	protection = CONFIG_ENTRY_LOCKED

/datum/config_entry/flag/ss13hub_whitelisted
	protection = CONFIG_ENTRY_LOCKED

/datum/config_entry/keyed_list/ss13hub_whitelist_link
	key_mode = KEY_MODE_TEXT
	value_mode = VALUE_MODE_TEXT
	protection = CONFIG_ENTRY_LOCKED

/datum/config_entry/string/ss13hub_whitelist_info
	protection = CONFIG_ENTRY_LOCKED

/datum/config_entry/string/ss13hub_terms_of_service
	protection = CONFIG_ENTRY_LOCKED

/// SS13Lib hub language
/datum/config_entry/string/ss13lib_language
	default = "en"
	lowercase = TRUE
	protection = CONFIG_ENTRY_LOCKED

/datum/config_entry/string/ss13lib_language/ValidateAndSet(str_val)
	if(length(str_val) != 2)
		return FALSE
	. = ..()

/// SS13Lib region code
/datum/config_entry/string/ss13lib_region
	protection = CONFIG_ENTRY_LOCKED

/datum/config_entry/str_list/server_tags
	protection = CONFIG_ENTRY_LOCKED

/// Override connection address
/datum/config_entry/string/override_connection_url
	protection = CONFIG_ENTRY_LOCKED

/datum/config_entry/string/da_private_key
	protection = CONFIG_ENTRY_HIDDEN
