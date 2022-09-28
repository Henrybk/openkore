package alertOnChat;

use strict;
use Log qw(message debug error warning);
use Time::HiRes qw(time);
use Misc;
use AI;
use Globals;
use Plugins;
use Utils;

Plugins::register("alertOnChat", "alertOnChat", \&on_unload);
my $hooks = Plugins::addHooks(
	['packet_privMsg', \&on_PM],
	['packet_pubMsg', \&on_Pub],
);

my $plugin_name = 'alertOnChat';

sub on_unload {
	Plugins::delHooks($hooks);
}

my $pushover_timeout = 0;

my $max_pub_in_screen = 2;
my $min_pub_dist = 10;

sub pushover {
	my ($reason, $message, $priority) = @_;
	return if !main::timeOut($pushover_timeout, 15);
	my @sound = ('gamelan', 'mechanical', 'alien');
	$pushover_timeout = time;
	my $final_message = $message."\n";
	my $server = $config{master};
	$final_message .= $server." - ".$config{username};
	require LWP::UserAgent;
	LWP::UserAgent->new()->post(
	  'https://api.pushover.net/1/messages.json' , [
	  "token" => 'axob2xx1d3qupkn5zf5m6ynv6q77b3',
	  "user" => 'uprdogxaqbvdtew1zqkyo8n5cifwo9',
	  "message" => $final_message,
	  "title" => $reason,
	  "priority" => 0,
	  "sound" => $priority == -1 ? 'none' : $sound[$priority],
	  "timestamp" => int(time)
	]);
	return;
}

sub cmdTestNotification {
	my $name = '[GM]test'.int(rand(20));
	my $push_title;
	$push_title .= sprintf("%s detectado.", $name) if $name;

	# my $push_msg
	pushover($push_title, sprintf("Mapa %s", 'gef_fild10'), 0);
}

sub on_PM {
	my ($Type, $Args) = @_;
	
	my $player = $Args->{'MsgUser'};
	my $recievedMessage = $Args->{'Msg'};
	
	my $push_title = sprintf("PM from %s", $player);
	
	pushover($push_title, $recievedMessage, 0);
}

sub on_Pub {
	return 0 if ($field->isCity());
	
	my $total = scalar @{$playersList->getItems()};
	return 0 if ($total > $max_pub_in_screen);
	
	my ($Type, $Args) = @_;
	my $player = $Args->{'MsgUser'};
	my $recievedMessage = $Args->{'Msg'};
	
	my $actor = Actor::get($args->{pubID});
	return unless ($actor->isa('Actor::Player'));
	
	my $realMyPos = calcPosition($char);
	my $realActorPos = calcPosition($actor);
	my $realActorDist = blockDistance($realMyPos, $realActorPos);
	
	return if ($realActorDist > $min_pub_dist);
	
	my $push_title = sprintf("Pub from %s (%d)", $player, $total);
	
	pushover($push_title, $recievedMessage, 0);
}

1;