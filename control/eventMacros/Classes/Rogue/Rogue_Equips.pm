
macro rogue_set_buyauto_equipment {
	
	$needDamascus = &eval((!defined $::char->inventory->getByNameID(1222) && $::char->{lv} > 24) ? 1 : 0)
	
	if ($needDamascus = 1) {
		$buyautoDamascus = set_nearest_vender("1222", "0", "1", "55000", "&config(future_saveMap_map)", "&config(future_saveMap_x)", "&config(future_saveMap_y)")
		if ($buyautoDamascus == 1) {
			log Everything went fine with the buyautoDamascus find function
			do iconf 1222 1 0 0
			
			$name = GetNamebyNameID(1222)
			$nextFreeUseSelfItemSlot = get_free_slot_index_for_key("buyAuto","$name")
			
			do conf -f buyAuto_$nextFreeUseSelfItemSlot_inInventory $name < 1
			
		} else {
			log There was a problem with the buyautoDamascus find function
			do quit
			stop
		}
	} else {
		log We either already have a damascus or are too low level to buy it
	}
	
}

automacro Equip_Damascus {
	ConfigKey eventMacro_1_99_stage leveling
    IsNotEquippedID rightHand 1222
    InInventoryID 1222 > 0
	BaseLevel > 24
	InCity 1
    exclusive 1
	priority 3
    call {
		%toequip = (rightHand => 1222)
        call start_equipping
    }
}

automacro Set_use_Meat_Heal {
	ConfigKey eventMacro_1_99_stage leveling
    ConfigKeyNot useSelf_item_0 Meat
    InInventoryID 569 = 0
    exclusive 1
	priority 3
    call {
		do iconf 517 30 1 0
	
		$meatName = GetNamebyNameID(517)
		do conf -f useSelf_item_0 $meatName
		do conf -f useSelf_item_0_disabled 0
		do conf -f useSelf_item_0_hp < 50%
		
		$nextFreeUseSelfItemSlot = get_free_slot_index_for_key("getAuto","$meatName")
		do conf -f getAuto_$nextFreeUseSelfItemSlot $meatName
		do conf -f getAuto_$nextFreeUseSelfItemSlot_minAmount 2
		do conf -f getAuto_$nextFreeUseSelfItemSlot_maxAmount 30
		do conf -f getAuto_$nextFreeUseSelfItemSlot_passive 0
    }
}

automacro Set_Buy_meat {
	ConfigKey eventMacro_1_99_stage leveling
	ConfigKey useSelf_item_0 Meat
	InStorageID 517 = 0
	InInventoryID 517 < 20
    exclusive 1
	priority 3
    call {
		$buyautoMeat = set_nearest_vender("517", "2", "30", "1000", "&config(saveMap_map)", "&config(saveMap_x)", "&config(saveMap_y)")
		[
		if ($buyautoMeat == 1) {
			log Everything went fine with the buyautoMeat find function
		} else {
			log There was a problem with the buyautoMeat find function
			do quit
			stop
		}
		]
    }
}