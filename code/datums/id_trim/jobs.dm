/**
 * This file contains all the trims associated with station jobs.
 * It also contains special prisoner trims and the miner's spare ID trim.
 */

/// ID Trims for station jobs.
/datum/access_template/job
	trim_state = "trim_assistant"

	/// The extra access the card should have when CONFIG_GET(flag/jobs_have_minimal_access) is FALSE.
	var/list/extra_access = list()
	/// The base access the card should have when CONFIG_GET(flag/jobs_have_minimal_access) is TRUE.
	var/list/minimal_access = list()

	/// Static list. Cache of any mapping config job changes.
	var/static/list/job_changes
	/// What config entry relates to this job. Should be a lowercase job name with underscores for spaces, eg "prisoner" "research_director" "head_of_security"
	var/config_job
	/// The typepath to the job datum from the id_trim. This is converted to one of the job singletons in New().
	var/datum/job/job = /datum/job/unassigned

/datum/access_template/job/New()
	if(ispath(job))
		job = SSjob.GetJobType(job)

	if(isnull(job_changes))
		job_changes = SSmapping.config.job_changes

	if(!length(job_changes) || !config_job)
		refresh_trim_access()
		return

	var/list/access_changes = job_changes[config_job]

	if(!length(access_changes))
		refresh_trim_access()
		return

	if(islist(access_changes["additional_access"]))
		extra_access |= access_changes["additional_access"]
	if(islist(access_changes["additional_minimal_access"]))
		minimal_access |= access_changes["additional_minimal_access"]

	refresh_trim_access()

/**
 * Goes through various non-map config settings and modifies the trim's access based on this.
 *
 * Returns TRUE if the config is loaded, FALSE otherwise.
 */
/datum/access_template/job/proc/refresh_trim_access()
	// If there's no config loaded then assume minimal access.
	if(!config)
		access = minimal_access.Copy()
		return FALSE

	// There is a config loaded. Check for the jobs_have_minimal_access flag being set.
	if(CONFIG_GET(flag/jobs_have_minimal_access))
		access = minimal_access.Copy()
	else
		access = minimal_access | extra_access

	// If the config has global maint access set, we always want to add maint access.
	if(CONFIG_GET(flag/everyone_has_maint_access))
		access |= list(ACCESS_MAINT_TUNNELS)

	return TRUE

/datum/access_template/job/assistant
	assignment = "Assistant"
	trim_state = "trim_assistant"
	sechud_icon_state = SECHUD_ASSISTANT
	extra_access = list(ACCESS_MAINT_TUNNELS)
	minimal_access = list()
	config_job = "assistant"
	job = /datum/job/assistant

/datum/access_template/job/atmospheric_technician
	assignment = "Atmospheric Technician"
	trim_state = "trim_atmospherictechnician"
	sechud_icon_state = SECHUD_ATMOSPHERIC_TECHNICIAN
	extra_access = list(
		ACCESS_ENGINE,
		ACCESS_ENGINE_EQUIP,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_TECH_STORAGE
	)
	minimal_access = list(
		ACCESS_ATMOSPHERICS,
		ACCESS_CONSTRUCTION,
		ACCESS_EXTERNAL_AIRLOCKS,
		ACCESS_MAINT_TUNNELS,
		ACCESS_MECH_ENGINE,
		ACCESS_MINERAL_STOREROOM
	)
	config_job = "atmospheric_technician"
	job = /datum/job/atmospheric_technician

/datum/access_template/job/bartender
	assignment = "Bartender"
	trim_state = "trim_bartender"
	sechud_icon_state = SECHUD_BARTENDER
	extra_access = list(
		ACCESS_HYDROPONICS,
		ACCESS_KITCHEN,
	)
	config_job = "bartender"
	job = /datum/job/bartender

/datum/access_template/job/botanist
	assignment = "Botanist"
	trim_state = "trim_botanist"
	sechud_icon_state = SECHUD_BOTANIST
	extra_access = list(
		ACCESS_BAR,
		ACCESS_KITCHEN
	)
	minimal_access = list(
		ACCESS_HYDROPONICS,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_SERVICE
	)
	config_job = "botanist"
	job = /datum/job/botanist

/datum/access_template/job/captain
	assignment = "Captain"
	intern_alt_name = "Captain-in-Training"
	trim_state = "trim_captain"
	sechud_icon_state = SECHUD_CAPTAIN
	config_job = "captain"
	job = /datum/job/captain

