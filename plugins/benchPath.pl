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

sub commandHandler {
	my $map = 'prontera';
	my $start_x = 155;
	my $start_y = 60;
	
	my $dest_x = 155;
	my $dest_y = 100;
	
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
	
	$start_x = 155;
	$start_y = 67;
	
	my $obstacle_x = 155;
	my $obstacle_y = 80;
	my $weights_array = [1000, 1000];
	
	my $changes = simulate_changes_array($testfield, $obstacle_x, $obstacle_y, $weights_array);
	
	$pathfinding->update_solution($start_x, $start_y, $changes);
	
	$result = $pathfinding->run($solution);
	
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

1;