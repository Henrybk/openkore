
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
	
	} elsif ($.lvl <= 38 || $hasWeaponLevel == 0) {
		if ($configlockMap != pay_fild01) {
			# kafra oldnewpayon 98 118
			# sell oldnewpayon 69 117
			call set_lockmap_pay_fild01
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
		call set_buyauto_equipment
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
	if ($hasWeaponLevel >= 1) {
		call set_buyauto_armor
		call set_buyauto_shoes
		call set_buyauto_robe
		call set_buyauto_topHead
	}
	]
}

macro set_buyauto_usables {
	[
	call set_tooldealers2
	if ($hasMeatVendor == 0) {
		call set_Redpotion
	} else {
		call set_Meat
	}
	call set_Orangepotion
	call set_Concentrationpotion
	call set_AwakeningPotion
	call set_Flywing
	call set_Butterlywing
	]
}

macro set_buyauto_refine {
	[
	call set_refine_weapon
	]
}

#############################
###### rightHand
macro set_refine_weapon {
	[
	$hasWeaponLevel = 0
	$Item1 = MainGauche
	$Item2 = Stiletto
	#call set_tempitems_2
	$Item3 = Gladius
	call set_tempitems_3
	
	$foundWeapon = 0
	$refineLevel = 0
	
	$wantedRefine = 0
	$needRefineCount = 0
	if ($itemHash{$temphash{Item1Equipped}} == 1) {
		if ($itemHash{$temphash{Item1autoRefine}}) {
			$foundWeapon = 1
			$refineLevel = $itemHash{$temphash{Item1refineLevel}}
		}
	} elsif ($itemHash{$temphash{Item2Equipped}} == 1) {
		if ($itemHash{$temphash{Item2autoRefine}}) {
			$foundWeapon = 1
			$refineLevel = $itemHash{$temphash{Item2refineLevel}}
		}
	#}
	} elsif ($itemHash{$temphash{Item3Equipped}} == 1) {
		if ($itemHash{$temphash{Item3autoRefine}}) {
			$foundWeapon = 1
			$refineLevel = $itemHash{$temphash{Item3refineLevel}}
		}
	}
	
	if ($foundWeapon == 1) {
		$currentRefine = get_weapon_refine()
		$maxSafeRefine = get_maxSafeRefine("$refineLevel")
		if ($currentRefine < $maxSafeRefine) {
			$wantedRefine = 1
			$needRefineCount = &eval($maxSafeRefine - $currentRefine)
		}
		log Current weapon has refine +$currentRefine/+$maxSafeRefine
		if ($wantedRefine) {
			log Still needs more $needRefineCount refines of level $refineLevel KEKW
			do conf -f autoRefine_on 1
			do conf -f autoRefine_weaponLevel $refineLevel
			do conf -f autoRefine_wantedRefine $maxSafeRefine
			do conf -f autoRefine_npc payon_in01 91 31
			call set_BetterBuy_refine
		} else {
			log No need to refine further POOOOGG
			do conf -f autoRefine_on 0
			do conf -f autoRefine_weaponLevel none
			do conf -f autoRefine_wantedRefine none
			do conf -f autoRefine_npc none
			call clear_BetterBuy_refine
		}
	}
	]
}

macro set_has_weapon_level {
	[
	$hasWeaponLevel = 0
	$Item1 = MainGauche
	$Item2 = Stiletto
	#call set_tempitems_2
	$Item3 = Gladius
	call set_tempitems_3
	if ($itemHash{$temphash{Item1Equipped}} == 1) {
		$hasWeaponLevel = 1
	} elsif ($itemHash{$temphash{Item2Equipped}} == 1) {
		$hasWeaponLevel = 2
	#}
	} elsif ($itemHash{$temphash{Item3Equipped}} == 1) {
		$hasWeaponLevel = 3
	}
	]
}

macro set_buyauto_rightHand {
	[
	$Item1 = MainGauche
	$Item2 = Stiletto
	$Item3 = Gladius
	call organize_and_run_buyauto_3
	#call organize_and_run_buyauto_2
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
	call set_item
	]
}

#############################
###### armor
macro set_buyauto_armor {
	[
	$Item1 = AdventureSuit
	$Item2 = Pantie
	call organize_and_run_buyauto_2
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
	$item{price} = 10000
	$item{minLevel} = 22
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
	call set_item
	]
}

#############################
###### robe
macro set_buyauto_robe {
	[
	$Item1 = Hood
	$Item2 = Muffler
	$Item3 = Undershirt
	call organize_and_run_buyauto_3
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
	call set_item
	]
}

#############################
###### topHead
macro set_buyauto_topHead {
	[
	$Item1 = Bandana
	call organize_and_run_buyauto_1
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
	call set_item
	]
}

macro set_tooldealers2 {
	if ($configsaveMap == prt_fild05) {
		$tooldealer = prt_fild05-290-221
		$hasMeatVendor = 0
		
	} elsif ($configsaveMap == oldnewpayon) {
		$tooldealer = oldnewpayon-69-117
		$hasMeatVendor = 1
		$meatDealer = oldnewpayon-44-119
		
	} elsif ($configsaveMap == aldebaran) {
		$tooldealer = aldeba_in-94-56
		$hasMeatVendor = 1
		$meatDealer = aldebaran-175-72
		
	} elsif ($configsaveMap == cmd_fild07) {
		$tooldealer = cmd_fild07-257-126
		$hasMeatVendor = 0
		
	}
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
	$item{maxAmount} = 30
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