/// Captain gets all station accesses hardcoded in because it's the Captain.
/datum/access_template/job/captain/New()
	minimal_access |= SSid_access.get_flag_access_list(ACCESS_FLAG_COMMON)
	minimal_access |= SSid_access.get_flag_access_list(ACCESS_FLAG_COMMAND)
	minimal_access |= SSid_access.get_flag_access_list(ACCESS_FLAG_PRV_COMMAND)
	minimal_access |= SSid_access.get_flag_access_list(ACCESS_FLAG_CAPTAIN)
	return ..()


/datum/access_template/job/cargo_technician
	assignment = "Cargo Technician"
	trim_state = "trim_cargotechnician"
	sechud_icon_state = SECHUD_CARGO_TECHNICIAN
	extra_access = list(
		ACCESS_QM,
		ACCESS_MINING,
		ACCESS_MINING_STATION
	)
	minimal_access = list(
		ACCESS_CARGO,
		ACCESS_MAILSORTING,
		ACCESS_MAINT_TUNNELS,
		ACCESS_MECH_MINING,
		ACCESS_MINERAL_STOREROOM
	)
	config_job = "cargo_technician"
	job = /datum/job/cargo_technician

/datum/access_template/job/chaplain
	assignment = "Chaplain"
	trim_state = "trim_chaplain"
	sechud_icon_state = SECHUD_CHAPLAIN
	extra_access = list()
	minimal_access = list(
		ACCESS_CHAPEL_OFFICE,
		ACCESS_CREMATORIUM,
		ACCESS_MORGUE,
		ACCESS_THEATRE,
		ACCESS_SERVICE
	)
	config_job = "chaplain"
	job = /datum/job/chaplain

/datum/access_template/job/chemist
	assignment = "Chemist"
	trim_state = "trim_chemist"
	sechud_icon_state = SECHUD_CHEMIST
	extra_access = list(
		ACCESS_SURGERY,
		ACCESS_VIROLOGY
	)
	minimal_access = list(
		ACCESS_CHEMISTRY,
		ACCESS_MECH_MEDICAL,
		ACCESS_MEDICAL,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_MORGUE,
		ACCESS_PHARMACY
	)
	config_job = "chemist"
	job = /datum/job/chemist

/datum/access_template/job/chief_engineer
	assignment = "Chief Engineer"
	intern_alt_name = "Chief Engineer-in-Training"
	trim_state = "trim_chiefengineer"
	sechud_icon_state = SECHUD_CHIEF_ENGINEER
	extra_access = list(ACCESS_TELEPORTER)
	minimal_access = list(
		ACCESS_ATMOSPHERICS,
		ACCESS_CE,
		ACCESS_CONSTRUCTION,
		ACCESS_ENGINE,
		ACCESS_ENGINE_EQUIP,
		ACCESS_EVA,
		ACCESS_EXTERNAL_AIRLOCKS,
		ACCESS_HEADS,
		ACCESS_KEYCARD_AUTH,
		ACCESS_MAINT_TUNNELS,
		ACCESS_MECH_ENGINE,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_MINISAT,
		ACCESS_RC_ANNOUNCE,
		ACCESS_BRIG_ENTRANCE,
		ACCESS_TCOMSAT,
		ACCESS_TECH_STORAGE
	)
	config_job = "chief_engineer"
	job = /datum/job/chief_engineer

/datum/access_template/job/chief_medical_officer
	assignment = "Medical Director"
	intern_alt_name = "Medical Director-in-Training"
	trim_state = "trim_chiefmedicalofficer"
	sechud_icon_state = SECHUD_CHIEF_MEDICAL_OFFICER
	extra_access = list(ACCESS_TELEPORTER)
	minimal_access = list(
		ACCESS_CHEMISTRY,
		ACCESS_EVA,
		ACCESS_HEADS,
		ACCESS_KEYCARD_AUTH,
		ACCESS_MAINT_TUNNELS,
		ACCESS_MECH_MEDICAL,
		ACCESS_MEDICAL,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_MORGUE,
		ACCESS_PHARMACY,
		ACCESS_PSYCHOLOGY,
		ACCESS_RC_ANNOUNCE,
		ACCESS_BRIG_ENTRANCE,
		ACCESS_SURGERY,
		ACCESS_VIROLOGY,
		ACCESS_CMO
	)
	config_job = "chief_medical_officer"
	job = /datum/job/chief_medical_officer

