
#Perl Subs

macro clear_equipauto {
	[
	do conf -f equipAuto_0_topHead none
	do conf -f equipAuto_0_leftHand none
	do conf -f equipAuto_0_robe none
	do conf -f equipAuto_0_shoes none
	do conf -f equipAuto_0_armor none
	do conf -f equipAuto_0_rightHand none
	do conf -f equipAuto_0_rightAccessory none
	]
}

macro clear_saveMap_keys {
	[
	do conf -f future_saveMap_map none
	do conf -f future_saveMap_x none
	do conf -f future_saveMap_y none
	
	do conf -f future_saveMap_kafra_map none
	do conf -f future_saveMap_kafra_x none
	do conf -f future_saveMap_kafra_y none
	do conf -f future_saveMap_save_sequence none
	]
}

macro basic_config_leveling_settings {
	[
	do conf -f attackAuto 2
	do conf -f lockMap_x none
	do conf -f lockMap_y none
	do conf -f lockMap_randX none
	do conf -f lockMap_randY none
	
	do conf -f teleportAuto_atkMiss 0
	do conf -f teleportAuto_deadly 1
	do conf -f attackAuto_inLockOnly 2
	do conf -f attackCheckLOS 1
	do conf -f attackRouteMaxPathDistance 28
	do conf -f route_randomWalk 1
	do conf -f itemsGatherAuto 0
	do conf -f itemsTakeAuto 2
	do conf -f route_step 9
	do conf -f portalRecord 2
	do conf -f route_avoidWalls 1
	do conf -f itemsMaxWeight_sellOrStore 68
	]
}

macro SetVar {
	[
	$configlockMap = &config(lockMap)
	$configsaveMap = &config(saveMap)
	$testvar = &config(eventMacro_test)
	]
}

sub set_common_equip_buyAuto {
	my $Slot = shift;
	my $name = shift;
	my $price = shift;
	my $npc = shift;
	$npc =~ s/-/ /g;
	
	check_key('buyAuto_'.$Slot, $name);
	check_key('buyAuto_'.$Slot.'_npc', $npc);
	check_key('buyAuto_'.$Slot.'_zeny', '> '.$price);
	check_key('buyAuto_'.$Slot.'_minAmount', 0);
	check_key('buyAuto_'.$Slot.'_maxAmount', 1);
	check_key('buyAuto_'.$Slot.'_minDistance', 1);
	check_key('buyAuto_'.$Slot.'_maxDistance', 10);
	check_key('buyAuto_'.$Slot.'_maxBase', 99);
	check_key('buyAuto_'.$Slot.'_minBase', 1);
	check_key('buyAuto_'.$Slot.'_disabled', 0);
	
	return 1;
}

sub clear_common_equip_buyAuto {
	my $Slot = shift;
	
	check_key('buyAuto_'.$Slot, undef);
	check_key('buyAuto_'.$Slot.'_npc', undef);
	check_key('buyAuto_'.$Slot.'_zeny', undef);
	check_key('buyAuto_'.$Slot.'_minAmount', undef);
	check_key('buyAuto_'.$Slot.'_maxAmount', undef);
	check_key('buyAuto_'.$Slot.'_minDistance', undef);
	check_key('buyAuto_'.$Slot.'_maxDistance', undef);
	check_key('buyAuto_'.$Slot.'_maxBase', undef);
	check_key('buyAuto_'.$Slot.'_minBase', undef);
	check_key('buyAuto_'.$Slot.'_disabled', undef);
	
	return 1;
}

sub GetEquippedInSlotName {
	my $slot = shift;
	
	return 0 unless (exists $char->{equipment} && $char->{equipment});
	return 0 unless (exists $char->{equipment}{$slot} && $char->{equipment}{$slot});
	my $item = $char->{equipment}{$slot};
	
	return $item->{name};
}

sub GetEquippedInSlotNameID {
	my $slot = shift;
	
	return 0 unless (exists $char->{equipment} && $char->{equipment});
	return 0 unless (exists $char->{equipment}{$slot} && $char->{equipment}{$slot});
	my $item = $char->{equipment}{$slot};
	
	return $item->{nameID};
}

sub isEquippedInSlotNameID {
	my $slot = shift;
	my $nameID = shift;
	
	#Log::warning "[isEquippedInSlotNameID] slot ($slot) | nameID ($nameID)\n";
	
	return 0 unless (exists $char->{equipment} && $char->{equipment});
	return 0 unless (exists $char->{equipment}{$slot} && $char->{equipment}{$slot});
	
	my $item = $char->{equipment}{$slot};
	
	return 0 unless ($item->{nameID} == $nameID);
	
	return 1;
}

macro set_tooldealers_and_kafra {
	if ($configsaveMap == prt_fild05) {
		$kafra = prt_fild05-290-224
		$storageSequence = r~/storage/i
		
		$tooldealer = prt_fild05-290-221
		$hasMeatVendor = 0
		
	} elsif ($configsaveMap == oldnewpayon) {
		$kafra = oldnewpayon-98-118
		$storageSequence = r~/storage/i
		
		$tooldealer = oldnewpayon-69-117
		$hasMeatVendor = 1
		$meatDealer = oldnewpayon-44-119
		
	} elsif ($configsaveMap == aldebaran) {
		$kafra = aldebaran-143-119
		$storageSequence = r~/storage/i
		
		$tooldealer = aldeba_in-94-56
		$hasMeatVendor = 1
		$meatDealer = aldebaran-175-72
		
	} elsif ($configsaveMap == cmd_fild07) {
		$kafra = cmd_fild07-136-134
		$storageSequence = r~/storage/i
		
		$tooldealer = cmd_fild07-257-126
		$hasMeatVendor = 0
		
	}
}

sub get_weapon_refine {
	my $weapon = $char->{equipment}{'rightHand'};
	my $refine = $weapon->{upgrade};
	return $refine;
}

macro fix_equipAuto_names {
	[
	fix_equipauto_names()
	]
}

