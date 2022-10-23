package bench;

use Plugins;
use Globals;
use Log qw( warning message error debug );
use Time::HiRes qw(time);
use Misc;

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
	my $n = 10000;
	
	my $wid = $field->{width};
	my $hei = $field->{height};
	
	my $dist = 15;
	
	my @startx;
	my @endx;
	my @starty;
	my @endy;
	
	my $time_s;
	my $time_e;
	
	print "[bench] Preparing $n test benchs with dist $dist\n";
	for(my $i = 0; $i < $n; $i++){
		while (!exists $start[$i]->{x} || !$field->isWalkable($start[$i]->{x}, $start[$i]->{y})) {
			$start[$i]->{x} = int rand $wid;
			$start[$i]->{y} = int rand $hei;
		}
		if (!$dist) {
			while (!exists $end[$i]->{x} || !$field->isWalkable($end[$i]->{x}, $end[$i]->{y})) {
				$end[$i]->{x} = int rand $wid;
				$end[$i]->{y} = int rand $hei;
			}
		} else {
			while (!exists $end[$i]->{x} || !$field->isWalkable($end[$i]->{x}, $end[$i]->{y})) {
				$end[$i]->{x} = $start[$i]->{x} + (int(rand($dist*2)) - $dist);
				$end[$i]->{y} = $start[$i]->{y} + (int(rand($dist*2)) - $dist);
			}
		}
	}
	
	my @results1;
	$time_s = time;
	for(my $i = 0; $i < $n; $i++){
		$results1[$i] = $field->checkLOS($start[$i], $end[$i], 1);
	}
	$time_e = time;
	printTime('checkLOS1', $time_s, $time_e, $n);
	
	my @results2;
	$time_s = time;
	for(my $i = 0; $i < $n; $i++){
		$results2[$i] = $field->checkLOS2($start[$i], $end[$i], 1);
	}
	$time_e = time;
	printTime('checkLOS2', $time_s, $time_e, $n);
	checkResults(\@results1, \@results2, 'checkLOS1', 'checkLOS2');
	
	my @results3;
	$time_s = time;
	for(my $i = 0; $i < $n; $i++){
		$results3[$i] = $field->checkLOS3($start[$i], $end[$i], 1);
	}
	$time_e = time;
	printTime('checkLOS3', $time_s, $time_e, $n);
	checkResults(\@results1, \@results3, 'checkLOS1', 'checkLOS3');
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
	my ($results1, $results2, $name1, $name2) = @_;
	print "[bench] Comparing results from $name1 x $name2\n";
	
	my $current_index = 0;
	while ($current_index <= $#{$results1}) {
		my $result1 = $results1->[$current_index];
		my $result2 = $results2->[$current_index];
		if ($result1 != $result2) {
			print "[bench] Error at index $current_index: $name1=$result1 $name2=$result2\n";
			return 0;
		}
	} continue {
		$current_index++;
	}
	print "[bench] No diferences found between $name1 x $name2\n";
	return 1;
}



1;