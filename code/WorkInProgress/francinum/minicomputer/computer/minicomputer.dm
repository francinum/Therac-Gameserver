/obj/machinery/minicomputer
	name = "Ananke DataMaster 4000"
	desc = "A top of the line general purpose minicomputer"
	icon_state = "blackcube"

	/// Current foreground program for the console, gets sent input from the UI by default.
	var/miniprocess/foreground_program
	/// List of all running processes
	var/list/miniprocess/all_processes
	/// List of all 'installed' hardware (fixed, expansion, peripheral)
	var/list/obj/item/minicomputer_hardware/all_hardware
	/// List of 25 80 character strings, used to display the screen. Drawn top-down, Line 25 is usually reserved.
	var/list/screenbuffer

/obj/machinery/minicomputer/Initialize(mapload)
	. = ..()
	var/list/tmplist[25]
	screenbuffer = tmplist
	var/i = screenbuffer.len
	while(i)
		screenbuffer[i--] = ""

/obj/machinery/minicomputer/ui_interact(mob/user, datum/tgui/ui)
	//Fuck TGUI you're getting raw HTML and you'll fucking L I K E I T
	//This uses ref incase someone tries to multi-computer drift
	var/datum/browser/popup = new(usr, REF(src))
	popup.width = 670
	popup.height = 600
	popup.window_options = "can_close=1;can_minimize=1;can_maximize=0;can_resize=0;titlebar=1;"
	//Generate the text output
	var/textfield_out = "<div class='statusDisplay' style='color:#ffb000;width:90%;margin-left:auto;margin-right:auto;font-family: monospace;'>[jointext(screenbuffer, "<br>")]</div>"
	var/const/divider = "<hr>"
	var/inputline = {"
	<form name='console_input' action='byond://?src=\ref[src]' method='GET'>
		<input type="hidden" name="src" value="\ref[src]">
		<input name='commandline' style='width:85%;margin-left:auto;margin-right:auto;'>
		<input type='submit' value='Enter' style='width:10%;margin-left:auto;margin-right:auto;'>
	</form>
	"}
	var/peripheral_block = {""}
	popup.add_content("[textfield_out][divider][inputline][divider]")
	popup.open()

/obj/machinery/minicomputer/Topic(href, href_list)
	if(..())
		return
	if(href_list["commandline"])
		//We have a command to parse. Hand it off to the primary program if we have one.
		foreground_program?.data_in(href_list["commandline"])
