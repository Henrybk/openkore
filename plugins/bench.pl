package bench;

use Plugins;
use Globals;
use Log qw( warning message error debug );
use Time::HiRes qw(time);
use Misc;
use Data::Dumper;
use Devel::Cycle;
use Devel::Refcount qw( refcount );

# Plugin
Plugins::register("bench", "bench", \&core_Unload, \&core_Reload);

my $commands_hooks = Commands::register(
	['bench', '',			\&cmdTest],
);

sub core_Unload {
	error("Unloading plugin...", "bench");
	core_SafeUnload();
}

sub core_Reload {
	warning("Reloading plugin...", "bench");
	core_SafeUnload();
}

sub core_SafeUnload {
	Commands::unregister($commands_hooks);
}

sub cmdTest {
	bench();
}

sub bench {
	my $n = 1000;
	
	my $wid = $field->{width};
	my $hei = $field->{height};
	
	my $use_dist = 1;
	my $use_sol = 0;
	my $use_range = 0;
	my $use_time = 1;
	my $use_explored = 0;
	
	my $dist = 15;
	
	my $min_range = 1;
	my $max_range = 30;
	
	my $min_time = 0;
	my $max_time = 4;
	
	my @start = ();
	my @end = ();
	my @range = ();
	my @sol = ();
	my @time = ();
	my @explored = ();
	
	my $time_s;
	my $time_e;
	
	my $delta_range = $max_range - $min_range;
	my $delta_time = $max_time - $min_time;
	
	print "[bench] Preparing $n test benchs with dist $dist\n";
	for(my $i = 0; $i < $n; $i++){
		while (!exists $start[$i]->{x} || !$field->isWalkable($start[$i]->{x}, $start[$i]->{y})) {
			$start[$i]->{x} = int(rand($wid));
			$start[$i]->{y} = int(rand($hei));
		}
		if (!$use_explored) {
			if ($use_dist) {
				while (!exists $end[$i]->{x} || !$field->isWalkable($end[$i]->{x}, $end[$i]->{y})) {
					$end[$i]->{x} = $start[$i]->{x} + (int(rand($dist*2)) - $dist);
					$end[$i]->{y} = $start[$i]->{y} + (int(rand($dist*2)) - $dist);
				}
			} else {
				while (!exists $end[$i]->{x} || !$field->isWalkable($end[$i]->{x}, $end[$i]->{y})) {
					$end[$i]->{x} = int(rand($wid));
					$end[$i]->{y} = int(rand($hei));
				}
			}
		}
		$range[$i] = (int(rand($delta_range))+$min_range) if ($use_range);
		
		$sol[$i] = Utils::get_solution($field, $start[$i], $end[$i]) if ($use_sol);
		
		$time[$i] = rand($delta_time)+$min_time if ($use_time);
		
		if ($use_explored) {
			my $pathfinding = new PathFinding();
			$pathfinding->resetExploring(
				field => $field,
				start => $start[$i]
			);
			my $explored_array = [];
			$pathfinding->explore($dist, $explored_array);
			my %explored_cells;
			foreach my $exp (@{$explored_array}) {
				$explored_cells{$exp->{x}}{$exp->{y}}{g} = $exp->{g};
				$explored_cells{$exp->{x}}{$exp->{y}}{pc} = $exp->{pc};
				$explored_cells{$exp->{x}}{$exp->{y}}{p} = 0;
				if ($exp->{p} == 1) {
					$explored_cells{$exp->{x}}{$exp->{y}}{p} = 1;
					$explored_cells{$exp->{x}}{$exp->{y}}{px} = $exp->{px};
					$explored_cells{$exp->{x}}{$exp->{y}}{py} = $exp->{py};
				}
			}
			$explored[$i] = \%explored_cells;
			undef $pathfinding;
			undef $explored_array;
			$end[$i]->{x} = (keys %explored_cells)[rand keys %explored_cells];
			$end[$i]->{y} = (keys %{$explored_cells{$end[$i]->{x}}})[rand keys %{$explored_cells{$end[$i]->{x}}}];
			#print "[bench] [$i] $end[$i]->{x} $end[$i]->{y} | g $explored_cells{$end[$i]->{x}}{$end[$i]->{y}}{g} | p $explored_cells{$end[$i]->{x}}{$end[$i]->{y}}{p} | pc $explored_cells{$end[$i]->{x}}{$end[$i]->{y}}{pc}\n";
			undef %explored_cells;
		}
	}
	print "[bench] Ended benchs\n";

	my @results1;
	$time_s = time;
	for(my $i = 0; $i < $n; $i++){
		$results1[$i] = Utils::get_client_solution($field, $start[$i], $end[$i]);
	}
	$time_e = time;
	printTime('get_client_solution1', $time_s, $time_e, $n);
	
	my @results2;
	$time_s = time;
	for(my $i = 0; $i < $n; $i++){
		$results2[$i] = Utils::get_client_solution2($field, $start[$i], $end[$i]);
	}
	$time_e = time;
	printTime('get_client_solution2', $time_s, $time_e, $n);
	my $check = checkResults(\@results1, \@results2, 'array_pos', 'get_client_solution1', 'get_client_solution2');
	printError(\@results1, \@results2, \@start, \@end, \@range, \@sol, \@time, $check, $use_sol, $use_range, $use_time) if ($check != -1);

}

