/proc/captain_announce(var/text)
	world << "<h1 class='alert'>Captain Announces</h1>"
	world << "<span class='alert'>[sanitize(text)]</span>"
	world << "<br>"

// The communications computer

/obj/machinery/computer/communications/process()
	..()
	if(state != STATE_STATUSDISPLAY)
		src.updateDialog()

/obj/machinery/computer/communications/Topic(href, href_list)
	if(..())
		return
	usr.machine = src

	if(!href_list["operation"])
		return
	switch(href_list["operation"])
		// main interface
		if("main")
			src.state = STATE_DEFAULT
		if("login")
			var/mob/M = usr
			var/obj/item/weapon/card/id/I = M.equipped()
			if (istype(I, /obj/item/device/pda))
				var/obj/item/device/pda/pda = I
				I = pda.id
			if (I && istype(I))
				if(src.check_access(I))
					authenticated = 1
				if(20 in I.access) //captain
					authenticated = 2
		if("logout")
			authenticated = 0
		if("nolockdown")
			disablelockdown(usr)
			post_status("alert", "default")
		if("call-prison")
			PrisonControl.start()
			radioalert("Prison Notice", "Prisoner Shuttle launching in one minute.")
		if("recall-prison")
			PrisonControl.recall()
			radioalert("Prison Notice", "Prisoner Shuttle returning in two minutes.")
		if("call-mining")
			MiningControl.start()
			radioalert("Archaeologist Notice", "Archaeologist Shuttle launching in thirty seconds.")
		if("recall-mining")
			MiningControl.recall()
			radioalert("Archaeologist Notice", "Archaeologist Shuttle returning in thirty seconds.")
		if("announce")
			if(src.authenticated==2)
				var/input = input(usr, "Please choose a message to announce to the station crew.", "What?", "")
				if(!input)
					return
				if(get_dist(usr.loc,src.loc) > 1) //dont "open and say from everywhere" abuse
					return
				captain_announce(input)
				log_admin("[key_name(usr)] has made a captain announcement: [input]")
				message_admins("[key_name_admin(usr)] has made a captain announcement.", 1)
		if("callshuttle")
			src.state = STATE_DEFAULT
			if(src.authenticated)
				src.state = STATE_CALLSHUTTLE
		if("callshuttle2")
			if(src.authenticated)
				call_shuttle_proc(usr)

				if(LaunchControl.online)
					post_status("shuttle")

			src.state = STATE_DEFAULT
		if("cancelshuttle")
			src.state = STATE_DEFAULT
			if(src.authenticated)
				src.state = STATE_CANCELSHUTTLE
		if("cancelshuttle2")
			if(src.authenticated)
				cancel_call_proc(usr)
			src.state = STATE_DEFAULT
		if("messagelist")
			src.currmsg = 0
			src.state = STATE_MESSAGELIST
		if("viewmessage")
			src.state = STATE_VIEWMESSAGE
			if (!src.currmsg)
				if(href_list["message-num"])
					src.currmsg = text2num(href_list["message-num"])
				else
					src.state = STATE_MESSAGELIST
		if("delmessage")
			src.state = (src.currmsg) ? STATE_DELMESSAGE : STATE_MESSAGELIST
		if("delmessage2")
			if(src.authenticated)
				if(src.currmsg)
					var/title = src.messagetitle[src.currmsg]
					var/text  = src.messagetext[src.currmsg]
					src.messagetitle.Remove(title)
					src.messagetext.Remove(text)
					if(src.currmsg == src.aicurrmsg)
						src.aicurrmsg = 0
					src.currmsg = 0
				src.state = STATE_MESSAGELIST
			else
				src.state = STATE_VIEWMESSAGE
		if("status")
			src.state = STATE_STATUSDISPLAY
		// Status display stuff
		if("setstat")
			switch(href_list["statdisp"])
				if("message")
					post_status("message", stat_msg1, stat_msg2)
				if("alert")
					post_status("alert", href_list["alert"])
				else
					post_status(href_list["statdisp"])

		if("setmsg1")
			stat_msg1 = input("Line 1", "Enter Message Text", stat_msg1) as text|null
			src.updateDialog()
		if("setmsg2")
			stat_msg2 = input("Line 2", "Enter Message Text", stat_msg2) as text|null
			src.updateDialog()
		if("toggle-redalert")
			var/area/CurArea = get_area(src)
			CurArea.redalert = !CurArea.redalert
			spawn(0)
				for(var/area/ToggleAlert in world)
					if (ToggleAlert.applyalertstatus && ToggleAlert.type != /area)
						ToggleAlert.redalert = CurArea.redalert

		// AI interface
		if("ai-main")
			src.aicurrmsg = 0
			src.aistate = STATE_DEFAULT
		if("ai-callshuttle")
			src.aistate = STATE_CALLSHUTTLE
		if("ai-callshuttle2")
			call_shuttle_proc(usr)
			src.aistate = STATE_DEFAULT
		if("ai-messagelist")
			src.aicurrmsg = 0
			src.aistate = STATE_MESSAGELIST
		if("ai-viewmessage")
			src.aistate = STATE_VIEWMESSAGE
			if (!src.aicurrmsg)
				if(href_list["message-num"])
					src.aicurrmsg = text2num(href_list["message-num"])
				else
					src.aistate = STATE_MESSAGELIST
		if("ai-delmessage")
			src.aistate = (src.aicurrmsg) ? STATE_DELMESSAGE : STATE_MESSAGELIST
		if("ai-delmessage2")
			if(src.aicurrmsg)
				var/title = src.messagetitle[src.aicurrmsg]
				var/text  = src.messagetext[src.aicurrmsg]
				src.messagetitle.Remove(title)
				src.messagetext.Remove(text)
				if(src.currmsg == src.aicurrmsg)
					src.currmsg = 0
				src.aicurrmsg = 0
			src.aistate = STATE_MESSAGELIST
		if("ai-status")
			src.aistate = STATE_STATUSDISPLAY
	src.updateUsrDialog()

