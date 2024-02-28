/// This should match the interface of /client wherever necessary.
/datum/client_interface
	/// The mob this client belongs to
	var/mob/mob
	var/ckey
	var/key
	/// Player preferences datum for the client
	var/datum/preferences/prefs

	/// The view of the client, similar to /client/var/view.
	var/view = "15x15"

/datum/client_interface/proc/transfer_to(mob/M)
	M.mock_client = src
	mob = M

/datum/client_interface/proc/IsByondMember()
	return FALSE

/datum/client_interface/proc/set_macros()
	return
