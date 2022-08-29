
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
	
	if ($char->{skills}{$handle}) {
		$level = $char->{skills}{$handle}{lv};
	} else {
		$level = 0;
	}
	
	#Log::warning "[getSkillLevelByHandle] skillhandle ($skillhandle) | level ($level)\n";
	
	return $level;
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
			Log::warning "[get_free_slot_index_for_key] Found new slot in key $key for value $value at index $index\n";
			last;
		} elsif ($config{$key_plus_index} eq $value) {
			Log::warning "[get_free_slot_index_for_key] Found already existent slot in key $key for value $value at index $index\n";
			last;
		}
		$index++;
	}
	return $index;
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