sub fix_equipauto_names {
	#Log::warning "[fix_equipauto_names] Start\n";
	
	foreach my $slot (values %equipSlot_lut) {
		#Log::warning "[Slot] $slot\n";
		
		my $slot_config = "equipAuto_0_$slot";
		next unless (exists $config{$slot_config});
		next unless (defined $config{$slot_config});
		#Log::warning "[Slot] $slot - $slot_config - $config{$slot_config}\n";
		
		next unless (exists $char->{equipment} && $char->{equipment});
		next unless (exists $char->{equipment}{$slot} && $char->{equipment}{$slot});
		
		my $equipauto = $config{$slot_config};
		my $item = $char->{equipment}{$slot};
		my $compName = itemName($item);
		#Log::warning "[1] Comparing $equipauto | $compName\n";
		if ($equipauto eq $compName) {
			#Log::warning "[1 2] Success\n";
			next;
		}
		my $name = GetNamebyNameID($item->{nameID});
		#Log::warning "[2] Comparing $equipauto | $name\n";
		if ($name eq $equipauto) {
			#Log::warning "[2 2] Success\n";
			check_key($slot_config, $compName);
			next;
		}
	}
}

macro after_buy_weapon {
	[
	call set_buyauto_rightHand
	]
	pause 3
	[
	call fix_equipAuto_names
	call set_has_weapon_level
	call set_buyauto_refine
	]
}

macro set_has_weapon_level {
	[
	call set_weapons
	call set_tempitems_$itemAmount
	
	call set_hasLevel
	$hasLevelWeapon = $hasLevel
	]
}

macro set_hasLevel {
	[
	$hasLevel = 0
	if ($itemHash{$temphash{Item1Equipped}} == 1) {
		$hasLevel = 1
	} elsif ($itemAmount >= 2 && $itemHash{$temphash{Item2Equipped}} == 1) {
		$hasLevel = 2
	} elsif ($itemAmount >= 3 && $itemHash{$temphash{Item3Equipped}} == 1) {
		$hasLevel = 3
	}
	]
}

macro set_buyauto_rightHand {
	[
	call set_weapons
	call organize_and_run_buyauto_$itemAmount
	]
}

macro set_buyauto_armor {
	[
	call set_armor
	call organize_and_run_buyauto_$itemAmount
	
	call set_hasLevel
	$hasLevelArmor = $hasLevel
	]
}

macro set_buyauto_shoes {
	[
	call set_shoes
	call organize_and_run_buyauto_$itemAmount
	
	call set_hasLevel
	$hasLevelShoes = $hasLevel
	]
}

macro set_buyauto_robe {
	[
	call set_robe
	call organize_and_run_buyauto_$itemAmount
	
	call set_hasLevel
	$hasLevelRobe = $hasLevel
	]
}

macro set_buyauto_topHead {
	[
	call set_topHead
	call organize_and_run_buyauto_$itemAmount
	
	call set_hasLevel
	$hasLeveltopHead = $hasLevel
	]
}

macro set_buyauto_rightAccessory {
	[
	call set_rightAccessory
	call organize_and_run_buyauto_$itemAmount
	
	call set_hasLevel
	$hasLevelrightAccessory = $hasLevel
	]
}

sub weapon_equipped {
	my $equipauto = $config{equipAuto_0_rightHand};
	return 0 unless ($equipauto);
	return 0 unless (exists $char->{equipment} && $char->{equipment});
	return 0 unless (exists $char->{equipment}{'rightHand'} && $char->{equipment}{'rightHand'});
	my $weapon = $char->{equipment}{'rightHand'};
	
	my $compName = itemName($weapon);
	if ($equipauto eq $compName) {
		return 1;
	}
	return 0;
}

macro set_buyauto_refine {
	[
	$weaponsafe = weapon_equipped()
	if ($weaponsafe) {
		call refine_weapon_logic
	} else {
		call clear_autoRefine
	}
	]
}

macro refine_weapon_logic {
	[
	call set_weapons
	call set_tempitems_$itemAmount
	
	$foundWeapon = 0
	$refineLevel = 0
	if ($hasLevelWeapon == 1) {
		if ($itemHash{$temphash{Item1autoRefine}}) {
			$foundWeapon = 1
			$refineLevel = $itemHash{$temphash{Item1refineLevel}}
		}
	} elsif ($hasLevelWeapon == 2) {
		if ($itemHash{$temphash{Item2autoRefine}}) {
			$foundWeapon = 1
			$refineLevel = $itemHash{$temphash{Item2refineLevel}}
		}
	} elsif ($hasLevelWeapon == 3) {
		if ($itemHash{$temphash{Item3autoRefine}}) {
			$foundWeapon = 1
			$refineLevel = $itemHash{$temphash{Item3refineLevel}}
		}
	}
	
	if ($foundWeapon == 1) {
		$wantedRefine = 0
		$needRefineCount = 0
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
			do conf -f autoRefine_commandOnSuccess eventMacro set_buyauto_refine
			call set_BetterBuy_refine
		} else {
			log No need to refine further POOOOGG
			call clear_autoRefine
		}
	}
	]
}

macro clear_autoRefine {
	[
	do conf -f autoRefine_on 0
	do conf -f autoRefine_weaponLevel none
	do conf -f autoRefine_wantedRefine none
	do conf -f autoRefine_npc none
	do conf -f autoRefine_commandOnSuccess none
	call clear_BetterBuy_refine
	]
}

sub get_maxSafeRefine {
	my $refineLevel = shift;
	if ($refineLevel == 1) {
		return 7;
	} elsif ($refineLevel == 2) {
		return 6;
	} elsif ($refineLevel == 3) {
		return 5;
	} elsif ($refineLevel == 4) {
		return 4;
	}
}

sub getSkillLevelByHandle {
	my $skillhandle = shift;
	
	my $level;
	
	return 0 unless (exists $char->{skills} && $char->{skills});
	
	if (exists $char->{skills}{$skillhandle}) {
		$level = $char->{skills}{$skillhandle}{lv};
	} else {
		$level = 0;
	}
	
	#Log::warning "[getSkillLevelByHandle] skillhandle ($skillhandle) | level ($level)\n";
	
	return $level;
}

sub hasIdentifiedItem {
	my $itemID = shift;
	
	return 0 unless ($char->inventory->isReady);
	
	my $item = $char->inventory->getByNameID($itemID, 1);
	
	if ($item) {
		return 1;
	}
	return 0;
}

sub GetNamebyNameID {
	my $itemID = shift;

	my $name = itemNameSimple($itemID);
	
	my $numSlots = $itemSlotCount_lut{$itemID};
	
	$name .= " [$numSlots]" if $numSlots;
	
	return $name;
}

sub fetchItemByIDReturnName {
	my $itemID = shift;
	
	my $item = $char->inventory->getByNameID($itemID, 1);
	
	my $compName = itemName($item);
	
	return $compName;
}

