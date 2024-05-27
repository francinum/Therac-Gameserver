/obj/machinery/manufacturing/ui_interact(mob/user, datum/tgui/ui)
	user.set_machine(src)

	var/datum/browser/popup = new(user, "manufacturing[ref(src)]", name, 460, 280)
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

	var/datum/slapcraft_recipe/loaded_recipe = inserted_disk?.read(DATA_IDX_MANU_TEMPLATE)?[1]

	. += {"
	<div style='width:100%;height: 100%'>
		<fieldset class='computerPane' style='height: 100%'>
			<legend class='computerLegend'>
				<b>[ui_name]</b>
			</legend>

			<div class='computerLegend flexColumn' style='margin: auto; width:70%; height: 5.5em; justify-content: center'>
				<div class='flexRow' style='font-size: 2.5em;padding-bottom: 20px'>
					<div class='computerText flexItem' style='width:50%'>
						STATUS:
					</div>
					<div class= 'computerText flexItem' style='width:50%; color: [state_color]; text-shadow: 0 0 0.417em [state_color];'>
						[operating_state]
					</div>
				</div>

				<div class='flexRow' style='font-size: 1.5em'>
					<div class='computerText flexItem' style='width: 100%;word-wrap: break-word;'>
						[loaded_recipe?.name || "NO DESIGN"]
					</div>
				</div>
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
