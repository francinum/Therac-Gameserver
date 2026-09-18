#define SS13LIB_EXTERNAL_CONFIGURATION
#define SS13LIB_EXTERNAL_INIT
#define SS13LIB_EXTERNAL_HEARTBEAT

#define SS13LIB_PLAYER_COUNT length(GLOB.player_list)

#define SS13LIB_SERVER_DISPLAY_NAME CONFIG_GET(string/servername)

#define SS13LIB_SERVER_LANGUAGE CONFIG_GET(string/ss13lib_language)

#define SS13LIB_SERVER_DESCRIPTION CONFIG_GET(string/ss13_hub_description)

#define SS13LIB_SERVER_LINKS (world.__ss13lib_build_server_links())

/world/proc/__ss13lib_build_server_links()
	var/list/links = list()

	var/link_check = CONFIG_GET(string/ss13hub_landingsite)
	if(link_check)
		links[++links.len] = list("type" = "web", "link" = link_check)

	link_check = CONFIG_GET(string/wikiurl)
	if(link_check)
		links[++links.len] = list("type" = "wiki", "link" = link_check)

	link_check = CONFIG_GET(string/forumurl)
	if(link_check)
		links[++links.len] = list("type" = "forum", "link" = link_check)

	link_check = CONFIG_GET(string/githuburl)
	if(link_check)
		links[++links.len] = list("type" = "github", "link" = link_check)

	link_check = CONFIG_GET(string/panic_bunker_discord_link)
	if(link_check)
		links[++links.len] = list("type" = "discord", "link" = link_check)

	return links

#define SS13LIB_WHITELISTED (world.__ss13lib_build_whitelisted())

#warn INCOMPLETE WHITELIST SETUP
/world/proc/__ss13lib_build_whitelisted()
	if(CONFIG_GET(flag/ss13hub_whitelisted))
		return list("link" = list("type" = "discord", "link" = "https://discord.gg/invite/example"), "description" = CONFIG_GET(string/ss13hub_whitelist_info))

#define SS13LIB_TERMS_OF_SERVICE CONFIG_GET(string/ss13hub_terms_of_service)

#define SS13LIB_PLAYER_LIMIT CONFIG_GET(number/soft_popcap)

#define SS13LIB_REGION CONFIG_GET(string/ss13lib_region)

#define SS13LIB_SERVER_TAGS CONFIG_GET(str_list/server_tags)

#define SS13LIB_HUB_VISIBILITY (world.visibility)

#define SS13LIB_AUTH_METHODS list("hub", "byond")
#warn INCOMPLETE AUTH METHODS

#ifdef OPENDREAM
#define SS13LIB_ENGINE "opendream"
#else
#define SS13LIB_ENGINE "byond"
#endif

#define SS13LIB_CONNECTION_ADDRESS CONFIG_GET(string/override_connection_url)


#define SS13LIB_ENGINE_MIN_VERSION ("[CONFIG_GET(number/client_error_version)].[CONFIG_GET(number/client_error_build)]")

//#define SS13LIB_ENGINE_MAX_VERSION

// We currently have no bad builds that are new enough to care about this.
//#define SS13LIB_ENGINE_BLACKLISTED_VERSIONS

#define SS13LIB_ROUND_MAP_NAME (SSmapping?.config?.map_name || "LOADING")

#define SS13LIB_ROUND_STARTED_AT_UNIX (SSticker?.round_start_unix)

#define SS13LIB_ROUND_SECURITY_LEVEL (get_security_level())

#define SS13LIB_ROUND_GAMEMODE (SSticker?.mode_display_name || SSticker?.mode?.name || "LOADING")

#define SS13LIB_ROUND_ID (GLOB.round_id)

#define SS13LIB_ROUND_STATE (world.__ss13lib_map_game_state())

/// Map SSticker state values to SS13Hub round state values.
/world/proc/__ss13lib_map_game_state()
	switch(SSticker?.current_state)
		if(null,GAME_STATE_STARTUP)
			return "initializing"
		if(GAME_STATE_PREGAME)
			return "lobby"
		if(GAME_STATE_SETTING_UP,GAME_STATE_PLAYING)
			return "playing"
		if(GAME_STATE_FINISHED)
			return "finished"

#define SS13LIB_INFO_LOG(message) log_world("SS13Lib Info: [##message]")
#define SS13LIB_WARNING_LOG(message) log_world("SS13Lib Warn: [##message]")
#define SS13LIB_ERROR_LOG(message) log_world("SS13Lib Error: [##message]")

#define SS13LIB_MESSAGE_ADMINS(X) message_admins("HUB ALERT: [X]")

#define SS13LIB_CLIENT_INFO(X) X.hub_info

// This currently fails loudly if no domain is provided.
//#define SS13LIB_ATTEST_DOMAIN

// Need to update rustg first.
//#define SS13LIB_ED25519_SIGN(privkey, message)

#define SS13LIB_ATTEST_PRIVKEY CONFIG_GET(string/da_private_key)

#define SS13LIB_UNIX_EPOCH rustg_unix_timestamp()

//This *SHOULD* cover everything, but I've filed for this to be made a proper hook
GENERAL_PROTECT_DATUM(/datum/ss13lib)