sub nextMap {
	my $map = $_[0];
	if ($map =~ /^new_(\d)-(\d)$/) {
		return "new_".$1."-".($2+1);
	} else {
		return 0;
	}
}
 
sub previousMap {
	my $map = $_[0];
	if ($map =~ /^new_(\d)-(\d)$/) {
		return "new_".$1."-".($2-1);
	} else {
		return 0;
	}
}

sub get_jobId {
	return $char->{jobID};
}

sub get_free_slot_index_for_key {
	my ($key, $value) = @_;
	my $index = 0;
	my $found = 0;
	my $first_not_def_index;
	while (1) {
		$key_plus_index = $key.'_'.$index;
		if (!exists $config{$key_plus_index}) {
			Log::warning "[get_free_slot_index_for_key] Found slot in block $key for value $value at index $index (!exists)\n";
			last;
			
		} elsif (!defined $config{$key_plus_index}) {
			$first_not_def_index = $index;
			
		} elsif ($config{$key_plus_index} eq $value) {
			$found = 1;
			last;
		}
		$index++;
	}
	if ($found) {
		Log::warning "[get_free_slot_index_for_key] Found $value in slot $index of block $key (eq)\n";
		return $index;
		
	} elsif (!$found && defined $first_not_def_index) {
		Log::warning "[get_free_slot_index_for_key] Found slot in block $key for value $value at index $index (!defined)\n";
		return $first_not_def_index;
		
	} elsif (!$found && !defined $first_not_def_index) {
		Log::warning "[get_free_slot_index_for_key] Found slot in block $key for value $value at index $index (!exists)\n";
		return $index;
	}
}

sub find_key_in_block {
	my ($key, $value) = @_;
	my $index = 0;
	while (1) {
		$key_plus_index = $key.'_'.$index;
		
		if (!exists $config{$key_plus_index}) {
			Log::warning "[find_key_in_block] Looked until index $index of block $key and did not find $value (!exists)\n";
			last;
		} elsif ($config{$key_plus_index} eq $value) {
			Log::warning "[find_key_in_block] Found $value in slot $index of block $key (eq)\n";
			return $index;
		}
		$index++;
	}
	return -1;
}

sub config_time_not_set {
	my ($key) = @_;
	return 1 if (!exists $config{$key} || !defined $config{$key} || $config{$key} !~ /\d+/);
	return 0;
}

sub time_passed {
	my ($time, $timeout) = @_;
	return 1 if (timeOut($time, $timeout));
	return 0;
}

sub sanity_check_steal_skill {
	my $Slot = shift;
	my $level = shift;
	
	check_key('attackSkillSlot_'.$Slot, 'TF_STEAL');
	check_key('attackSkillSlot_'.$Slot.'_lvl', $level);
	check_key('attackSkillSlot_'.$Slot.'_sp', '> 10');
	check_key('attackSkillSlot_'.$Slot.'_maxUses', 1);
	check_key('attackSkillSlot_'.$Slot.'_timeout', 1);
	check_key('attackSkillSlot_'.$Slot.'_maxAttempts', 2);
	check_key('attackSkillSlot_'.$Slot.'_disabled', 0);
	
	return 1;
}

sub sanity_clear_steal_skill {
	my $Slot = shift;
	
	check_key('attackSkillSlot_'.$Slot, undef);
	check_key('attackSkillSlot_'.$Slot.'_lvl', undef);
	check_key('attackSkillSlot_'.$Slot.'_sp', undef);
	check_key('attackSkillSlot_'.$Slot.'_maxUses', undef);
	check_key('attackSkillSlot_'.$Slot.'_timeout', undef);
	check_key('attackSkillSlot_'.$Slot.'_maxAttempts', undef);
	check_key('attackSkillSlot_'.$Slot.'_disabled', undef);
	
	return 1;
}

sub sanity_check_stealCoin_skill {
	my $Slot = shift;
	my $level = shift;
	
	check_key('attackSkillSlot_'.$Slot, 'RG_STEALCOIN');
	check_key('attackSkillSlot_'.$Slot.'_lvl', $level);
	check_key('attackSkillSlot_'.$Slot.'_sp', '> 15');
	check_key('attackSkillSlot_'.$Slot.'_target_notCoinStolen', 1);
	check_key('attackSkillSlot_'.$Slot.'_timeout', 1);
	check_key('attackSkillSlot_'.$Slot.'_maxAttempts', 4);
	check_key('attackSkillSlot_'.$Slot.'_disabled', 0);
	
	return 1;
}

sub sanity_check_Two_Handed_Quicken {
	my $Slot = shift;
	my $level = shift;
	
	check_key('useSelf_skill_'.$Slot, 'KN_TWOHANDQUICKEN');
	check_key('useSelf_skill_'.$Slot.'_lvl', $level);
	check_key('useSelf_skill_'.$Slot.'_sp', '> 50');
	check_key('useSelf_skill_'.$Slot.'_whenStatusInactive', 'EFST_TWOHANDQUICKEN');
	check_key('useSelf_skill_'.$Slot.'_inLockOnly', 1);
	check_key('useSelf_skill_'.$Slot.'_notWhileSitting', 1);
	check_key('useSelf_skill_'.$Slot.'_disabled', 0);
	
	return 1;
}

sub sanity_check_getauto {
	my $Slot = shift;
	my $name = shift;
	my $amount = shift;
	
	check_key('getAuto_'.$Slot, $name);
	check_key('getAuto_'.$Slot.'_maxAmount', $amount);
	check_key('getAuto_'.$Slot.'_passive', 1);
	check_key('getAuto_'.$Slot.'_disabled', 0);
	
	return 1;
}

sub clear_common_getauto {
	my $Slot = shift;
	
	check_key('getAuto_'.$Slot, undef);
	check_key('getAuto_'.$Slot.'_maxAmount', undef);
	check_key('getAuto_'.$Slot.'_passive', undef);
	check_key('getAuto_'.$Slot.'_disabled', undef);
	
	return 1;
}

