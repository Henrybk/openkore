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
	['AI_pre',					\&AI_pre],
	['npc_chat',				\&on_npc_chat],
);

use constant {
	PLUGIN_NAME => 'MarketWatcher',
	RECHECK_TIMEOUT => 5,
	INACTIVE => 0,
	ACTIVE => 1
};

my $time = time;
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

sub AI_pre {
	return unless (main::timeOut($time, RECHECK_TIMEOUT));
	return unless ($config{PLUGIN_NAME.'_on'});
	return unless (exists $config{PLUGIN_NAME.'_0'});
	
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
	return unless ($config{PLUGIN_NAME.'_on'});
	return unless (exists $config{PLUGIN_NAME.'_0'});
	return unless (defined $lastSentID);
	
	if (defined $lastSentID && $args->{message} =~ /SHOPS CONTAINING YOUR QUERY/) {
		#//==SHOPS CONTAINING YOUR QUERY===================================//
		$started = 1;
		warning "[".PLUGIN_NAME."] Started QUERY for item $lastSentID\n", "MarketWatcher", 1;
		
		
	} elsif (defined $lastSentID && $started && $args->{message} =~ /END OF SEARCH RESULTS/) {
		#//==END OF SEARCH RESULTS=========================================//
		$started = 0;
		warning "[".PLUGIN_NAME."] Ended QUERY for item $lastSentID\n", "MarketWatcher", 1;
		
		@found = sort { $a->{Cost} <=> $b->{Cost} } @found;
		
		foreach my $found (@found) {
			warning "[".PLUGIN_NAME."] Found item $found->{id}, sold at $found->{Cost}, quant $found->{quant}, map $found->{Map} ($found->{x} $found->{y}), by $found->{Seller}\n", "MarketWatcher", 1;
		}
		
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
		if ($found{id} == $lastSentID && $found{quant} >= $last_minAmount && $found{Cost} <= $last_maxPrice) {
			push(@found, \%found);
		}
	}
	
}

return 1;

