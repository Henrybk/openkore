
macro knight_set_buyauto_equipment {
	$name = GetNamebyNameID(1157)
	$nextFreeSlot = get_free_slot_index_for_key("buyAuto","$name")
	do conf -f buyAuto_$nextFreeSlot $name
	do conf -f buyAuto_$nextFreeSlot_npc izlude_in 60 127
	do conf -f buyAuto_$nextFreeSlot_minAmount 0
	do conf -f buyAuto_$nextFreeSlot_maxAmount 1
	do conf -f buyAuto_$nextFreeSlot_minDistance 1
	do conf -f buyAuto_$nextFreeSlot_maxDistance 10
	do conf -f buyAuto_$nextFreeSlot_zeny > 65000
	do iconf 1157 1 0 0
}

automacro Equip_TwoHanded {
	ConfigKey eventMacro_1_99_stage leveling
    IsNotEquippedID rightHand 1157
    InInventoryID 1157 > 0
	BaseLevel > 34
    exclusive 1
	priority 3
    call {
		do conf -f equipAuto_0_rightHand GetNamebyNameID(1157)
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
		
		do reload eventMacros
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
