package DStarLiteAvoid;

use strict;
use Globals;
use Settings;
use Misc;
use Plugins;
use Utils;
use Log qw(message debug error warning);
use Data::Dumper;

Plugins::register('DStarLiteAvoid', 'Enables smart pathing using the dynamic aspect of D* Lite pathfinding', \&onUnload);

use constant {
	PLUGIN_NAME => 'DStarLiteAvoid',
	ENABLE_MOVE => 1,
	ENABLE_REMOVE => 0,
};

my $hooks = Plugins::addHooks(
	['getRoute_post', \&on_getRoute_post, undef],
	['packet_mapChange',      \&on_packet_mapChange, undef],
);

my $obstacle_hooks = Plugins::addHooks(
	# Mobs
	['add_monster_list', \&on_add_monster_list, undef],
	['monster_disappeared', \&on_monster_disappeared, undef],
	['monster_moved', \&on_monster_moved, undef],
	
	# Players
	['add_player_list', \&on_add_player_list, undef],
	['player_disappeared', \&on_player_disappeared, undef],
	['player_moved', \&on_player_moved, undef],
	
	# Spells
	['packet_areaSpell', \&on_add_areaSpell_list, undef],
	['packet_pre/area_spell_disappears', \&on_areaSpell_disappeared, undef],
);

sub onUnload {
    Plugins::delHooks($hooks);
	Plugins::delHooks($obstacle_hooks);
}

my %mob_nameID_obstacles = (
	1368 => [1000, 1000, 1000, 1000], #Planta carnívora
	1475 => [1000, 1000, 1000, 1000], #wraith
	1084 => [1000, 1000, 1000, 1000], #black shrom
	1085 => [1000, 1000, 1000, 1000], #red shrom
);

my %player_name_obstacles = (
	'testCreator' => [1000, 1000, 1000, 1000],
);

my %area_spell_type_obstacles = (
	'177' => [1000, 1000],
);

my %obstaclesList;

sub on_packet_mapChange {
	undef %obstaclesList;
}

###################################################
######## Main obstacle management
###################################################

sub add_obstacle {
	my ($actor, $weights) = @_;
	
	warning "[".PLUGIN_NAME."] Adding obstacle $actor on location ".$actor->{pos}{x}." ".$actor->{pos}{y}.".\n";
	
	my $changes = create_changes_array($actor->{pos}{x}, $actor->{pos}{y}, $weights);
	
	$obstaclesList{$actor->{ID}} = $changes;
	
	add_changes_to_task($changes);
}

sub move_obstacle {
	my ($actor, $weights) = @_;
	
	return unless (ENABLE_MOVE);
	
	warning "[".PLUGIN_NAME."] Moving obstacle $actor (from ".$actor->{pos}{x}." ".$actor->{pos}{y}." to ".$actor->{pos_to}{x}." ".$actor->{pos_to}{y}.").\n";
	
	my $new_changes = create_changes_array($actor->{pos_to}{x}, $actor->{pos_to}{y}, $weights);
	
	my $old_changes = $obstaclesList{$actor->{ID}};
	my @old_changes = @{$old_changes};
	
	$old_changes = revert_changes(\@old_changes);
	
	my @changes_pack = ($old_changes, $new_changes);
	my $final_changes = merge_changes(\@changes_pack);
	
	$obstaclesList{$actor->{ID}} = $new_changes;
	
	add_changes_to_task($final_changes);
}

sub remove_obstacle {
	my ($actor) = @_;
	
	return unless (ENABLE_REMOVE);
	
	warning "[".PLUGIN_NAME."] Removing obstacle $actor from ".$actor->{pos}{x}." ".$actor->{pos}{y}.".\n";
	
	my $changes = $obstaclesList{$actor->{ID}};
	
	delete $obstaclesList{$actor->{ID}};
	
	$changes = revert_changes($changes);
	
	add_changes_to_task($changes);
}

###################################################
######## Tecnical subs
###################################################

sub revert_changes {
	my ($changes) = @_;
	
	my @changes = @{$changes};
	
	my @changed_array;
	
	foreach my $cell (@changes) {
		my %cell = %{$cell};
		$cell{weight} *= -1;
		push(@changed_array, \%cell);
	}
	
	return \@changed_array;
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
	
	my @obstacles = keys(%obstaclesList);
	
	warning "[".PLUGIN_NAME."] on_getRoute_post before check, there are ".@obstacles." obstacles.\n";
	
	return unless (@obstacles > 0);
	
	return if ($args->{field}->baseName ne $field->baseName);
	
	my $changes = sum_all_changes();
	
	warning "[".PLUGIN_NAME."] adding changes on on_getRoute_post.\n";
	
	$args->{pathfinding}->update_solution($args->{start}{x}, $args->{start}{y}, $changes);
}

###################################################
######## Player avoiding
###################################################

sub on_add_player_list {
	my (undef, $args) = @_;
	my $actor = $args;
	
	return unless (exists $player_name_obstacles{$actor->{name}});
	
	my @weights = @{$player_name_obstacles{$actor->{name}}};
	
	add_obstacle($actor, \@weights);
}

sub on_player_moved {
	my (undef, $args) = @_;
	my $actor = $args;
	
	return unless (exists $obstaclesList{$actor->{ID}});
	
	my @weights = @{$player_name_obstacles{$actor->{name}}};
	
	move_obstacle($actor, \@weights);
}

sub on_player_disappeared {
	my (undef, $args) = @_;
	my $actor = $args->{player};
	
	return unless (exists $obstaclesList{$actor->{ID}});
	
	remove_obstacle($actor);
}

###################################################
######## Mob avoiding
###################################################

sub on_add_monster_list {
	my (undef, $args) = @_;
	my $actor = $args;
	
	return unless (exists $mob_nameID_obstacles{$actor->{nameID}});
	
	my @weights = @{$mob_nameID_obstacles{$actor->{nameID}}};
	
	add_obstacle($actor, \@weights);
}

sub on_monster_moved {
	my (undef, $args) = @_;
	my $actor = $args;

	return unless (exists $obstaclesList{$actor->{ID}});
	
	my @weights = @{$mob_nameID_obstacles{$actor->{nameID}}};
	
	move_obstacle($actor, \@weights);
}

sub on_monster_disappeared {
	my (undef, $args) = @_;
	my $actor = $args->{monster};
	
	return unless (exists $obstaclesList{$actor->{ID}});
	
	remove_obstacle($actor);
}

###################################################
######## Spell avoiding
###################################################

# TODO: Add fail flag check

sub on_add_areaSpell_list {
	my (undef, $args) = @_;
	my $ID = $args->{ID};
	my $spell = $spells{$ID};
	
	return unless (exists $area_spell_type_obstacles{$spell->{type}});
	
	my @weights = @{$area_spell_type_obstacles{$spell->{type}}};
	
	add_obstacle($spell, \@weights);
}

sub on_areaSpell_disappeared {
	my (undef, $args) = @_;
	my $ID = $args->{ID};
	my $spell = $spells{$ID};
	
	return unless (exists $obstaclesList{$spell->{ID}});
	
	remove_obstacle($spell);
}

return 1;