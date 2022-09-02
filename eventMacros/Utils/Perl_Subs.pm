
#Perl Subs

macro clear_equipauto {
	[
	do conf -f equipAuto_0_topHead none
	do conf -f equipAuto_0_leftHand none
	do conf -f equipAuto_0_robe none
	do conf -f equipAuto_0_shoes none
	do conf -f equipAuto_0_armor none
	do conf -f equipAuto_0_rightHand none
	do conf -f equipAuto_0_topHead none
	do conf -f equipAuto_0_leftHand none
	do conf -f equipAuto_0_robe none
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
	do conf -f attackAuto_inLockOnly 2
	do conf -f attackCheckLOS 1
	do conf -f attackRouteMaxPathDistance 28
	do conf -f route_randomWalk 1
	do conf -f itemsGatherAuto 0
	do conf -f itemsTakeAuto 2
	do conf -f route_step 15
	do conf -f portalRecord 2
	do conf -f route_avoidWalls 1
	]
}

macro SetVar {
	$configlockMap = &config(lockMap)
	$configsaveMap = &config(saveMap)
}

sub set_common_equip_buyAuto {
	my $Slot = shift;
	my $name = shift;
	my $price = shift;
	my $place = shift;
	my $x = shift;
	my $y = shift;
	
	configModify('buyAuto_'.$Slot, $name);
	configModify('buyAuto_'.$Slot.'_npc', $place.' '.$x.' '.$y);
	configModify('buyAuto_'.$Slot.'_zeny', '> '.$price);
	configModify('buyAuto_'.$Slot.'_minAmount', 0);
	configModify('buyAuto_'.$Slot.'_maxAmount', 1);
	configModify('buyAuto_'.$Slot.'_minDistance', 1);
	configModify('buyAuto_'.$Slot.'_maxDistance', 10);
	configModify('buyAuto_'.$Slot.'_maxBase', 99);
	configModify('buyAuto_'.$Slot.'_minBase', 1);
	configModify('buyAuto_'.$Slot.'_disabled', 0);
	
	return 1;
}