sub check_key {
	my $key = shift;
	my $value = shift;
	if ($config{$key} ne $value) {
		configModify($key, $value);
	}
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
	
	if ($item{buytype} == player) {
		$totalcost = &eval($item{minSearchPrice} + $extraBuyCost)
		
	} elsif ($item{buytype} == fallback) {
		$totalcost = &eval($item{minSearchPrice} + $extraBuyCost)
		
	} elsif ($item{buytype} == npc) {
		$item{minSearchPrice} = 0
		$totalcost = &eval($item{price} + $extraBuyCost)
	}
	
	if ($currentZeny >= $totalcost) {
		$item{CanBuy} = 1
	} else {
		$item{CanBuy} = 0
	}
	
	$itemHash{$item{name}name} = $item{name}
	$itemHash{$item{name}id} = $item{id}
	$itemHash{$item{name}slot} = $item{slot}
	$itemHash{$item{name}buytype} = $item{buytype}
	$itemHash{$item{name}price} = $item{price}
	$itemHash{$item{name}minSearchPrice} = $item{minSearchPrice}
	$itemHash{$item{name}minLevel} = $item{minLevel}
	if ($testvar == 1) {
		$itemHash{$item{name}npc} = prt_fild05-290-217
	} else {
		$itemHash{$item{name}npc} = $item{npc}
	}
	$itemHash{$item{name}Has} = $item{Has}
	$itemHash{$item{name}Equipped} = $item{Equipped}
	$itemHash{$item{name}CanEquip} = $item{CanEquip}
	$itemHash{$item{name}CanBuy} = $item{CanBuy}
	$itemHash{$item{name}autoRefine} = $item{autoRefine}
	$itemHash{$item{name}refineLevel} = $item{refineLevel}
	$itemHash{$item{name}commandAfterBuy} = $item{commandAfterBuy}
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
	$name = fetchItemByIDReturnName("$.param[0]")
	log Setting equipauto $name
	do conf -f equipAuto_0_$.param[1] $name
	do eq $name
	do iconf $.param[0] 1 0 1
	]
}

macro buyAuto_clear {
	[
	$name = GetNamebyNameID("$.param[0]")
	log Clearing buyAuto $name
	$foundSlot = find_key_in_block("buyAuto","$name")
	if ($foundSlot != -1) {
		clear_common_equip_buyAuto("$foundSlot")
	}
	do iconf $.param[0] 0 0 1
	]
}

sub get_hash_key {
	my $part1 = shift;
	my $part2 = shift;
	my $final = $part1.$part2;
	return $final;
}

macro setTempHash1 {
	[
	$temphash{Item1name} = get_hash_key("$Item1","name")
	$temphash{Item1id} = get_hash_key("$Item1","id")
	$temphash{Item1slot} = get_hash_key("$Item1","slot")
	$temphash{Item1buytype} = get_hash_key("$Item1","buytype")
	$temphash{Item1price} = get_hash_key("$Item1","price")
	$temphash{Item1minSearchPrice} = get_hash_key("$Item1","minSearchPrice")
	$temphash{Item1minLevel} = get_hash_key("$Item1","minLevel")
	$temphash{Item1npc} = get_hash_key("$Item1","npc")
	$temphash{Item1Has} = get_hash_key("$Item1","Has")
	$temphash{Item1Equipped} = get_hash_key("$Item1","Equipped")
	$temphash{Item1CanEquip} = get_hash_key("$Item1","CanEquip")
	$temphash{Item1CanBuy} = get_hash_key("$Item1","CanBuy")
	$temphash{Item1autoRefine} = get_hash_key("$Item1","autoRefine")
	$temphash{Item1refineLevel} = get_hash_key("$Item1","refineLevel")
	$temphash{Item1commandAfterBuy} = get_hash_key("$Item1","commandAfterBuy")
	]
}

macro setTempHash2 {
	[
	$temphash{Item2name} = get_hash_key("$Item2","name")
	$temphash{Item2id} = get_hash_key("$Item2","id")
	$temphash{Item2slot} = get_hash_key("$Item2","slot")
	$temphash{Item2buytype} = get_hash_key("$Item2","buytype")
	$temphash{Item2price} = get_hash_key("$Item2","price")
	$temphash{Item2minSearchPrice} = get_hash_key("$Item2","minSearchPrice")
	$temphash{Item2minLevel} = get_hash_key("$Item2","minLevel")
	$temphash{Item2npc} = get_hash_key("$Item2","npc")
	$temphash{Item2Has} = get_hash_key("$Item2","Has")
	$temphash{Item2Equipped} = get_hash_key("$Item2","Equipped")
	$temphash{Item2CanEquip} = get_hash_key("$Item2","CanEquip")
	$temphash{Item2CanBuy} = get_hash_key("$Item2","CanBuy")
	$temphash{Item2autoRefine} = get_hash_key("$Item2","autoRefine")
	$temphash{Item2refineLevel} = get_hash_key("$Item2","refineLevel")
	$temphash{Item2commandAfterBuy} = get_hash_key("$Item2","commandAfterBuy")
	]
}

macro setTempHash3 {
	[
	$temphash{Item3name} = get_hash_key("$Item3","name")
	$temphash{Item3id} = get_hash_key("$Item3","id")
	$temphash{Item3slot} = get_hash_key("$Item3","slot")
	$temphash{Item3buytype} = get_hash_key("$Item3","buytype")
	$temphash{Item3price} = get_hash_key("$Item3","price")
	$temphash{Item3minSearchPrice} = get_hash_key("$Item3","minSearchPrice")
	$temphash{Item3minLevel} = get_hash_key("$Item3","minLevel")
	$temphash{Item3npc} = get_hash_key("$Item3","npc")
	$temphash{Item3Has} = get_hash_key("$Item3","Has")
	$temphash{Item3Equipped} = get_hash_key("$Item3","Equipped")
	$temphash{Item3CanEquip} = get_hash_key("$Item3","CanEquip")
	$temphash{Item3CanBuy} = get_hash_key("$Item3","CanBuy")
	$temphash{Item3autoRefine} = get_hash_key("$Item3","autoRefine")
	$temphash{Item3refineLevel} = get_hash_key("$Item3","refineLevel")
	$temphash{Item3commandAfterBuy} = get_hash_key("$Item3","commandAfterBuy")
	]
}

macro set_tempitems_1 {
	[
	call set_$Item1
	call setTempHash1
	]
}

macro organize_and_run_buyauto_1 {
	[
	call set_tempitems_1
	call buyauto_logic_run_1
	]
}

macro set_tempitems_2 {
	[
	call set_$Item1
	call set_$Item2
	call setTempHash1
	call setTempHash2
	]
}

macro organize_and_run_buyauto_2 {
	[
	call set_tempitems_2
	call buyauto_logic_run_2
	]
}

macro set_tempitems_3 {
	[
	call set_$Item1
	call set_$Item2
	call set_$Item3
	call setTempHash1
	call setTempHash2
	call setTempHash3
	]
}

