GLOBAL_REAL(datacore, /datum/controller/datacore)

/datum/dc_record
	name = "Uninitialized Datacore Record"
	/// Security record specific data.
	var/list/security_data
	/// Medical record specific data.
	var/list/medical_data
	/// Employment/Shared data. Contains everything you'd want to use to find the record.
	var/list/general_data
	/// Initial snapshot of all records. Immutable.
	var/list/initial_data

/datum/controller/datacore
	name = "Data Core"

	var/list/datum/dc_record/records


/datum/controller/datacore/New()
	if(!datacore)
		datacore = src
		Initialize()
		return
	CRASH("Creating datacore while one already exists. Get your own global var.")

/datum/controller/datacore/Initialize()
	records = list()


/datum/controller/datacore/find_record(field, value, list/inserted_list = records)
	for(var/datum/datum/dc_record/record_to_check in inserted_list)
		if(record_to_check.general_data[field] == value)
			return record_to_check
	return null
