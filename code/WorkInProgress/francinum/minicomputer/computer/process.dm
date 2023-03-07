/*

	This is almost certainly oversimulationist.
	Represents individual threads of execution, holding their own memory, and their own Process ID

*/
/miniprocess
	/// Process ID for IPC and control
	var/process_id
	/// Source file that contains our code
	var/minifile/program/running_program
	/// Heap memory
	var/list/memory
	/// Process flags
	var/process_flags = NONE
	/// What do we call on our program based on the various flavors of interrupt?
	var/list/handlers
	/// Process status. Kernel checks this on System Timer.
	var/process_status

/miniprocess/proc/sys_timer()
	running_program.sys_timer()

/miniprocess/proc/data_in(datastream as text)
