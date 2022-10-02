
macro baseMacroUp {
	[
	$currentZeny = $.zeny
	$extraBuyCost = 0
	
	call SetVar
	call set_has_weapon_level
	call set_skills_stats
	
	$changed = 0
	
	$TFSTEALLevel = getSkillLevelByHandle("TF_STEAL")
	$RGSNATCHERLevel = getSkillLevelByHandle("RG_SNATCHER")
	$RGSTEALCOINLevel = getSkillLevelByHandle("RG_STEALCOIN")
	if ($RGSNATCHERLevel >= 1) {
		call clear_steal
	} elsif ($TFSTEALLevel >= 5) {
		call set_steal
	}
	if ($RGSTEALCOINLevel >= 5) {
		call set_STEALCOIN
	}
	
	#Leveling
	if ($testvar == 1) {
		if ($.lvl <= 25) {
			do mconf 1052 1 0 0 #Rocker
			do mconf 1014 0 0 0 #Spore
			do mconf 1127 0 0 0 #Hode
		} elsif ($.lvl <= 40) {
			do mconf 1052 0 0 0 #Rocker
			do mconf 1014 1 0 0 #Spore
			do mconf 1127 0 0 0 #Hode
		} else {
			do mconf 1052 0 0 0 #Rocker
			do mconf 1014 0 0 0 #Spore
			do mconf 1127 1 0 0 #Hode
		}
		if ($configlockMap != prt_fild05) {
			# kafra prt_fild05 290 224
			# sell prt_fild05 290 221
			call set_lockmap_prt_fild05
			$changed = 1
		}
	
	} elsif ($.lvl <= 14) {
		if ($configlockMap != pay_fild08) {
			call set_lockmap_pay_fild08
			$changed = 1
		}
	
	} elsif ($.lvl <= 38 || $hasLevelWeapon <= 1) {
		if ($configlockMap != pay_fild01) {
			# kafra oldnewpayon 98 118
			# sell oldnewpayon 69 117
			call set_lockmap_pay_fild01
			$changed = 1
		}
		
	#} elsif ($.lvl <= 50 && $hasLevelWeapon >= 1) {
	} elsif ($hasLevelWeapon >= 2) {
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
		call set_buyauto_equipment
		call fix_equipAuto_names
		call set_buyauto_usables
		call set_buyauto_refine
	}
	]
}

macro set_skills_stats {
	[
	set_skills_stats()
	]
}

sub set_skills_stats {
	my $stats = '10 agi, 10 dex, 10 str, 15 agi, 15 dex, 25 agi, 15 str, 9 vit, 30 agi, 25 dex, 40 agi, 9 int, 30 dex, 50 agi, 19 str, 35 dex, 65 agi, 45 dex, 30 str, 70 agi, 40 str, 50 dex, 80 agi, 19 vit, 55 dex, 45 str, 60 dex, 50 str, 85 agi, 70 str, 90 agi';
	my $skills;
	if ($char->{jobID} == 0) {
		$skills = 'NV_BASIC 9';
	} elsif ($char->{jobID} == 6) {
		$skills = 'TF_MISS 10, TF_DOUBLE 10, TF_STEAL 10, TF_HIDING 10, TF_POISON 8, TF_DETOXIFY 1';
	} elsif ($char->{jobID} == 17) {
		$skills = 'RG_SNATCHER 5, RG_STEALCOIN 10, RG_SNATCHER 10, SM_SWORD 10, RG_BACKSTAP 4, RG_TUNNELDRIVE 5, RG_RAID 5, RG_INTIMIDATE 5, RG_PLAGIARISM 10';
	}
	
	check_key('statsAddAuto_list', $stats);
	check_key('skillsAddAuto_list', $skills);
}

macro set_steal {
	[
	$foundSlot = find_key_in_block("attackSkillSlot","TF_STEAL")
	if ($foundSlot == -1) {
		$nextFreeSlot = get_free_slot_index_for_key("attackSkillSlot","TF_STEAL")
		do conf -f attackSkillSlot_$nextFreeSlot TF_STEAL
		$foundSlot = find_key_in_block("attackSkillSlot","TF_STEAL")
	}
	sanity_check_steal_skill("$foundSlot", "$TFSTEALLevel")
	]
}

macro clear_steal {
	$foundSlot = find_key_in_block("attackSkillSlot","TF_STEAL")
	if ($foundSlot != -1) {
		sanity_clear_steal_skill("$foundSlot")
	}
}

