
macro set_config_class {
	[
	$configClass = &config(eventMacro_goal_class)
	]
}

macro set_class_answer_novice {
	[
	call set_config_class
	if ($configClass = rogue) {
		do conf -f current_event_include Turn_Thief.pm
		include on Turn_Thief.pm
		
	} elsif ($configClass = knight) {
		do conf -f current_event_include Turn_Swordman.pm
		include on Turn_Swordman.pm
	}
	]
}

macro set_class_leveling {
	[
	call set_config_class
	if ($configClass = rogue) {
		do conf -f eventMacro_1_99_stage leveling
		do conf -f current_event_include Leveling.pm
		include on Leveling.pm
		include on Rogue_Settings.pm
		
	} elsif ($configClass = knight) {
		do conf -f eventMacro_1_99_stage leveling
		do conf -f current_event_include Leveling.pm
		include on Leveling.pm
		include on Knight_Settings.pm
	}
	]
}

macro set_class_stats_and_skills {
	[
	if ($configClass = rogue) {
		call rogue_set_skills_stats
	} elsif ($configClass = knight) {
		call knight_set_skills_stats
	}
	]
}

macro rogue_set_skills_stats {
	[
	do conf -f statsAddAuto_list 10 agi, 10 dex, 10 str, 15 agi, 15 dex, 25 agi, 15 str, 9 vit, 30 agi, 25 dex, 40 agi, 30 dex, 50 agi, 19 str, 35 dex, 65 agi, 19 vit, 30 int, 70 agi, 29 str, 40 int, 50 dex, 99 agi, 70 int
    do conf -f skillsAddAuto_list NV_BASIC 9, TF_MISS 10, TF_DOUBLE 10, TF_STEAL 10, TF_HIDING 10, TF_POISON 8, TF_DETOXIFY 1
	]
}

macro knight_set_skills_stats {
	[
	do conf -f statsAddAuto_list 10 agi, 10 dex, 10 str, 10 vit, 15 agi, 15 dex, 15 str, 15 vit, 25 agi, 25 dex, 20 str, 20 vit, 50 agi, 25 vit, 25 luk, 35 dex, 35 str, 35 vit, 70 agi, 50 str, 50 dex, 45 vit, 45 luk, 75 agi, 55 str, 50 vit, 80 agi, 65 str, 60 vit, 70 str, 90 agi
    do conf -f skillsAddAuto_list NV_BASIC 9, SM_SWORD 1, SM_TWOHAND 10, SM_RECOVERY 10, SM_BASH 10, SM_PROVOKE 5, SM_ENDURE 10, SM_MAGNUM 3, KN_TWOHANDQUICKEN 10, KN_RIDING 1, KN_CAVALIERMASTERY 5, KN_AUTOCOUNTER 5, KN_BOWLINGBASH 10
	]
}

macro set_buyauto_equipment {
	[
	call set_config_class
	if ($configClass = rogue) {
		call rogue_set_buyauto_equipment
		
	} elsif ($configClass = knight) {
		call knight_set_buyauto_equipment
	}
	]
}

macro set_item {
	[
	$item{Has} = hasIdentifiedItem("$item{id}")
	$item{Equipped} = isEquippedInSlotNameID("$item{slot}", "$item{id}")
	if ($.lvl >= $item{minLevel}) {
		$item{CanEquip} = 1
	} else {
		$item{CanEquip} = 0
	}
	$totalcost = &eval($item{price} + $extraBuyCost)
	if ($currentZeny >= $totalcost) {
		$item{CanBuy} = 1
	} else {
		$item{CanBuy} = 0
	}
	]
}

macro set_buyAuto {
	[
	$name = GetNamebyNameID("$.param[0]")
	log Setting buyAuto $name
	$nextFreeSlot = get_free_slot_index_for_key("buyAuto","$name")
	set_common_equip_buyAuto("$nextFreeSlot","$name","$.param[1]","$.param[2]","$.param[3]","$.param[4]")
	$totalcost = &eval($.param[1] + $extraBuyCost)
	$currentZeny = &eval($currentZeny - $totalcost)
	do iconf $.param[0] 1 0 0
	]
}

macro set_equip {
	[
	$name = GetNamebyNameID("$.param[0]")
	log Setting equipauto $name
	do iconf $.param[0] 1 0 0
	do conf -f equipAuto_0_$.param[1] $name
	]
}

macro buyAuto_clear {
	[
	$name = GetNamebyNameID("$.param[0]")
	log Clearing buyAuto $name
	$foundSlot = get_free_slot_index_for_key("buyAuto","$name")
	do conf -f buyAuto_$foundSlot none
	]
}