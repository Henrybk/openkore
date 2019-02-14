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
	#['PathFindingReset', \&on_PathFindingReset, undef], # Changes args
	['packet_mapChange', \&on_packet_mapChange, undef],
);

my $mob_hooks = Plugins::addHooks(
	['add_monster_list', \&on_add_monster_list, undef],
	#['monster_disappeared', \&on_monster_disappeared, undef],
	#['monster_moved', \&on_monster_moved, undef],
	#['add_player_list', \&on_add_player_list, undef],
);

sub onUnload {
    Plugins::delHooks($hooks);
	Plugins::delHooks($mob_hooks);
}

my %nameID_obstacles = (
	1368 => [1000, 1000, 1000, 1000], #Planta carnívora
);

my %player_name_obstacles = (
#	'henry safado' => [1000, 1000],
	'henry safado' => [1000, 1000, 1000, 1000],
);

my %obstaclesList;

sub create_changes_array {
	my ($mob_binID) = @_;
	my $monster = $monstersList->get($mob_binID);
	my $obs_x = $monster->{pos}{x};
	my $obs_y = $monster->{pos}{y};
	
	my $mob_id = $monster->{nameID};
	
	my @weights = @{$nameID_obstacles{$mob_id}};
	
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

sub on_packet_mapChange {
	undef %obstaclesList;
}

sub on_add_player_list {
	my (undef, $args) = @_;
	my $actor = $args;
	
	return unless (exists $player_name_obstacles{$actor->{name}});
	
	print "[test] Adding Player $actor on location ".$actor->{pos}{x}." ".$actor->{pos}{y}.".\n";
	
	my $obs_x = $actor->{pos}{x};
	my $obs_y = $actor->{pos}{y};
	
	my $player_name = $actor->{name};
	
	my @weights = @{$player_name_obstacles{$actor->{name}}};
	
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
	
	$obstaclesList{$actor->{binID}} = \@changes_array;
	
	add_changes_to_task(\@changes_array);
}

sub on_add_monster_list {
	my (undef, $args) = @_;
	my $actor = $args;
	
	return unless (exists $nameID_obstacles{$actor->{nameID}});
	
	print "[test] Adding Monster $actor on location ".$actor->{pos}{x}." ".$actor->{pos}{y}.".\n";
	
	my $changes = create_changes_array($actor->{binID});
	
	$obstaclesList{$actor->{binID}} = $changes;
	
	add_changes_to_task($changes);
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

sub on_monster_moved {
	my (undef, $args) = @_;
	my $actor = $args;
	
	return unless (exists $obstaclesList{$actor->{binID}});
	
	print "[test] Updating Monster $actor.\n";
	
	my $old_changes = $obstaclesList{$actor->{binID}};
	delete $obstaclesList{$actor->{binID}};
	
	$old_changes = revert_changes($old_changes);
	
	add_changes_to_task($old_changes);
	
	my $new_changes = create_changes_array($actor->{binID});
	$obstaclesList{$actor->{binID}} = $new_changes;
	
	add_changes_to_task($new_changes);
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

sub on_PathFindingReset {
	my (undef, $args) = @_;
	
	return unless (keys(%obstaclesList) > 0);
	
	print "[test] Using grided info.\n";

	my $c_map = $field->{weightMap};
	
	use Data::Dumper;
	
	foreach my $obstacle (keys(%obstaclesList)) {
		foreach my $change (@{$obstaclesList{$obstacle}}) {
			my $position = (($change->{y} * $field->{width}) + $change->{x});
			
			my $current_weight = unpack('C', substr($c_map, $position, 1));
			
			my $weight_changed = $change->{weight};
			
			my $new_weight = $current_weight + $weight_changed;
			
			substr($c_map, $position, 1, pack('C', $new_weight));
		}
	}
	
	$args->{args}{weight_map} = \$c_map;
	
	$args->{args}{width} = $args->{args}{field}{width} unless ($args->{args}{width});
	$args->{args}{height} = $args->{args}{field}{height} unless ($args->{args}{height});
	$args->{args}{timeout} = 1500 unless ($args->{args}{timeout});
	$args->{args}{avoidWalls} = 1 unless ($args->{args}{avoidWalls});
	
	$args->{return} = 0;
}

return 1;