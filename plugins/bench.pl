package bench;

use Plugins;
use Globals;
use Log qw( warning message error debug );
use Time::HiRes qw(time);
use Misc;

# Plugin
Plugins::register("bench", "bench", \&core_Unload, \&core_Reload);

my $commands_hooks = Commands::register(
	['bench', 'test notification',			\&cmdTest],
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
	
	my @startx;
	my @endx;
	my @starty;
	my @endy;
	
	for(my $i = 0; $i < $n; $i++){
		$start[$i]->{x} = int rand $wid;
		$start[$i]->{y} = int rand $hei;
		$end[$i]->{x} = int rand $wid;
		$end[$i]->{y} = int rand $hei;
	}
	
	my $time_s;
	my $time_e;
	my $time_d;
	
	$time_s = time;
	for(my $i = 0; $i < $n; $i++){
		$field->checkLOS($start[$i], $end[$i], 1);
	}
	$time_e = time;
	$time_d = $time_e - $time_s;
	print "checkLOS took $time_d\n";
}

1;