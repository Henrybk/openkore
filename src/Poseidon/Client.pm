############################################################
# Poseidon query interface for OpenKore
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# Copyright (c) 2005-2006 OpenKore Development Team
############################################################
##
# MODULE DESCRIPTION: Poseidon GameGuard query handler.
#
# Poseidon provides a simple way to respond to GameGuard queries.
package Poseidon::Client;

use strict;
use IO::Socket::INET;
use Time::HiRes qw(time usleep);
use Globals qw(%config);
use Log qw(warning error debug);
use Bus::MessageParser;
use Bus::Messages qw(serialize);
use Utils qw(dataWaiting);
use Plugins;
use Misc;

use constant DEFAULT_POSEIDON_SERVER_PORT => 24390;
use constant DEFAULT_POSEIDON_SERVER_TIMEOUT => 5;
use constant POSEIDON_SUPPORT_URL => 'https://openkore.com/wiki/Poseidon';
use constant MAX_RETRIES => 5;  # Number of retries for socket creation
use constant RETRY_DELAY => 100000;  # Delay between retries in microseconds (0.1s)

our $instance;


# Poseidon::Client Poseidon::Client->new(String host, int port, int timeout)
#
# Create a new Poseidon::Client object.
sub _new {
    my ($class, $host, $port, $timeout) = @_;
    my %self = (
        host => $host,
        port => $port,
        timeout => $timeout,
        timestamp => undef
    );
    return bless \%self, $class;
}

# IO::Socket::INET $PoseidonClient->_connect()
#
# Connect to the poseidon server.
sub _connect {
    my ($self) = @_;
    my $attempt = 0;
    my $socket;

    while ($attempt < MAX_RETRIES) {
        $attempt++;
        my $start_time = time;
        debug "[Poseidon _connect] Attempt $attempt: Connecting to $self->{host}:$self->{port}\n", "poseidon";

        # Attempt to create socket
        $socket = IO::Socket::INET->new(
            PeerHost => $self->{host},
            PeerPort => $self->{port},
            Proto => 'tcp',
            Timeout => 0.20
        );

        my $end_time = time;
        my $duration = $end_time - $start_time;

        if ($socket) {
            warning "[Poseidon _connect] Socket created successfully in $duration seconds (attempt $attempt).\n", "poseidon";
            return $socket;
        }

        # Log detailed error information
        my $error = $!;  # Capture system error
        error "[Poseidon _connect] Failed to create socket on attempt $attempt: $error\n", "poseidon";
        debug "[Poseidon _connect] Host: $self->{host}, Port: $self->{port}, Timeout: 2\n", "poseidon";

        # Check if retry is possible
        if ($attempt < MAX_RETRIES) {
            warning "[Poseidon _connect] Retrying in " . (RETRY_DELAY / 1000000) . " seconds...\n", "poseidon";
            usleep(RETRY_DELAY);  # Delay before retry
        }
    }

    error "[Poseidon _connect] All MAX_RETRIES attempts failed to connect to $self->{host}:$self->{port}.\n", "poseidon";
    return undef;
}

# void $PoseidonClient->_disconnect()
#
# Disconnect from poseidon server when error ocurred.
sub _disconnect_error {
    my ($self, $msg) = @_;
    my $error_msg = defined $msg ? $msg :
        "The Poseidon server closed the connection unexpectedly or could not respond " .
        "to your request due to a server bandwidth issue. Please report this bug.\n";

    error $error_msg, "poseidon";
    $self->reset();

    offlineMode();

    my %hookArgs;
    $hookArgs{error_msg} = $error_msg;
    $hookArgs{return} = 0;
    Plugins::callHook('Poseidon_disconnect_error', \%hookArgs);

    return -1;
}

sub reset {
    my ($self) = @_;
    $self->{socket} = undef;
    $self->{timestamp} = undef;
    $self->{parser} = undef;
}

sub isWaitingQuery {
    my ($self) = @_;
    return 1 if (exists $self->{timestamp} && defined $self->{timestamp});
	return 0;
}

##
# void $PoseidonClient->query(Bytes packet)
# packet: A GameGuard query packet.
#
# Send a GameGuard query packet to the Poseidon core.
#
# When an appropriate response packet has been determined,
# it will be available through $PoseidonClient->getResult()
sub query {
	my ($self, $packet) = @_;
	my $socket = $self->_connect();

    if (!$socket) {
        return $self->_disconnect_error("Could not connect to the Poseidon server.\n");
    }

    my (%args, $data);
	# Plugin hook to make it possible to add additional data piggy-backed to the Poseidon request packet (auth information for example)
    Plugins::callHook('Poseidon/client_authenticate', { args => \%args });
    $args{packet} = $packet;
    $data = serialize("Poseidon Query", \%args);
    $socket->send($data);
    $socket->flush();
    $self->{socket} = $socket;
    $self->{parser} = new Bus::MessageParser();
    $self->{timestamp} = time;
    debug "[Poseidon query] Query sent to $self->{host}:$self->{port}\n", "poseidon";
	return 1;
}

##
# Bytes $PoseidonClient->getResult()
# Returns: the GameGuard query result, or undef if there is no result yet.
# Ensures: if defined(result): !defined($self->getResult())
#
# Get the result for the last query.
sub getResult {
    my ($self) = @_;

    if ($self->{timestamp} && time - $self->{timestamp} > $self->{timeout}) {
        return $self->_disconnect_error("The Poseidon server reply timeout reached. Check your Ragnarok Online client.\n");
    }

    if (!$self->{socket} || !$self->{socket}->connected) {
        return $self->_disconnect_error("Socket is not connected or undefined.\n");
    }

    if (!dataWaiting($self->{socket})) {
        debug "[Poseidon getResult] No data waiting on socket.\n", "poseidon";
        return undef;
    }

    my ($buf, $ID, $args);
    $self->{socket}->recv($buf, 1024 * 32);
    if (!$buf) {
        return $self->_disconnect_error("Received empty buffer.\n");
    }

    $self->{parser}->add($buf);
    if ($args = $self->{parser}->readNext(\$ID)) {
        if ($ID ne "Poseidon Reply") {
            return $self->_disconnect_error("The Poseidon server sent a wrong reply ID ($ID). Please report this bug.\n");
        } else {
            my $packet = $args->{packet};
            my $recv_time = time;
            warning "[Poseidon getResult] Getting result took '" . ($recv_time - $self->{timestamp}) . "' seconds.\n", "poseidon";
            $self->reset();
            return $packet;
        }
    } else {
        debug "[Poseidon getResult] Incomplete message received. Waiting for more data.\n", "poseidon";
        return undef;
    }
}

##
# Poseidon::Client Poseidon::Client::getInstance()
#
# Get the global Poseidon::Client instance.
sub getInstance {
	if (!$instance) {
		$instance = Poseidon::Client->_new(
            $config{poseidonServer} || 'localhost',
            $config{poseidonPort} || DEFAULT_POSEIDON_SERVER_PORT,
            $config{poseidonTimeout} || DEFAULT_POSEIDON_SERVER_TIMEOUT);
    }
    return $instance;
}

1;
