package DStarLiteAvoid;

use strict;
use Globals;
use Settings;
use Misc;
use Plugins;
use Utils;
use Log qw(message debug error warning);

Plugins::register('DStarLiteAvoid', 'enables smart pathing', \&onUnload);

my $hooks = Plugins::addHooks(
	['getRoute_post', \&on_getRoute_post, undef],
	['packet_mapChange',      \&on_packet_mapChange, undef],
);

my $obstacle_hooks = Plugins::addHooks(
	['add_monster_list', \&on_add_monster_list, undef],
	['monster_disappeared', \&on_monster_disappeared, undef],
	['monster_moved', \&on_monster_moved, undef],
	['add_player_list', \&on_add_player_list, undef],
	['player_disappeared', \&on_player_disappeared, undef],
	['player_moved', \&on_player_moved, undef],
);

sub onUnload {
    Plugins::delHooks($hooks);
	Plugins::delHooks($obstacle_hooks);
}

my %nameID_obstacles = (
	1368 => [1000, 1000, 1000, 1000], #Planta carnívora
	1475 => [1000, 1000, 1000, 1000], #wraith
);

my %player_name_obstacles = (
#	'henry safado' => [1000, 1000],
	'henry safado' => [1000, 1000, 1000, 1000],
);

my %obstaclesList;

sub on_packet_mapChange {
	undef %obstaclesList;
}

sub on_add_player_list {
	my (undef, $args) = @_;
	my $actor = $args;
	
	return unless (exists $player_name_obstacles{$actor->{name}});
	
	my $obs_x = $actor->{pos}{x};
	my $obs_y = $actor->{pos}{y};
	
	print "[test] Adding Player $actor on location ".$obs_x." ".$obs_y.".\n";
	
	my $player_name = $actor->{name};
	
	my @weights = @{$player_name_obstacles{$actor->{name}}};
	
	my $changes = create_changes_array($obs_x, $obs_y, \@weights);
	
	$obstaclesList{$actor->{binID}} = $changes;
	
	add_changes_to_task($changes);
}

sub on_player_moved {
	my (undef, $args) = @_;
	my $actor = $args;
	
	return unless (exists $obstaclesList{$actor->{binID}});
	
	my $obs_x = $actor->{pos_to}{x};
	my $obs_y = $actor->{pos_to}{y};
	
	my $player_name = $actor->{name};
	
	print "[test] Updating Player $actor (from ".$actor->{pos}{x}." ".$actor->{pos}{y}." to ".$actor->{pos_to}{x}." ".$actor->{pos_to}{y}.").\n";
	
	my $old_changes = $obstaclesList{$actor->{binID}};
	delete $obstaclesList{$actor->{binID}};
	
	$old_changes = revert_changes($old_changes);
	
	my @weights = @{$player_name_obstacles{$actor->{name}}};
	
	my $new_changes = create_changes_array($obs_x, $obs_y, \@weights);
	
	$obstaclesList{$actor->{binID}} = $new_changes;
	
	my @changes_pack = ($old_changes, $new_changes);
	
	my $final_changes = merge_changes(\@changes_pack);
	
	add_changes_to_task($final_changes);
}

sub on_player_disappeared {
	my (undef, $args) = @_;
	my $actor = $args->{player};
	
	return unless (exists $obstaclesList{$actor->{binID}});
	
	print "[test] Removing Player $actor.\n";
	
	my $changes = $obstaclesList{$actor->{binID}};
	
	delete $obstaclesList{$actor->{binID}};
	
	$changes = revert_changes($changes);
	
	add_changes_to_task($changes);
}

sub on_add_monster_list {
	my (undef, $args) = @_;
	my $actor = $args;
	
	return unless (exists $nameID_obstacles{$actor->{nameID}});
	
	my $obs_x = $actor->{pos}{x};
	my $obs_y = $actor->{pos}{y};
	
	print "[test] Adding Monster $actor on location ".$obs_x." ".$obs_y.".\n";
	
	my $mob_id = $actor->{nameID};
	
	my @weights = @{$nameID_obstacles{$mob_id}};
	
	my $changes = create_changes_array($obs_x, $obs_y, \@weights);
	
	$obstaclesList{$actor->{binID}} = $changes;
	
	add_changes_to_task($changes);
}