/datum/access_template/job/clown
	assignment = "Clown"
	trim_state = "trim_clown"
	sechud_icon_state = SECHUD_CLOWN
	extra_access = list()
	minimal_access = list(
		ACCESS_THEATRE,
		ACCESS_SERVICE
	)
	config_job = "clown"
	job = /datum/job/clown

/datum/access_template/job/cook
	assignment = "Cook"
	trim_state = "trim_cook"
	sechud_icon_state = SECHUD_COOK
	extra_access = list(
		ACCESS_BAR,
		ACCESS_HYDROPONICS
	)
	minimal_access = list(
		ACCESS_KITCHEN,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_SERVICE
	)
	config_job = "cook"
	job = /datum/job/cook

/datum/access_template/job/cook/chef
	assignment = "Chef"
	sechud_icon_state = SECHUD_CHEF

/datum/access_template/job/curator
	assignment = "Curator"
	trim_state = "trim_curator"
	sechud_icon_state = SECHUD_CURATOR
	extra_access = list()
	minimal_access = list(
		ACCESS_LIBRARY,
		ACCESS_MINING_STATION,
		ACCESS_SERVICE
	)
	config_job = "curator"
	job = /datum/job/curator

/datum/access_template/job/detective
	assignment = "Detective"
	trim_state = "trim_detective"
	sechud_icon_state = SECHUD_DETECTIVE
	extra_access = list()
	minimal_access = list(
		ACCESS_FORENSICS,
		ACCESS_MAINT_TUNNELS,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_WEAPONS
	)
	config_job = "detective"
	job = /datum/job/detective

/datum/access_template/job/geneticist
	assignment = "Geneticist"
	trim_state = "trim_geneticist"
	sechud_icon_state = SECHUD_GENETICIST
	extra_access = list(
		ACCESS_ROBOTICS,
		ACCESS_TECH_STORAGE,
		ACCESS_XENOBIOLOGY
	)
	minimal_access = list(
		ACCESS_GENETICS,
		ACCESS_MECH_SCIENCE,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_MORGUE,
		ACCESS_RESEARCH,
		ACCESS_RND
	)
	config_job = "geneticist"
	job = /datum/job/geneticist

/datum/access_template/job/head_of_personnel
	assignment = "Head of Personnel"
	intern_alt_name = "Head of Personnel-in-Training"
	trim_state = "trim_headofpersonnel"
	sechud_icon_state = SECHUD_HEAD_OF_PERSONNEL
	minimal_access = list(
		ACCESS_AI_UPLOAD,
		ACCESS_ALL_PERSONAL_LOCKERS,
		ACCESS_BAR,
		ACCESS_BRIG,
		ACCESS_CHAPEL_OFFICE,
		ACCESS_CHANGE_IDS, ACCESS_CONSTRUCTION, ACCESS_COURT, ACCESS_CREMATORIUM, ACCESS_ENGINE, ACCESS_EVA, ACCESS_GATEWAY,
		ACCESS_HEADS, ACCESS_HYDROPONICS, ACCESS_JANITOR, ACCESS_KEYCARD_AUTH, ACCESS_KITCHEN, ACCESS_LAWYER, ACCESS_LIBRARY,
		ACCESS_MAINT_TUNNELS, ACCESS_MECH_ENGINE, ACCESS_MECH_MEDICAL, ACCESS_MECH_SCIENCE, ACCESS_MECH_SECURITY, ACCESS_MEDICAL,
		ACCESS_MORGUE, ACCESS_PSYCHOLOGY, ACCESS_RC_ANNOUNCE, ACCESS_RESEARCH, ACCESS_BRIG_ENTRANCE, ACCESS_TELEPORTER,
		ACCESS_THEATRE, ACCESS_VAULT, ACCESS_WEAPONS, ACCESS_HOP)
	config_job = "head_of_personnel"
	job = /datum/job/head_of_personnel

