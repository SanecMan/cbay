/datum/disease/cold
	name = "The Cold"
	max_stages = 4
	spread = "Airborne"
	cure = "Rest"
	affected_species = list("Human")
	resistant = 1

/datum/disease/cold/stage_act()
	..()
	if (!affected_mob.stat != 2)
		return
	switch(stage)
		if(2)
			if(affected_mob.sleeping && prob(40))
				affected_mob << "\blue You feel better."
				affected_mob.resistances += affected_mob.virus.type
				affected_mob.virus = null
				return
			if(prob(1) && prob(10))
				affected_mob << "\blue You feel better."
				affected_mob.resistances += affected_mob.virus.type
				affected_mob.virus = null
				return
			if(prob(15))
				affected_mob.emote("sneeze")
			if(prob(5))
				affected_mob.emote("cough")
			if(prob(30))
				affected_mob << "\red Your throat feels sore."
			if(prob(1))
				affected_mob << "\red Mucous runs down the back of your throat."
		if(3)
			if(affected_mob.sleeping && prob(25))
				affected_mob << "\blue You feel better."
				affected_mob.resistances += affected_mob.virus.type
				affected_mob.virus = null
				return
			if(prob(1) && prob(10))
				affected_mob << "\blue You feel better."
				affected_mob.resistances += affected_mob.virus.type
				affected_mob.virus = null
			if(prob(20))
				affected_mob.emote("sneeze")
			if(prob(10))
				affected_mob.emote("cough")
			if(prob(40))
				affected_mob << "\red Your throat feels sore."
			if(prob(32))
				affected_mob << "\red Mucous runs down the back of your throat."
		if(4)
			if(affected_mob.sleeping && prob(25))
				affected_mob << "\blue You feel better."
				affected_mob.resistances += affected_mob.virus.type
				affected_mob.virus = null
				return
			if(prob(1) && prob(10))
				affected_mob << "\blue You feel better."
				affected_mob.resistances += affected_mob.virus.type
				affected_mob.virus = null
			if(prob(1))
				affected_mob.emote("gasp")
			if(prob(25))
				affected_mob.contract_disease(new /datum/disease/flu,1)