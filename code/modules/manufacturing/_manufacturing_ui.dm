/obj/machinery/manufacturing/ui_interact(mob/user, datum/tgui/ui)
	user.set_machine(src)

	var/datum/browser/popup = new(user, "manufacturing[ref(src)]", name, 460, 260)
	popup.set_content(jointext(ui_content(), ""))
	popup.open()

/// Returns the ui's body html.
/obj/machinery/manufacturing/proc/ui_content()
	PRIVATE_PROC(TRUE)
	. = list()
	var/operating_state
	var/state_color
	switch(src.operating_state)
		if(M_IDLE)
			operating_state = "IDLE"
			state_color = COLOR_WHITE
		if(M_WORKING)
			operating_state = "RUN"
			state_color = COLOR_LIME
		else
			operating_state = "ERR"
			state_color = COLOR_WHITE

	. += {"
	<div style='width:100%;height: 100%'>
		<fieldset class='computerPane' style='height: 100%'>
			<legend class='computerLegend'>
				<b>[ui_name]</b>
			</legend>

			<div class='computerLegend flexColumn' style='margin: auto; width:70%; height: 70px; justify-content: center'>
				<span class='computerText flexItem' style='font-size: 2.3em'>
					STATUS: <span style='color: [state_color]; text-shadow: 0 0 0.417em [state_color];'>[operating_state]</color>
				</span>
			</div>

			<div class='flexColumn' style='width: 100%; justify-content: center; padding-top: 20px; align-items: center;'>
				<div class='highlighterRed' style='width: 2em;border: 4px ridge #000000; background-color: #752d2d; text-align: center; cursor: pointer; width: 50%; height: 3.5em;'>
					<div class='flexColumn' style='width: 100%; height: 100%; justify-content: center; align-items: center;'>
						<div style='font-size: 3em' onClick=[onclick_callback(src, "restart=1")]>
							<b>RESTART</b>
						</div>
					</div>
				</div>
			</div>

		</fieldset>
	</div>
	"}
