##############################
# =======================
# BetterShopper v1.9
# =======================
# This plugin is licensed under the GNU GPL
# Created by Henrybk from openkorebrasil
# Based on the shopper plugin made by kaliwanagan on 2006 which was also licensed under the GNU GPL
#
# What it does: Opens vending shops and buys desired items.
#
# Config keys (put in config.txt):
#	BetterShopper_on 1/0  # Activates the plugin
#	BetterShopper_name
#
#
# Config blocks: (used to buy items)
###############################################
#
# BetterShopper = Name of the item you want to buy.
# maxPrice = Maximum price of the item you want to buy.
# maxAmount = Amount of the item that you want to buy.
#
# Example:
###############################################
#  # Awakening Potion
#	BetterShopper 656 {
#		maxPrice 1500
#		minInventoryAmount 0
#		minShopAmount 3
#		minDistance 1
#		maxDistance 10
#		maxAmount 3
#  }
###############################################
package BetterShopper;

use strict;
use Plugins;
use Globals;
use Field;
use Log qw(message warning error debug);
use AI;
use Misc;
use Utils;
use Network;
use Network::Send;
use POSIX;
use I18N qw(bytesToString stringToBytes);
use Translation qw( T TF );

Plugins::register('BetterShopper', 'automatically buy items from merchant vendors', \&Unload);

my $market_hooks = Plugins::addHooks(
	['AI_pre',					\&AI_pre_market],
	['npc_chat',				\&on_npc_chat],
	['force_check_market',		\&AI_pre_market],
);

my $shopping_hooks = Plugins::addHooks(
	['packet_vender_store2',	\&storeList],
	['packet_mapChange',		\&mapchange],
	['packet/vender_buy_fail',	\&buy_fail],
	['item_gathered',			\&possible_buy_success],
);

my $buying_hooks = Plugins::addHooks(
	['AI_pre',					\&AI_pre_buying],
);

use constant {
	MARKET_RECHECK_TIMEOUT => 10,
};

use constant {
	PLUGIN_NAME => 'BetterShopper',
	RECHECK_TIMEOUT => 30,
	OPENSHOP_DELAY => 1,
};

use constant {
	MAX_ITEM_AMOUNT => 30000,
	MAX_SHOPPING_WEIGHT_PERCENT => 89,
	MAX_INVENTORY_SIZE => 100,
};

my $time = time;

my @last_buy_log;
my @last_buyList;

sub Unload {
	Plugins::delHook($market_hooks);
	Plugins::delHook($shopping_hooks);
	Plugins::delHook($buying_hooks);
	message "[".PLUGIN_NAME."] Plugin unloading or reloading.\n", 'success';
}

sub mapchange {
	undef @last_buy_log;
	undef @last_buyList;
}

my $market_time = 0;
my $lastIndex = 0;
my $lastSentID;
my $last_minShopAmount;
my $last_maxPrice;
my $started = 0;
my @found;

my $received = 0;
my $itemList;
my $buy_sucess = 0;
my $buy_fail = 0;

my %found_best_shops;

sub AI_pre_market {
	my ($hook) = @_;
	return unless ($hook eq 'force_check_market' || main::timeOut($market_time, MARKET_RECHECK_TIMEOUT));
	return unless ($config{BetterShopper_on});
	return unless (exists $config{BetterShopper_0});
	
	my $prefix = PLUGIN_NAME.'_';
	my $current = $lastIndex;
	my $item_prefix = $prefix.$current;
	
	warning "[BetterShopper] Sending WS on block $current - $config{$item_prefix}\n", "BetterShopper", 1;
	my $msg = '@ws '.$config{$item_prefix};
	sendMessage($messageSender, 'c', $msg);
	$lastSentID = $config{$item_prefix};
	$last_minShopAmount = $config{$item_prefix.'_minShopAmount'};
	$last_maxPrice = $config{$item_prefix.'_maxPrice'};
	
	$market_time = time;
	my $next = $current + 1;
	if (!exists $config{$prefix.$next}) {
		$next = 0;
	}
	$lastIndex = $next;
}