/datum/access_template/job/head_of_security
	assignment = "Head of Security"
	intern_alt_name = "Head of Security-in-Training"
	trim_state = "trim_headofsecurity"
	sechud_icon_state = SECHUD_HEAD_OF_SECURITY
	extra_access = list(ACCESS_TELEPORTER)
	minimal_access = list(
		ACCESS_MAINT_TUNNELS,ACCESS_ALL_PERSONAL_LOCKERS, ACCESS_ARMORY, ACCESS_BRIG, ACCESS_CONSTRUCTION, ACCESS_COURT,
		ACCESS_ENGINE, ACCESS_EVA, ACCESS_FORENSICS, ACCESS_GATEWAY, ACCESS_HEADS, ACCESS_KEYCARD_AUTH,
		ACCESS_MAINT_TUNNELS, ACCESS_MECH_SECURITY, ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_RC_ANNOUNCE,
		ACCESS_RESEARCH, ACCESS_SECURITY, ACCESS_BRIG_ENTRANCE, ACCESS_WEAPONS, ACCESS_HOS)
	config_job = "head_of_security"
	job = /datum/job/head_of_security


/datum/access_template/job/janitor
	assignment = "Janitor"
	trim_state = "trim_janitor"
	sechud_icon_state = SECHUD_JANITOR
	extra_access = list()
	minimal_access = list(
		ACCESS_JANITOR,
		ACCESS_MAINT_TUNNELS,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_SERVICE
	)
	config_job = "janitor"
	job = /datum/job/janitor

/datum/access_template/job/lawyer
	assignment = "Lawyer"
	trim_state = "trim_lawyer"
	sechud_icon_state = SECHUD_LAWYER
	extra_access = list()
	minimal_access = list(
		ACCESS_COURT,
		ACCESS_LAWYER,
		ACCESS_BRIG_ENTRANCE,
		ACCESS_SERVICE
	)
	config_job = "lawyer"
	job = /datum/job/lawyer

/datum/access_template/job/medical_doctor
	assignment = "Medical Doctor"
	trim_state = "trim_medicaldoctor"
	sechud_icon_state = SECHUD_MEDICAL_DOCTOR
	extra_access = list(
		ACCESS_CHEMISTRY,
		ACCESS_VIROLOGY
	)
	minimal_access = list(
		ACCESS_MECH_MEDICAL,
		ACCESS_MEDICAL,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_MORGUE,
		ACCESS_PHARMACY,
		ACCESS_SURGERY
	)
	config_job = "medical_doctor"
	job = /datum/job/doctor

/datum/access_template/job/mime
	assignment = "Mime"
	trim_state = "trim_mime"
	sechud_icon_state = SECHUD_MIME
	extra_access = list()
	minimal_access = list(
		ACCESS_THEATRE,
		ACCESS_SERVICE
	)
	config_job = "mime"
	job = /datum/job/mime

/datum/access_template/job/paramedic
	assignment = "Paramedic"
	trim_state = "trim_paramedic"
	sechud_icon_state = SECHUD_PARAMEDIC
	extra_access = list(ACCESS_SURGERY)
	minimal_access = list(
		ACCESS_CONSTRUCTION,
		ACCESS_HYDROPONICS,
		ACCESS_MAINT_TUNNELS,
		ACCESS_MECH_MEDICAL,
		ACCESS_MEDICAL,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_MINING,
		ACCESS_MORGUE,
		ACCESS_RESEARCH
	)
	config_job = "paramedic"
	job = /datum/job/paramedic

/datum/access_template/job/prisoner
	assignment = "Prisoner"
	trim_state = "trim_prisoner"
	sechud_icon_state = SECHUD_PRISONER
	config_job = "prisoner"
	job = /datum/job/prisoner

/datum/access_template/job/prisoner/one
	trim_state = "trim_prisoner_1"
	//template_access = null

/datum/access_template/job/prisoner/two
	trim_state = "trim_prisoner_2"
	//template_access = null

/datum/access_template/job/prisoner/three
	trim_state = "trim_prisoner_3"
	//template_access = null

/datum/access_template/job/prisoner/four
	trim_state = "trim_prisoner_4"
	//template_access = null

/datum/access_template/job/prisoner/five
	trim_state = "trim_prisoner_5"
	//template_access = null

/datum/access_template/job/prisoner/six
	trim_state = "trim_prisoner_6"
	//template_access = null

/datum/access_template/job/prisoner/seven
	trim_state = "trim_prisoner_7"
	//template_access = null

