package testnot;

use Plugins;
use Globals;
use Log qw( warning message error debug );
use Time::HiRes qw(time);
use Utils qw( existsInList getFormattedDate timeOut makeIP compactArray calcPosition distance);
use Misc;

my $pushover_timeout = 0;

sub pushover {
	my ($reason, $message, $priority) = @_;
	return if !timeOut($pushover_timeout, 15);
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


# Plugin
Plugins::register(PLUGINNAME, "", \&core_Unload, \&core_Reload);

my $commands_hooks = Commands::register(
	['testnot', 'test notification',			\&cmdTestNotification],
);

sub core_Unload {
	error("Unloading plugin...", "testnot");
	core_SafeUnload();
}

sub core_Reload {
	warning("Reloading plugin...", "testnot");
	core_SafeUnload();
}

sub core_SafeUnload {
	Commands::unregister($commands_hooks);
}

1;