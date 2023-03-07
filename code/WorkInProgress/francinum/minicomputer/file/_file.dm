/*

	Minicomputer Files, the basic unit of information.


*/
/minifile
	var/name
	/// File permissions, Unnecessary right now, something to consider later.
	var/permissions = 0777 // BYOND actually supports octal notation!
	///The "contents" of the file, usually generated nonsense for binary type files, otherwise it's probably text.
	var/data
	/// Does a process have a lock on this file? Prevents modification
	var/locking_pid
