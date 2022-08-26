
#Perl Subs
 
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

sub set_nearest_vender {
    my ($itemID, $minAmount, $maxAmount, $zeny, $map, $x, $y) = @_;

	my $name = itemNameSimple($itemID);
		
	my $numSlots = $itemSlotCount_lut{$itemID};
		
	$name .= " [$numSlots]" if $numSlots;
	
	my $index = 0;
	while (1) {
		$key_plus_index = 'buyAuto_'.$index;
		if (!exists $config{$key_plus_index}) {
			Log::warning "Found new slot in buyAuto for $name at index $index\n";
			last;
		} elsif ($config{$key_plus_index} eq $name) {
			Log::warning "Found already existent slot in buyAuto for $name at index $index\n";
			last;
		}
		$index++;
	}
	
	my $args = { item => $itemID, map => $map, x => $x, y => $y };
	
    Plugins::callHook( npcvendor_closest => $args );
	return (0) if !$args->{return};
	
	Log::message(
		sprintf "Best NPC is [%s] at [%d %d %s], [%s] maps and [%s] tiles away, and costs [%s] zeny.\n",
		$args->{return}->{target}->{name},
		$args->{return}->{target}->{x},
		$args->{return}->{target}->{y},
		$args->{return}->{target}->{map},
		scalar( @{ $args->{return}->{maps} } ) - 1,
		$args->{return}->{tiles},
		$args->{return}->{zeny},
	);
	
	configModify('buyAuto_'.$index, "$name");
	configModify('buyAuto_'.$index.'_npc', "$args->{return}->{target}->{map} $args->{return}->{target}->{x} $args->{return}->{target}->{y}");
	configModify('buyAuto_'.$index.'_minAmount', "$minAmount");
	configModify('buyAuto_'.$index.'_maxAmount', "$maxAmount");
	configModify('buyAuto_'.$index.'_minDistance', "2");
	configModify('buyAuto_'.$index.'_maxDistance', "10");
	configModify('buyAuto_'.$index.'_zeny', " > $zeny");

	return 1;
}

sub set_nearest_savepoint {
    my ($map, $x, $y) = @_;
	
	my $args = { map => $map, x => $x, y => $y };
	Plugins::callHook( savepoint_closest => $args );
	return (0) if !$args->{return};

	Log::message(
		sprintf "Best savepoint is at [%d %d %s], [%s] maps and [%s] tiles away, and costs [%s] zeny.\n",
		$args->{return}->{target}->{x},
		$args->{return}->{target}->{y},
		$args->{return}->{target}->{map},
		scalar( @{ $args->{return}->{maps} } ) - 1,
		$args->{return}->{tiles},
		$args->{return}->{zeny},
	);

	Log::message(
		sprintf "It belongs to kafra at [%d %d %s] that has sequence [%s], the storage costs [%s] and has sequence [%s].\n",
		$args->{return_kafra}->{x},
		$args->{return_kafra}->{y},
		$args->{return_kafra}->{map},
		$args->{return_kafra}->{sequence},
		$args->{return_kafra}->{storage_cost},
		$args->{return_kafra}->{storage_sequence}
	);
	
	
	my $route = join(', ', @{ $args->{return}->{maps} });
	
	configModify('future_saveMap_to_lockMap_route', "$route");
	
	configModify('future_saveMap_map', "$args->{return}->{target}->{map}");
	configModify('future_saveMap_x', "$args->{return}->{target}->{x}");
	configModify('future_saveMap_y', "$args->{return}->{target}->{y}");
	
	configModify('future_saveMap_kafra_map', "$args->{return_kafra}->{map}");
	configModify('future_saveMap_kafra_x', "$args->{return_kafra}->{x}");
	configModify('future_saveMap_kafra_y', "$args->{return_kafra}->{y}");
	configModify('future_saveMap_save_sequence', "$args->{return_kafra}->{sequence}");
	
	return 1;
}

sub set_nearest_storage {
	my ($savepoint) = @_;
	
	my $args = { savepoint => $savepoint };
	Plugins::callHook( get_savepoint_info => $args );
	return (0) if !$args->{return};
	
	configModify('minStorageZeny', "$args->{return}->{storage_cost}");
	configModify('storageAuto_npc', "$args->{return}->{kafra_map} $args->{return}->{kafra_x} $args->{return}->{kafra_y}");
	configModify('storageAuto_npc_steps', "$args->{return}->{storage_sequence}");
	configModify('storageAuto_npc_type', '3');
	configModify('storageAuto', "1");
	
	return 1;
}

sub set_nearest_sellauto {
	my ($map, $x, $y) = @_;
	
	my $args = { map => $map, x => $x, y => $y };
	Plugins::callHook( npcseller_closest => $args );
	return (0) if !$args->{return};

	Log::message(
		sprintf "Best seller NPC is [%s] at [%d %d %s], [%s] maps and [%s] tiles away, and costs [%s] zeny.\n",
		$args->{return}->{target}->{name},
		$args->{return}->{target}->{x},
		$args->{return}->{target}->{y},
		$args->{return}->{target}->{map},
		scalar( @{ $args->{return}->{maps} } ) - 1,
		$args->{return}->{tiles},
		$args->{return}->{zeny},
	);
	
	configModify('sellAuto', 1);
	configModify('sellAuto_npc', "$args->{return}->{target}->{map} $args->{return}->{target}->{x} $args->{return}->{target}->{y}");
	
	return 1;
}

