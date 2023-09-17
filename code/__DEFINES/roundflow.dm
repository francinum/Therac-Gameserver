// Defines for Pluggable Round Flow modules

/*
 * Evac Stages:
 * Stagename - Evac Shuttle Equivalent
 * Waiting - Evac Shuttle waiting at centcom
 * Preparing - Evac shuttle heading to station
 * Cooldown - Evac shuttle recalled/Uncallable
 * Occurring - Evac shuttle docked, Waiting for boarders
 * Transit - Evac shuttle headed back to centcom with survivors
 * Finished - Evac shuttle docked at centcom. Round over.
 */

/// Waiting - Evac Shuttle waiting at centcom
#define RFM_EVAC_WAITING 0

/// Aborting - Evac shuttle recalled
#define RFM_EVAC_COOLDOWN -1

/// Preparing - Evac shuttle heading to station
#define RFM_EVAC_PREPARING 1

/// Launched

/// Occurring - Evac shuttle docked, Waiting for boarders
#define RFM_EVAC_OCCURRING 3

/// Transit - Evac shuttle headed back to centcom with survivors
#define RFM_EVAC_TRANSIT 4

/// Finished - Evac shuttle docked at centcom. Round over.
#define RFM_EVAC_FINISHED 5
