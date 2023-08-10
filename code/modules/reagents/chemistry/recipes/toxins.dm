
/datum/chemical_reaction/formaldehyde
	results = list(/datum/reagent/toxin/formaldehyde = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol = 1, /datum/reagent/oxygen = 1, /datum/reagent/silver = 1)
	mix_message = "The mixture fizzles and gives off a fierce smell."
	is_cold_recipe = FALSE
	required_temp = 420
	optimal_temp = 520
	thermic_constant = 200
	rate_up_lim = 15
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_DAMAGING | REACTION_TAG_CHEMICAL | REACTION_TAG_BRUTE | REACTION_TAG_TOXIN

/datum/chemical_reaction/fentanyl
	results = list(/datum/reagent/toxin/fentanyl = 1)
	required_reagents = list(/datum/reagent/drug/space_drugs = 1)
	mix_message = "The mixture turns cloudy, then becomes clear again."
	is_cold_recipe = FALSE
	required_temp = 674
	optimal_temp = 774
	overheat_temp = 874
	thermic_constant = 50
	rate_up_lim = 5
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_DAMAGING | REACTION_TAG_ORGAN | REACTION_TAG_TOXIN

/datum/chemical_reaction/cyanide
	results = list(/datum/reagent/toxin/cyanide = 3)
	required_reagents = list(/datum/reagent/fuel/oil = 1, /datum/reagent/ammonia = 1, /datum/reagent/oxygen = 1)
	mix_message = "The mixture emits the faint smell of almonds."
	is_cold_recipe = FALSE
	required_temp = 380
	optimal_temp = 420
	overheat_temp = NO_OVERHEAT
	thermic_constant = -300
	rate_up_lim = 10
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_DAMAGING | REACTION_TAG_OXY | REACTION_TAG_TOXIN

/datum/chemical_reaction/itching_powder
	results = list(/datum/reagent/toxin/itching_powder = 3)
	required_reagents = list(/datum/reagent/fuel = 1, /datum/reagent/ammonia = 1, /datum/reagent/medicine/dylovene = 1)
	mix_message = "The mixture emits nose-irritating fumes."
	is_cold_recipe = FALSE
	required_temp = 280
	optimal_temp = 360
	overheat_temp = 700
	thermic_constant = -200
	rate_up_lim = 20
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_DAMAGING | REACTION_TAG_BRUTE

/datum/chemical_reaction/facid
	results = list(/datum/reagent/toxin/acid/fluacid = 4)
	required_reagents = list(/datum/reagent/toxin/acid = 1, /datum/reagent/fluorine = 1, /datum/reagent/hydrogen = 1, /datum/reagent/potassium = 1)
	mix_message = "The mixture bubbles fiercly."
	is_cold_recipe = FALSE
	required_temp = 380
	thermic_constant = -200
	rate_up_lim = 20
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_DAMAGING | REACTION_TAG_PLANT | REACTION_TAG_BURN | REACTION_TAG_TOXIN

/datum/chemical_reaction/nitracid
	results = list(/datum/reagent/toxin/acid/nitracid = 2)
	required_reagents = list(/datum/reagent/toxin/acid/fluacid = 1, /datum/reagent/nitrogen = 1,  /datum/reagent/space_cleaner = 1)
	mix_message = "The mixture bubbles fiercly and gives off a pungent smell."
	is_cold_recipe = FALSE
	required_temp = 480
	optimal_temp = 680
	overheat_temp = 900
	thermic_constant = -200
	rate_up_lim = 20
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_DAMAGING | REACTION_TAG_BURN | REACTION_TAG_TOXIN

/datum/chemical_reaction/sulfonal
	results = list(/datum/reagent/toxin/sulfonal = 3)
	required_reagents = list(/datum/reagent/acetone = 1, /datum/reagent/diethylamine = 1, /datum/reagent/sulfur = 1)
	mix_message = "The mixture changes color and becomes clear."
	is_cold_recipe = FALSE
	required_temp = 100
	optimal_temp = 450
	overheat_temp = 900
	thermic_constant = 200
	rate_up_lim = 10
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_DAMAGING | REACTION_TAG_TOXIN | REACTION_TAG_OTHER