macro organize_and_run_buyauto_3 {
	[
	call set_tempitems_3
	call buyauto_logic_run_3
	]
}

macro buyauto_logic_run_1 {
	[
	if ($itemHash{$temphash{Item1Equipped}} == 1) {
		log $Item1 is equipped DAMNN
		
	} elsif ($itemHash{$temphash{Item1Equipped}} == 0 && $itemHash{$temphash{Item1CanEquip}} == 0) {
		log $Item1 is not equipped, cannot equip it
		
	} elsif ($itemHash{$temphash{Item1Equipped}} == 0 && $itemHash{$temphash{Item1CanBuy}} == 0 && $itemHash{$temphash{Item1Has}} == 0) {
		log $Item1 is not equipped, cannot buy it
		
	} elsif ($itemHash{$temphash{Item1Equipped}} == 0 && $itemHash{$temphash{Item1CanEquip}} == 1 && $itemHash{$temphash{Item1Has}} >= 1) {
		call set_clear_buy_item_1
		call set_equip $itemHash{$temphash{Item1id}} $itemHash{$temphash{Item1slot}}
		
	} elsif ($itemHash{$temphash{Item1Equipped}} == 0 && $itemHash{$temphash{Item1CanEquip}} == 1 && $itemHash{$temphash{Item1Has}} == 0 && $itemHash{$temphash{Item1CanBuy}} == 1) {
		call set_buyauto_item_1
	}
	]
}

macro buyauto_logic_run_2 {
	[
	if ($itemHash{$temphash{Item2Equipped}} == 1) {
		log $Item2 is equipped DAMNN
		
	} elsif ($itemHash{$temphash{Item1Equipped}} == 1 && $itemHash{$temphash{Item2CanEquip}} == 0) {
		log $Item1 is equipped and cannot equip $Item2 DAMNN
		
	} elsif ($itemHash{$temphash{Item1Equipped}} == 1 && $itemHash{$temphash{Item2CanEquip}} == 1 && $itemHash{$temphash{Item2CanBuy}} == 0 && $itemHash{$temphash{Item2Has}} == 0) {
		log $Item1 is equipped, can equip $Item2 but cannot buy it DAMNN
		
	} elsif ($itemHash{$temphash{Item1Equipped}} == 0 && $itemHash{$temphash{Item1CanBuy}} == 0 && $itemHash{$temphash{Item1Has}} == 0) {
		log $Item1 is not equipped, cannot buy it
		
	} elsif ($itemHash{$temphash{Item2Equipped}} == 0 && $itemHash{$temphash{Item2CanEquip}} == 1 && $itemHash{$temphash{Item2Has}} >= 1) {
		call set_clear_buy_item_1
		call set_clear_buy_item_2
		call set_equip $itemHash{$temphash{Item2id}} $itemHash{$temphash{Item2slot}}
		
	} elsif ($itemHash{$temphash{Item2Equipped}} == 0 && $itemHash{$temphash{Item2CanEquip}} == 1 && $itemHash{$temphash{Item2Has}} == 0 && $itemHash{$temphash{Item2CanBuy}} == 1) {
		call set_clear_buy_item_1
		call set_buyauto_item_2
		
	} elsif (($itemHash{$temphash{Item2CanEquip}} == 0 || $itemHash{$temphash{Item2CanBuy}} == 0) && $itemHash{$temphash{Item1Equipped}} == 0 && $itemHash{$temphash{Item1CanEquip}} == 1 && $itemHash{$temphash{Item1Has}} >= 1) {
		call set_clear_buy_item_1
		call set_equip $itemHash{$temphash{Item1id}} $itemHash{$temphash{Item1slot}}
		
	} elsif (($itemHash{$temphash{Item2CanEquip}} == 0 || $itemHash{$temphash{Item2CanBuy}} == 0) && $itemHash{$temphash{Item1Equipped}} == 0 && $itemHash{$temphash{Item1CanEquip}} == 1 && $itemHash{$temphash{Item1Has}} == 0 && $itemHash{$temphash{Item1CanBuy}} == 1) {
		call set_buyauto_item_1
	}
	]
}

################

macro buyauto_logic_run_3 {
	[
	if ($itemHash{$temphash{Item3Equipped}} == 1) {
		log $Item3 is equipped DAMNN
		
	} elsif ($itemHash{$temphash{Item2Equipped}} == 1 && $itemHash{$temphash{Item3CanEquip}} == 0) {
		log $Item2 is equipped and cannot equip $Item3 DAMNN
		
	} elsif ($itemHash{$temphash{Item2Equipped}} == 1 && $itemHash{$temphash{Item3CanEquip}} == 1 && $itemHash{$temphash{Item3CanBuy}} == 0 && $itemHash{$temphash{Item3Has}} == 0) {
		log $Item2 is equipped, can equip $Item3 but cannot buy it DAMNN
		
	} elsif ($itemHash{$temphash{Item1Equipped}} == 1 && $itemHash{$temphash{Item3CanEquip}} == 0 && $itemHash{$temphash{Item2CanEquip}} == 0) {
		log $Item1 is equipped and cannot equip $Item2 or $Item3 DAMNN
		
	} elsif ($itemHash{$temphash{Item1Equipped}} == 1 && ($itemHash{$temphash{Item3CanEquip}} == 1 || $itemHash{$temphash{Item2CanEquip}} == 1) && $itemHash{$temphash{Item3CanBuy}} == 0 && $itemHash{$temphash{Item2CanBuy}} == 0 && $itemHash{$temphash{Item3Has}} == 0 && $itemHash{$temphash{Item2Has}} == 0) {
		log $Item1 is equipped, can equip $Item2 or $Item3 stuff but not buy either DAMNN
		
	} elsif ($itemHash{$temphash{Item1Equipped}} == 0 && $itemHash{$temphash{Item1CanBuy}} == 0 && $itemHash{$temphash{Item1Has}} == 0) {
		log $Item1 is not equipped, cannot buy it
		
	} elsif ($itemHash{$temphash{Item3Equipped}} == 0 && $itemHash{$temphash{Item3CanEquip}} == 1 && $itemHash{$temphash{Item3Has}} >= 1) {
		call set_clear_buy_item_1
		call set_clear_buy_item_2
		call set_clear_buy_item_3
		call set_equip $itemHash{$temphash{Item3id}} $itemHash{$temphash{Item3slot}}
		
	} elsif ($itemHash{$temphash{Item3Equipped}} == 0 && $itemHash{$temphash{Item3CanEquip}} == 1 && $itemHash{$temphash{Item3Has}} == 0 && $itemHash{$temphash{Item3CanBuy}} == 1) {
		call set_clear_buy_item_1
		call set_clear_buy_item_2
		call set_buyauto_item_3
		
	} elsif (($itemHash{$temphash{Item3CanEquip}} == 0 || $itemHash{$temphash{Item3Has}} == 0) && $itemHash{$temphash{Item2Equipped}} == 0 && $itemHash{$temphash{Item2CanEquip}} == 1 && $itemHash{$temphash{Item2Has}} >= 1) {
		call set_clear_buy_item_1
		call set_clear_buy_item_2
		call set_equip $itemHash{$temphash{Item2id}} $itemHash{$temphash{Item2slot}}
		
	} elsif (($itemHash{$temphash{Item3CanEquip}} == 0 || $itemHash{$temphash{Item3CanBuy}} == 0) && $itemHash{$temphash{Item2Equipped}} == 0 && $itemHash{$temphash{Item2CanEquip}} == 1 && $itemHash{$temphash{Item2Has}} == 0 && $itemHash{$temphash{Item2CanBuy}} == 1) {
		call set_clear_buy_item_1
		call set_buyauto_item_2
		
	} elsif (($itemHash{$temphash{Item3CanEquip}} == 0 || $itemHash{$temphash{Item3CanBuy}} == 0) && ($itemHash{$temphash{Item2CanEquip}} == 0 || $itemHash{$temphash{Item2CanBuy}} == 0) && $itemHash{$temphash{Item1Equipped}} == 0 && $itemHash{$temphash{Item1CanEquip}} == 1 && $itemHash{$temphash{Item1Has}} >= 1) {
		call set_clear_buy_item_1
		call set_equip $itemHash{$temphash{Item1id}} $itemHash{$temphash{Item1slot}}
		
	} elsif (($itemHash{$temphash{Item3CanEquip}} == 0 || $itemHash{$temphash{Item3CanBuy}} == 0) && ($itemHash{$temphash{Item2CanEquip}} == 0 || $itemHash{$temphash{Item2CanBuy}} == 0) && $itemHash{$temphash{Item1Equipped}} == 0 && $itemHash{$temphash{Item1CanEquip}} == 1 && $itemHash{$temphash{Item1Has}} == 0 && $itemHash{$temphash{Item1CanBuy}} == 1) {
		call set_buyauto_item_1
	}
	]
}

