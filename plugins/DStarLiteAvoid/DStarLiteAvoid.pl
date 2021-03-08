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
	['route_step_final', \&on_route_step_final, undef],
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
	'testCreator' => {
		weight_format => 'circle',
		weight => [1000, 1000, 1000, 1000, 50, 20],
		avoid_format => 'square',
		avoid => [1, 1, 1, 1]
		
	}
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
	
	my $changes = create_changes_array($actor->{pos_to}, $weights);
	
	$obstaclesList{$actor->{ID}} = $changes;
	
	add_changes_to_task($changes);
}

sub move_obstacle {
	my ($actor, $weights) = @_;
	
	return unless (ENABLE_MOVE);
	
	warning "[".PLUGIN_NAME."] Moving obstacle $actor (from ".$actor->{pos}{x}." ".$actor->{pos}{y}." to ".$actor->{pos_to}{x}." ".$actor->{pos_to}{y}.").\n";
	
	my $new_changes = create_changes_array($actor->{pos_to}, $weights);
	
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
	my ($obstacle_pos, $weight_array) = @_;
	
	my @weights = @{$weight_array};
	
	my $max_distance = $#weights;
	
	my @changes_array;
	
	my ($min_x, $min_y, $max_x, $max_y) = Utils::getSquareEdgesFromCoord($field, $obstacle_pos, $max_distance);
	
	my @y_range = ($min_y..$max_y);
	my @x_range = ($min_x..$max_x);
	
	foreach my $y (@y_range) {
		foreach my $x (@x_range) {
			next unless ($field->isWalkable($x, $y));
			my $pos = {
				x => $x,
				y => $y
			};
			my $distance = blockDistance($pos, $obstacle_pos);
			my $delta_weight = $weights[$distance];
			push(@changes_array, {
				x => $x,
				y => $y,
				weight => $delta_weight
			});
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

sub on_route_step_final {
	my (undef, $args) = @_;
	
	my @obstacles = keys(%obstaclesList);
	
	warning "[".PLUGIN_NAME."] on_route_step_final, there are ".@obstacles." obstacles.\n";
	
	return unless (@obstacles > 0);
	
	#return if ($args->{field}->baseName ne $field->baseName);
	
	my $route = $args->{route};
	my $actor_pos = $route->{actor}{pos};
	
	my $current_next_step_pos;
	my $current_next_step_index = $route->{step_index};
	
	my $abs_dif_x;
	my $abs_dif_y;
	
	my $is_line;
	my $found;
	my $decrease = 0;
	
	while ($current_next_step_index > 0) {
		@{$current_next_step_pos}{qw(x y)} = @{$route->{solution}[$current_next_step_index]}{qw(x y)};
		
		$abs_dif_x = abs($actor_pos->{x} - $current_next_step_pos->{x});
		$abs_dif_y = abs($actor_pos->{y} - $current_next_step_pos->{y});
		
		if (blockDistance($actor_pos, $current_next_step_pos) <= 17 && $field->checkLOS($actor_pos, $current_next_step_pos, 0)) {
			warning "[".PLUGIN_NAME."] you can move there with los.\n";
			
			my $changes = sum_all_changes();
			
			my %obstacle_hash;
			foreach my $obstacle_cell (@{$changes}) {
				$obstacle_hash{$obstacle_cell->{x}}{$obstacle_cell->{y}} = 1;
			}
			
			if (check_intercept_avoid_cell($actor_pos, $current_next_step_pos, \%obstacle_hash)) {
				warning "[".PLUGIN_NAME."] and you also wont intercept anything YAYYYYY, changing next step to $current_next_step_index.\n";
				$route->{step_index} = $current_next_step_index;
				$route->{decreasing_step_index} += $decrease;
				return;
				
			} else {
				warning "[".PLUGIN_NAME."] but intercetp an obstacle.\n";
			}
		} else {
			warning "[".PLUGIN_NAME."] but you cannot move there with los.\n";
		}
	
	} continue {
		$current_next_step_index--;
		$decrease++;
	}
	
	warning "[".PLUGIN_NAME."] DID NOT FIND GOOD NEXT STEP.\n";
}

sub check_intercept_avoid_cell {
	my ($from, $to, $obstacle_hash) = @_;

	# Simulate tracing a line to the location (modified Bresenham's algorithm)
	my ($X0, $Y0, $X1, $Y1) = ($from->{x}, $from->{y}, $to->{x}, $to->{y});

	my $steep;
	my $posX = 1;
	my $posY = 1;
	if ($X1 - $X0 < 0) {
		$posX = -1;
	}
	if ($Y1 - $Y0 < 0) {
		$posY = -1;
	}
	if (abs($Y0 - $Y1) < abs($X0 - $X1)) {
		$steep = 0;
	} else {
		$steep = 1;
	}
	if ($steep == 1) {
		my $Yt = $Y0;
		$Y0 = $X0;
		$X0 = $Yt;

		$Yt = $Y1;
		$Y1 = $X1;
		$X1 = $Yt;
	}
	if ($X0 > $X1) {
		my $Xt = $X0;
		$X0 = $X1;
		$X1 = $Xt;

		my $Yt = $Y0;
		$Y0 = $Y1;
		$Y1 = $Yt;
	}
	my $dX = $X1 - $X0;
	my $dY = abs($Y1 - $Y0);
	my $E = 0;
	my $dE;
	if ($dX) {
		$dE = $dY / $dX;
	} else {
		# Delta X is 0, it only occures when $from is equal to $to
		return 1;
	}
	my $stepY;
	if ($Y0 < $Y1) {
		$stepY = 1;
	} else {
		$stepY = -1;
	}
	my $Y = $Y0;
	my $Erate = 0.99;
	if (($posY == -1 && $posX == 1) || ($posY == 1 && $posX == -1)) {
		$Erate = 0.01;
	}
	for (my $X=$X0;$X<=$X1;$X++) {
		$E += $dE;
		if ($steep == 1) {
			return 0 if (exists $obstacle_hash->{$Y} && exists $obstacle_hash->{$Y}{$X});
		} else {
			return 0 if (exists $obstacle_hash->{$X} && exists $obstacle_hash->{$X}{$Y});
		}
		if ($E >= $Erate) {
			$Y += $stepY;
			$E -= 1;
		}
	}
	return 1;
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