package benchPath;

use strict;
use Plugins;
use Globals;
use Log qw(debug message warning error);
use Commands;
use Task::Route;

use Time::HiRes qw(time);
use Benchmark;

return unless
Plugins::register('benchPath', 'benchPath', \&on_unload);

my $chooks = Commands::register(
      ['benchPath', "benchPath", \&commandHandler]
);

sub on_unload {
   Commands::unregister($chooks);
}

sub test_pathing_new {
	my $map = 'prontera';
	my $start_x = 150;
	my $start_y = 150;
	my $dest_x = 150;
	my $dest_y = 170;
	
	my $testfield = new Field(name => $map);
	
	my $teststart = {
		x => $start_x,
		y => $start_y,
	};
	
	my $testend = {
		x => $dest_x,
		y => $dest_y,
	};
	
	my $result;
	my $solution = [];
	my $message;
	
	my $pathfinding = new PathFinding;
	
	$pathfinding->reset(
		field => $testfield,
		start => $teststart,
		dest => $testend,
		timeout => 1500,
		avoidWalls => 1
	);
	
	$result = $pathfinding->run($solution);
=pod
	
	$message = "Run Solution is : (start --> ";
	
	foreach my $step (@{$solution}) {
		$message .= "\"".$step->{x}." ".$step->{y}."\"";
	} continue {
		$message .= " --> ";
	}
	
	Log::warning "Result from first run was $result.\n";
	
	$message .= "end)\n";
	
	Log::warning $message;
=cut
	
	undef $result;
	$solution = [];
	undef $message;
	
	$start_x = 150;
	$start_y = 155;
	
	my $obstacle_x = 150;
	my $obstacle_y = 160;
	my $weights_array = [100, 100, 100, 100];
	
	my $changes = simulate_changes_array($testfield, $obstacle_x, $obstacle_y, $weights_array);
	
	$pathfinding->update_cell($start_x, $start_y, $changes);
	
	$result = $pathfinding->run($solution);
=pod
	
	$message = "Run Solution is : (start --> ";
	
	foreach my $step (@{$solution}) {
		$message .= "\"".$step->{x}." ".$step->{y}."\"";
	} continue {
		$message .= " --> ";
	}
	
	Log::warning "Result from second run was $result.\n";
	
	$message .= "end)\n";
	
	Log::warning $message;
=cut
	
	return 1;
}

sub simulate_changes_array {
	my ($test_field, $x, $y, $weight_array) = @_;
	my $obs_x = $x;
	my $obs_y = $y;
	
	my @weights = @{$weight_array};
	
	my $max_distance = $#weights;
	
	my @changes_array;
	
	for (my $y = ($obs_y - $max_distance);     $y <= ($obs_y + $max_distance);   $y++) {
		for (my $x = ($obs_x - $max_distance);     $x <= ($obs_x + $max_distance);   $x++) {
			my $xDistance = abs($obs_x - $x);
			my $yDistance = abs($obs_y - $y);
			my $cell_distance = (($xDistance > $yDistance) ? $xDistance : $yDistance);
			my $delta_weight = $weights[$cell_distance];
			next unless ($test_field->isWalkable($x, $y));
			push(@changes_array, { x => $x, y => $y, weight => $delta_weight});
		}
	}
	
	return \@changes_array;
}

sub test_pathing_old {
	my $map = 'prontera';
	my $start_x = 150;
	my $start_y = 150;
	my $dest_x = 150;
	my $dest_y = 170;
	
	my $testfield = new Field(name => $map);
	
	my $teststart = {
		x => $start_x,
		y => $start_y,
	};
	
	my $testend = {
		x => $dest_x,
		y => $dest_y,
	};
	
	my $result;
	my $solution = [];
	my $message;
	
	my $pathfinding = new PathFinding;
	
	$pathfinding->reset(
		field => $testfield,
		start => $teststart,
		dest => $testend,
		timeout => 1500,
		avoidWalls => 1
	);
	
	$result = $pathfinding->run($solution);
	
	undef $result;
	$solution = [];
	undef $message;
	
	my $obstacle_x = 150;
	my $obstacle_y = 160;
	my $weights_array = [100, 100, 100, 100];
	
	my $changes = simulate_changes_array($testfield, $obstacle_x, $obstacle_y, $weights_array);
	
	$start_x = 150;
	$start_y = 155;
	
	$teststart = {
		x => $start_x,
		y => $start_y,
	};
	
	$pathfinding->reset(
		field => $testfield,
		start => $teststart,
		dest => $testend,
		timeout => 1500,
		avoidWalls => 1
	);
	
	$result = $pathfinding->run($solution);
	
	return 1;
}

sub commandHandler {
=pod
	timethis( 10000, sub {
		test_pathing_new();
	});
	timethis( 10000, sub {
		test_pathing_old();
	});
	Commands::run('quit');
=cut
	my $map = 'prontera';
	my $start_x = 155;
	my $start_y = 100;
	my $dest_x = 155;
	my $dest_y = 60;
	
	my $testfield = new Field(name => $map);
	
	my $teststart = {
		x => $start_x,
		y => $start_y,
	};
	
	my $testend = {
		x => $dest_x,
		y => $dest_y,
	};
	
	my $result;
	my $solution = [];
	my $message;
	
	my $pathfinding = new PathFinding;
	
	$pathfinding->reset(
		field => $testfield,
		start => $teststart,
		dest => $testend,
		timeout => 1500,
		avoidWalls => 1
	);
	
	$result = $pathfinding->run($solution);
	
	undef $result;
	$solution = [];
	undef $message;
	
	$start_x = 155;
	$start_y = 94;
	
	my $obstacle_x = 150;
	my $obstacle_y = 160;
	my $weights_array = [100, 100, 100, 100];
	
	my @changes;
	
	my @obstacles = (
		{ x => 151, y => 84},
		{ x => 159, y => 84},
		{ x => 155, y => 84},
		{ x => 158, y => 84},
		{ x => 158, y => 83},
		{ x => 156, y => 83},
		{ x => 159, y => 83},
		{ x => 157, y => 83},
		{ x => 157, y => 83},
	);
	
	foreach my $obstacle (@obstacles) {
		my $changes = simulate_changes_array($testfield, $obstacle->{x}, $obstacle->{y}, $weights_array);
		push(@changes, @{$changes});
		
	}
	
	my %changes_hash;
	foreach my $change (@changes) {
		my $x = $change->{x};
		my $y = $change->{y};
		my $changed = $change->{weight};
		$changes_hash{$x}{$y} += $changed;
	}
	
	my @rebuilt_array;
	foreach my $x_keys (keys %changes_hash) {
		foreach my $y_keys (keys %{$changes_hash{$x_keys}}) {
			next if ($changes_hash{$x_keys}{$y_keys} == 0);
			push(@rebuilt_array, { x => $x_keys, y => $y_keys, weight => $changes_hash{$x_keys}{$y_keys} });
		}
	}
	
	$pathfinding->update_cell($start_x, $start_y, \@rebuilt_array);
	
	$result = $pathfinding->run($solution);
}