/datum/access_template/job/psychologist
	assignment = "Psychologist"
	trim_state = "trim_psychologist"
	sechud_icon_state = SECHUD_PSYCHOLOGIST
	minimal_access = list(
		ACCESS_MEDICAL,
		ACCESS_PSYCHOLOGY,
		ACCESS_SERVICE
	)
	config_job = "psychologist"
	job = /datum/job/psychologist

/datum/access_template/job/quartermaster
	assignment = "Quartermaster"
	trim_state = "trim_quartermaster"
	sechud_icon_state = SECHUD_QUARTERMASTER
	minimal_access = list(
		ACCESS_BRIG_ENTRANCE,
		ACCESS_CARGO,
		ACCESS_HEADS,
		ACCESS_KEYCARD_AUTH,
		ACCESS_MAILSORTING,
		ACCESS_MAINT_TUNNELS,
		ACCESS_MECH_MINING,
		ACCESS_MINING_STATION,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_MINING,
		ACCESS_QM,
		ACCESS_RC_ANNOUNCE,
		ACCESS_VAULT
	)
	config_job = "quartermaster"
	job = /datum/job/quartermaster

/datum/access_template/job/research_director
	assignment = "Research Director"
	intern_alt_name = "Research Director-in-Training"
	trim_state = "trim_researchdirector"
	sechud_icon_state = SECHUD_RESEARCH_DIRECTOR
	extra_access = list()
	minimal_access = list(
		ACCESS_AI_UPLOAD, ACCESS_EVA, ACCESS_GATEWAY, ACCESS_GENETICS, ACCESS_HEADS, ACCESS_KEYCARD_AUTH,
		ACCESS_NETWORK, ACCESS_MAINT_TUNNELS, ACCESS_MECH_ENGINE, ACCESS_MECH_MINING, ACCESS_MECH_SECURITY, ACCESS_MECH_SCIENCE,
		ACCESS_MEDICAL, ACCESS_MINERAL_STOREROOM, ACCESS_MINING, ACCESS_MINING_STATION, ACCESS_MINISAT,
		ACCESS_ORDNANCE, ACCESS_ORDNANCE_STORAGE, ACCESS_RC_ANNOUNCE, ACCESS_RESEARCH, ACCESS_RND, ACCESS_ROBOTICS,
		ACCESS_BRIG_ENTRANCE, ACCESS_TECH_STORAGE, ACCESS_TELEPORTER, ACCESS_XENOBIOLOGY, ACCESS_RD
	)
	config_job = "research_director"
	job = /datum/job/research_director

/datum/access_template/job/roboticist
	assignment = "Roboticist"
	trim_state = "trim_roboticist"
	sechud_icon_state = SECHUD_ROBOTICIST
	extra_access = list(
		ACCESS_GENETICS,
		ACCESS_ORDNANCE,
		ACCESS_ORDNANCE_STORAGE,
		ACCESS_XENOBIOLOGY
	)
	minimal_access = list(
		ACCESS_MECH_SCIENCE,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_RESEARCH,
		ACCESS_RND,
		ACCESS_ROBOTICS,
		ACCESS_TECH_STORAGE
	)
	config_job = "roboticist"
	job = /datum/job/roboticist

/datum/access_template/job/scientist
	assignment = "Scientist"
	trim_state = "trim_scientist"
	sechud_icon_state = SECHUD_SCIENTIST
	extra_access = list(
		ACCESS_GENETICS,
		ACCESS_ROBOTICS
	)
	minimal_access = list(
		ACCESS_MECH_SCIENCE,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_ORDNANCE,
		ACCESS_ORDNANCE_STORAGE,
		ACCESS_RESEARCH,
		ACCESS_RND,
		ACCESS_XENOBIOLOGY
	)
	config_job = "scientist"
	job = /datum/job/scientist

/// Sec officers have departmental variants. They each have their own trims with bonus departmental accesses.
/datum/access_template/job/security_officer
	assignment = "Security Officer"
	trim_state = "trim_securityofficer"
	sechud_icon_state = SECHUD_SECURITY_OFFICER
	extra_access = list(
		ACCESS_FORENSICS,
		ACCESS_MAINT_TUNNELS,
	)
	minimal_access = list(
		ACCESS_MAINT_TUNNELS,
		ACCESS_BRIG,
		ACCESS_COURT,
		ACCESS_SECURITY,
		ACCESS_BRIG_ENTRANCE,
		ACCESS_MECH_SECURITY,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_WEAPONS
	)
	/// List of bonus departmental accesses that departmental sec officers get.
	var/department_access = list()
	config_job = "security_officer"
	job = /datum/job/security_officer

