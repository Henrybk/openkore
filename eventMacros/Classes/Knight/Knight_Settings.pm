
macro baseMacroUp {
	[
	$currentZeny = $.zeny
	$extraBuyCost = 4000
	
	call SetVar
	call set_has_weapon_level
	call set_skills_stats
	
	call set_buyauto_equipment
	
	$changed = 0
	
	$TWOHANDQUICKENLevel = getSkillLevelByHandle("KN_TWOHANDQUICKEN")
	if ($TWOHANDQUICKENLevel >= 7) {
		call Set_use_Two_Handed_Quicken
	}
	
	$HPRecoveryWhileMovingLevel = getSkillLevelByHandle("SM_MOVINGRECOVERY")
	if ($configlockMap == yuno_fild01 && $HPRecoveryWhileMovingLevel == 1) {
		do conf lockMap none
		call SetVar
	}
	
	#Leveling
	if ($.lvl <= 17) {
		if ($configlockMap != prt_fild07) {
			# kafra prt_fild05 290 224
			# sell prt_fild05 290 221
			call set_lockmap_prt_fild07
			$changed = 1
		}
	
	} elsif ($.lvl <= 22) {
		if ($configlockMap != prt_sewb2) {
			# kafra prt_fild05 290 224
			# sell prt_fild05 290 221
			call set_lockmap_prt_sewb2
			$changed = 1
		}
	
	} elsif ($.lvl <= 35 || $hasWeaponLevel == 0) {
		if ($configlockMap != pay_fild01) {
			# kafra oldnewpayon 98 118
			# sell oldnewpayon 69 117
			call set_lockmap_pay_fild01
			$changed = 1
		}
		
	} elsif ($.joblvl >= 25 && $.lvl >= 40 && $HPRecoveryWhileMovingLevel == 0 && $hasWeaponLevel >= 1) {
		if ($configlockMap != yuno_fild01) {
			# kafra aldebaran 143 119
			# sell aldeba_in 94 56
			call set_lockmap_yuno_fild01
			$changed = 1
		}
		
	#} elsif ($.lvl <= 50 && $hasWeaponLevel >= 1) {
	} elsif ($hasWeaponLevel >= 1) {
		if ($configlockMap != lasa_dun01) {
			# kafra aldebaran 143 119
			# sell aldeba_in 94 56
			call set_lockmap_lasa_dun01
			$changed = 1
		}
		
	}
	
	if ($changed == 1) {
		call after_lock_change
	} else {
		log Current lockmap $configlockMap is still good
	}
	]
}

macro set_skills_stats {
	set_skills_stats()
}

sub set_skills_stats {
	my $stats = '10 agi, 10 dex, 10 str, 10 vit, 15 agi, 15 dex, 15 str, 15 vit, 25 agi, 25 dex, 20 str, 20 vit, 50 agi, 25 vit, 25 luk, 35 dex, 35 str, 35 vit, 70 agi, 50 str, 50 dex, 45 vit, 45 luk, 75 agi, 55 str, 50 vit, 80 agi, 65 str, 60 vit, 70 str, 90 agi';
	my $skills = 'NV_BASIC 9, SM_SWORD 1, SM_TWOHAND 10, SM_RECOVERY 10, SM_BASH 10, SM_PROVOKE 5, SM_ENDURE 10, SM_MAGNUM 3, KN_TWOHANDQUICKEN 10, KN_RIDING 1, KN_CAVALIERMASTERY 5, KN_AUTOCOUNTER 5, KN_BOWLINGBASH 10';
	check_key('statsAddAuto_list', $stats);
	check_key('skillsAddAuto_list', $skills);
}

macro set_has_weapon_level {
	$hasWeaponLevel = 0
	$Item1 = Katana
	$Item2 = Slayer
	$Item3 = TwoHandedSword
	call set_tempitems_3
	if ($itemHash{$temphash{Item1Equipped}} == 1) {
		$hasWeaponLevel = 1
	} elsif ($itemHash{$temphash{Item2Equipped}} == 1) {
		$hasWeaponLevel = 2
	} elsif ($itemHash{$temphash{Item3Equipped}} == 1) {
		$hasWeaponLevel = 3
	}
}