macro set_buyauto_item_1 {
	[
	if ($itemHash{$temphash{Item1buytype}} == player) {
		call set_BetterbuyAuto_item_equip $itemHash{$temphash{Item1id}} $itemHash{$temphash{Item1price}} $itemHash{$temphash{Item1commandAfterBuy}}
	
	} elsif ($itemHash{$temphash{Item1buytype}} == fallback) {
		call set_BetterbuyAuto_item_equip_fallback $itemHash{$temphash{Item1id}} $itemHash{$temphash{Item1price}} $itemHash{$temphash{Item1commandAfterBuy}} $itemHash{$temphash{Item1npc}}
		
	} elsif ($itemHash{$temphash{Item1buytype}} == npc) {
		call set_buyAuto $itemHash{$temphash{Item1id}} $itemHash{$temphash{Item1price}} $itemHash{$temphash{Item1npc}}
	}
	]
}

macro set_clear_buy_item_1 {
	[
	if ($itemHash{$temphash{Item1buytype}} == player || $itemHash{$temphash{Item1buytype}} == fallback) {
		call BetterbuyAuto_clear_equip $itemHash{$temphash{Item1id}}
		
	} elsif ($itemHash{$temphash{Item1buytype}} == npc) {
		call buyAuto_clear $itemHash{$temphash{Item1id}}
	}
	]
}

macro set_buyauto_item_2 {
	[
	if ($itemHash{$temphash{Item2buytype}} == player) {
		call set_BetterbuyAuto_item_equip $itemHash{$temphash{Item2id}} $itemHash{$temphash{Item2price}} $itemHash{$temphash{Item2commandAfterBuy}}
	
	} elsif ($itemHash{$temphash{Item2buytype}} == fallback) {
		call set_BetterbuyAuto_item_equip_fallback $itemHash{$temphash{Item2id}} $itemHash{$temphash{Item2price}} $itemHash{$temphash{Item2commandAfterBuy}} $itemHash{$temphash{Item2npc}}
		
	} elsif ($itemHash{$temphash{Item2buytype}} == npc) {
		call set_buyAuto $itemHash{$temphash{Item2id}} $itemHash{$temphash{Item2price}} $itemHash{$temphash{Item2npc}}
	}
	]
}

macro set_clear_buy_item_2 {
	[
	if ($itemHash{$temphash{Item2buytype}} == player || $itemHash{$temphash{Item2buytype}} == fallback) {
		call BetterbuyAuto_clear_equip $itemHash{$temphash{Item2id}}
		
	} elsif ($itemHash{$temphash{Item2buytype}} == npc) {
		call buyAuto_clear $itemHash{$temphash{Item2id}}
	}
	]
}

macro set_buyauto_item_3 {
	[
	if ($itemHash{$temphash{Item3buytype}} == player) {
		call set_BetterbuyAuto_item_equip $itemHash{$temphash{Item3id}} $itemHash{$temphash{Item3price}} $itemHash{$temphash{Item3commandAfterBuy}}
	
	} elsif ($itemHash{$temphash{Item3buytype}} == fallback) {
		call set_BetterbuyAuto_item_equip_fallback $itemHash{$temphash{Item3id}} $itemHash{$temphash{Item3price}} $itemHash{$temphash{Item3commandAfterBuy}} $itemHash{$temphash{Item3npc}}
	
	} elsif ($itemHash{$temphash{Item3buytype}} == npc) {
		call set_buyAuto $itemHash{$temphash{Item3id}} $itemHash{$temphash{Item3price}} $itemHash{$temphash{Item3npc}}
	}
	]
}

macro set_clear_buy_item_3 {
	[
	if ($itemHash{$temphash{Item3buytype}} == player || $itemHash{$temphash{Item3buytype}} == fallback) {
		call BetterbuyAuto_clear_equip $itemHash{$temphash{Item3id}}
		
	} elsif ($itemHash{$temphash{Item3buytype}} == npc) {
		call buyAuto_clear $itemHash{$temphash{Item3id}}
	}
	]
}

