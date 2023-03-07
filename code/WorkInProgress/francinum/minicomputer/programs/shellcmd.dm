// "builtin" commands for shells

/shellcmd

// Usual format is list($FILE_CALLED, $TARGET)
/shellcmd/proc/Run(...)
	. = EXITCODE_SUCCESS //Fallthroughs are successes, errors must be explicit.


// /// "Change Directory"
// /shellcmd/cd/Run(...)
