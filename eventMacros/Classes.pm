
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
	$item{Has} = &invamount($item{id})
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