/*
 *
 * Mercifully, much simplified from P2P ones, since state information is distributed
 * throughout the exchange fabric
 *
 * https://file.house/9Jfm.png
 *
 */

/obj/machinery/telephone
	name = "phone - UNINITIALIZED"
	desc = "It's a phone. You pick it up, select from the list of other phones, and scream at the other person. The voice quality isn't all that great."
	icon = 'goon/icons/obj/phones.dmi'
	icon_state = "phone"

	net_class = NETCLASS_P2P_PHONE
	network_flags = NETWORK_FLAGS_STANDARD_CONNECTION

	/// The 'common name' of the station. Used for caller ID.
	var/friendly_name = null
	/// Name 'placard', such as 'Special Hotline', gets appended to the end.
	var/placard_name

	/// Network ID of our exchange,
	var/exchange_netid