macro set_BetterbuyAuto_item_equip {
	[
	$name = GetNamebyNameID("$.param[0]")
	log Setting BetterShopper item_equip $name ($.param[0]) for price $.param[1], command $.param[2]
	$nextFreeSlot = get_free_slot_index_for_key("BetterShopper","$.param[0]")
	set_common_equip_BetterbuyAuto("$nextFreeSlot","$.param[0]","$.param[1]","$.param[2]")
	$totalcost = &eval($.param[1] + $extraBuyCost)
	$currentZeny = &eval($currentZeny - $totalcost)
	do iconf $.param[0] 1 0 0
	]
}

sub set_common_equip_BetterbuyAuto {
	my $Slot = shift;
	my $id = shift;
	my $price = shift;
	my $command = shift;
	$command =~ s/-/ /g;
	
	check_key('BetterShopper_'.$Slot, $id);
	check_key('BetterShopper_'.$Slot.'_price', undef);
	check_key('BetterShopper_'.$Slot.'_maxPrice', $price);
	check_key('BetterShopper_'.$Slot.'_minInventoryAmount', 0);
	check_key('BetterShopper_'.$Slot.'_minShopAmount', 1);
	check_key('BetterShopper_'.$Slot.'_maxAmount', 1);
	check_key('BetterShopper_'.$Slot.'_fallbackNpcShop', undef);
	check_key('BetterShopper_'.$Slot.'_fallbackNpcTalk', undef);
	check_key('BetterShopper_'.$Slot.'_fallbackNpcTSequence', undef);
	check_key('BetterShopper_'.$Slot.'_commandAfterBuy', $command);
	
	return 1;
}

macro set_BetterbuyAuto_item_equip_fallback {
	[
	$name = GetNamebyNameID("$.param[0]")
	log Setting BetterShopper item_equip $name ($.param[0]) for price $.param[1] with fallbackNpcShop $.param[3], command $.param[2]
	$nextFreeSlot = get_free_slot_index_for_key("BetterShopper","$.param[0]")
	set_common_equip_BetterbuyAuto_fallback("$nextFreeSlot","$.param[0]","$.param[1]","$.param[2]","$.param[3]")
	$totalcost = &eval($.param[1] + $extraBuyCost)
	$currentZeny = &eval($currentZeny - $totalcost)
	do iconf $.param[0] 1 0 0
	]
}

sub set_common_equip_BetterbuyAuto_fallback {
	my $Slot = shift;
	my $id = shift;
	my $price = shift;
	my $command = shift;
	$command =~ s/-/ /g;
	my $fallback = shift;
	$fallback =~ s/-/ /g;
	
	check_key('BetterShopper_'.$Slot, $id);
	check_key('BetterShopper_'.$Slot.'_price', $price);
	check_key('BetterShopper_'.$Slot.'_maxPrice', $price);
	check_key('BetterShopper_'.$Slot.'_minInventoryAmount', 0);
	check_key('BetterShopper_'.$Slot.'_minShopAmount', 1);
	check_key('BetterShopper_'.$Slot.'_maxAmount', 1);
	check_key('BetterShopper_'.$Slot.'_fallbackNpcShop', $fallback);
	check_key('BetterShopper_'.$Slot.'_fallbackNpcTalk', undef);
	check_key('BetterShopper_'.$Slot.'_fallbackNpcTSequence', undef);
	check_key('BetterShopper_'.$Slot.'_commandAfterBuy', $command);
	
	return 1;
}

macro BetterbuyAuto_clear_equip {
	[
	$name = GetNamebyNameID("$.param[0]")
	log Clearing BetterShopper $name
	$foundSlot = find_key_in_block("BetterShopper","$.param[0]")
	if ($foundSlot != -1) {
		clear_BetterbuyAuto_item("$foundSlot")
	}
	do iconf $.param[0] 0 0 1
	]
}

macro BetterbuyAuto_clear_item {
	[
	$name = GetNamebyNameID("$.param[0]")
	log Clearing BetterShopper $name
	$foundSlot = find_key_in_block("BetterShopper","$.param[0]")
	if ($foundSlot != -1) {
		clear_BetterbuyAuto_item("$foundSlot")
	}
	]
}

sub clear_BetterbuyAuto_item {
	my $Slot = shift;
	
	check_key('BetterShopper_'.$Slot, undef);
	check_key('BetterShopper_'.$Slot.'_price', undef);
	check_key('BetterShopper_'.$Slot.'_maxPrice', undef);
	check_key('BetterShopper_'.$Slot.'_minInventoryAmount', undef);
	check_key('BetterShopper_'.$Slot.'_minShopAmount', undef);
	check_key('BetterShopper_'.$Slot.'_maxAmount', undef);
	check_key('BetterShopper_'.$Slot.'_fallbackNpcShop', undef);
	check_key('BetterShopper_'.$Slot.'_fallbackNpcTalk', undef);
	check_key('BetterShopper_'.$Slot.'_fallbackNpcTSequence', undef);
	check_key('BetterShopper_'.$Slot.'_commandAfterBuy', undef);
	
	return 1;
}

#############

macro set_BetterbuyAuto_item_quest {
	[
	$name = GetNamebyNameID("$.param[0]")
	log Setting BetterShopper_item_quest $name
	$nextFreeSlot = get_free_slot_index_for_key("BetterShopper","$.param[0]")
	set_BetterbuyAuto_item_quest("$nextFreeSlot","$.param[0]","$.param[1]","$.param[2]")
	]
}

sub set_BetterbuyAuto_item_quest {
	my $Slot = shift;
	my $id = shift;
	my $price = shift;
	my $amount = shift;
	
	check_key('BetterShopper_'.$Slot, $id);
	check_key('BetterShopper_'.$Slot.'_price', undef);
	check_key('BetterShopper_'.$Slot.'_maxPrice', $price);
	check_key('BetterShopper_'.$Slot.'_minInventoryAmount', ($amount-1));
	check_key('BetterShopper_'.$Slot.'_minShopAmount', 1);
	check_key('BetterShopper_'.$Slot.'_maxAmount', $amount);
	check_key('BetterShopper_'.$Slot.'_fallbackNpcShop', undef);
	check_key('BetterShopper_'.$Slot.'_fallbackNpcTalk', undef);
	check_key('BetterShopper_'.$Slot.'_fallbackNpcTSequence', undef);
	check_key('BetterShopper_'.$Slot.'_commandAfterBuy', undef);
	
	return 1;
}

