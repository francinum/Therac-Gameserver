// Program Return Values
#define EXITCODE_SUCCESS 0
#define EXITCODE_FAILURE 1

// Minicomputer hardware slots
/// "Fixed" internal storage disks, Think hard drives.
#define MINICOM_HARDWARE_FIXED_DISK "fixed_disk"
/// "Peripheral" devices that can be interacted with externally, Think floppy drives.
#define MINICOM_HARDWARE_PERIPHERAL "peripheral"
/// "Expansion" devices provide some internal functionality, Think network cards.
#define MINICOM_HARDWARE_EXPANSION "expansion"
/// "Removable" devices that are used to interact with Peripheral class devices, Think floppy disks.
#define MINICOM_HARDWARE_REMOVABLE "removable"

// Process Flags
/// Not processed by system timer
#define MPFLAG_NOTIMER (1<<0)
/// Woken on Background timer (every 2 standard timers)
#define MPFLAG_BACKGROUND (1<<1)

// Process Interrupts
/// Scheduler timer
#define MPINTERRUPT_TIMER "timer"
/// Data Input (stdin)
#define MPINTERRUPT_DATAIN "data_in"

// System Flags Register
/// Suppress automatic echo
#define MSFLAG_SUPPRESS_ECHO (1<<0)
/// Halt the system timer
#define MSFLAG_HALT (1<<1)