/proc/disablelockdown(var/mob/usr)
	world << "\red Lockdown cancelled by [usr.name]!"

	for(var/obj/machinery/firealarm/FA in world) //deactivate firealarms
		spawn( 0 )
			if(FA.lockdownbyai == 1)
				FA.lockdownbyai = 0
				FA.reset()
	for(var/obj/machinery/door/airlock/AL in world) //open airlocks
		spawn ( 0 )
			if(AL.canAIControl() && AL.lockdownbyai == 1)
				AL.open()
				AL.lockdownbyai = 0

/obj/machinery/computer/communications/attackby(I as obj, user as mob)
	if(istype(I, /obj/item/weapon/screwdriver))
		playsound(src.loc, 'OGGS/items/Screwdriver.ogg', 50, 1)
		if(do_after(user, 20))
			if (src.stat & BROKEN)
				user << "\blue The broken glass falls out."
				var/obj/computerframe/A = new /obj/computerframe( src.loc )
				new /obj/item/weapon/shard( src.loc )
				var/obj/item/weapon/circuitboard/communications/M = new /obj/item/weapon/circuitboard/communications( A )
				for (var/obj/C in src)
					C.loc = src.loc
				A.circuit = M
				A.state = 3
				A.icon_state = "3"
				A.anchored = 1
				del(src)
			else
				user << "\blue You disconnect the monitor."
				var/obj/computerframe/A = new /obj/computerframe( src.loc )
				var/obj/item/weapon/circuitboard/communications/M = new /obj/item/weapon/circuitboard/communications( A )
				for (var/obj/C in src)
					C.loc = src.loc
				A.circuit = M
				A.state = 4
				A.icon_state = "4"
				A.anchored = 1
				del(src)
	else
		src.attack_hand(user)
	return