macro Set_use_Two_Handed_Quicken {
	[
	$foundSlot = find_key_in_block("useSelf_skill","KN_TWOHANDQUICKEN")
	if ($foundSlot == -1) {
		$nextFreeSlot = get_free_slot_index_for_key("useSelf_skill","KN_TWOHANDQUICKEN")
		do conf -f useSelf_skill_$nextFreeSlot KN_TWOHANDQUICKEN
		$foundSlot = find_key_in_block("useSelf_skill","KN_TWOHANDQUICKEN")
	}
	sanity_check_Two_Handed_Quicken("$foundSlot", "$TWOHANDQUICKENLevel")
	]
}

macro set_buyauto_equipment {
	[
	call set_buyauto_rightHand
	if ($hasWeaponLevel >= 1) {
		call set_buyauto_armor
		call set_buyauto_shoes
		call set_buyauto_robe
		call set_buyauto_topHead
	}
	]
}

#############################
###### rightHand
macro set_buyauto_rightHand {
	[
	$Item1 = Katana
	$Item2 = Slayer
	$Item3 = TwoHandedSword
	call organize_and_run_buyauto_3
}

macro set_Katana {
	[
	$item{name} = Katana
	$item{id} = 1116
	$item{slot} = rightHand
	$item{price} = 2000
	$item{minLevel} = 4
	$item{npcMap} = prt_in
	$item{npcX} = 172
	$item{npcY} = 130
	call set_item
	]
}

macro set_Slayer {
	[
	$item{name} = Slayer
	$item{id} = 1151
	$item{slot} = rightHand
	$item{price} = 15000
	$item{minLevel} = 18
	$item{npcMap} = izlude_in
	$item{npcX} = 60
	$item{npcY} = 127
	call set_item
	]
}

macro set_TwoHandedSword {
	[
	$item{name} = TwoHandedSword
	$item{id} = 1157
	$item{slot} = rightHand
	$item{price} = 60000
	$item{minLevel} = 33
	$item{npcMap} = izlude_in
	$item{npcX} = 60
	$item{npcY} = 127
	call set_item
	]
}

#############################
###### armor
macro set_buyauto_armor {
	[
	$Item1 = AdventureSuit
	$Item2 = PaddedArmor
	$Item3 = PlateArmor
	call organize_and_run_buyauto_3
}

macro set_AdventureSuit {
	[
	$item{name} = AdventureSuit
	$item{id} = 2305
	$item{slot} = armor
	$item{price} = 1000
	$item{minLevel} = 4
	$item{npcMap} = payon_in01
	$item{npcX} = 134
	$item{npcY} = 51
	call set_item
	]
}

macro set_PaddedArmor {
	[
	$item{name} = PaddedArmor
	$item{id} = 2312
	$item{slot} = armor
	$item{price} = 480000
	$item{minLevel} = 25
	$item{npcMap} = payon_in01
	$item{npcX} = 76
	$item{npcY} = 70 
	call set_item
	]
}

macro set_PlateArmor {
	[
	$item{name} = PlateArmor
	$item{id} = 2316
	$item{slot} = armor
	$item{price} = 800000
	$item{minLevel} = 40
	$item{npcMap} = payon_in01
	$item{npcX} = 76
	$item{npcY} = 70 
	call set_item
	]
}

#############################
###### shoes
macro set_buyauto_shoes {
	[
	$Item1 = Sandals
	$Item2 = Shoes
	$Item3 = Boots
	call organize_and_run_buyauto_3
}

macro set_Sandals {
	[
	$item{name} = Sandals
	$item{id} = 2401
	$item{slot} = shoes
	$item{price} = 400
	$item{minLevel} = 4
	$item{npcMap} = payon_in01
	$item{npcX} = 134
	$item{npcY} = 51
	call set_item
	]
}

macro set_Shoes {
	[
	$item{name} = Shoes
	$item{id} = 2403
	$item{slot} = shoes
	$item{price} = 3500
	$item{minLevel} = 14
	$item{npcMap} = payon_in01
	$item{npcX} = 134
	$item{npcY} = 51
	call set_item
	]
}

macro set_Boots {
	[
	$item{name} = Boots
	$item{id} = 2405
	$item{slot} = shoes
	$item{price} = 18000
	$item{minLevel} = 33
	$item{npcMap} = payon_in01
	$item{npcX} = 134
	$item{npcY} = 51
	call set_item
	]
}

#############################
###### robe
macro set_buyauto_robe {
	[
	$Item1 = Hood
	$Item2 = Muffler
	$Item3 = Manteau
	call organize_and_run_buyauto_3
}

macro set_Hood {
	[
	$item{name} = Hood
	$item{id} = 2501
	$item{slot} = robe
	$item{price} = 1000
	$item{minLevel} = 4
	$item{npcMap} = payon_in01
	$item{npcX} = 134
	$item{npcY} = 51
	call set_item
	]
}

macro set_Muffler {
	[
	$item{name} = Muffler
	$item{id} = 2503
	$item{slot} = robe
	$item{price} = 5000
	$item{minLevel} = 14
	$item{npcMap} = payon_in01
	$item{npcX} = 134
	$item{npcY} = 51
	call set_item
	]
}

macro set_Manteau {
	[
	$item{name} = Manteau
	$item{id} = 2505
	$item{slot} = robe
	$item{price} = 32000
	$item{minLevel} = 33
	$item{npcMap} = payon_in01
	$item{npcX} = 134
	$item{npcY} = 51
	call set_item
	]
}

#############################
###### topHead
macro set_buyauto_topHead {
	[
	$Item1 = Hat
	$Item2 = Cap
	$Item3 = Helm
	call organize_and_run_buyauto_3
}

macro set_Hat {
	[
	$item{name} = Hat
	$item{id} = 2220
	$item{slot} = topHead
	$item{price} = 1000
	$item{minLevel} = 4
	$item{npcMap} = prt_in
	$item{npcX} = 172
	$item{npcY} = 132
	call set_item
	]
}

macro set_Cap {
	[
	$item{name} = Cap
	$item{id} = 2226
	$item{slot} = topHead
	$item{price} = 12000
	$item{minLevel} = 14
	$item{npcMap} = prt_in
	$item{npcX} = 172
	$item{npcY} = 132
	call set_item
	]
}

macro set_Helm {
	[
	$item{name} = Helm
	$item{id} = 2228
	$item{slot} = topHead
	$item{price} = 440000
	$item{minLevel} = 40
	$item{npcMap} = payon_in01
	$item{npcX} = 76
	$item{npcY} = 70 
	call set_item
	]
}

automacro Go_Job_Change {
	ConfigKey eventMacro_1_99_stage leveling
	ConfigKeyNotExist doing_knight_job_change
	SkillLevel SM_MOVINGRECOVERY = 1
	JobLevel = 50
	JobID 1
	exclusive 1
	priority 0
	call {
		do conf -f eventMacro_1_99_stage turning_knight_true_start
		do conf -f doing_knight_job_change start
		
		do conf -f Turn_Knight_lockMap_before &config(lockMap)
		do conf -f lockMap none
		
		include on Turn_Knight.pm
		
		do reload eventMacros
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

automacro need_to_do_SM_MOVINGRECOVERY_Quest {
	exclusive 1
	priority 0
	ConfigKey eventMacro_1_99_stage leveling
	SkillLevel SM_MOVINGRECOVERY = 0
	InInventoryID 713 >= 50
	InInventoryID 1058 >= 1
	JobLevel >= 25
	JobID 1
	call {
		do conf -f SM_MOVINGRECOVERY_Quest_before &config(eventMacro_1_99_stage)
		do conf -f eventMacro_1_99_stage SM_MOVINGRECOVERY_Quest
		do conf -f before_event_include &config(current_event_include)
		do conf -f current_event_include SM_MOVINGRECOVERY_Quest.pm
		include off &config(before_event_include)
		include on SM_MOVINGRECOVERY_Quest.pm
		
		do reload eventMacros
	}
}