/datum/access_template/job/security_officer/refresh_trim_access()
	. = ..()

	if(!.)
		return

	access |= department_access

/datum/access_template/job/security_officer/supply
	assignment = "Security Officer (Cargo)"
	trim_state = "trim_securityofficer_car"
	department_access = list(
		ACCESS_CARGO,
		ACCESS_MAILSORTING,
		ACCESS_MINING,
		ACCESS_MINING_STATION
	)

/datum/access_template/job/security_officer/engineering
	assignment = "Security Officer (Engineering)"
	trim_state = "trim_securityofficer_engi"
	department_access = list(
		ACCESS_ATMOSPHERICS,
		ACCESS_CONSTRUCTION,
		ACCESS_ENGINE
	)

/datum/access_template/job/security_officer/medical
	assignment = "Security Officer (Medical)"
	trim_state = "trim_securityofficer_med"
	department_access = list(
		ACCESS_MEDICAL,
		ACCESS_MORGUE,
		ACCESS_SURGERY
	)

/datum/access_template/job/security_officer/science
	assignment = "Security Officer (Science)"
	trim_state = "trim_securityofficer_sci"
	department_access = list(
		ACCESS_RESEARCH,
		ACCESS_RND
	)

/datum/access_template/job/shaft_miner
	assignment = "Prospector"
	trim_state = "trim_shaftminer"
	sechud_icon_state = SECHUD_SHAFT_MINER
	extra_access = list(
		ACCESS_CARGO,
		ACCESS_MAINT_TUNNELS,
		ACCESS_QM
	)
	minimal_access = list(
		ACCESS_MAILSORTING,
		ACCESS_MECH_MINING,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_MINING,
		ACCESS_MINING_STATION
	)
	config_job = "shaft_miner"
	job = /datum/job/shaft_miner

/// ID card obtained from the mining Disney dollar points vending machine.
/datum/access_template/job/shaft_miner/spare
	extra_access = list()
	minimal_access = list(ACCESS_MAILSORTING, ACCESS_MECH_MINING, ACCESS_MINERAL_STOREROOM, ACCESS_MINING, ACCESS_MINING_STATION)
	template_access = null

/datum/access_template/job/station_engineer
	assignment = "Station Engineer"
	trim_state = "trim_stationengineer"
	sechud_icon_state = SECHUD_STATION_ENGINEER
	extra_access = list(ACCESS_ATMOSPHERICS)
	minimal_access = list(
		ACCESS_CONSTRUCTION,
		ACCESS_ENGINE,
		ACCESS_ENGINE_EQUIP,
		ACCESS_EXTERNAL_AIRLOCKS,
		ACCESS_MAINT_TUNNELS,
		ACCESS_MECH_ENGINE,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_TCOMSAT,
		ACCESS_TECH_STORAGE
	)
	config_job = "station_engineer"
	job = /datum/job/station_engineer

/datum/access_template/job/virologist
	assignment = "Virologist"
	trim_state = "trim_virologist"
	sechud_icon_state = SECHUD_VIROLOGIST
	extra_access = list(
		ACCESS_CHEMISTRY,
		ACCESS_MORGUE,
		ACCESS_SURGERY
	)
	minimal_access = list(
		ACCESS_MEDICAL,
		ACCESS_MECH_MEDICAL,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_VIROLOGY
	)
	config_job = "virologist"
	job = /datum/job/virologist

/datum/access_template/job/warden
	assignment = "Warden"
	trim_state = "trim_warden"
	sechud_icon_state = SECHUD_WARDEN
	extra_access = list(
		ACCESS_MAINT_TUNNELS,
	)
	minimal_access = list(
		ACCESS_MAINT_TUNNELS,
		ACCESS_ARMORY,
		ACCESS_BRIG,
		ACCESS_COURT,
		ACCESS_MECH_SECURITY,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_SECURITY,
		ACCESS_BRIG_ENTRANCE,
		ACCESS_WEAPONS
	) // See /datum/job/warden/get_access()
	config_job = "warden"
	job = /datum/job/warden