/datum/chemical_reaction/lipolicide
	results = list(/datum/reagent/toxin/lipolicide = 3)
	required_reagents = list(/datum/reagent/mercury = 1, /datum/reagent/diethylamine = 1, /datum/reagent/medicine/ephedrine = 1)
	mix_message = "The mixture becomes cloudy."
	is_cold_recipe = FALSE
	required_temp = 100
	optimal_temp = 450
	overheat_temp = 900
	thermic_constant = 500
	rate_up_lim = 10
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_DAMAGING | REACTION_TAG_OTHER

/datum/chemical_reaction/mutagen
	results = list(/datum/reagent/toxin/mutagen = 3)
	required_reagents = list(/datum/reagent/uranium/radium = 1, /datum/reagent/phosphorus = 1, /datum/reagent/chlorine = 1)
	mix_message = "The mixture glows faintly, then stops."
	is_cold_recipe = FALSE
	required_temp = 100
	optimal_temp = 450
	overheat_temp = 900
	thermic_constant = 350
	rate_up_lim = 10
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_DAMAGING | REACTION_TAG_PLANT | REACTION_TAG_OTHER

/datum/chemical_reaction/lexorin
	results = list(/datum/reagent/toxin/lexorin = 3)
	required_reagents = list(/datum/reagent/toxin/plasma = 1, /datum/reagent/hydrogen = 1, /datum/reagent/medicine/dexalin = 1)
	mix_message = "The mixture turns clear and stops reacting."
	is_cold_recipe = FALSE
	required_temp = 100
	optimal_temp = 450
	overheat_temp = 900
	thermic_constant = -400
	rate_up_lim = 25
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_DAMAGING | REACTION_TAG_OXY

/datum/chemical_reaction/hot_ice_melt
	results = list(/datum/reagent/toxin/plasma = 12) //One sheet of hot ice makes 200m of plasma
	required_reagents = list(/datum/reagent/toxin/hot_ice = 1)
	required_temp = T0C + 30 //Don't burst into flames when you melt
	thermic_constant = -200//Counter the heat
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_DAMAGING | REACTION_TAG_CHEMICAL | REACTION_TAG_TOXIN

/datum/chemical_reaction/chloralhydrate
	results = list(/datum/reagent/toxin/chloralhydrate = 1)
	required_reagents = list(/datum/reagent/consumable/ethanol = 1, /datum/reagent/chlorine = 3, /datum/reagent/water = 1)
	mix_message = "The mixture turns deep blue."
	is_cold_recipe = FALSE
	required_temp = 200
	optimal_temp = 450
	overheat_temp = 900
	thermic_constant = 250
	rate_up_lim = 10
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_DAMAGING | REACTION_TAG_OTHER

/datum/chemical_reaction/mutetoxin //i'll just fit this in here snugly between other unfun chemicals :v
	results = list(/datum/reagent/toxin/mutetoxin = 2)
	required_reagents = list(/datum/reagent/uranium = 2, /datum/reagent/water = 1, /datum/reagent/carbon = 1)
	mix_message = "The mixture calms down."
	is_cold_recipe = FALSE
	required_temp = 100
	optimal_temp = 450
	overheat_temp = 900
	thermic_constant = -250
	rate_up_lim = 15
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_DAMAGING | REACTION_TAG_OTHER

/datum/chemical_reaction/zombiepowder
	results = list(/datum/reagent/toxin/zombiepowder = 2)
	required_reagents = list(/datum/reagent/toxin/carpotoxin = 5, /datum/reagent/medicine/morphine = 5, /datum/reagent/copper = 5)
	mix_message = "The mixture turns into a strange green powder."
	is_cold_recipe = FALSE
	required_temp = 100
	optimal_temp = 450
	overheat_temp = 900
	temp_exponent_factor = 3
	thermic_constant = 150
	rate_up_lim = 15
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_DAMAGING | REACTION_TAG_OTHER

/datum/chemical_reaction/ghoulpowder
	results = list(/datum/reagent/toxin/ghoulpowder = 2)
	required_reagents = list(/datum/reagent/toxin/zombiepowder = 1, /datum/reagent/medicine/epinephrine = 1)
	mix_message = "The mixture turns into a strange brown powder."
	is_cold_recipe = FALSE
	required_temp = 100
	optimal_temp = 450
	overheat_temp = 900
	temp_exponent_factor = 3
	thermic_constant = 150
	rate_up_lim = 15
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_DAMAGING | REACTION_TAG_OTHER

