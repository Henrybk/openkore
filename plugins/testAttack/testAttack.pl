package testAttack;

use Plugins;
use Globals;
use Log qw( warning message error debug );
use Time::HiRes qw(time);
use Misc;

# Plugin
Plugins::register('testAttack', "testAttack", \&core_Unload, \&core_Reload);

my $commands_hooks = Commands::register(
	['ta', 'test notification',			\&cmdtestAttackification],
);

my $hooks = Plugins::addHooks(
	['monster_ranged_attack',		\&onhook, undef],
);

sub core_Unload {
	error("Unloading plugin testAttack...", "testAttack");
	core_SafeUnload();
}

sub core_Reload {
	warning("Reloading plugin testAttack...", "testAttack");
	core_SafeUnload();
}

sub core_SafeUnload {
	Plugins::delHook($hooks);
	Commands::unregister($commands_hooks);
}

sub cmdtestAttackification {
	if (!defined $_[1]) {
		message "usage: ta [mob binID]\n", "list";
		return;
	}
	my ( $command, $arg ) = @_;
	
	my $id = $arg;
	
	if ($id !~ /^\d+$/) {
		error "Provided mob binID is not numerical\n", "list";
		return;
	}
	
	my $monster = $monstersList->get($id);
	unless ($monster) {
		error "THere is no mob of binID $id\n";
		return;
	}
	
	#$messageSender->sendAction($monster->{ID}, 7);
	
	#my $pos = meetingPosition($char, 1, $monster, 1);
	#$char->sendMove($pos->{x},$pos->{y});
	
	$messageSender->sendAction($monster->{ID}, 7);
}

sub onhook {
	my ($hook, $args) = @_;
	my $ID = $args->{ID};
	my $target = $monstersList->getByID($ID);
	
	my $pos = $target->{movetoattack_pos};
	#my $pos = meetingPosition($char, 1, $target, 1);
	
	$char->sendMove($pos->{x},$pos->{y});
	$messageSender->sendAction($target->{ID}, 7);
}

1;