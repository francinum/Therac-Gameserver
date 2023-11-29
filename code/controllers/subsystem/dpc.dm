SUBSYSTEM_DEF(dpc)
	name = "Delayed Proc Call"

	flags = SS_NO_INIT|SS_TICKER|SS_HIBERNATE
	runlevels = ALL
	wait = 1

	var/list/datum/callback/queue = list()

/datum/controller/subsystem/dpc/PreInit()
	. = ..()
	hibernate_checks = list(
		NAMEOF(src, queue),
	)


/datum/controller/subsystem/dpc/fire(resumed)
	var/index = 1
	while(index <= length(currentrun))
		var/datum/callback/callback = currentrun[index]
		index++
		queue -= callback

		callback.InvokeAsync()

		if (MC_TICK_CHECK)
			break

	if(index > 1)
		queue.Cut(1, index)