sub clear_common_equip_buyAuto {
	my $Slot = shift;
	
	configModify('buyAuto_'.$Slot, undef);
	configModify('buyAuto_'.$Slot.'_npc', undef);
	configModify('buyAuto_'.$Slot.'_zeny', undef);
	configModify('buyAuto_'.$Slot.'_minAmount', undef);
	configModify('buyAuto_'.$Slot.'_maxAmount', undef);
	configModify('buyAuto_'.$Slot.'_minDistance', undef);
	configModify('buyAuto_'.$Slot.'_maxDistance', undef);
	configModify('buyAuto_'.$Slot.'_maxBase', undef);
	configModify('buyAuto_'.$Slot.'_minBase', undef);
	configModify('buyAuto_'.$Slot.'_disabled', undef);
	
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
	
	foreach my $item (@{$char->inventory->getItems}) {
		next unless ($item->{nameID} == $itemID);
		next unless ($item->{identified});
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
	$totalcost = &eval($item{price} + $extraBuyCost)
	if ($currentZeny >= $totalcost) {
		$item{CanBuy} = 1
	} else {
		$item{CanBuy} = 0
	}
	$itemHash{$item{name}name} = $item{name}
	$itemHash{$item{name}id} = $item{id}
	$itemHash{$item{name}slot} = $item{slot}
	$itemHash{$item{name}price} = $item{price}
	$itemHash{$item{name}minLevel} = $item{minLevel}
	$itemHash{$item{name}npcMap} = $item{npcMap}
	$itemHash{$item{name}npcX} = $item{npcX}
	$itemHash{$item{name}npcY} = $item{npcY}
	$itemHash{$item{name}Has} = $item{Has}
	$itemHash{$item{name}Equipped} = $item{Equipped}
	$itemHash{$item{name}CanEquip} = $item{CanEquip}
	$itemHash{$item{name}CanBuy} = $item{CanBuy}
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
	do conf -f equipAuto_0_$.param[1] $name
	do iconf $.param[0] 1 0 0
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
	$temphash{Item1name} = get_hash_key("$Item1","name")
	$temphash{Item1id} = get_hash_key("$Item1","id")
	$temphash{Item1slot} = get_hash_key("$Item1","slot")
	$temphash{Item1price} = get_hash_key("$Item1","price")
	$temphash{Item1minLevel} = get_hash_key("$Item1","minLevel")
	$temphash{Item1npcMap} = get_hash_key("$Item1","npcMap")
	$temphash{Item1npcX} = get_hash_key("$Item1","npcX")
	$temphash{Item1npcY} = get_hash_key("$Item1","npcY")
	$temphash{Item1Has} = get_hash_key("$Item1","Has")
	$temphash{Item1Equipped} = get_hash_key("$Item1","Equipped")
	$temphash{Item1CanEquip} = get_hash_key("$Item1","CanEquip")
	$temphash{Item1CanBuy} = get_hash_key("$Item1","CanBuy")
}

macro setTempHash2 {
	$temphash{Item2name} = get_hash_key("$Item2","name")
	$temphash{Item2id} = get_hash_key("$Item2","id")
	$temphash{Item2slot} = get_hash_key("$Item2","slot")
	$temphash{Item2price} = get_hash_key("$Item2","price")
	$temphash{Item2minLevel} = get_hash_key("$Item2","minLevel")
	$temphash{Item2npcMap} = get_hash_key("$Item2","npcMap")
	$temphash{Item2npcX} = get_hash_key("$Item2","npcX")
	$temphash{Item2npcY} = get_hash_key("$Item2","npcY")
	$temphash{Item2Has} = get_hash_key("$Item2","Has")
	$temphash{Item2Equipped} = get_hash_key("$Item2","Equipped")
	$temphash{Item2CanEquip} = get_hash_key("$Item2","CanEquip")
	$temphash{Item2CanBuy} = get_hash_key("$Item2","CanBuy")
}

macro setTempHash3 {
	$temphash{Item3name} = get_hash_key("$Item3","name")
	$temphash{Item3id} = get_hash_key("$Item3","id")
	$temphash{Item3slot} = get_hash_key("$Item3","slot")
	$temphash{Item3price} = get_hash_key("$Item3","price")
	$temphash{Item3minLevel} = get_hash_key("$Item3","minLevel")
	$temphash{Item3npcMap} = get_hash_key("$Item3","npcMap")
	$temphash{Item3npcX} = get_hash_key("$Item3","npcX")
	$temphash{Item3npcY} = get_hash_key("$Item3","npcY")
	$temphash{Item3Has} = get_hash_key("$Item3","Has")
	$temphash{Item3Equipped} = get_hash_key("$Item3","Equipped")
	$temphash{Item3CanEquip} = get_hash_key("$Item3","CanEquip")
	$temphash{Item3CanBuy} = get_hash_key("$Item3","CanBuy")
}

macro set_tempitems_2 {
	call set_$Item1
	call set_$Item2
	call setTempHash1
	call setTempHash2
}

macro organize_and_run_buyauto_2 {
	call set_tempitems_2
	call buyauto_logic_run_2
}

macro set_tempitems_3 {
	call set_$Item1
	call set_$Item2
	call set_$Item3
	call setTempHash1
	call setTempHash2
	call setTempHash3
}

macro organize_and_run_buyauto_3 {
	call set_tempitems_3
	call buyauto_logic_run_3
}

macro buyauto_logic_run_3 {
	[
	if ($itemHash{$temphash{Item3Equipped}} == 1) {
		log $Item3 is equippede DAMNN
		
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
		call buyAuto_clear $itemHash{$temphash{Item1id}}
		call buyAuto_clear $itemHash{$temphash{Item2id}}
		call buyAuto_clear $itemHash{$temphash{Item3id}}
		call set_equip $itemHash{$temphash{Item3id}} $itemHash{$temphash{Item3slot}}
		
	} elsif ($itemHash{$temphash{Item3Equipped}} == 0 && $itemHash{$temphash{Item3CanEquip}} == 1 && $itemHash{$temphash{Item3Has}} == 0 && $itemHash{$temphash{Item3CanBuy}} == 1) {
		call buyAuto_clear $itemHash{$temphash{Item1id}}
		call buyAuto_clear $itemHash{$temphash{Item2id}}
		call set_buyAuto $itemHash{$temphash{Item3id}} $itemHash{$temphash{Item3price}} $itemHash{$temphash{Item3npcMap}} $itemHash{$temphash{Item3npcX}} $itemHash{$temphash{Item3npcY}}
		
	} elsif (($itemHash{$temphash{Item3CanEquip}} == 0 || $itemHash{$temphash{Item3Has}} == 0) && $itemHash{$temphash{Item2Equipped}} == 0 && $itemHash{$temphash{Item2CanEquip}} == 1 && $itemHash{$temphash{Item2Has}} >= 1) {
		call buyAuto_clear $itemHash{$temphash{Item1id}}
		call buyAuto_clear $itemHash{$temphash{Item2id}}
		call set_equip $itemHash{$temphash{Item2id}} $itemHash{$temphash{Item2slot}}
		
	} elsif (($itemHash{$temphash{Item3CanEquip}} == 0 || $itemHash{$temphash{Item3CanBuy}} == 0) && $itemHash{$temphash{Item2Equipped}} == 0 && $itemHash{$temphash{Item2CanEquip}} == 1 && $itemHash{$temphash{Item2Has}} == 0 && $itemHash{$temphash{Item2CanBuy}} == 1) {
		call buyAuto_clear $itemHash{$temphash{Item1id}}
		call set_buyAuto $itemHash{$temphash{Item2id}} $itemHash{$temphash{Item2price}} $itemHash{$temphash{Item2npcMap}} $itemHash{$temphash{Item2npcX}} $itemHash{$temphash{Item2npcY}}
		
	} elsif (($itemHash{$temphash{Item3CanEquip}} == 0 || $itemHash{$temphash{Item3CanBuy}} == 0) && ($itemHash{$temphash{Item2CanEquip}} == 0 || $itemHash{$temphash{Item2CanBuy}} == 0) && $itemHash{$temphash{Item1Equipped}} == 0 && $itemHash{$temphash{Item1CanEquip}} == 1 && $itemHash{$temphash{Item1Has}} >= 1) {
		call buyAuto_clear $itemHash{$temphash{Item1id}}
		call set_equip $itemHash{$temphash{Item1id}} $itemHash{$temphash{Item1slot}}
		
	} elsif (($itemHash{$temphash{Item3CanEquip}} == 0 || $itemHash{$temphash{Item3CanBuy}} == 0) && ($itemHash{$temphash{Item2CanEquip}} == 0 || $itemHash{$temphash{Item2CanBuy}} == 0) && $itemHash{$temphash{Item1Equipped}} == 0 && $itemHash{$temphash{Item1CanEquip}} == 1 && $itemHash{$temphash{Item1Has}} == 0 && $itemHash{$temphash{Item1CanBuy}} == 1) {
		call set_buyAuto $itemHash{$temphash{Item1id}} $itemHash{$temphash{Item1price}} $itemHash{$temphash{Item1npcMap}} $itemHash{$temphash{Item1npcX}} $itemHash{$temphash{Item1npcY}}
	}
	]
}

macro buyauto_logic_run_2 {
	[
	if ($itemHash{$temphash{Item2Equipped}} == 1) {
		log $Item2 is equippede DAMNN
		
	} elsif ($itemHash{$temphash{Item1Equipped}} == 1 && $itemHash{$temphash{Item2CanEquip}} == 0) {
		log $Item1 is equipped and cannot equip $Item2 DAMNN
		
	} elsif ($itemHash{$temphash{Item1Equipped}} == 1 && $itemHash{$temphash{Item2CanEquip}} == 1 && $itemHash{$temphash{Item2CanBuy}} == 0 && $itemHash{$temphash{Item2Has}} == 0) {
		log $Item1 is equipped, can equip $Item2 but cannot buy it DAMNN
		
	} elsif ($itemHash{$temphash{Item1Equipped}} == 0 && $itemHash{$temphash{Item1CanBuy}} == 0 && $itemHash{$temphash{Item1Has}} == 0) {
		log $Item1 is not equipped, cannot buy it
		
	} elsif ($itemHash{$temphash{Item2Equipped}} == 0 && $itemHash{$temphash{Item2CanEquip}} == 1 && $itemHash{$temphash{Item2Has}} >= 1) {
		call buyAuto_clear $itemHash{$temphash{Item1id}}
		call buyAuto_clear $itemHash{$temphash{Item2id}}
		call set_equip $itemHash{$temphash{Item2id}} $itemHash{$temphash{Item2slot}}
		
	} elsif ($itemHash{$temphash{Item2Equipped}} == 0 && $itemHash{$temphash{Item2CanEquip}} == 1 && $itemHash{$temphash{Item2Has}} == 0 && $itemHash{$temphash{Item2CanBuy}} == 1) {
		call buyAuto_clear $itemHash{$temphash{Item1id}}
		call set_buyAuto $itemHash{$temphash{Item2id}} $itemHash{$temphash{Item2price}} $itemHash{$temphash{Item2npcMap}} $itemHash{$temphash{Item2npcX}} $itemHash{$temphash{Item2npcY}}
		
	} elsif (($itemHash{$temphash{Item2CanEquip}} == 0 || $itemHash{$temphash{Item2CanBuy}} == 0) && $itemHash{$temphash{Item1Equipped}} == 0 && $itemHash{$temphash{Item1CanEquip}} == 1 && $itemHash{$temphash{Item1Has}} >= 1) {
		call buyAuto_clear $itemHash{$temphash{Item1id}}
		call set_equip $itemHash{$temphash{Item1id}} $itemHash{$temphash{Item1slot}}
		
	} elsif (($itemHash{$temphash{Item2CanEquip}} == 0 || $itemHash{$temphash{Item2CanBuy}} == 0) && $itemHash{$temphash{Item1Equipped}} == 0 && $itemHash{$temphash{Item1CanEquip}} == 1 && $itemHash{$temphash{Item1Has}} == 0 && $itemHash{$temphash{Item1CanBuy}} == 1) {
		call set_buyAuto $itemHash{$temphash{Item1id}} $itemHash{$temphash{Item1price}} $itemHash{$temphash{Item1npcMap}} $itemHash{$temphash{Item1npcX}} $itemHash{$temphash{Item1npcY}}
		
	}
	]
}