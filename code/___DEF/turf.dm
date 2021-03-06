/turf
	icon = 'ICON/turf/floors.dmi'
	var/intact = 1

	level = 1.0

	var
		//Properties for open tiles (/floor)
		oxygen = 0
		carbon_dioxide = 0
		nitrogen = 0
		toxins = 0

		//Properties for airtight tiles (/wall)
		thermal_conductivity = 0.05
		heat_capacity = 1

		//Properties for both
		temperature = T20C

		blocks_air = 0
		icon_old = null
		pathweight = 1
		list/obj/machinery/network/wirelessap/wireless = list( )
		explosionstrength = 1 //NEVER SET THIS BELOW 1
		floorstrength = 6


/turf/space
	icon = 'ICON/turf/space.dmi'
	name = "space"
	icon_state = "placeholder"
	var/sand = 0
	temperature = TSPC
	thermal_conductivity = OPEN_HEAT_TRANSFER_COEFFICIENT
	heat_capacity = 700000
	mouse_opacity = 2

/turf/space/sand
	name = "sand"
	icon = 'ICON/obj/sand.dmi'
	icon_state = "placeholder"
	sand = 1
	temperature = T20C + 80


/turf/space/New()
	. = ..()
	if(!sand)
		icon = 'ICON/turf/space.dmi'
		//icon_state = "[rand(1,25)]"
		icon_state = pick("1", "2", "3", "4", "5", "6", "7", "8", "9", "10",
					"11", "12", "13", "14", "15", "16", "17", "18", "19",
					"20", "21", "22", "23", "24", "25")
		/* Just did a quick test: In an otherwise empty project and a 1000x1000 map,
			pick()ing from a list took less than half as long as creating a string
			from the result of rand(). (~3 seconds vs ~7).

			Would be even faster if a numerical index could be used directly,
			without the "[]", though.*/
	else
		icon = 'ICON/obj/sand.dmi'
		icon_state = "[rand(1,3)]"

/turf/space/proc/Check()
	var/turf/T = locate(x, y, z + 1)
	if (T)
		if(istype(T, /turf/space) || istype(T, /turf/unsimulated))
			return
		var/turf/space/S = src
		var/turf/simulated/floor/open/open = new(src)
		open.LightLevelRed = S.LightLevelRed
		open.LightLevelBlue = S.LightLevelBlue
		open.LightLevelGreen = S.LightLevelGreen
		open.ul_UpdateLight()

/turf/simulated/floor/prison			//Its good to be lazy.
	name = "Welcome to Admin Prison"
	wet = 0
	image/wet_overlay = null

	thermite = 0
	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD

/turf/simulated/
	name = "station"
	var/wet = 0
	var/image/wet_overlay = null

	var/thermite = 0
	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD

/turf/simulated/floor/engine
	name = "reinforced floor"
	icon_state = "engine"
	thermal_conductivity = 0.025
	heat_capacity = 325000

/turf/simulated/floor/engine/vacuum
	name = "vacuum floor"
	icon_state = "engine"
	oxygen = 0
	nitrogen = 0.000
	temperature = TSPC

///turf/space/hull //TEST
turf/space/hull
	name = "Hull Plating"
	icon = 'ICON/turf/floors.dmi'
	icon_state = "engine"
turf/space/hull/New()
	return
/*	oxygen = 0
	nitrogen = 0.000
	temperature = TSPC
	thermal_conductivity = OPEN_HEAT_TRANSFER_COEFFICIENT
	heat_capacity = 700000*/
/turf/simulated/floor/