sub on_npc_chat {
	my ($hook, $args) = @_;
	return unless ($config{BetterShopper_on});
	return unless (exists $config{BetterShopper_0});
	return unless (defined $lastSentID);
	
	if (defined $lastSentID && $args->{message} =~ /SHOPS CONTAINING YOUR QUERY/) {
		#//==SHOPS CONTAINING YOUR QUERY===================================//
		$started = 1;
		undef @found;
		delete $found_best_shops{$lastSentID};
		warning "[BetterShopper] Started QUERY for item $lastSentID\n", "BetterShopper", 1;
		
		
	} elsif (defined $lastSentID && $started && $args->{message} =~ /Nobody is selling that item at this time/) {
		#//==END OF SEARCH RESULTS=========================================//
		$started = 0;
		undef @found;
		delete $found_best_shops{$lastSentID};
		warning "[BetterShopper] No one is selling item $lastSentID\n", "BetterShopper", 1;
		return;
		
	} elsif (defined $lastSentID && $started && $args->{message} =~ /END OF SEARCH RESULTS/) {
		#//==END OF SEARCH RESULTS=========================================//
		$started = 0;
		warning "[BetterShopper] Ended QUERY for item $lastSentID\n", "BetterShopper", 1;
		
		@found = sort { $a->{Cost} <=> $b->{Cost} } @found;
		
		if (!scalar @found) {
			delete $found_best_shops{$lastSentID};
			warning "[BetterShopper] No one is selling item $lastSentID in the right amount, price and place\n", "BetterShopper", 1;
			return;
		}
		
		my $first = 0;
		foreach my $found (@found) {
			if ($first == 0) {
				$first = 1;
				$found_best_shops{$found->{id}} = $found;
				warning "[BetterShopper] Found item $found->{id}, sold at $found->{Cost}, quant $found->{quant}, map $found->{Map} ($found->{x} $found->{y}), by $found->{Seller}\n", "BetterShopper", 1;
			}
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
		if ($found{id} == $lastSentID && $found{quant} >= $last_minShopAmount && $found{Cost} <= $last_maxPrice) {
			push(@found, \%found);
		}
	}
	
}

sub AI_pre_buying {
	if (
		   $char->inventory->isReady()
		&& (AI::isIdle || AI::action eq "route" || AI::action eq "move")
		&& !AI::inQueue("attack")
		&& !AI::inQueue("storageAuto")
		&& !AI::inQueue("buyAuto")
		&& !AI::inQueue("sellAuto")
		&& !AI::inQueue("teleport", "NPC")
		&& !AI::inQueue("skill_use")
		&& !AI::inQueue("eventMacro")
		&& !AI::inQueue("Shopping")
		&& main::timeOut($timeout{'Shopping'})
		&& (scalar keys %found_best_shops)
	) {
		
		my $i = 0;
		my $bai;
		my $tprice;
		for($i = 0; exists $config{"BetterShopper_$i"}; $i++) {
			next if (!$config{"BetterShopper_$i"} || $config{"BetterShopper_${i}_disabled"});
			
			my $amount;
			my $cart_amount;
			
			if ($config{"BetterShopper_$i"} =~ /^\d{3,}$/) {
				$amount = $char->inventory->sumByNameID($config{"BetterShopper_$i"}, $config{"BetterShopper_${i}_onlyIdentified"});
				$cart_amount = $char->cart->sumByNameID($config{"BetterShopper_$i"});
			} else {
				$amount = $char->inventory->sumByName($config{"BetterShopper_$i"}, $config{"BetterShopper_${i}_onlyIdentified"});
				$cart_amount = $char->cart->sumByName($config{"BetterShopper_$i"});
			}
			my $char_total = $amount + $cart_amount;
			
			if (
				$config{"BetterShopper_$i"."_minInventoryAmount"} ne "" &&
				$config{"BetterShopper_$i"."_maxAmount"} ne "" &&
				$char_total <= $config{"BetterShopper_$i"."_minInventoryAmount"} &&
				$char_total < $config{"BetterShopper_$i"."_maxAmount"} &&
				exists $found_best_shops{$config{"BetterShopper_$i"}} &&
				$found_best_shops{$config{"BetterShopper_$i"}}
			) {
				my $amount_want = $config{"BetterShopper_$i"."_maxAmount"};
				my $amount_have = $char_total;
				my $amount_need_buy = $amount_want - $amount_have;
				my $price_per_amount = $found_best_shops{$config{"BetterShopper_$i"}}{Cost};
				my $total_price = $price_per_amount * $amount_need_buy;
				
				if ($char->{zeny} >= $total_price) {
					$bai = $i;
					$tprice = $total_price;
					last;
				}
			}
		}
		return unless (defined $bai);
		AI::clear("move");
		AI::clear("route");
		AI::queue("Shopping", { Better_index => $bai, item => $config{"BetterShopper_$bai"}, needed_zeny => $tprice });
		$buy_sucess = 0;
		$buy_fail = 0;
		$timeout{'Shopping'}{'time'} = time;
		$timeout{'Shopping'}{'timeout'} = 1;
	}

	if (AI::action eq "Shopping" && AI::args->{'done'}) {

		if (exists AI::args->{'error'}) {
			error AI::args->{'error'}.".\n";
		}

		# Shopping finished
		AI::dequeue while AI::inQueue("Shopping");

	} elsif (AI::action eq "Shopping") {
		my $args = AI::args;
		
		$args->{index} = $args->{Better_index};
		#$args->{needed_zeny}
		my $prefixN = "BetterShopper_".$args->{Better_index};
		my $prefix = $config{$prefixN};
		
		if (!exists $found_best_shops{$prefix}) {
			$args->{'error'} = 'Store does not exist anymore';
			$args->{'done'} = 1;
			return;
		}
		
		if ($args->{'seller'} && $found_best_shops{$prefix}{'Seller'} ne $args->{'seller'}{'name'}) {
			$args->{'error'} = "[$prefix] Best seller changed name";
			$args->{'done'} = 1;
			return;
		}
		
		if ($args->{'seller'} && ($found_best_shops{$prefix}{'x'} != $args->{'seller'}{'pos'}{'x'} || $found_best_shops{$prefix}{'y'} != $args->{'seller'}{'pos'}{'y'})) {
			$args->{'error'} = "[$prefix] Best seller changed position";
			$args->{'done'} = 1;
			return;
		}
		
		if ($args->{'seller'} && $found_best_shops{$prefix}{'Cost'} ne $args->{'seller'}{'Cost'}) {
			$args->{'error'} = "[$prefix] Best seller changed Cost";
			$args->{'done'} = 1;
			return;
		}
		
		if ($buy_sucess == 1) {
			Log::warning "Sucesssssss CARAIO!!!\n";
			$args->{'done'} = 1;
			return;
		}
		
		if ($buy_fail == 1) {
			$args->{'error'} = "[$prefix] Buy failed";
			$args->{'done'} = 1;
			return;
		}
		
		if (!exists $args->{sentBuyPacket_time} && $char->{zeny} < $args->{needed_zeny}) {
			$args->{'error'} = 'We do not have enough zeny anymore';
			$args->{'done'} = 1;
			return;
		}
		
		if (exists $args->{sentBuyPacket_time}) {
			if (
				timeOut($args->{sentBuyPacket_time}, 5) &&
				!$buy_sucess &&
				!$buy_fail
			) {
				$args->{'error'} = 'Did not received the buy result from server after buy packet was sent';
				$args->{'done'} = 1;
			}
			return;
		}

		if (!exists $args->{lastIndex}) {
			$args->{'seller'}{'map'} = $found_best_shops{$prefix}{Map};
			$args->{'seller'}{'pos'}{'x'} = $found_best_shops{$prefix}{x};
			$args->{'seller'}{'pos'}{'y'} = $found_best_shops{$prefix}{y};
			$args->{'seller'}{'name'} = $found_best_shops{$prefix}{Seller};
			$args->{'seller'}{'Cost'} = $found_best_shops{$prefix}{Cost};
			$args->{'seller'}{'id'} = $found_best_shops{$prefix}{id};
			
			#use Data::Dumper;
			#warning "found: ".Dumper \%found_best_shops;
			#warning "args: ".Dumper $args;

			# Failed to load any slots for Shopping (we're done or they're all invalid)
			if (!defined $args->{index}) {
				$args->{'done'} = 1;
				return;
			}

			undef $ai_v{'temp'}{'do_route'};
			if (!$args->{distance}) {
				# Calculate variable or fixed (old) distance
				if ($config{"BetterShopper_".$args->{index}."_minDistance"} && $config{"BetterShopper_".$args->{index}."_maxDistance"}) {
					$args->{distance} = $config{"BetterShopper_$args->{index}"."_minDistance"} + round(rand($config{"BetterShopper_$args->{index}"."_maxDistance"} - $config{"BetterShopper_$args->{index}"."_minDistance"}));
				}
			}

			if ($field->baseName ne $args->{'seller'}{'map'}) {
				$ai_v{'temp'}{'do_route'} = 1;
			} else {
				my $found = 0;
				foreach my $vender_index (0..$#venderListsID) {
					my $venderID = $venderListsID[$vender_index];
					next unless (defined $venderID);
					my $vender = $venderLists{$venderID};
					my $name = get_player_name($venderID);
					if ($args->{'seller'}{'name'} eq $name) {
						debug "[".PLUGIN_NAME."] Adding shop '".$vender->{'title'}."' of player '$name' to AI queue check list from $config{BetterShopper_name}.\n", "shopper", 1;
						$found = 1;
						last;
					}
				}
				unless ($found) {
					$ai_v{'temp'}{'do_route'} = 1;
				}
			}

			if ($ai_v{'temp'}{'do_route'}) {

				my $msgneeditem;
				if ($args->{'seller'}{'id'}) {
					$msgneeditem = "Auto-buy: $args->{'seller'}{'id'}\n";
				}
				message TF($msgneeditem."Calculating Shopping route to: %s (%s): %s, %s\n", $maps_lut{$args->{'seller'}{map}.'.rsw'}, $args->{'seller'}{map}, $args->{'seller'}{pos}{x}, $args->{'seller'}{pos}{y}), "route";
				ai_route(
					$args->{'seller'}{map}, $args->{'seller'}{pos}{x}, $args->{'seller'}{pos}{y},
					attackOnRoute => 1,
					distFromGoal => $args->{distance}
				);
				return;
			}
		}

		if (!exists $args->{lastIndex}) {
			$args->{lastIndex} = $args->{index};
			return;

		} elsif (!exists $args->{'sentOpenShop'}) {

			my $found = 0;
			foreach my $vender_index (0..$#venderListsID) {
				my $venderID = $venderListsID[$vender_index];
				next unless (defined $venderID);
				my $vender = $venderLists{$venderID};
				my $name = get_player_name($venderID);
				if ($args->{'seller'}{'name'} eq $name) {
					debug "[".PLUGIN_NAME."] Openning shop '".$vender->{'title'}."' of player ".get_player_name($venderID).".\n", "shopper", 1;
					$received = 0;
					undef $itemList;
					$buy_sucess = 0;
					$buy_fail = 0;
					$messageSender->sendEnteringVender($venderID);
					last;
				}
			}

			$args->{'sentOpenShop'} = 1;
			$args->{'sentOpenShop_time'} = time;

			return;

		} elsif ($received == 0) {
			if (main::timeOut($args->{'sentOpenShop_time'}, 7)) {
				$args->{'error'} = 'Store did not respond';
				$args->{'done'} = 1;
			}
			return;

		} elsif (!exists $args->{'recv_buyList_time'}) {
			$args->{'recv_buyList_time'} = time;
			return;

		} else {
			return unless (main::timeOut($args->{'recv_buyList_time'}, 2));
		}
		
		undef @last_buy_log;
		undef @last_buyList;
		
		my @current_buy_log;
		my @current_buyList;
		
		my $current_zeny = $char->{zeny};
		my $current_weight = $char->{weight};
		my $weight_cap = ($char->{weight_max}*(MAX_SHOPPING_WEIGHT_PERCENT/100));
		
		my $current_inv_size = $char->inventory->size();
		
		my %bought;
		
		foreach my $item (@{$itemList}) {
			my $price = $item->{price};
			my $name = $item->{name};
			my $nameID = $item->{nameID};
			my $index = $item->{ID};
			my $store_amount = $item->{amount};
			
			next unless ($nameID == $args->{'seller'}{'id'});
			next unless ($price <= $args->{'seller'}{'Cost'});
			
			my $item_prefix = $prefixN;
			
			my $maxPrice = $config{$item_prefix."_maxPrice"};
			my $maxAmount = $config{$item_prefix."_maxAmount"};
			
			my $inv_amount = $char->inventory->sumByNameID($nameID);
			next if ($inv_amount == MAX_ITEM_AMOUNT);
			
			my $cart_amount = $char->cart->sumByNameID($nameID);
			my $char_total = $inv_amount + $cart_amount;
			next unless ($char_total < $maxAmount);
			
			my $buy_amount = (exists $bought{$name} ? $bought{$name} : 0);
			
			my $max_wanted = (($maxAmount - $char_total) - $buy_amount);

			
			my $max_possible_buy_by_store_amount = $store_amount >= $max_wanted ? $max_wanted : $store_amount;
			
			my $max_possible_buy_by_zeny;
			
			if ($price == 0) {
				$max_possible_buy_by_zeny = $max_possible_buy_by_store_amount
			} else {
				my $max_zeny_can_buy = floor($current_zeny / $price);
				$max_possible_buy_by_zeny = $max_possible_buy_by_store_amount > $max_zeny_can_buy ? $max_zeny_can_buy : $max_possible_buy_by_store_amount;
			}
			
			my $max_possible_buy_by_inventory_amount = (($max_possible_buy_by_zeny + $inv_amount) > MAX_ITEM_AMOUNT) ? (MAX_ITEM_AMOUNT - $inv_amount) : $max_possible_buy_by_zeny;
			
			my $max_possible_buy_by_weight_percent;
			my $item_weight = $item->weight;
			if (defined $item_weight) {
				$item_weight = $item_weight/10;
				$max_possible_buy_by_weight_percent = ((($max_possible_buy_by_inventory_amount * $item_weight) + $current_weight) > $weight_cap) ? (floor($weight_cap - $current_weight/$item_weight)) : $max_possible_buy_by_inventory_amount;
			} else {
				$max_possible_buy_by_weight_percent = $max_possible_buy_by_inventory_amount;
			}
			
			my $will_buy = $max_possible_buy_by_weight_percent >= $max_wanted ? $max_wanted : $max_possible_buy_by_weight_percent;
			next if ($will_buy == 0);
			
			message "[".PLUGIN_NAME."] Found item $name with good price! Price is $price, max price for it is ".$maxPrice."! The store has $store_amount of it, with our zeny we can buy $max_possible_buy_by_zeny, store amount limits us by $max_possible_buy_by_store_amount, inventory amount by $max_possible_buy_by_inventory_amount, and char weight by $max_possible_buy_by_weight_percent. Buying $will_buy of it!\n";
			
			my $zeny_wasted = $will_buy * $price;
			$current_zeny -= $zeny_wasted;
			
			my $weight_gained = $will_buy * $item_weight;
			$current_weight += $weight_gained;
			$current_inv_size++;
			
			$bought{$name} += $will_buy;
			
			my %buy = (
				itemIndex => $index,
				amount    => $will_buy,
			);
			
			push(@current_buyList, \%buy);
			
			my $buy_string = "[".getFormattedDate(int(time))."] ". $name ." - ". $will_buy ." - ". $price ." - ". get_player_name($venderID) ."\n";
			
			my %buy_log = (
				string   => $buy_string,
				name     => $name,
				venderID => $args->{venderID},
			);
			
			push(@current_buy_log, \%buy_log);
			
			last if ($current_inv_size == MAX_INVENTORY_SIZE);
		}
		
		if (!scalar @current_buyList) {
			$args->{'error'} = 'Did not find anything to buy in store';
			$args->{'done'} = 1;
			return;
		}
		
		@last_buyList = @current_buyList;
		@last_buy_log = @current_buy_log;
		
		#$messageSender->sendBuyBulkVender($venderID, \@current_buyList, $venderCID);
		message "[".PLUGIN_NAME."] Sent Buy!\n";
			
		delete $args->{'sentOpenShop'};
		delete $args->{'sentOpenShop_time'};
		delete $args->{'recv_buyList_time'};
		
		$args->{sentBuyPacket_time} = time;
	}
}

sub get_player_name {
	my ($ID) = @_;
	my $player = Actor::get($ID);
	my $name = $player->name;
	return $name;
}

# we're currently inside a store if we receive this packet
sub storeList {
	my ($packet, $args) = @_;
	
	return unless (AI::action eq "Shopping");
	my $ai_args = AI::args;
	return unless (exists $ai_args->{'seller'});
	my $pname = get_player_name($args->{venderID});
	return unless ($pname eq $ai_args->{'seller'}{'name'});
	$received = 1;
	$itemList = \@{$args->{itemList}->getItems};
	
	warning "[test] Received Correct item list\n";
}

sub buy_fail {
	my ($packet, $args) = @_;
	
	return unless (@last_buyList); # should never happen
	
	# Error messages for the items we could not buy
	my $ID;
	foreach my $item_index (0..$#last_buyList) {
		my $log = $last_buy_log[$item_index];
		$ID = $log->{venderID};
		error "[".PLUGIN_NAME."] Failed to buy ".$log->{name}.".\n";
	}
	
	# Re-add the shop to the top of the list if we could still want something from it
	return unless ($args->{fail} == 4);
	$buy_fail = 1;
}

sub possible_buy_success {
	my ($packet, $args) = @_;
	return unless (@last_buyList);
	my $item_name = $args->{item};
	my $amount = $args->{amount};
	
	my $found_index;
	foreach my $possible_item_index (0..$#last_buyList) {
		my $possible_item = $last_buyList[$possible_item_index];
		my $possible_item_log = $last_buy_log[$possible_item_index];
		if ($possible_item_log->{name} eq $item_name && $possible_item->{amount} eq $amount) {
			# We were able to buy the item
			message "[".PLUGIN_NAME."] Successfully bought ".$possible_item_log->{name}.".\n";
			writter_bought($possible_item_log->{string});
			$found_index = $possible_item_index;
			last;
		}
	}
	return unless (defined $found_index);
	$buy_sucess = 1;
	splice(@last_buyList, $found_index, 1);
	splice(@last_buy_log, $found_index, 1);
}

sub writter_bought {
	my ($args, $self) = @_;
	my $tmp = "$Settings::logs_folder/Shopper.txt";
	
	open my $out, '>>:utf8', $tmp or die "Erro ao Abrir Arquivo";
	print $out "[".getFormattedDate(int(time))."] $args  \n";
	warning "$args \n";
	close $out;
}
	


return 1;

