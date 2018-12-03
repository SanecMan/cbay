/obj/crate
	desc = "A crate."
	name = "Crate"
	icon = 'icons/obj/storage.dmi'
	icon_state = "crate"
	density = 1
	var/openicon = "crateopen"
	var/closedicon = "crate"
	req_access = null
	var/opened = 0
	var/locked = 0
	flags = FPRINT
	m_amt = 7500
	mouse_drag_pointer = MOUSE_ACTIVE_POINTER

/obj/crate/internals
	desc = "A internals crate."
	name = "Internals crate"
	icon = 'icons/obj/storage.dmi'
	icon_state = "o2crate"
	density = 1
	openicon = "o2crateopen"
	closedicon = "o2crate"

/obj/crate/medical
	desc = "A medical crate."
	name = "Medical crate"
	icon = 'icons/obj/storage.dmi'
	icon_state = "medicalcrate"
	density = 1
	openicon = "medicalcrateopen"
	closedicon = "medicalcrate"

/obj/crate/rcd
	desc = "A crate for the storage of the RCD."
	name = "RCD crate"
	icon = 'icons/obj/storage.dmi'
	icon_state = "crate"
	density = 1
	openicon = "crateopen"
	closedicon = "crate"

/obj/crate/engineering
	desc = "A crate for the storage of engineering equipment."
	name = "Engineering crate"
	icon = 'icons/obj/storage.dmi'
	icon_state = "crate"
	density = 1
	openicon = "crateopen"
	closedicon = "crate"
/obj/crate/engineeringsuits
	desc = "A crate for the storage of engineering space suits."
	name = "Engineering crate"
	icon = 'icons/obj/storage.dmi'
	icon_state = "crate"
	density = 1
	openicon = "crateopen"
	closedicon = "crate"

/obj/crate/freezer
	desc = "A freezer."
	name = "Freezer"
	icon = 'icons/obj/storage.dmi'
	icon_state = "freezer"
	density = 1
	openicon = "freezeropen"
	closedicon = "freezer"

/obj/crate/bin
	desc = "A large bin."
	name = "Large bin"
	icon = 'icons/obj/storage.dmi'
	icon_state = "largebin"
	density = 1
	openicon = "largebinopen"
	closedicon = "largebin"

/obj/crate/secure/weapon
	desc = "A secure weapons crate."
	name = "Weapons crate"
	icon = 'icons/obj/storage.dmi'
	icon_state = "weaponcrate"
	density = 1
	openicon = "weaponcrateopen"
	closedicon = "weaponcrate"

/obj/crate/secure/plasma
	desc = "A secure plasma crate."
	name = "Plasma crate"
	icon = 'icons/obj/storage.dmi'
	icon_state = "plasmacrate"
	density = 1
	openicon = "plasmacrateopen"
	closedicon = "plasmacrate"
	req_access = list(access_tox)

/obj/crate/secure/gear
	desc = "A secure gear crate."
	name = "Gear crate"
	icon = 'icons/obj/storage.dmi'
	icon_state = "secgearcrate"
	density = 1
	openicon = "secgearcrateopen"
	closedicon = "secgearcrate"

/obj/crate/secure/bin
	desc = "A secure bin."
	name = "Secure bin"
	icon_state = "largebins"
	openicon = "largebinsopen"
	closedicon = "largebins"
	redlight = "largebinr"
	greenlight = "largebing"
	sparks = "largebinsparks"
	emag = "largebinemag"

/obj/crate/secure
	desc = "A secure crate."
	name = "Secure crate"
	icon_state = "securecrate"
	openicon = "securecrateopen"
	closedicon = "securecrate"
	var/redlight = "securecrater"
	var/greenlight = "securecrateg"
	var/sparks = "securecratesparks"
	var/emag = "securecrateemag"
	var/broken = 0
	locked = 1
	req_access = list(access_security)


/obj/crate/New()
	..()
	spawn(1)
		if(!opened)		// if closed, any item at the crate's loc is put in the contents
			for(var/obj/item/I in src.loc)
				if(I.density || I.anchored || I == src) continue
				I.loc = src

/obj/crate/secure/New()
	..()
	if(locked)
		overlays = null
		overlays += redlight
	else
		overlays = null
		overlays += greenlight

/obj/crate/internals/New()
	..()
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/weapon/tank/air(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/weapon/tank/air(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/weapon/tank/air(src)

/obj/crate/engineering/New()
	..()
	new /obj/item/weapon/weldingtool(src)
	new /obj/item/weapon/weldingtool(src)
	new /obj/item/weapon/wrench(src)
	new /obj/item/weapon/wrench(src)
	new /obj/item/clothing/head/helmet/welding(src)
	new /obj/item/clothing/head/helmet/welding(src)
/obj/crate/engineeringsuits/New()
	..()
	new /obj/item/clothing/head/helmet/space/spaceengi(src)
	new /obj/item/clothing/suit/space/spaceengi(src)
	new /obj/item/clothing/head/helmet/space/spaceengi(src)
	new /obj/item/clothing/suit/space/spaceengi(src)
/obj/crate/rcd/New()
	..()
	new /obj/item/weapon/rcd_ammo(src)
	new /obj/item/weapon/rcd_ammo(src)
	new /obj/item/weapon/rcd_ammo(src)
	new /obj/item/weapon/rcd(src)

/obj/crate/proc/open()
	playsound(src.loc, 'sound/machines/click.ogg', 15, 1, -3)

	for(var/obj/O in src)
		O.loc = get_turf(src)
	for(var/mob/M in src)
		M.loc = get_turf(src)

	icon_state = openicon
	src.opened = 1

/obj/crate/proc/close()
	playsound(src.loc, 'sound/machines/click.ogg', 15, 1, -3)
	for(var/obj/O in get_turf(src))
		if(O.density || O.anchored || O == src) continue
		O.loc = src
	icon_state = closedicon
	src.opened = 0

/obj/crate/attack_hand(mob/user as mob)
	if(!locked)
		if(opened) close()
		else open()
	else
		user << "\red It's locked."
	return

/obj/crate/secure/attack_hand(mob/user as mob)
	if(locked && allowed(user) && !broken)
		user << "\blue You unlock the [src]."
		src.locked = 0
		overlays = null
		overlays += greenlight
	return ..()

/obj/crate/secure/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/cargotele))
		W:cargoteleport(src,user)
		return
	if(istype(user,/mob/living/silicon))
		return attack_hand(user)
	if(istype(W, /obj/item/weapon/card) && src.allowed(user) && !locked && !opened && !broken)
		user << "\red You lock the [src]."
		src.locked = 1
		overlays = null
		overlays += redlight
		return
	else if (istype(W, /obj/item/weapon/card/emag) && locked &&!broken)
		overlays = null
		overlays += emag
		overlays += sparks
		spawn(6) overlays -= sparks //Tried lots of stuff but nothing works right. so i have to use this *sadface*
		playsound(src.loc, 'sound/effects/sparks4.ogg', 75, 1)
		src.locked = 0
		src.broken = 1
		user << "\blue You unlock the [src]."
		return

	return ..()

/obj/crate/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/crate/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/cargotele))
		W:cargoteleport(src,user)
		return
	if(istype(user,/mob/living/silicon))
		return attack_hand(user)
	if(opened)
		user.drop_item()
		W.loc = src.loc
	else return attack_hand(user)