/turf/simulated/floor
	name = "floor"
	icon = 'ICON/turf/afloors.dmi'
	icon_state = "floor"
	thermal_conductivity = 0.040
	heat_capacity = 225000
	var/broken = 0
	var/burnt = 0
	var/turf/simulated/floor/open/open = null

	New()
		..()
		var/turf/T = locate(x,y,z-1)
		if(T)
			if(istype(T, /turf/simulated/floor/open))
				open = T
				open.update()

	Enter(var/atom/movable/AM)
		. = ..()
		if(open && istype(open))
			open.update()

	Exit(var/atom/movable/AM)
		. = ..()
		if(open && istype(open))
			open.update()

	airless
		name = "airless floor"
		oxygen = 0.01
		nitrogen = 0.01
		temperature = TSPC

		New()
			..()
			name = "floor"

	open
		name = "open space"
		intact = 0
		icon_state = "open"
		pathweight = 100000 //Seriously, don't try and path over this one numbnuts
		var/icon/darkoverlays = null
		var/turf/floorbelow
		floorstrength = 1

		mouse_opacity = 2

		New()
			..()
			spawn(1)
				if(!istype(src, /turf/simulated/floor/open)) //This should not be needed but is.
					return

				floorbelow = locate(x, y, z + 1)
				if(ticker)
					add_to_other_zone()
				update()
			var/turf/T = locate(x, y, z + 1)
			if(T)
				//Fortunately, I've done this before. - Aryn
				if(istype(T,/turf/space) || T.z > 4)
					new/turf/space(src)
				else if(!istype(T,/turf/simulated/floor))
					new/turf/simulated/floor/plating(src)
				/*
				switch (T.type) //Somehow, I don't think I thought this cunning plan all the way through - Sukasa
					if (/turf/simulated/floor)
						//Do nothing - valid
					if (/turf/simulated/floor/plating)
						//Do nothing - valid
					if (/turf/simulated/floor/engine)
						//Do nothing - valid
					if (/turf/simulated/floor/engine/vacuum)
						//Do nothing - valid
					if (/turf/simulated/floor/airless)
						//Do nothing - valid
					if (/turf/simulated/floor/grid)
						//Do nothing - valid
					if (/turf/simulated/floor/plating/airless)
						//Do nothing - valid
					if (/turf/simulated/floor/open)
						//Do nothing - valid
					if (/turf/space)
						var/turf/space/F = new(src)									//Then change to a Space tile (no falling into space)
						F.name = F.name
						return
					else
						var/turf/simulated/floor/plating/F = new(src)				//Then change to a floor tile (no falling into unknown crap)
						F.name = F.name
						return*/
		Del()
			if(zone)
				zone.Disconnect(src,floorbelow)
			. = ..()


		Enter(var/atom/movable/AM)
			if (..()) //TODO make this check if gravity is active (future use) - Sukasa
				spawn(1)
					if(AM)
						AM.Move(locate(x, y, z + 1))
						if (istype(AM, /mob))
							AM:bruteloss += 20 //You were totally doin it wrong. 5 damage? Really? - Aryn
							AM:weakened = max(AM:weakened,5)
							AM:updatehealth()
			return ..()


		attackby()


		proc
			update() //Update the overlayss to make the openspace turf show what's down a level

				if(!floorbelow) return
				src.clearoverlays()
				src.addoverlay(floorbelow)

				for(var/obj/o in floorbelow.contents)
					src.addoverlay(image(o, dir=o.dir, layer = TURF_LAYER+0.05*o.layer))

				var/image/I = image('ICON/effects/ULIcons.dmi', "[min(max(floorbelow.LightLevelRed - 4, 0), 7)]-[min(max(floorbelow.LightLevelGreen - 4, 0), 7)]-[min(max(floorbelow.LightLevelBlue - 4, 0), 7)]")
				I.layer = TURF_LAYER + 0.2
				src.addoverlay(I)
				I = image('ICON/effects/ULIcons.dmi', "1-1-1")
				I.layer = TURF_LAYER + 0.2
				src.addoverlay(I)

			process_extra()
				if(!floorbelow) return
				if(istype(floorbelow,/turf/simulated)) //Infeasibly complicated gooncode for the Elder System. =P
					var/turf/simulated/FB = floorbelow
					if(parent && parent.group_processing)
						if(FB.parent && FB.parent.group_processing)
							parent.air.share(FB.parent.air)

						else
							parent.air.share(FB.air)
					else
						if(FB.parent && FB.parent.group_processing)
							air.share(FB.parent.air)
						else
							air.share(FB.air)
					//var/datum/gas_mixture/fb_air = FB.return_air(1)
					//var/datum/gas_mixture/my_air = return_air(1)
					//my_air.share(fb_air)
					//my_air.temperature_share(fb_air,FLOOR_HEAT_TRANSFER_COEFFICIENT)
				else
					air.mimic(floorbelow,1)
					air.temperature_mimic(floorbelow,FLOOR_HEAT_TRANSFER_COEFFICIENT,1)

				if(floorbelow.zone && zone)
					if(!(floorbelow.zone in zone.connections))
						zone.Connect(src,floorbelow)

	plating
		name = "Plating"
		icon_state = "plating"
		intact = 0



