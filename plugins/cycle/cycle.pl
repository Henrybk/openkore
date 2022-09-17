package cycle;

use Plugins;
use Globals;
use Log qw( warning message error debug );
use Time::HiRes qw(time);
use Misc;
use Devel::Cycle;
use Devel::Refcount qw( refcount );

# Plugin
Plugins::register(PLUGINNAME, "", \&core_Unload, \&core_Reload);

my $commands_hooks = Commands::register(
	['cycle', 'test notification',			\&cmdcycleification],
);

my $hooks = Plugins::addHooks(
	['docycle',		\&cmdcycleification, undef],
	['docycle2',		\&cmdcycleification2, undef],
);

sub core_Unload {
	error("Unloading plugin...", "cycle");
	core_SafeUnload();
}

sub core_Reload {
	warning("Reloading plugin...", "cycle");
	core_SafeUnload();
}

sub core_SafeUnload {
	Plugins::delHook($hooks);
	Commands::unregister($commands_hooks);
}

sub cmdcycleification {
	warning "Finding memory cycles\n";
	find_cycle($char->{homunculus});
	my $count = refcount( $char->{homunculus} );
	warning "Refcount is $count\n";
}

sub cmdcycleification2 {
	#warning "Finding memory cycles in args\n";
	find_cycle($char->{homunculus}->args);
	my $count = refcount( $char->{homunculus}->args );
	warning "Refcount args is $count\n";
}
1;