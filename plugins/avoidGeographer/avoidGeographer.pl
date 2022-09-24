package avoidGeographer;

use strict;
use Globals;
use Settings;
use Misc;
use Plugins;
use Utils;
use Log qw(message debug error warning);

Plugins::register('avoidGeographer', 'enable custom conditions', \&onUnload);

my $hooks = Plugins::addHooks(
	['checkMonsterAutoAttack', \&on_checkMonsterAutoAttack, undef],
);

sub onUnload {
    Plugins::delHooks($hooks);
}

my $avoidGeographerID = 1368;

sub on_checkMonsterAutoAttack {
	my (undef, $args) = @_;
	
	my $count = 0;
	for my $monster (@$monstersList) {
		if ($monster->{nameID} == $avoidGeographerID) {
			warning "[avoidGeographer] Dropping target ".$args->{monster}." because there is a Geographer near it ($monster).\n";
			$args->{return} = 0;
			return;
		}
	}
}

return 1;