
macro knight_set_buyauto_equipment {
	
	$needHanded = &eval((!defined $::char->inventory->getByNameID(1157) && $::char->{lv} > 34) ? 1 : 0)
	
	if ($needHanded = 1) {
		$buyAutoTwoHanded = set_nearest_vender("1157", "0", "1", "65000", "&config(future_saveMap_map)", "&config(future_saveMap_x)", "&config(future_saveMap_y)")
		if ($buyAutoTwoHanded == 1) {
			log Everything went fine with the buyAutoTwoHanded find function
			do iconf 1157 1 0 0
			
			$name = GetNamebyNameID(1157)
			$nextFreeUseSelfItemSlot = get_free_slot_index_for_key("buyAuto","$name")
			
			do conf -f buyAuto_$nextFreeUseSelfItemSlot_inInventory $name < 1
			
		} else {
			log There was a problem with the buyAutoTwoHanded find function
			do quit
			stop
		}
	} else {
		log We either already have a two handed sword or are too low level to buy it
	}
}

automacro Equip_TwoHanded {
	ConfigKey eventMacro_1_99_stage leveling
    IsNotEquippedID rightHand 1157
    InInventoryID 1157 > 0
	BaseLevel > 34
	InCity 1
    exclusive 1
	priority 3
    call {
		%toequip = (rightHand => 1157)
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
		$meatName = GetNamebyNameID(517)
		do conf -f useSelf_item_0 $meatName
		do conf -f useSelf_item_0_disabled 0
		do conf -f useSelf_item_0_hp < 50%
    }
}

automacro Go_Job_Change {
	ConfigKey eventMacro_1_99_stage leveling
	ConfigKeyNotExist doing_knight_job_change
	IsEquippedID rightHand 1157
    InInventoryID 1157 > 0
	JobLevel = 50
    exclusive 1
	priority 0
    call {
		do conf -f eventMacro_1_99_stage turning_knight_true_start
		do conf -f doing_knight_job_change start
		
		do conf -f turn_knight_lockMap_before &config(lockMap)
		do conf -f lockMap none
		
		include on Turn_Knight.pm
		
		do reload acros
    }
}

automacro Set_use_Two_Handed_Quicken {
	ConfigKey eventMacro_1_99_stage leveling
    ConfigKeyNot useSelf_skill_0 KN_TWOHANDQUICKEN
	SkillLevel KN_TWOHANDQUICKEN > 7
    exclusive 1
    call {
		[
		do conf -f useSelf_skill_0 KN_TWOHANDQUICKEN
		do conf -f useSelf_skill_0_disabled 0
		do conf -f useSelf_skill_0_sp > 50
		do conf -f useSelf_skill_0_whenStatusInactive EFST_TWOHANDQUICKEN
		do conf -f useSelf_skill_0_lvl 10
		do conf -f useSelf_skill_0_inLockOnly 1
		do conf -f useSelf_skill_0_notWhileSitting 1
		do conf -f useSelf_skill_0_notInTown 1
		]
    }
}

# Peco Peco

automacro Go_Get_Peco {
	ConfigKey eventMacro_1_99_stage leveling
	SkillLevel KN_CAVALIERMASTERY = 5
	StatusInactiveHandle EFST_RIDING
	Zeny > 10000
    exclusive 1
	priority 0
    call {
		do conf -f eventMacro_1_99_stage knight_getting_peco
    }
}

macro Move_to_peco_breeder {
	do move prontera 55 350 &rand(3,4,5,6,7,8)
}

automacro move_to_breeder_outside {
	ConfigKey eventMacro_1_99_stage knight_getting_peco
	StatusInactiveHandle EFST_RIDING
	NotInMap prontera
	exclusive 1
	call Move_to_peco_breeder
}

automacro move_to_breeder_inside {
	ConfigKey eventMacro_1_99_stage knight_getting_peco
	StatusInactiveHandle EFST_RIDING
	InMap prontera
	NpcNotNear /peco peco/i
	exclusive 1
	call Move_to_peco_breeder
}

automacro Talk_to_Breeder {
	ConfigKey eventMacro_1_99_stage knight_getting_peco
	StatusInactiveHandle EFST_RIDING
	InMap prontera
	NpcNear /peco peco/i
	exclusive 1
	call {
		do talknpc &arg("$.NpcNearLastPos", 1) &arg("$.NpcNearLastPos", 2) r0
	}
}

automacro Got_my_peco_peco {
	ConfigKey eventMacro_1_99_stage knight_getting_peco
	StatusActiveHandle EFST_RIDING
	exclusive 1
	priority 0
	call {
		do conf -f eventMacro_1_99_stage leveling
	}
}

automacro Peco_shit_happened_zeny {
	ConfigKey eventMacro_1_99_stage knight_getting_peco
	StatusInactiveHandle EFST_RIDING
	Zeny < 2500
	exclusive 1
	priority 0
	call {
		do conf -f eventMacro_1_99_stage leveling
	}
}

automacro Peco_shit_happened_skill {
	ConfigKey eventMacro_1_99_stage knight_getting_peco
	StatusActiveHandle EFST_RIDING
	SkillLevel KN_CAVALIERMASTERY < 5
	exclusive 1
	priority 0
	call {
		do conf -f eventMacro_1_99_stage leveling
	}
}