macro set_STEALCOIN {
	[
	$foundSlot = find_key_in_block("attackSkillSlot","RG_STEALCOIN")
	if ($foundSlot == -1) {
		$nextFreeSlot = get_free_slot_index_for_key("attackSkillSlot","RG_STEALCOIN")
		do conf -f attackSkillSlot_$nextFreeSlot RG_STEALCOIN
		$foundSlot = find_key_in_block("attackSkillSlot","RG_STEALCOIN")
	}
	sanity_check_stealCoin_skill("$foundSlot", "$RGSTEALCOINLevel")
	]
}

macro set_buyauto_equipment {
	[
	call set_buyauto_rightHand
	if ($hasLevelWeapon >= 2) {
		call set_buyauto_armor
		call set_buyauto_shoes
		call set_buyauto_robe
		call set_buyauto_topHead
	}
	if ($hasLevelWeapon >= 3) {
		call set_buyauto_rightAccessory
		#if ($hasLevelrightAccessory == 3) {1
		#	#kukre 4027 2~3m
		#}
		
		#if ($hasLevelShoes == 3) {
		#	#Spectring 8216 
		#}
		
		#if ($hasLeveltopHead == 3) {
		#	
		#}
	}
	]
}

macro set_buyauto_usables {
	[
	call set_tooldealers2
	if ($hasMeatVendor == 0) {
		call set_Redpotion
		call BetterbuyAuto_clear_item 517
		do iconf 517 0 1 0
	} else {
		call set_Meat
		call BetterbuyAuto_clear_item 501
		do iconf 501 0 1 0
	}
	call set_Orangepotion
	call set_Concentrationpotion
	call set_AwakeningPotion
	call set_Flywing
	call set_Butterlywing
	]
}

#############################
###### rightHand

macro set_weapons {
	[
	$Item1 = MainGauche
	$Item2 = Stiletto
	$Item3 = Gladius
	$itemAmount = 3
	]
}

macro set_MainGauche {
	[
	$item{name} = MainGauche
	$item{id} = 1207
	$item{slot} = rightHand
	$item{buytype} = fallback
	$item{minSearchPrice} = 1900
	$item{price} = 2400
	$item{minLevel} = 1
	$item{npc} = payon_in01-76-58
	$item{autoRefine} = 1
	$item{refineLevel} = 1
	$item{commandAfterBuy} = eventMacro-after_buy_weapon
	call set_item
	]
}

macro set_Stiletto {
	[
	$item{name} = Stiletto
	$item{id} = 1216
	$item{slot} = rightHand
	$item{buytype} = fallback
	$item{minSearchPrice} = 15000
	$item{price} = 19500
	$item{minLevel} = 12
	$item{npc} = payon_in01-76-58
	$item{autoRefine} = 1
	$item{refineLevel} = 2
	$item{commandAfterBuy} = eventMacro-after_buy_weapon
	call set_item
	]
}

macro set_Gladius {
	[
	$item{name} = Gladius
	$item{id} = 1220
	$item{slot} = rightHand
	$item{buytype} = player
	$item{minSearchPrice} = 750000
	$item{price} = 500000
	$item{minLevel} = 24
	$item{autoRefine} = 1
	$item{refineLevel} = 4
	$item{commandAfterBuy} = eventMacro-after_buy_weapon
	call set_item
	]
}

#############################
###### armor
macro set_armor {
	[
	$Item1 = AdventureSuit
	$Item2 = Pantie
	$itemAmount = 2
	]
}

macro set_AdventureSuit {
	[
	$item{name} = AdventureSuit
	$item{id} = 2305
	$item{slot} = armor
	$item{buytype} = fallback
	$item{minSearchPrice} = 600
	$item{price} = 1000
	$item{minLevel} = 4
	$item{npc} = payon_in01-134-51
	$item{commandAfterBuy} = eventMacro-set_buyauto_armor
	call set_item
	]
}

macro set_Pantie {
	[
	$item{name} = Pantie
	$item{id} = 2339
	$item{slot} = armor
	$item{buytype} = player
	$item{minSearchPrice} = 5000
	$item{price} = 25000
	$item{minLevel} = 22
	$item{commandAfterBuy} = eventMacro-set_buyauto_armor
	call set_item
	]
}

#############################
###### shoes
macro set_shoes {
	[
	$Item1 = Sandals
	$Item2 = Shoes
	$Item3 = Boots
	$itemAmount = 3
	]
}

macro set_Sandals {
	[
	$item{name} = Sandals
	$item{id} = 2401
	$item{slot} = shoes
	$item{buytype} = fallback
	$item{minSearchPrice} = 300
	$item{price} = 400
	$item{minLevel} = 4
	$item{npc} = payon_in01-134-51
	$item{commandAfterBuy} = eventMacro-set_buyauto_shoes
	call set_item
	]
}

