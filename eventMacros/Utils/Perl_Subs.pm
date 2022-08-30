
#Perl Subs

macro clear_equipauto {
	do conf -f equipAuto_0_topHead none
	do conf -f equipAuto_0_leftHand none
	do conf -f equipAuto_0_robe none
	do conf -f equipAuto_0_shoes none
	do conf -f equipAuto_0_armor none
	do conf -f equipAuto_0_rightHand none
	do conf -f equipAuto_0_topHead none
	do conf -f equipAuto_0_leftHand none
	do conf -f equipAuto_0_robe none
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
}

macro SetVar {
	$configlockMap = &config(lockMap)
	$configsaveMap = &config(saveMap)
	$joinedSewb = &config(Joined_Sewb)
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
	while (1) {
		$key_plus_index = $key.'_'.$index;
		if (!exists $config{$key_plus_index}) {
			Log::warning "[get_free_slot_index_for_key] Found slot in block $key for value $value at index $index (!exists)\n";
			last;
			
		} elsif (!defined $config{$key_plus_index}) {
			Log::warning "[get_free_slot_index_for_key] Found slot in block $key for value $value at index $index (!defined)\n";
			last;
			
		} elsif ($config{$key_plus_index} eq $value) {
			Log::warning "[get_free_slot_index_for_key] Found $value in slot $index of block $key (eq)\n";
			last;
		}
		$index++;
	}
	return $index;
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