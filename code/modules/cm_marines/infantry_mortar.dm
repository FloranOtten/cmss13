#define INFANTRY_MORTAR_SETUP_TIME (1 SECONDS)

/obj/item/device/m56d_gun/infantry_mortar
	name = "51mm Mortar"
	desc = "A low-caliber infantry mortar, intended for close-range fire support"
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/USCM/grenade_launchers.dmi'
	icon_state = "infantry_mortar_collapsed"



/obj/item/device/m56d_gun/infantry_mortar/attack_self(mob/user)
	..()
	if(!do_after(user, INFANTRY_MORTAR_SETUP_TIME, INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_BUILD))
		return


	var/obj/structure/machinery/m56d_hmg/infantry_mortar/mortar = new(user.loc)
	transfer_label_component(mortar)
	mortar.setDir(user.dir) // Make sure we face the right direction
	mortar.anchored = TRUE
	playsound(mortar, 'sound/items/m56dauto_setup.ogg', 75, TRUE)
	to_chat(user, SPAN_NOTICE("You deploy []."))
	qdel(src)

/obj/structure/machinery/m56d_hmg/infantry_mortar
	name = "\improper 51mm Infantry Mortar"
	desc = "A low-caliber infantry mortar, intended for close-range fire support"
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/USCM/grenade_launchers.dmi'
	icon_state = "infantry_mortar"
	icon_full = "infantry_mortar"
	icon_empty = "infantry_mortar"
	rounds_max = 1
	ammo = /obj/item/explosive/grenade


/obj/item/device/m56d_gun/infantry_mortar/update_icon()
	return

/obj/structure/machinery/m56d_hmg/infantry_mortar/attackby(obj/item/O as obj, mob/user as mob) //This will be how we take it apart.
	if(!ishuman(user) && !HAS_TRAIT(user, TRAIT_OPPOSABLE_THUMBS))
		return ..()

	if(QDELETED(O))
		return

	if(HAS_TRAIT(O, TRAIT_TOOL_WRENCH)) // Let us rotate this stuff.
		if(locked)
			to_chat(user, "This one is anchored in place and cannot be rotated.")
			return
		else
			playsound(src.loc, 'sound/items/Ratchet.ogg', 25, 1)
			user.visible_message("[user] rotates [src].", "You rotate [src].")
			setDir(turn(dir, -90))
			if(operator)
				update_pixels(operator)
		return

	if(HAS_TRAIT(O, TRAIT_TOOL_SCREWDRIVER)) // Lets take it apart.
		if(locked)
			to_chat(user, "This one cannot be disassembled.")
		else
			to_chat(user, "You begin disassembling [src]...")

			var/disassemble_time = 30
			if(do_after(user, disassemble_time * user.get_skill_duration_multiplier(SKILL_ENGINEER), INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_BUILD))
				user.visible_message(SPAN_NOTICE("[user] disassembles [src]!"), SPAN_NOTICE("You disassemble [src]!"))
				playsound(src.loc, 'sound/items/Screwdriver.ogg', 25, 1)
				var/obj/item/device/m56d_gun/infantry_mortar/mortar = new(loc)
				transfer_label_component(mortar)
				mortar.rounds = rounds
				mortar.has_mount = TRUE
				mortar.health = health
				qdel(src)
				return

	if(istype(O, /obj/item/explosive/grenade)) // RELOADING DOCTOR FREEMAN.
		if(!skillcheck(user, SKILL_FIREARMS, SKILL_FIREARMS_TRAINED))
			if(user.action_busy)
				return
			if(!do_after(user, 25 * user.get_skill_duration_multiplier(SKILL_ENGINEER), INTERRUPT_ALL, BUSY_ICON_FRIENDLY))
				return
		user.visible_message(SPAN_NOTICE("[user] loads [src]!"), SPAN_NOTICE("You load [src]!"))
		rounds = 1
		user.temp_drop_inv_item(O)
		qdel(O)
		return

	if(iswelder(O))
		if(!HAS_TRAIT(O, TRAIT_TOOL_BLOWTORCH))
			to_chat(user, SPAN_WARNING("You need a stronger blowtorch!"))
			return
		if(user.action_busy)
			return

		var/obj/item/tool/weldingtool/WT = O

		if(health == health_max)
			to_chat(user, SPAN_WARNING("[src] doesn't need repairs."))
			return

		if(WT.remove_fuel(0, user))
			user.visible_message(SPAN_NOTICE("[user] begins repairing damage to [src]."),
				SPAN_NOTICE("You begin repairing the damage to [src]."))
			playsound(src.loc, 'sound/items/Welder2.ogg', 25, 1)
			if(do_after(user, 5 SECONDS * user.get_skill_duration_multiplier(SKILL_ENGINEER), INTERRUPT_ALL, BUSY_ICON_FRIENDLY, src))
				user.visible_message(SPAN_NOTICE("[user] repairs some damage on [src]."),
					SPAN_NOTICE("You repair [src]."))
				update_health(-floor(health_max*0.2))
				playsound(src.loc, 'sound/items/Welder2.ogg', 25, 1)
		else
			to_chat(user, SPAN_WARNING("You need more fuel in [WT] to repair damage to [src]."))
		return
	return ..()
