
macro baseMacroUp {
	[
	$currentZeny = $.zeny
	$extraBuyCost = 4000
	
	call SetVar
	call set_has_weapon_level
	call set_skills_stats
	
	call set_buyauto_equipment
	
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
	
	} elsif ($.lvl <= 21) {
		if ($configlockMap != prt_fild07) {
			# kafra prt_fild05 290 224
			# sell prt_fild05 290 221
			call set_lockmap_prt_fild07
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
	}
	]
}

macro set_skills_stats {
	set_skills_stats()
}

sub set_skills_stats {
	my $stats = '10 agi, 10 dex, 10 str, 15 agi, 15 dex, 25 agi, 15 str, 9 vit, 30 agi, 25 dex, 40 agi, 30 dex, 50 agi, 19 str, 35 dex, 65 agi, 45 dex, 19 vit, 30 int, 70 agi, 29 str, 50 dex, 40 int, 80 agi, 80 dex, 40 str, 95 agi';
	my $skills;
	if ($char->{jobID} == 0) {
		$skills = 'NV_BASIC 9';
	} elsif ($char->{jobID} == 6) {
		$skills = 'TF_MISS 10, TF_DOUBLE 10, TF_STEAL 10, TF_HIDING 10, TF_POISON 8, TF_DETOXIFY 1';
	} elsif ($char->{jobID} == 17) {
		$skills = 'RG_SNATCHER 10, RG_STEALCOIN 10, RG_BACKSTAP 4, RG_TUNNELDRIVE 5, RG_RAID 5, RG_INTIMIDATE 5, RG_PLAGIARISM 10';
	}
	
	check_key('statsAddAuto_list', $stats);
	check_key('skillsAddAuto_list', $skills);
}

macro set_has_weapon_level {
	$hasWeaponLevel = 0
	$Item1 = Dirk
	$Item2 = Stiletto
	$Item3 = Damascus
	call set_tempitems_3
	if ($itemHash{$temphash{Item1Equipped}} == 1) {
		$hasWeaponLevel = 1
	} elsif ($itemHash{$temphash{Item2Equipped}} == 1) {
		$hasWeaponLevel = 2
	} elsif ($itemHash{$temphash{Item3Equipped}} == 1) {
		$hasWeaponLevel = 3
	}
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

#############################
###### rightHand
macro set_buyauto_rightHand {
	[
	$Item1 = Dirk
	$Item2 = Stiletto
	$Item3 = Damascus
	call organize_and_run_buyauto_3
}

macro set_Dirk {
	[
	$item{name} = Dirk
	$item{id} = 1210
	$item{slot} = rightHand
	$item{price} = 8500
	$item{minLevel} = 12
	$item{npcMap} = payon_in01
	$item{npcX} = 76
	$item{npcY} = 58
	call set_item
	]
}

macro set_Stiletto {
	[
	$item{name} = Stiletto
	$item{id} = 1216
	$item{slot} = rightHand
	$item{price} = 19500
	$item{minLevel} = 12
	$item{npcMap} = payon_in01
	$item{npcX} = 76
	$item{npcY} = 58
	call set_item
	]
}

macro set_Damascus {
	[
	$item{name} = Damascus
	$item{id} = 1222
	$item{slot} = rightHand
	$item{price} = 49000
	$item{minLevel} = 24
	$item{npcMap} = payon_in01
	$item{npcX} = 76
	$item{npcY} = 58
	call set_item
	]
}

#############################
###### armor
macro set_buyauto_armor {
	[
	$Item1 = AdventureSuit
	$Item2 = Coat
	$Item3 = ChainMail
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

macro set_Coat {
	[
	$item{name} = Coat
	$item{id} = 2309
	$item{slot} = armor
	$item{price} = 48000
	$item{minLevel} = 25
	$item{npcMap} = payon_in01
	$item{npcX} = 76
	$item{npcY} = 70 
	call set_item
	]
}

macro set_ChainMail {
	[
	$item{name} = ChainMail
	$item{id} = 2314
	$item{slot} = armor
	$item{price} = 80000
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
	call organize_and_run_buyauto_2
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

automacro Go_Job_Change {
	ConfigKey eventMacro_1_99_stage leveling
	JobLevel = 50
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