sub printError {
	my ($results1, $results2, $start, $end, $range, $sol, $time, $check, $use_sol, $use_range, $use_time) = @_;
	
	print "[printError] [start] $start->[$check]{x} $start->[$check]{y}\n";
	print "[printError] [end] $end->[$check]{x} $end->[$check]{y}\n";
	print "[printError] [range] $range->[$check]\n" if ($use_range);
	print "[printError] [time] $time->[$check]\n" if ($use_time);
	if ($use_sol) {
		print "[printError] [sol] ".Dumper($sol->[$check]);
	}
}

sub printTime {
	my ($name, $time_s, $time_e, $n) = @_;
	
	my $decimals = 2;
	
	my $time_po;
	my @units = ('sec', 'milisec', 'microsec', 'nanosec');
	
	my $time_t = $time_e - $time_s;
	
	$time_po = ($time_t/$n);
	
	my $ui = 0;
	while ($time_po < 1) {
		$time_po *= 1000;
		$ui++;
	}
	
	my $decimal_round = (10**$decimals);
	$time_po = int($time_po*($decimal_round))/$decimal_round;
	
	print "[bench] $name: $time_po ".($units[$ui])." p.o.\n";
}

sub checkResults {
	my ($results1, $results2, $type, $name1, $name2) = @_;
	print "[bench] Comparing results from $name1 x $name2\n";
	
	my $current_index = 0;
	while ($current_index <= $#{$results1}) {
		my $result1 = $results1->[$current_index];
		my $result2 = $results2->[$current_index];
		
		if ($type eq 'scalar') {
			if ($result1 != $result2) {
				print "[bench scalar] Error at index $current_index: $name1=$result1 $name2=$result2\n";
				return $current_index;
			}
		
		} elsif ($type eq 'array_pos') {
			my $size1 = scalar @{$result1};
			my $size2 = scalar @{$result2};
			if ($size1 != $size2) {
				print "[bench pos] Error at index $current_index: size $name1=$size1 $name2=$size2\n";
				return $current_index;
			}
			foreach my $i (0..($size1-1)) {
				my $x1 = $result1->[$i]{x};
				my $y1 = $result1->[$i]{y};
				my $x2 = $result2->[$i]{x};
				my $y2 = $result2->[$i]{y};
				if ($x1 != $x2 || $y1 != $y2) {
					print "[bench pos] Error at index $current_index: pos $name1='$x1 $y1' $name2='$x2 $y2'\n";
					return $current_index;
				}
			}
		
		} elsif ($type eq 'single_pos') {
			my $x1 = $result1->{x};
			my $y1 = $result1->{y};
			my $x2 = $result2->{x};
			my $y2 = $result2->{y};
			if ($x1 != $x2 || $y1 != $y2) {
				print "[bench pos] Error at index $current_index: pos $name1='$x1 $y1' $name2='$x2 $y2'\n";
				return $current_index;
			}
		}
		
	} continue {
		$current_index++;
	}
	print "[bench] No diferences found between $name1 x $name2\n";
	return -1;
}



1;