/proc/update_open()
	for(var/turf/simulated/floor/open/a in world)
		a.update()

/turf/simulated/floor/plating/airless
	name = "Airless Plating"
	oxygen = 0.01
	nitrogen = 0.01
	temperature = TSPC

	New()
		..()
		name = "plating"

/turf/simulated/floor/grid
	icon = 'ICON/turf/floors.dmi'
	icon_state = "circuit"

/turf/simulated/wall
	name = "Wall"
	icon = 'ICON/turf/high_walls.dmi'
	icon_state = "wall"
	layer = 5
	opacity = 1
	density = 1
	blocks_air = 1
	explosionstrength = 2
	floorstrength = 6
	thermal_conductivity = WALL_HEAT_TRANSFER_COEFFICIENT
	heat_capacity = 312500 //a little over 5 cm thick , 312500 for 1 m by 2.5 m by 0.25 m steel wall
	var/Zombiedamage

/turf/simulated/wall/New()
	..()
	var/icon/I = new('ICON/turf/afloors.dmi', icon_state = "floor")
	underlays += I

/turf/simulated/wall/r_wall
	name = "Reinforced Wall"
	icon = 'ICON/turf/high_walls.dmi'
	icon_state = "r_wall"
	opacity = 1
	density = 1
	var/d_state = 0
	explosionstrength = 4

/turf/simulated/wall/heatshield
	thermal_conductivity = 0
	opacity = 0
	explosionstrength = 5
	name = "Heat Shielding"
	icon = 'ICON/turf/thermal.dmi'
	icon_state = "thermal"

/turf/simulated/wall/heatshield/attackby()
	return
/turf/simulated/wall/heatshield/attack_hand()
	return

/turf/simulated/shuttle
	name = "Shuttle"
	icon = 'ICON/turf/shuttle.dmi'
	thermal_conductivity = 0.05
	heat_capacity = 10000000

/turf/simulated/shuttle/floor
	name = "Shuttle Floor"
	icon_state = "floor"

/turf/simulated/shuttle/wall
	name = "Shuttle Wall"
	icon_state = "wall"
	explosionstrength = 4
	opacity = 1
	density = 1
	blocks_air = 1

/turf/unsimulated
	name = "Command"
	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD

/turf/unsimulated/shuttle
	name = "Shuttle"
	icon = 'ICON/turf/shuttle.dmi'

/turf/unsimulated/shuttle/floor
	name = "Shuttle Floor"
	icon_state = "floor"

/turf/unsimulated/shuttle/wall
	name = "Shuttle Wall"
	icon_state = "wall"
	opacity = 1
	density = 1

/turf/unsimulated/floor
	name = "Floor"
	icon = 'ICON/turf/floors.dmi'
	icon_state = "Floor3"

/turf/unsimulated/wall
	name = "Wall"
	icon = 'ICON/turf/walls.dmi'
	icon_state = "riveted"
	opacity = 1
	density = 1

/turf/unsimulated/wall/other
	icon_state = "r_wall"