sub get_next_to_be_equipped_item {
	my @slots = qw( topHead midHead lowHead leftHand rightHand robe armor shoes leftAccessory rightAccessory arrow costumeTopHead costumeMidHead costumeLowHead costumeRobe costumeFloor shadowLeftHand shadowRightHand shadowArmor shadowShoes shadowLeftAccessory shadowRightAccessory );
	
	foreach my $slot (@slots) {
		next unless ($config{'to_be_equipped_'.$slot});
		if (exists $char->{equipment}{$slot} && $char->{equipment}{$slot}->{nameID} == $config{'to_be_equipped_'.$slot}) {
			configModify('to_be_equipped_'.$slot, undef);
			next;
		}
		my $id = $config{'to_be_equipped_'.$slot};
		my $Item = $char->inventory->getByNameID($id);
		unless ($Item) {
			configModify('to_be_equipped_'.$slot, undef);
			next;
		}
		my $inv_index = $Item->{binID};
		return "$slot $inv_index";
	}
	return -1;
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



sub check_current_lockMap {
    my ($map, $index, $class, $current_class, $blvl, $jlvl, $skip) = @_;
	
	my $args = { map => $map, index => $index, class => $class, current_class => $current_class, blvl => $blvl, jlvl => $jlvl, skip => $skip };
	
	Plugins::callHook( check_current_lockMap => $args );
	
	return $args->{return};
}

sub set_best_lockMap {
    my ($class, $current_class, $blvl, $jlvl, $skip) = @_;
	
	my $args = { class => $class, current_class => $current_class, blvl => $blvl, jlvl => $jlvl, skip => $skip };
	
	Plugins::callHook( get_best_lockMap => $args );
	if (!$args->{return}) {
		error "It was not possible to find a good lockmap.\n";
		return 0;
	}
	
	Log::message(
		sprintf "The selected lockMap for you necessities is [%s].\n",
		$args->{return}->{map}
	);
	
	configModify('lockMap', "$args->{return}->{map}");
	configModify('lockMap_index', "$args->{return}->{index}");
	
	foreach my $mob_key (keys %{$args->{return}->{mobs}}) {
		my $mob_value = $args->{return}->{mobs}{$mob_key};
		Commands::run("mconf $mob_key $mob_value");
	}
	
	my $pry_command = '';
	my $index = 0;
	foreach my $mob_pry_id (@{$args->{return}->{priority}}) {
		if ($monsters_lut{$mob_pry_id}) {
			unless ($index == 0) {
				$pry_command .= ', ';
			}
			$pry_command .= $monsters_lut{$mob_pry_id};
			$index++;
		}
	}
	if ($index > 0) {
		Commands::run("priconf $pry_command");
	}
	
	return 1;
}

macro lockMap_too_dangerous {
	log It has been determined that our current lockMap is too dangerous, adding it to skiplist for an hour and changing lockMap.
	add_skip_lockMap("&config(lockMap)")
	
	$lockMap = set_best_lockMap("&config(eventMacro_goal_class)", "$.lvl", "$.joblvl", "&config(lockMap_skip)")
	[
		if ($lockMap == 1) {
			log Everything went fine with the auto find lockMap function
		} else {
			log There was a problem with the auto find lockMap function
			do quit
			stop
		}
	]
	
	call get_best_savepoint
}

sub re_add_skipped_lockMaps {
	my @config_skips = split(/\s*,\s*/, $config{'lockMap_skip'});
	
	my @config_timings = split(/\s*,\s*/, $config{'lockMap_skipTimings'});
	
	my $timeout = 3600;
	
	my @remove_indexes;
	
	foreach my $time_index (0..$#config_timings) {
		next if ($time_index == 0);
		next unless (timeOut($config_timings[$time_index], $timeout));
		push(@remove_indexes, $time_index);
	}
	
	unless (@remove_indexes) {
		Log::warning "There are no skipped lockmaps to be readded.\n";
		return;
	}
	
	my $removed = 0;
	for (@remove_indexes) {
		my $current = ($_ - $removed);
		Log::warning "Re adding skipped lockmap ".$config_skips[$current].".\n";
		splice(@config_skips, ($_ - $removed), 1);
		splice(@config_timings, ($_ - $removed), 1);
		$removed++;
	}
	
	my $new_config = join(', ', @config_skips);
	
	my $new_config_timings = join(', ', @config_timings);
	
	configModify('lockMap_skip', "$new_config");
	configModify('lockMap_skipTimings', "$new_config_timings");
}

sub add_skip_lockMap {
	my $lockMap = shift;
	
	my $config_skips = $config{'lockMap_skip'};
	
	my $config_timings = $config{'lockMap_skipTimings'};
	
	my $time = time;
	
	my $new_config = $config_skips.", ".$lockMap;
	
	my $new_config_timings = $config_timings.", ".$time;
	
	configModify('lockMap_skip', "$new_config");
	configModify('lockMap_skipTimings', "$new_config_timings");
}