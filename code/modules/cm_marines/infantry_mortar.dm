#define INFANTRY_MORTAR_SETUP_TIME (1 SECONDS)

/obj/item/device/infantry_mortar
	name = "51mm Mortar"
	desc = "A low-caliber infantry mortar, intended for close-range fire support"
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/USCM/grenade_launchers.dmi'
	icon_state = "infantry_mortar_collapsed"


/obj/item/device/infantry_mortar/attack_self(mob/user)
	..()
	if(!do_after(user, INFANTRY_MORTAR_SETUP_TIME, INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_BUILD))
		return


	var/obj/structure/machinery/infantry_mortar/mortar = new(user.loc)
	transfer_label_component(mortar)
	mortar.setDir(user.dir) // Make sure we face the right direction
	mortar.anchored = TRUE
	playsound(mortar, 'sound/items/m56dauto_setup.ogg', 75, TRUE)
	to_chat(user, SPAN_NOTICE("You deploy []."))
	qdel(src)

/obj/structure/machinery/infantry_mortar
	name = "\improper 51mm Infantry Mortar"
	desc = "A low-caliber infantry mortar, intended for close-range fire support"
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/USCM/grenade_launchers.dmi'
	icon_state = "infantry_mortar"
