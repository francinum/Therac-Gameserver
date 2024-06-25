// Define set that decides how an atom will be scanned for astar things
/// If set, we make the assumption that CanAStarPass() will NEVER return FALSE unless density is true
#define CANASTARPASS_DENSITY 0
/// If this is set, we bypass density checks and always call the proc
#define CANASTARPASS_ALWAYS_PROC 1

/// Uncachable, do the full proc scan.
#define ASTAR_CACHE_DIRTY null
/// Cached as a passable turf
#define ASTAR_CACHE_PASSABLE FALSE
/// Cached as an unpassable turf
#define ASTAR_CACHE_UNPASSABLE TRUE

/**
 * A helper macro to see if it's possible to step from the first turf into the second one, minding things like door access and directional windows.
 * Note that this can only be used inside the [datum/pathfind][pathfind datum] since it uses variables from said datum.
 * If you really want to optimize things, optimize this, cuz this gets called a lot.
 * We do early next.density check despite it being already checked in LinkBlockedWithAccess for short-circuit performance
 */
#define CAN_STEP(cur_turf, next) (next && (next != avoid) && !next.density && !(simulated_only && isspaceturf(next)) && !cur_turf.LinkBlockedWithAccess(next, caller, access))
/// Another helper macro for JPS, for telling when a node has forced neighbors that need expanding
#define STEP_NOT_HERE_BUT_THERE(cur_turf, dirA, dirB) ((!CAN_STEP(cur_turf, get_step(cur_turf, dirA)) && CAN_STEP(cur_turf, get_step(cur_turf, dirB))))