macro set_Shoes {
	[
	$item{name} = Shoes
	$item{id} = 2403
	$item{slot} = shoes
	$item{buytype} = fallback
	$item{minSearchPrice} = 2500
	$item{price} = 3500
	$item{minLevel} = 14
	$item{npc} = payon_in01-134-51
	$item{commandAfterBuy} = eventMacro-set_buyauto_shoes
	call set_item
	]
}

macro set_Boots {
	[
	$item{name} = Boots
	$item{id} = 2405
	$item{slot} = shoes
	$item{buytype} = fallback
	$item{minSearchPrice} = 12000
	$item{price} = 18000
	$item{minLevel} = 33
	$item{npc} = payon_in01-134-51
	$item{commandAfterBuy} = eventMacro-set_buyauto_shoes
	call set_item
	]
}

#############################
###### robe
macro set_robe {
	[
	$Item1 = Hood
	$Item2 = Muffler
	$Item3 = Undershirt
	$itemAmount = 3
	]
}

macro set_Hood {
	[
	$item{name} = Hood
	$item{id} = 2501
	$item{slot} = robe
	$item{buytype} = fallback
	$item{minSearchPrice} = 800
	$item{price} = 1000
	$item{minLevel} = 4
	$item{npc} = payon_in01-134-51
	$item{commandAfterBuy} = eventMacro-set_buyauto_robe
	call set_item
	]
}

macro set_Muffler {
	[
	$item{name} = Muffler
	$item{id} = 2503
	$item{slot} = robe
	$item{buytype} = fallback
	$item{minSearchPrice} = 3500
	$item{price} = 5000
	$item{minLevel} = 14
	$item{npc} = payon_in01-134-51
	$item{commandAfterBuy} = eventMacro-set_buyauto_robe
	call set_item
	]
}

macro set_Undershirt {
	[
	$item{name} = Undershirt
	$item{id} = 2522
	$item{slot} = robe
	$item{buytype} = player
	$item{minSearchPrice} = 40000
	$item{price} = 65000
	$item{minLevel} = 22
	$item{commandAfterBuy} = eventMacro-set_buyauto_robe
	call set_item
	]
}

#############################
###### topHead
macro set_topHead {
	[
	$Item1 = Bandana
	$Item2 = NutShell
	$itemAmount = 2
	]
}

macro set_Bandana {
	[
	$item{name} = Bandana
	$item{id} = 2211
	$item{slot} = topHead
	$item{buytype} = fallback
	$item{minSearchPrice} = 300
	$item{price} = 400
	$item{minLevel} = 1
	$item{npc} = payon_in01-134-51
	$item{commandAfterBuy} = eventMacro-set_buyauto_topHead
	call set_item
	]
}

macro set_NutShell {
	[
	$item{name} = NutShell
	$item{id} = 5037
	$item{slot} = topHead
	$item{buytype} = player
	$item{minSearchPrice} = 4000
	$item{price} = 8000
	$item{minLevel} = 5
	$item{commandAfterBuy} = eventMacro-set_buyauto_topHead
	call set_item
	]
}

#############################
###### rightAccessory
macro set_rightAccessory {
	[
	$Item1 = MatyrLeash
	$Item2 = Brooch0
	$Item3 = Brooch1
	$itemAmount = 3
	]
}

macro set_MatyrLeash {
	[
	$item{name} = MatyrLeash
	$item{id} = 2618
	$item{slot} = rightAccessory
	$item{buytype} = player
	$item{minSearchPrice} = 100000
	$item{price} = 200000
	$item{minLevel} = 35
	$item{commandAfterBuy} = eventMacro-set_buyauto_rightAccessory
	call set_item
	]
}

macro set_Brooch0 {
	[
	$item{name} = Brooch0
	$item{id} = 2605
	$item{slot} = rightAccessory
	$item{buytype} = player
	$item{minSearchPrice} = 800000
	$item{price} = 1000000
	$item{minLevel} = 20
	$item{commandAfterBuy} = eventMacro-set_buyauto_rightAccessory
	call set_item
	]
}

macro set_Brooch1 {
	[
	$item{name} = Brooch1
	$item{id} = 2625
	$item{slot} = rightAccessory
	$item{buytype} = player
	$item{minSearchPrice} = 1500000
	$item{price} = 3000000
	$item{minLevel} = 90
	$item{commandAfterBuy} = eventMacro-set_buyauto_rightAccessory
	call set_item
	]
}