/datum/chemical_reaction/mindbreaker
	results = list(/datum/reagent/toxin/mindbreaker = 5)
	required_reagents = list(/datum/reagent/silicon = 1, /datum/reagent/hydrogen = 1, /datum/reagent/medicine/dylovene = 1)
	mix_message = "The mixture turns into a vivid red liquid."
	is_cold_recipe = FALSE
	required_temp = 100
	optimal_temp = 450
	overheat_temp = 900
	temp_exponent_factor = 2.5
	thermic_constant = 150
	rate_up_lim = 15
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_DAMAGING | REACTION_TAG_OTHER

/datum/chemical_reaction/heparin
	results = list(/datum/reagent/toxin/heparin = 4)
	required_reagents = list(/datum/reagent/toxin/formaldehyde = 1, /datum/reagent/sodium = 1, /datum/reagent/chlorine = 1, /datum/reagent/lithium = 1)
	mix_message = "<span class='danger'>The mixture thins and loses all color.</span>"
	is_cold_recipe = FALSE
	required_temp = 100
	optimal_temp = 450
	overheat_temp = 800
	temp_exponent_factor = 2.5
	thermic_constant = 375
	rate_up_lim = 10
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_DAMAGING | REACTION_TAG_OTHER

/datum/chemical_reaction/rotatium
	results = list(/datum/reagent/toxin/rotatium = 3)
	required_reagents = list(/datum/reagent/toxin/mindbreaker = 1, /datum/reagent/teslium = 1, /datum/reagent/toxin/fentanyl = 1)
	mix_message = "<span class='danger'>After sparks, fire, and the smell of mindbreaker, the mix is constantly spinning with no stop in sight.</span>"
	is_cold_recipe = FALSE
	required_temp = 100
	optimal_temp = 450
	overheat_temp = 900
	temp_exponent_factor = 2.5
	thermic_constant = -425
	rate_up_lim = 15
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_DAMAGING | REACTION_TAG_TOXIN | REACTION_TAG_OTHER

/datum/chemical_reaction/anacea
	results = list(/datum/reagent/toxin/anacea = 3)
	required_reagents = list(/datum/reagent/medicine/haloperidol = 1, /datum/reagent/impedrezene = 1, /datum/reagent/uranium/radium = 1)
	mix_message = "The mixture turns into a strange green ooze."
	is_cold_recipe = FALSE
	required_temp = 100
	optimal_temp = 450
	overheat_temp = 900
	temp_exponent_factor = 1.6
	thermic_constant = 250
	rate_up_lim = 10
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_DAMAGING | REACTION_TAG_TOXIN | REACTION_TAG_OTHER

/datum/chemical_reaction/mimesbane
	results = list(/datum/reagent/toxin/mimesbane = 3)
	required_reagents = list(/datum/reagent/uranium/radium = 1, /datum/reagent/toxin/mutetoxin = 1, /datum/reagent/consumable/nothing = 1)
	mix_message = "The mixture turns into an indescribable white."
	is_cold_recipe = FALSE
	required_temp = 100
	optimal_temp = 450
	overheat_temp = 900
	temp_exponent_factor = 1.5
	thermic_constant = -400
	rate_up_lim = 15
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_DAMAGING | REACTION_TAG_OTHER

/datum/chemical_reaction/bonehurtingjuice
	results = list(/datum/reagent/toxin/bonehurtingjuice = 5)
	required_reagents = list(/datum/reagent/toxin/mutagen = 1, /datum/reagent/toxin/itching_powder = 3, /datum/reagent/consumable/milk = 1)
	mix_message = "<span class='danger'>The mixture suddenly becomes clear and looks a lot like water. You feel a strong urge to drink it.</span>"
	is_cold_recipe = FALSE
	required_temp = 100
	optimal_temp = 450
	overheat_temp = 900
	temp_exponent_factor = 0.5
	thermic_constant = -400
	rate_up_lim = 15
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_DAMAGING | REACTION_TAG_OTHER
