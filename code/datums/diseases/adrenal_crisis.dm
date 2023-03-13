/datum/disease/adrenal_crisis
	form = "Condition"
	name = "Adrenal Crisis"
	max_stages = 2
	cure_text = "Trauma"
	cure_chance = 10
	agent = "Shitty Adrenal Glands"
	viable_mobtypes = list(/mob/living/carbon/human)
	permeability_mod = 1
	desc = "If left untreated the subject will suffer from lethargy, dizziness and periodic loss of conciousness."
	severity = DISEASE_SEVERITY_MEDIUM
	disease_flags = CAN_CARRY|CAN_RESIST
	spread_flags = DISEASE_SPREAD_NON_CONTAGIOUS
	visibility_flags = HIDDEN_PANDEMIC
	bypasses_immunity = TRUE

/datum/disease/adrenal_crisis/stage_act(delta_time, times_fired)
	. = ..()
	if(!.)
		return

	switch(stage)
		if(1)
			if(DT_PROB(2.5, delta_time))
				to_chat(affected_mob, span_warning(pick("You feel lightheaded.", "You feel lethargic.")))
		if(2)
			if(DT_PROB(5, delta_time))
				affected_mob.Unconscious(40)

			if(DT_PROB(10, delta_time))
				affected_mob.adjust_timed_status_effect(14 SECONDS, /datum/status_effect/speech/slurring/drunk)

			if(DT_PROB(7, delta_time))
				affected_mob.set_timed_status_effect(20 SECONDS, /datum/status_effect/dizziness, only_if_higher = TRUE)

			if(DT_PROB(2.5, delta_time))
				to_chat(affected_mob, span_warning(pick("You feel pain shoot down your legs!", "You feel like you are going to pass out at any moment.", "You feel really dizzy.")))