#############################
###### usables

macro set_Redpotion {
	[
	$item{id} = 501
	$item{price} = 50
	$item{maxPrice} = 45
	$item{minInventoryAmount} = 5
	$item{maxAmount} = 30
	$item{minLevel} = 1
	$item{maxLevel} = 55
	$item{useSelf} = 1
	call set_item_usable
	call deal_with_usables
	if ($item{CanUse} == 1 && $item{useSelf} == 1) {
		do conf -f useSelf_item_$nextFreeSlot_hp < 70%
	}
	]
}

macro set_Meat {
	[
	$item{id} = 517
	$item{price} = 50
	$item{maxPrice} = 45
	$item{minInventoryAmount} = 5
	if ($.lvl <= 38) {
		$item{maxAmount} = 30
	} else {
		$item{maxAmount} = 50
	}
	$item{minLevel} = 1
	$item{maxLevel} = 55
	$item{useSelf} = 1
	call set_item_usable
	call deal_with_usables
	if ($item{CanUse} == 1 && $item{useSelf} == 1) {
		do conf -f useSelf_item_$nextFreeSlot_hp < 60%
	}
	]
}

macro set_Orangepotion {
	[
	$item{id} = 502
	$item{price} = 200
	$item{maxPrice} = 190
	$item{minInventoryAmount} = 5
	$item{maxAmount} = 30
	$item{minLevel} = 22
	$item{maxLevel} = 99
	$item{useSelf} = 1
	call set_item_usable
	call deal_with_usables
	if ($item{CanUse} == 1 && $item{useSelf} == 1) {
		do conf -f useSelf_item_$nextFreeSlot_hp < 50%
	}
	]
}

macro set_Concentrationpotion {
	[
	$item{id} = 645
	$item{price} = 800
	$item{maxPrice} = 760
	$item{minInventoryAmount} = 0
	$item{maxAmount} = 2
	$item{minLevel} = 22
	$item{maxLevel} = 39
	$item{useSelf} = 1
	call set_item_usable
	call deal_with_usables
	if ($item{CanUse} == 1 && $item{useSelf} == 1) {
		do conf -f useSelf_item_$nextFreeSlot_whenStatusInactive EFST_ATTHASTE_POTION1,EFST_ATTHASTE_POTION2
		do conf -f useSelf_item_$nextFreeSlot_inLockOnly 1
		do conf -f useSelf_item_$nextFreeSlot_notWhileSitting 1
		do conf -f useSelf_item_$nextFreeSlot_timeout 5
	}
	]
}

macro set_AwakeningPotion {
	[
	$item{id} = 656
	$item{price} = 1500
	$item{maxPrice} = 1400
	$item{minInventoryAmount} = 0
	$item{maxAmount} = 2
	$item{minLevel} = 40
	$item{maxLevel} = 99
	$item{useSelf} = 1
	call set_item_usable
	call deal_with_usables
	if ($item{CanUse} == 1 && $item{useSelf} == 1) {
		do conf -f useSelf_item_$nextFreeSlot_whenStatusInactive EFST_ATTHASTE_POTION1,EFST_ATTHASTE_POTION2
		do conf -f useSelf_item_$nextFreeSlot_inLockOnly 1
		do conf -f useSelf_item_$nextFreeSlot_notWhileSitting 1
		do conf -f useSelf_item_$nextFreeSlot_timeout 5
	}
	]
}

macro set_Flywing {
	[
	$item{id} = 601
	$item{price} = 60
	$item{maxPrice} = 55
	$item{minInventoryAmount} = 0
	$item{maxAmount} = 10
	$item{minLevel} = 1
	$item{maxLevel} = 99
	$item{useSelf} = 0
	call set_item_usable
	call set_buy_item_usable
	]
}

macro set_Butterlywing {
	[
	$item{id} = 602
	$item{price} = 300
	$item{maxPrice} = 285
	$item{minInventoryAmount} = 0
	$item{maxAmount} = 2
	$item{minLevel} = 1
	$item{maxLevel} = 99
	$item{useSelf} = 0
	call set_item_usable
	call set_buy_item_usable
	]
}

##################################

automacro Go_Job_Change {
	ConfigKey eventMacro_1_99_stage leveling
	JobLevel >= 40
	JobID 6
	exclusive 1
	priority 0
	call {
		do conf -f eventMacro_1_99_stage turn_rogue_start
		do conf -f doing_rogue_job_change start
		
		do conf -f lockMap none
		
		include on Turn_Rogue.pm
		
		do reload eventMacros
	}
}