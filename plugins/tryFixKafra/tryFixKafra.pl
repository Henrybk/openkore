package tryFixKafra;
 
use strict;
use Plugins;
use Settings;
use Globals;
use Utils;
use Misc;
use Log qw(message error warning);
use Translation;
use Network;
 
#########
# startup
Plugins::register('tryFixKafra', '', \&Unload, \&Unload);

my $hooks = Plugins::addHooks(
	['npc_teleport_missing',   \&onmiss,    undef]
);

# onUnload
sub Unload {
	Plugins::delHooks($hooks);
}

sub onmiss {
	my ($self, $args) = @_;
	
	#$plugin_args{x} = $self->{mapSolution}[0]{pos}{x};
	#$plugin_args{y} = $self->{mapSolution}[0]{pos}{y};
	#$plugin_args{steps} = $self->{mapSolution}[0]{steps};
	#$plugin_args{plugin_retry} = $self->{mapSolution}[0]{plugin_retry};
	#$plugin_args{return} = 0;
	
	return if ($args->{plugin_retry} > 0);
	
	my $closest_portal_binID;
	my $closest_portal_dist;
	my $closest_name;
	my $closest_x;
	my $closest_y;
	
	foreach my $actor (@{$npcsList->getItems()}) {
		my $pos = ($actor->isa('Actor::NPC')) ? $actor->{pos} : $actor->{pos_to};
		next if ($actor->{statuses}->{EFFECTSTATE_BURROW});
		next if ($config{avoidHiddenActors} && ($actor->{type} == 111 || $actor->{type} == 139 || $actor->{type} == 2337)); # HIDDEN_ACTOR TYPES
		next unless (defined $actor->{name});
		next unless ($actor->{name} =~ /^Kafra Employee$/);
		my $dist = blockDistance($char->{pos_to}, $pos);
		next if (defined $closest_portal_dist && $closest_portal_dist < $dist);
		$closest_portal_binID = $actor->{binID};
		$closest_portal_dist = $dist;
		$closest_name = $actor->{name};
		$closest_x = $pos->{x};
		$closest_y = $pos->{y};
	}
	
	if (defined $closest_portal_binID) {
		warning TF("[tryFixKafra] Guessing our desired kafra to be %s (%s,%s).\n", $closest_name, $closest_x, $closest_y), "system";
		$args->{x} = $closest_x;
		$args->{y} = $closest_y;
		$args->{return} = 1;
	}
	
	return;
}

return 1;
