
 
automacro Novice_potion_over {
    exclusive 1
    InInventoryID 569 < 20
	InStorageID 569 = 0
    call Set_Buy_Meat
}

macro Set_Buy_Meat {
	$buyautoMeat = set_nearest_vender("517", "2", "20", "1000", "&config(saveMap_map)", "&config(saveMap_x)", "&config(saveMap_y)")
	if ($buyautoMeat == 1) {
		log Everything went fine with the buyautoMeat find function
	} else {
		log There was a problem with the buyautoMeat find function
		do quit
		stop
	}
	
	$name = GetNamebyNameID(517)
	$nextFreeUseSelfItemSlot = get_free_slot_index_for_key("useSelf_item","$name")
	do iconf 517 20 1 0
	do conf -f useSelf_item_$nextFreeUseSelfItemSlot $name
	do conf -f useSelf_item_$nextFreeUseSelfItemSlot_disabled 0
	do conf -f useSelf_item_$nextFreeUseSelfItemSlot_hp < 60%
	do conf -f useSelf_item_$nextFreeUseSelfItemSlot_timeout 1
	
	include off Set_Buy_Meat.pm
	do reload eventMacros
}