macro set_BetterbuyAuto_item_refineNPC {
	[
	$name = GetNamebyNameID("$.param[0]")
	log Setting set_BetterbuyAuto_item_refineNPC $name
	$nextFreeSlot = get_free_slot_index_for_key("BetterShopper","$.param[0]")
	set_BetterbuyAuto_item_refineNPC("$nextFreeSlot","$.param[0]","$.param[1]","$.param[2]","$.param[3]","$.param[4]","$.param[5]")
	]
}

sub set_BetterbuyAuto_item_refineNPC {
	my $Slot = shift;
	my $id = shift;
	my $price = shift;
	my $max_price = shift;
	my $amount = shift;
	my $fallback = shift;
	$fallback =~ s/-/ /g;
	my $sequence = shift;
	
	check_key('BetterShopper_'.$Slot, $id);
	check_key('BetterShopper_'.$Slot.'_price', $price);
	check_key('BetterShopper_'.$Slot.'_maxPrice', $max_price);
	check_key('BetterShopper_'.$Slot.'_minInventoryAmount', ($amount-1));
	check_key('BetterShopper_'.$Slot.'_minShopAmount', 1);
	check_key('BetterShopper_'.$Slot.'_maxAmount', $amount);
	check_key('BetterShopper_'.$Slot.'_fallbackNpcShop', undef);
	check_key('BetterShopper_'.$Slot.'_fallbackNpcTalk', $fallback);
	check_key('BetterShopper_'.$Slot.'_fallbackNpcTSequence', $sequence);
	check_key('BetterShopper_'.$Slot.'_commandAfterBuy', undef);
	
	return 1;
}

macro set_BetterBuy_refine {
	[
	# Phracon
	if ($refineLevel == 1) {
		call set_Phracon
		
	# Emveretarcon
	} elsif ($refineLevel == 2) {
		call set_Emveretarcon
		
	# Oridecon
	} elsif ($refineLevel == 3 || $refineLevel == 4) {
		call set_Oridecon
		
	}
	]
}

macro set_Phracon {
	[
	call set_BetterbuyAuto_item_refineNPC 1010 200 180 $needRefineCount payon_in01-84-26 r0-amount-
	do iconf 1010 $needRefineCount 1 0
	]
}

macro set_Emveretarcon {
	[
	call set_BetterbuyAuto_item_refineNPC 1011 1000 800 $needRefineCount payon_in01-84-26 r1-amount-
	do iconf 1011 $needRefineCount 1 0
	]
}

macro set_Oridecon {
	[
	call set_BetterbuyAuto_item_quest 984 28000 $needRefineCount
	do iconf 984 $needRefineCount 1 0
	]
}

macro clear_BetterBuy_refine {
	[
	call BetterbuyAuto_clear_item 1010
	do iconf 1010 0 1 0
	call BetterbuyAuto_clear_item 1011
	do iconf 1011 0 1 0
	call BetterbuyAuto_clear_item 984
	do iconf 984 0 1 0
	]
}

macro set_BetterbuyAuto_item_usable {
	[
	$name = GetNamebyNameID("$.param[0]")
	log Setting BetterShopper_item_usable $name
	$nextFreeSlot = get_free_slot_index_for_key("BetterShopper","$.param[0]")
	set_BetterbuyAuto_item_usable("$nextFreeSlot","$.param[0]","$.param[1]","$.param[2]","$.param[3]","$.param[4]","$.param[5]")
	do iconf $.param[0] $.param[4] 1 0
	]
}

sub clear_hifens {
	my $name = shift;
	$name =~ s/-/ /g;
	return $name;
}

sub set_BetterbuyAuto_item_usable {
	my $Slot = shift;
	my $id = shift;
	my $price = shift;
	my $max_price = shift;
	my $min_amount = shift;
	my $max_amount = shift;
	my $fallback = shift;
	$fallback =~ s/-/ /g;
	
	check_key('BetterShopper_'.$Slot, $id);
	check_key('BetterShopper_'.$Slot.'_price', $price);
	check_key('BetterShopper_'.$Slot.'_maxPrice', $max_price);
	check_key('BetterShopper_'.$Slot.'_minInventoryAmount', $min_amount);
	check_key('BetterShopper_'.$Slot.'_minShopAmount', $max_amount);
	check_key('BetterShopper_'.$Slot.'_maxAmount', $max_amount);
	check_key('BetterShopper_'.$Slot.'_fallbackNpcShop', $fallback);
	check_key('BetterShopper_'.$Slot.'_fallbackNpcTalk', undef);
	check_key('BetterShopper_'.$Slot.'_fallbackNpcTSequence', undef);
	check_key('BetterShopper_'.$Slot.'_commandAfterBuy', undef);
	
	return 1;
}

macro set_item_usable {
	[
	if ($.lvl >= $item{minLevel} && $.lvl <= $item{maxLevel}) {
		$item{CanUse} = 1
	} else {
		$item{CanUse} = 0
	}
	]
}

macro deal_with_usables {
	[
	if ($item{CanUse} == 0) {
		call set_item_usable_cannot
	} else {
		call set_buy_item_usable
		if ($item{useSelf} == 1) {
			call set_use_item_basic
		}
	}
	]
}

macro set_item_usable_cannot {
	[
	call BetterbuyAuto_clear_item $item{id}
	do iconf $item{id} 0 1 0
	]
}

macro set_buy_item_usable {
	[
	if ($item{id} == 517) {
		call set_BetterbuyAuto_item_usable $item{id} $item{price} $item{maxPrice} $item{minInventoryAmount} $item{maxAmount} $meatDealer
	} else {
		call set_BetterbuyAuto_item_usable $item{id} $item{price} $item{maxPrice} $item{minInventoryAmount} $item{maxAmount} $tooldealer
	}
	do iconf $item{id} $item{maxAmount} 1 0
	]
}

macro set_use_item_basic {
	[
	$name = GetNamebyNameID("$item{id}")
	$nextFreeSlot = get_free_slot_index_for_key("useSelf_item","$name")
	do conf -f useSelf_item_$nextFreeSlot $name
	do conf -f useSelf_item_$nextFreeSlot_disabled 0
	]
}

#####

sub force_market_search {
	my $id = shift;
	my %plugin_args = ( id => $id );
	Plugins::callHook( force_check_market => \%plugin_args );
}

sub check_MarketWatcher {
	my $id = shift;
	my %plugin_args = ( id => $id );
	Plugins::callHook( check_market_found => \%plugin_args );
	return 1 if ($plugin_args{return});
	return 0;
}