/turf/proc
	AdjacentTurfs()

		var/L[] = new()
		for(var/turf/simulated/t in oview(src,1))
			if(!t.density && !LinkBlocked(src, t) && !TurfBlockedNonWindow(t))
				L.Add(t)

		return L
	Railturfs()

		var/L[] = new()
		for(var/turf/simulated/t in oview(src,1))
			if(!t.density && !LinkBlocked(src, t) && !TurfBlockedNonWindow(t))
				if(locate(/obj/rail) in t)
					L.Add(t)

		return L
	Distance(turf/t)
		if(!src || !t)
			return 1e31
		t = get_turf(t)
		if(get_dist(src, t) == 1 || src.z != t.z)
			var/cost = (src.x - t.x) * (src.x - t.x) + (src.y - t.y) * (src.y - t.y) + (src.z - t.z) * (src.z - t.z) * 3
			cost *= (pathweight+t.pathweight)/2
			return cost
		else
			return max(get_dist(src,t), 1)
	AdjacentTurfsSpace()
		var/L[] = new()
		for(var/turf/t in oview(src,1))
			if(!t.density)
				if(!LinkBlocked(src, t) && !TurfBlockedNonWindow(t))
					L.Add(t)

		return L
	process()
		return

/turf/simulated/asteroid
	oxygen = 0.01
	nitrogen = 0.01
	var/mapped = 0
	name = "rocky floor"
	icon = 'ICON/turf/mining.dmi'
	icon_state = "floor"

/turf/simulated/asteroid/wall
	var/health = 40
	name = "rocky wall"
	icon = 'ICON/turf/mining.dmi'
	icon_state = "wall"
	oxygen = 0.01
	nitrogen = 0.01
	opacity = 1
	density = 1
	blocks_air = 1

/turf/simulated/asteroid/wall/planet
	mapped = 1
	thermal_conductivity = 0

/turf/simulated/asteroid/wall/New()
	health+= rand(1)
	..()

/turf/simulated/asteroid/wall/attackby(obj/item/weapon/pickaxe/W, mob/user)
	//if(istype(W, /obj/item/weapon/pickaxe))
	if(W.minelevel > 2) // quick fix
		src.health -= 20
		user << "You use \the [W.name] to hack away part of the unwanted ore."
	else
		src.health -= 5
		user << "The [W.name] wasn't very effective against the ore."
	if(src.health < 1)
		src.mine()

/turf/simulated/asteroid/wall/laser_act(var/obj/beam/e_beam/b)
	var/power = b.power
	//Get the collective laser power
	src.health-=power/100
	if(src.health<1)
		src.mine()

/turf/simulated/asteroid/wall/proc/mine()
	while(!rand(1))
		if(rand(2))
			new/obj/item/weapon/ore(locate(src.x,src.y,src.z))
		else
			new/obj/item/weapon/artifact(locate(src.x,src.y,src.z))
	processing_turfs.Remove(src)
	new/turf/simulated/asteroid/floor(locate(src.x,src.y,src.z))


/turf/simulated/asteroid/floor
	oxygen = 0.01
	nitrogen = 0.01
	level = 1
	name = "rocky floor"
	icon = 'ICON/turf/mining.dmi'
	icon_state = "floor"

/turf/simulated/asteroid/floor/planet
	mapped = 1
	name = "sand"
	icon = 'ICON/obj/sand.dmi'
	icon_state = "placeholder"
	carbon_dioxide = 0.3 * ONE_ATMOSPHERE
	toxins = 0.54 * ONE_ATMOSPHERE
	nitrogen = 0.03 * ONE_ATMOSPHERE
	temperature = 742

/turf/simulated/asteroid/floor/planet/New()
	icon_state = "sand[rand(1,3)]"
	return ..()

/turf/simulated/floor/cyberstone
	icon = 'ICON/turf/floorsm.dmi'
	icon_state = "s-1"

/turf/simulated/floor/cyberstone/New()
	icon_state = "s-[rand(1,8)]"
	return ..()

/turf/simulated/floor/cyber
	icon = 'ICON/turf/floorsm.dmi'
	icon_state = "cyberfloor"

/turf/simulated/wall/b_wall
	name = "Bar Wall"
	icon = 'ICON/turf/walls.dmi'
	icon_state = "bwall0"
	opacity = 1
	density = 1
	explosionstrength = 8

/turf/simulated/wall/dark_wall
	name = "Wall"
	icon = 'ICON/turf/wallsdark.dmi'
	icon_state = "bwall0"
	opacity = 1
	density = 1
	explosionstrength = 8