/obj/machinery/computer/communications/attack_ai(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/communications/attack_paw(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/communications/attack_hand(var/mob/user as mob)
	if(..())
		return

	user.machine = src
	var/dat = "<head><title>Communications Console</title></head><body>"
	if (LaunchControl.online && main_shuttle.location==0)
		var/timeleft = LaunchControl.timeleft()
		dat += "<B>Escape Pod Launch Sequence</B>\n<BR>\nETA: [timeleft / 60 % 60]:[add_zero(num2text(timeleft % 60), 2)]<BR>"

	if (istype(user, /mob/living/silicon))
		var/dat2 = src.interact_ai(user) // give the AI a different interact proc to limit its access
		if(dat2)
			dat +=  dat2
			user << browse(dat, "window=communications;size=400x500")
			onclose(user, "communications")
		return

	switch(src.state)
		if(STATE_DEFAULT)
			if (src.authenticated)
				dat += "<BR>\[ <A HREF='?src=\ref[src];operation=logout'>Log Out</A> \]"
				if(PrisonControl.departed)
					dat += "<BR>Prison Shuttle is in flight..."
				else if(PrisonControl.location == 1)
					dat += "<BR>\[ <A HREF='?src=\ref[src];operation=call-prison'>Send Prison Shuttle</A> \]"
				else
					dat += "<BR>\[ <A HREF='?src=\ref[src];operation=recall-prison'>Recall Prison Shuttle</A> \]"

				if(MiningControl.departed)
					dat += "<BR>Archaeologist Shuttle is in flight..."
				else if(MiningControl.location == 1)
					dat += "<BR>\[ <A HREF='?src=\ref[src];operation=call-mining'>Send Archaeologist Shuttle</A> \]"
				else
					dat += "<BR>\[ <A HREF='?src=\ref[src];operation=recall-mining'>Recall Archaeologist Shuttle</A> \]"

				//dat += "<BR>\[ <A HREF='?src=\ref[src];operation=call-prison'>Send Prison Shutle</A> \]"
				dat += "<BR>\[ <A HREF='?src=\ref[src];operation=nolockdown'>Disable Lockdown</A> \]"
				if (src.authenticated==2)
					dat += "<BR>\[ <A HREF='?src=\ref[src];operation=announce'>Make An Announcement</A> \]"
				var/area/CurArea = get_area(src)
				if (CurArea.redalert)
					dat += "<BR>\[ <A HREF='?src=\ref[src];operation=toggle-redalert'>Cancel Red Alert</A> \]"
				else
					dat += "<BR>\[ <A HREF='?src=\ref[src];operation=toggle-redalert'>Declare Red Alert</A> \]"
				if(main_shuttle.location == 1)
					if (LaunchControl.online)
						dat += "<BR>\[ <A HREF='?src=\ref[src];operation=cancelshuttle'>Cancel Escape Pod Launch</A> \]"
					else
						dat += "<BR>\[ <A HREF='?src=\ref[src];operation=callshuttle'>Start Escape Pod Launch</A> \]"

				dat += "<BR>\[ <A HREF='?src=\ref[src];operation=status'>Set Status Display</A> \]"
			else
				dat += "<BR>\[ <A HREF='?src=\ref[src];operation=login'>Log In</A> \]"
			dat += "<BR>\[ <A HREF='?src=\ref[src];operation=messagelist'>Message List</A> \]"
		if(STATE_CALLSHUTTLE)
			dat += "Are you sure you want to start the escape pod launch sequence? \[ <A HREF='?src=\ref[src];operation=callshuttle2'>OK</A> | <A HREF='?src=\ref[src];operation=main'>Cancel</A> \]"
		if(STATE_CANCELSHUTTLE)
			dat += "Are you sure you want to cancel the escape pod launch sequence? \[ <A HREF='?src=\ref[src];operation=cancelshuttle2'>OK</A> | <A HREF='?src=\ref[src];operation=main'>Cancel</A> \]"
		if(STATE_MESSAGELIST)
			dat += "Messages:"
			for(var/i = 1; i<=src.messagetitle.len; i++)
				dat += "<BR><A HREF='?src=\ref[src];operation=viewmessage;message-num=[i]'>[src.messagetitle[i]]</A>"
		if(STATE_VIEWMESSAGE)
			if (src.currmsg)
				dat += "<B>[src.messagetitle[src.currmsg]]</B><BR><BR>[src.messagetext[src.currmsg]]"
				if (src.authenticated)
					dat += "<BR><BR>\[ <A HREF='?src=\ref[src];operation=delmessage'>Delete \]"
			else
				src.state = STATE_MESSAGELIST
				src.attack_hand(user)
				return
		if(STATE_DELMESSAGE)
			if (src.currmsg)
				dat += "Are you sure you want to delete this message? \[ <A HREF='?src=\ref[src];operation=delmessage2'>OK</A> | <A HREF='?src=\ref[src];operation=viewmessage'>Cancel</A> \]"
			else
				src.state = STATE_MESSAGELIST
				src.attack_hand(user)
				return
		if(STATE_STATUSDISPLAY)
			dat += "Set Status Displays<BR>"
			dat += "\[ <A HREF='?src=\ref[src];operation=setstat;statdisp=blank'>Clear</A> \]<BR>"
			dat += "\[ <A HREF='?src=\ref[src];operation=setstat;statdisp=shuttle'>Shuttle ETA</A> \]<BR>"
			dat += "\[ <A HREF='?src=\ref[src];operation=setstat;statdisp=message'>Message</A> \]"
			dat += "<ul><li> Line 1: <A HREF='?src=\ref[src];operation=setmsg1'>[ stat_msg1 ? stat_msg1 : "(none)"]</A>"
			dat += "<li> Line 2: <A HREF='?src=\ref[src];operation=setmsg2'>[ stat_msg2 ? stat_msg2 : "(none)"]</A></ul><br>"
			dat += "\[ Alert: <A HREF='?src=\ref[src];operation=setstat;statdisp=alert;alert=default'>None</A> |"
			dat += " <A HREF='?src=\ref[src];operation=setstat;statdisp=alert;alert=redalert'>Red Alert</A> |"
			dat += " <A HREF='?src=\ref[src];operation=setstat;statdisp=alert;alert=lockdown'>Lockdown</A> |"
			dat += " <A HREF='?src=\ref[src];operation=setstat;statdisp=alert;alert=biohazard'>Biohazard</A> \]<BR><HR>"


	dat += "<BR>\[ [(src.state != STATE_DEFAULT) ? "<A HREF='?src=\ref[src];operation=main'>Main Menu</A> | " : ""]<A HREF='?src=\ref[user];mach_close=communications'>Close</A> \]"
	user << browse(dat, "window=communications;size=400x500")
	onclose(user, "communications")

/obj/machinery/computer/communications/proc/interact_ai(var/mob/living/silicon/ai/user as mob)
	var/dat = ""
	switch(src.aistate)
		if(STATE_DEFAULT)
			if(main_shuttle.location == 1 && !LaunchControl.online)
				dat += "<BR>\[ <A HREF='?src=\ref[src];operation=ai-callshuttle'>Start Escape Pod Launch</A> \]"
			dat += "<BR>\[ <A HREF='?src=\ref[src];operation=call-prison'>Send Prison Shutle</A> \]"
			dat += "<BR>\[ <A HREF='?src=\ref[src];operation=ai-messagelist'>Message List</A> \]"
			dat += "<BR>\[ <A HREF='?src=\ref[src];operation=nolockdown'>Disable Lockdown</A> \]"
			var/area/CurArea = get_area(src)
			if (CurArea.redalert)
				dat += "<BR>\[ <A HREF='?src=\ref[src];operation=toggle-redalert'>Cancel Red Alert</A> \]"
			else
				dat += "<BR>\[ <A HREF='?src=\ref[src];operation=toggle-redalert'>Declare Red Alert</A> \]"
			dat += "<BR>\[ <A HREF='?src=\ref[src];operation=ai-status'>Set Status Display</A> \]"
		if(STATE_CALLSHUTTLE)
			dat += "Are you sure you want to start the escape pod launch sequence? \[ <A HREF='?src=\ref[src];operation=ai-callshuttle2'>OK</A> | <A HREF='?src=\ref[src];operation=ai-main'>Cancel</A> \]"
		if(STATE_MESSAGELIST)
			dat += "Messages:"
			for(var/i = 1; i<=src.messagetitle.len; i++)
				dat += "<BR><A HREF='?src=\ref[src];operation=ai-viewmessage;message-num=[i]'>[src.messagetitle[i]]</A>"
		if(STATE_VIEWMESSAGE)
			if (src.aicurrmsg)
				dat += "<B>[src.messagetitle[src.aicurrmsg]]</B><BR><BR>[src.messagetext[src.aicurrmsg]]"
				dat += "<BR><BR>\[ <A HREF='?src=\ref[src];operation=ai-delmessage'>Delete</A> \]"
			else
				src.aistate = STATE_MESSAGELIST
				src.attack_hand(user)
				return null
		if(STATE_DELMESSAGE)
			if(src.aicurrmsg)
				dat += "Are you sure you want to delete this message? \[ <A HREF='?src=\ref[src];operation=ai-delmessage2'>OK</A> | <A HREF='?src=\ref[src];operation=ai-viewmessage'>Cancel</A> \]"
			else
				src.aistate = STATE_MESSAGELIST
				src.attack_hand(user)
				return

		if(STATE_STATUSDISPLAY)
			dat += "Set Status Displays<BR>"
			dat += "\[ <A HREF='?src=\ref[src];operation=setstat;statdisp=blank'>Clear</A> \]<BR>"
			dat += "\[ <A HREF='?src=\ref[src];operation=setstat;statdisp=shuttle'>Shuttle ETA</A> \]<BR>"
			dat += "\[ <A HREF='?src=\ref[src];operation=setstat;statdisp=message'>Message</A> \]"
			dat += "<ul><li> Line 1: <A HREF='?src=\ref[src];operation=setmsg1'>[ stat_msg1 ? stat_msg1 : "(none)"]</A>"
			dat += "<li> Line 2: <A HREF='?src=\ref[src];operation=setmsg2'>[ stat_msg2 ? stat_msg2 : "(none)"]</A></ul><br>"
			dat += "\[ Alert: <A HREF='?src=\ref[src];operation=setstat;statdisp=alert;alert=default'>None</A> |"
			dat += " <A HREF='?src=\ref[src];operation=setstat;statdisp=alert;alert=redalert'>Red Alert</A> |"
			dat += " <A HREF='?src=\ref[src];operation=setstat;statdisp=alert;alert=lockdown'>Lockdown</A> |"
			dat += " <A HREF='?src=\ref[src];operation=setstat;statdisp=alert;alert=biohazard'>Biohazard</A> \]<BR><HR>"


	dat += "<BR>\[ [(src.aistate != STATE_DEFAULT) ? "<A HREF='?src=\ref[src];operation=ai-main'>Main Menu</A> | " : ""]<A HREF='?src=\ref[user];mach_close=communications'>Close</A> \]"
	return dat

/mob/living/silicon/ai/verb/ai_call_shuttle()
	set category = "AI Commands"
	set name = "Launch Pods"
	if(usr.stat == 2)
		usr << "You can't launch the pods because you are dead!"
		return

	var/confirm = alert("Confirm launching pods?",,"Launch pods","Cancel")
	if(confirm == "Cancel")
		return

	call_shuttle_proc(src)

	// hack to display shuttle timer
	if(LaunchControl.online)
		var/obj/machinery/computer/communications/C = locate() in world
		if(C)
			C.post_status("shuttle")

	return

/proc/enable_prison_shuttle(var/mob/user)
	for(var/obj/machinery/computer/prison_shuttle/PS in world)
		PS.allowedtocall = !(PS.allowedtocall)


/proc/call_shuttle_proc(var/mob/user)
	if ((!( ticker ) || main_shuttle.location == 0))
		return

	if (LaunchControl.online)
		user << "\red Launch process already started!"
		return

	if(ticker.mode.name == "blob" || ticker.mode.name == "Corporate Restructuring" || ticker.mode.name == "Sandbox")
		user << "Under directive 7-10, [station_name()] is quarantined until further notice."
		return
	if(ticker.mode.name == "revolution" || ticker.mode.name == "rp-revolution" || ticker.mode.name == "AI malfunction" || ticker.mode.name == "confliction")
		//user << "Centcom will not allow the shuttle to be called."
		user << "The pods are not responding.. how odd." // avoid metagame at all costs!
		return
	if(ticker.mode.name == "nuclear emergency" && world.time < 36000)
		// on nuke, only allow evacuation after an hour
		user << "The pods are not responding.. how odd."
		return
	if(ticker.mode.name == "zombie" && world.time < 36000)
		// on nuke, only allow evacuation after an hour
		user << "The pods are not responding.. how odd."
		return

	LaunchControl.start()

//	main_shuttle.incall()
	world << "\blue <B>Alert: Escape pods launching in [round(LaunchControl.timeleft()/60)] minutes.</B>"

	return

/proc/cancel_call_proc(var/mob/user)
	if ((!( ticker ) || main_shuttle.location != 1 || main_shuttle.direction == 0 || LaunchControl.timeleft() < 30))
		return
	if( ticker.mode.name == "blob" )
		return

	world << "\blue <B>Alert: Escape pods launch sequence aborted</B>" //marker4

	LaunchControl.stop()

	//main_shuttle.recall()

	return

/obj/machinery/computer/communications/proc/post_status(var/command, var/data1, var/data2)

	var/datum/radio_frequency/frequency = radio_controller.return_frequency(status_display_freq)

	if(!frequency) return



	var/datum/signal/status_signal = new
	status_signal.source = src
	status_signal.transmission_method = 1
	status_signal.data["command"] = command

	switch(command)
		if("message")
			status_signal.data["msg1"] = data1
			status_signal.data["msg2"] = data2
		if("alert")
			status_signal.data["picture_state"] = data1

	frequency.post_signal(src, status_signal)



	/*
		receive_signal(datum/signal/signal)

		switch(signal.data["command"])
			if("blank")
				mode = 0

			if("shuttle")
				mode = 1

			if("message")
				set_message(signal.data["msg1"], signal.data["msg2"])

			if("alert")
				set_picture(signal.data["picture_state"])
*/