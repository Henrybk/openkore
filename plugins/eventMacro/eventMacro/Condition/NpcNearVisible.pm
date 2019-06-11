package eventMacro::Condition::NpcNearVisible;

use strict;
use Globals qw( $npcsList $char $field );
use Utils qw( distance );

use base 'eventMacro::Conditiontypes::RegexConditionState';

sub _hooks {
	['packet_mapChange','add_npc_list','npc_disappeared','npcNameUpdate','changed_status'];
}

sub _parse_syntax {
	my ( $self, $condition_code ) = @_;
	
	$self->{actorList} = \$npcsList;
	
	$self->SUPER::_parse_syntax($condition_code);
}

sub validate_condition {
	my ( $self, $callback_type, $callback_name, $args ) = @_;
	
	$self->{actor} = undef;
	$self->{hook_type} = undef;
	
	if ($callback_type eq 'hook') {
		if ($callback_name eq 'add_npc_list') {
			$self->{actor} = $args;
			$self->{hook_type} = 'add_list';

		} elsif ($callback_name eq 'npc_disappeared') {
			$self->{actor} = $args->{npc};
			$self->{hook_type} = 'disappeared';
		
		} elsif ($callback_name eq 'npcNameUpdate') {
			$self->{actor} = $args->{npc};
			$self->{hook_type} = 'NameUpdate';
			
		} elsif ($callback_name eq 'changed_status') {
			$self->{actor} = $args->{npc};
			$self->{hook_type} = 'status_info';
		}
	}
	
	if ($callback_type eq 'variable') {
		$self->update_validator_var($callback_name, $args);
		$self->recheck_all_actor_names;
		
	} elsif ($callback_type eq 'hook') {
		
		if ($self->{hook_type} eq 'add_list' && !defined $self->{fulfilled_actor} && $self->validator_check($self->{actor}->{name}) && !$self->{actor}->{statuses}->{EFFECTSTATE_BURROW}) {
			$self->{fulfilled_actor} = $self->{actor};

		} elsif ($self->{hook_type} eq 'disappeared' && defined $self->{fulfilled_actor} && $self->{actor}->{binID} == $self->{fulfilled_actor}->{binID}) {
		
			#need to check all other actor to find another one that matches or not
			my $last_bin_id = $self->{fulfilled_actor}->{binID};
			$self->{fulfilled_actor} = undef;
			foreach my $actor (@{${$self->{actorList}}->getItems}) {
				next if ($actor->{binID} == $last_bin_id);
				next unless ($self->validator_check($actor->{name}));
				next if ($actor->{statuses}->{EFFECTSTATE_BURROW});
				$self->{fulfilled_actor} = $actor;
				last;
			}
		
		} elsif ($self->{hook_type} eq 'NameUpdate') {
		
			if (!defined $self->{fulfilled_actor} && $self->validator_check($self->{actor}->{name}) && !$self->{actor}->{statuses}->{EFFECTSTATE_BURROW}) {
				$self->{fulfilled_actor} = $self->{actor};
				
			} elsif (defined $self->{fulfilled_actor} && $self->{actor}->{binID} == $self->{fulfilled_actor}->{binID}) {
				unless ($self->validator_check($self->{actor}->{name})) {
					$self->{fulfilled_actor} = undef;
					foreach my $actor (@{${$self->{actorList}}->getItems}) {
						next unless ($self->validator_check($actor->{name}));
						next if ($actor->{statuses}->{EFFECTSTATE_BURROW});
						$self->{fulfilled_actor} = $actor;
						last;
					}
				}
			}

		} elsif ($self->{hook_type} eq 'status_info') {
		
			if (!defined $self->{fulfilled_actor} && $self->validator_check($self->{actor}->{name}) && !$self->{actor}->{statuses}->{EFFECTSTATE_BURROW}) {
				$self->{fulfilled_actor} = $self->{actor};
				
			} elsif (defined $self->{fulfilled_actor} && $self->{actor}->{binID} == $self->{fulfilled_actor}->{binID} && $self->{actor}->{statuses}->{EFFECTSTATE_BURROW}) {
				$self->{fulfilled_actor} = undef;
				foreach my $actor (@{${$self->{actorList}}->getItems}) {
					next unless ($self->validator_check($actor->{name}));
					next if ($actor->{statuses}->{EFFECTSTATE_BURROW});
					$self->{fulfilled_actor} = $actor;
					last;
				}
			}
			
		} elsif ($callback_name eq 'packet_mapChange') {
			$self->{fulfilled_actor} = undef;
		}
		
	} elsif ($callback_type eq 'recheck') {
		$self->recheck_all_actor_names;
	}
	
	return $self->SUPER::validate_condition( (defined $self->{fulfilled_actor} ? 1 : 0) );
}

sub recheck_all_actor_names {
	my ($self) = @_;
	$self->{fulfilled_actor} = undef;
	foreach my $actor (@{${$self->{actorList}}->getItems}) {
		next unless ($self->validator_check($actor->{name}));
		next if ($actor->{statuses}->{EFFECTSTATE_BURROW});
		$self->{fulfilled_actor} = $actor;
		last;
	}
}

sub get_new_variable_list {
	my ($self) = @_;
	my $new_variables;
	
	$new_variables->{".".$self->{name}."Last"} = $self->{fulfilled_actor}->{name};
	$new_variables->{".".$self->{name}."Last"."Pos"} = sprintf("%d %d %s", $self->{fulfilled_actor}->{pos_to}{x}, $self->{fulfilled_actor}->{pos_to}{y}, $field->baseName);
	$new_variables->{".".$self->{name}."Last"."BinId"} = $self->{fulfilled_actor}->{binID};
	$new_variables->{".".$self->{name}."Last"."Dist"} = distance($char->{pos_to}, $self->{fulfilled_actor}->{pos_to});
	
	return $new_variables;
}

sub usable {
	1;
}

1;