sub on_monster_moved {
	my (undef, $args) = @_;
	my $actor = $args;

	return unless (exists $obstaclesList{$actor->{binID}});
	
	my $obs_x = $actor->{pos_to}{x};
	my $obs_y = $actor->{pos_to}{y};
	
	my $mob_id = $actor->{nameID};
	
	print "[test] Updating Monster $actor (from ".$actor->{pos}{x}." ".$actor->{pos}{y}." to ".$actor->{pos_to}{x}." ".$actor->{pos_to}{y}.").\n";
	
	my $old_changes = $obstaclesList{$actor->{binID}};
	delete $obstaclesList{$actor->{binID}};
	
	$old_changes = revert_changes($old_changes);
	
	my @weights = @{$nameID_obstacles{$mob_id}};
	
	my $new_changes = create_changes_array($obs_x, $obs_y, \@weights);
	
	$obstaclesList{$actor->{binID}} = $new_changes;
	
	my @changes_pack = ($old_changes, $new_changes);
	
	my $final_changes = merge_changes(\@changes_pack);
	
	add_changes_to_task($final_changes);
}

sub on_monster_disappeared {
	my (undef, $args) = @_;
	my $actor = $args->{monster};
	
	return unless (exists $obstaclesList{$actor->{binID}});
	
	print "[test] Removing Monster $actor.\n";
	
	my $changes = $obstaclesList{$actor->{binID}};
	
	delete $obstaclesList{$actor->{binID}};
	
	$changes = revert_changes($changes);
	
	add_changes_to_task($changes);
}

sub revert_changes {
	my ($changes) = @_;
	
	foreach my $cell (@{$changes}) {
		$cell->{weight} *= -1;
	}
	
	return $changes;
}

sub add_changes_to_task {
	my ($changes) = @_;
	return unless (AI::is("route"));
	
	my $task;
	
	if (UNIVERSAL::isa($char->args, 'Task::Route')) {
		$task = $char->args;
		
	} elsif ($char->args->getSubtask && UNIVERSAL::isa($char->args->getSubtask, 'Task::Route')) {
		$task = $char->args->getSubtask;
		
	} else {
		return;
	}
	
	$task->addChanges($changes);
}

sub create_changes_array {
	my ($obs_x, $obs_y, $weight_array) = @_;
	
	my @weights = @{$weight_array};
	
	my $max_distance = $#weights;
	
	my @changes_array;
	
	for (my $y = ($obs_y - $max_distance);     $y <= ($obs_y + $max_distance);   $y++) {
		for (my $x = ($obs_x - $max_distance);     $x <= ($obs_x + $max_distance);   $x++) {
			my $xDistance = abs($obs_x - $x);
			my $yDistance = abs($obs_y - $y);
			my $cell_distance = (($xDistance > $yDistance) ? $xDistance : $yDistance);
			my $delta_weight = $weights[$cell_distance];
			next unless ($field->isWalkable($x, $y));
			push(@changes_array, { x => $x, y => $y, weight => $delta_weight});
		}
	}
	
	return \@changes_array;
}

sub merge_changes {
	my ($changes) = @_;
	
	my @changes_pack = @{$changes};
	
	my %changes_hash;
	
	foreach my $changes_unit (@changes_pack) {
		foreach my $change (@{$changes_unit}) {
			my $x = $change->{x};
			my $y = $change->{y};
			my $changed = $change->{weight};
			$changes_hash{$x}{$y} += $changed;
		}
	}
	
	my @rebuilt_array;
	foreach my $x_keys (keys %changes_hash) {
		foreach my $y_keys (keys %{$changes_hash{$x_keys}}) {
			next if ($changes_hash{$x_keys}{$y_keys} == 0);
			push(@rebuilt_array, { x => $x_keys, y => $y_keys, weight => $changes_hash{$x_keys}{$y_keys} });
		}
	}
	
	return \@rebuilt_array;
}

sub sum_all_changes {
	my %changes_hash;
	
	foreach my $key (keys %obstaclesList) {
		foreach my $change (@{$obstaclesList{$key}}) {
			my $x = $change->{x};
			my $y = $change->{y};
			my $changed = $change->{weight};
			$changes_hash{$x}{$y} += $changed;
		}
	}
	
	my @rebuilt_array;
	foreach my $x_keys (keys %changes_hash) {
		foreach my $y_keys (keys %{$changes_hash{$x_keys}}) {
			next if ($changes_hash{$x_keys}{$y_keys} == 0);
			push(@rebuilt_array, { x => $x_keys, y => $y_keys, weight => $changes_hash{$x_keys}{$y_keys} });
		}
	}
	
	return \@rebuilt_array;
}

sub on_getRoute_post {
	my (undef, $args) = @_;
	
	return unless (keys(%obstaclesList) > 0);
	
	return if ($args->{field}->baseName ne $field->baseName);
	
	my $changes = sum_all_changes();
	
	print "[test DstarLiteAvoid] adding changes on on_getRouteInternal_post.\n";
	
	$args->{pathfinding}->update_solution($args->{start}{x}, $args->{start}{y}, $changes);
}

return 1;