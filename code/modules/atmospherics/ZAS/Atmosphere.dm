/datum/atmosphere
	var/datum/gas_mixture/air_singleton

	var/list/base_gases // A list of gases to always have
	var/list/normal_gases // A list of allowed gases:base_amount
	var/list/restricted_gases // A list of allowed gases like normal_gases but each can only be selected a maximum of one time
	var/restricted_chance = 10 // Chance per iteration to take from restricted gases

	var/minimum_pressure
	var/maximum_pressure

	var/minimum_temp
	var/maximum_temp
	var/ideal_temp //The temperature to adjust towards every tick

/datum/atmosphere/New()
	generate_air()

/datum/atmosphere/proc/generate_air()
	var/list/spicy_gas = restricted_gases.Copy()
	var/target_pressure = rand(minimum_pressure, maximum_pressure)
	var/pressure_scalar = target_pressure / maximum_pressure

	if(HAS_TRAIT(SSstation, STATION_TRAIT_UNNATURAL_ATMOSPHERE))
		restricted_chance = restricted_chance + 40

	// First let's set up the gasmix and base gases for this template
	// We make the string from a gasmix in this proc because gases need to calculate their pressure
	var/datum/gas_mixture/gasmix = new
	var/list/gaslist = gasmix.gas
	gasmix.temperature = rand(minimum_temp, maximum_temp)
	ideal_temp = gasmix.temperature
	for(var/i in base_gases)
		gaslist[i] = base_gases[i]

	// Now let the random choices begin
	var/gasid
	var/amount
	while(gasmix.returnPressure() < target_pressure)
		if(!prob(restricted_chance) || !length(spicy_gas))
			gasid = pick(normal_gases)
			amount = normal_gases[gasid]
		else
			gasid = pick(spicy_gas)
			amount = spicy_gas[gasid]
			spicy_gas -= gasid //You can only pick each restricted gas once

		amount *= rand(50, 200) / 100 // Randomly modifes the amount from half to double the base for some variety
		amount *= pressure_scalar // If we pick a really small target pressure we want roughly the same mix but less of it all
		amount = CEILING(amount, 0.1)

		gaslist[gasid] += amount
		AIR_UPDATE_VALUES(gasmix)

	// That last one put us over the limit, remove some of it
	while(gasmix.returnPressure() > target_pressure)
		gaslist[gasid] -= gaslist[gasid] * 0.1
		AIR_UPDATE_VALUES(gasmix)

	gaslist[gasid] = FLOOR(gaslist[gasid], 0.1)

	air_singleton = gasmix

/datum/atmosphere/planetary/lavaland

	base_gases = list(
		GAS_OXYGEN = 5,
		GAS_RADON = 10
	)
	normal_gases = list(
		GAS_OXYGEN = 10,
		GAS_NITROGEN = 10,
		GAS_CO2 = 10,
	)

	restricted_gases = list(
		GAS_NEON = 5,
		GAS_ARGON = 5,
		GAS_KRYPTON = 5,
		GAS_NO = 0.1,
		GAS_SULFUR = 1,
	)

	restricted_chance = 30

	minimum_pressure = HAZARD_LOW_PRESSURE + 10
	maximum_pressure = LAVALAND_EQUIPMENT_EFFECT_PRESSURE - 1

	minimum_temp = BODYTEMP_COLD_DAMAGE_LIMIT + 1
	maximum_temp = 350

/datum/atmosphere/planetary/icemoon
	base_gases = list(
		GAS_OXYGEN = 5,
		GAS_RADON = 10
	)
	normal_gases = list(
		GAS_OXYGEN = 10,
		GAS_NITROGEN = 10,
		GAS_CO2 = 10,
	)

	restricted_gases = list(
		GAS_NEON = 5,
		GAS_ARGON = 5,
		GAS_KRYPTON = 5,
		GAS_NO = 0.1,
		GAS_SULFUR = 1,
	)

	restricted_chance = 30

	minimum_pressure = HAZARD_LOW_PRESSURE + 10
	maximum_pressure = LAVALAND_EQUIPMENT_EFFECT_PRESSURE - 1

	minimum_temp = BODYTEMP_COLD_DAMAGE_LIMIT + 1
	maximum_temp = 350

	restricted_chance = 20

	minimum_pressure = HAZARD_LOW_PRESSURE + 10
	maximum_pressure = LAVALAND_EQUIPMENT_EFFECT_PRESSURE - 1

	minimum_temp = 180
	maximum_temp = 180
