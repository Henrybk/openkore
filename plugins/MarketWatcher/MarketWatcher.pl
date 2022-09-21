##############################
# =======================
# MarketWatcher
# =======================
# This plugin is licensed under the GNU GPL
# Created by Henrybk from openkorebrasil
#
# What it does: Opens vending shops and buys desired items.
#
# Config keys (put in config.txt):
#	MarketWatcher_on 1/0  # Activates the plugin
#
#
# Config blocks: (used to buy items)
###############################################
#
# MarketWatcher = Name of the item you want to buy.
# maxPrice = Maximum price of the item you want to buy.
# maxAmount = Amount of the item that you want to buy.
# disabled = Disables the blocks (this is set by default after a successful buying session)
#
# Example:
###############################################
#  MarketWatcher 958 {
#      maxPrice 1000
#      minAmount 10
#  }
###############################################
package MarketWatcher;

use strict;
use Plugins;
use Globals;
use Log qw(message warning error debug);
use AI;
use Misc;
use Utils qw(getFormattedDate);
use Network;
use Network::Send;
use POSIX;
use I18N qw(bytesToString stringToBytes);

Plugins::register('MarketWatcher', 'automatically buy items from merchant vendors', \&Unload);

my $base_hooks = Plugins::addHooks(
	['postloadfiles', 			\&checkConfig],
	['AI_pre',					\&AI_pre],
	['npc_chat',				\&on_npc_chat],
	['force_check_market',		\&AI_pre],
);

use constant {
	PLUGIN_NAME => 'MarketWatcher',
	RECHECK_TIMEOUT => 30,
	INACTIVE => 0,
	ACTIVE => 1
};

my $time = 0;
my %recently_checked;
my %in_AI_queue;
my $shopping_hooks;
my $status = INACTIVE;

my $lastIndex = 0;
my $lastSentID;
my $last_minAmount;
my $last_maxPrice;

sub Unload {
	Plugins::delHook($base_hooks);
	message "[".PLUGIN_NAME."] Plugin unloading or reloading.\n", 'success';
}

sub checkConfig {
	if (exists $config{'MarketWatcher_on'} && $config{'MarketWatcher_on'} == 1) {
		#message "[".PLUGIN_NAME."] Config set to '1' MarketWatcher will be active.\n", 'success';
	} else {
		#message "[".PLUGIN_NAME."] Config set to '0' MarketWatcher will be inactive.\n", 'success';
	}
}

sub AI_pre {
	my ($hook) = @_;
	return unless ($hook eq 'force_check_market' || main::timeOut($time, RECHECK_TIMEOUT));
	return unless ($config{MarketWatcher_on});
	return unless (exists $config{MarketWatcher_0});
	
	my $prefix = PLUGIN_NAME.'_';
	my $current = $lastIndex;
	my $item_prefix = $prefix.$current;
	
	warning "[".PLUGIN_NAME."] Sending WS on block $current - $config{$item_prefix}\n", "MarketWatcher", 1;
	my $msg = '@ws '.$config{$item_prefix};
	sendMessage($messageSender, 'c', $msg);
	$lastSentID = $config{$item_prefix};
	$last_minAmount = $config{$item_prefix.'_minAmount'};
	$last_maxPrice = $config{$item_prefix.'_maxPrice'};
	
	$time = time;
	my $next = $current + 1;
	if (!exists $config{$prefix.$next}) {
		$next = 0;
	}
	$lastIndex = $next;
}

my $started = 0;
my @found;

sub on_npc_chat {
	my ($hook, $args) = @_;
	return unless ($config{MarketWatcher_on});
	return unless (exists $config{MarketWatcher_0});
	return unless (defined $lastSentID);
	
	if (defined $lastSentID && $args->{message} =~ /SHOPS CONTAINING YOUR QUERY/) {
		#//==SHOPS CONTAINING YOUR QUERY===================================//
		$started = 1;
		undef @found;
		warning "[".PLUGIN_NAME."] Started QUERY for item $lastSentID\n", "MarketWatcher", 1;
		
		
	} elsif (defined $lastSentID && $started && $args->{message} =~ /END OF SEARCH RESULTS/) {
		#//==END OF SEARCH RESULTS=========================================//
		$started = 0;
		warning "[".PLUGIN_NAME."] Ended QUERY for item $lastSentID\n", "MarketWatcher", 1;
		
		@found = sort { $a->{Cost} <=> $b->{Cost} } @found;
		
		my $first = 0;
		foreach my $found (@found) {
			if ($first == 0) {
				$first = 1;
				configModify('MarketWatcher_'.$found->{id}.'_found', 1);
				configModify('MarketWatcher_'.$found->{id}.'_map', $found->{Map});
				configModify('MarketWatcher_'.$found->{id}.'_x', $found->{x});
				configModify('MarketWatcher_'.$found->{id}.'_y', $found->{y});
				configModify('MarketWatcher_'.$found->{id}.'_price', $found->{Cost});
				configModify('MarketWatcher_'.$found->{id}.'_name', $found->{Seller});
			}
			warning "[".PLUGIN_NAME."] Found item $found->{id}, sold at $found->{Cost}, quant $found->{quant}, map $found->{Map} ($found->{x} $found->{y}), by $found->{Seller}\n", "MarketWatcher", 1;
		}
		undef @found;
		
	} elsif (defined $lastSentID && $started && $args->{message} =~ /^ID (\d+) \| Cost: (\d+)z \| Qty: (\d+) \| Map: (.+) \[(\d+), (\d+)\] \| Seller: (.+)$/) {
		#ID 958 | Cost: 1350z | Qty: 26 | Map: oldnewpayon [110, 96] | Seller: arnaldo
		my %found;
		$found{id} = $1;
		$found{Cost} = $2;
		$found{quant} = $3;
		$found{Map} = $4;
		$found{x} = $5;
		$found{y} = $6;
		$found{Seller} = $7;
		return if ($found{Map} ne 'oldnewpayon' && $found{Map} ne 'aldebaran');
		if ($found{id} == $lastSentID && $found{quant} >= $last_minAmount && $found{Cost} <= $last_maxPrice) {
			push(@found, \%found);
		}
	}
	
}

return 1;

