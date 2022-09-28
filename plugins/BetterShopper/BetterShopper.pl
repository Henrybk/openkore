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
#	BetterShopper_on 1
#	BetterShopper_minDistance 1
#	BetterShopper_maxDistance 10
#
#
#	BetterSeller_on 1
#	BetterSeller_minDistance 1
#	BetterSeller_maxDistance 10
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
#
#		# Awakening Potion
#		BetterShopper 656 {
#			price 1500
#			maxPrice 1400
#			minInventoryAmount 0
#			minShopAmount 2
#			maxAmount 2
#			fallbackNpc aldeba_in 94 56
#		}
#		
#		# Strawberry
#		BetterSeller 578 {
#			minPrice 900
#			minBuyShopAmount 3
#		}
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

my $basic_hooks = Plugins::addHooks(
	['AI_pre',					\&AI_pre],
);

my $market_hooks = Plugins::addHooks(
	['npc_chat',				\&on_npc_chat],
	['force_check_market',		\&on_force_check_market],
	['check_market_found',		\&check_market_found],
);

my $shopping_hooks = Plugins::addHooks(
	['packet_vender_store2',	\&storeList],
	['packet/vender_buy_from_player_fail',	\&buy_from_player_fail],
	['item_gathered',			\&possible_buy_success],
);

my $buying_hooks = Plugins::addHooks(
	['buy_result',				\&on_buy_result],
);

my $buying_store_hooks = Plugins::addHooks(
	['packet_buying_store2',		\&buying_store_item_list],
	['packet/buying_store_fail',	\&buying_store_fail],
	['packet_pre/buying_store_item_delete',	\&buying_store_item_delete],
);

my $extra_hooks = Plugins::addHooks(
	['packet_mapChange',							\&mapchange],
	['AI_storage_auto_weight_start',				\&manage_storage_buy_sell_hooks],
	['AI_storage_auto_get_auto_start',				\&manage_storage_buy_sell_hooks],
	['AI_sell_auto_start',							\&manage_storage_buy_sell_hooks],
	['AI_buy_auto_start',							\&manage_storage_buy_sell_hooks],
	['AI_storage_auto_queued',						\&storage_buy_sell_clear_route],
	['AI_sell_auto_queued',							\&sell_queue],
	['AI_buy_auto_queued',							\&storage_buy_sell_clear_route],
);

my $storage_hooks = Plugins::addHooks(
	['AI_storage_done_after_getAuto',							\&AI_storage_done_after_getAuto],
);

my $commands_hooks = Commands::register(
	['ds', '',			\&cmdDS],
);

use constant {
	QUERY_TIMEOUT => 2,
	MARKET_RECHECK_TIMEOUT => 10,
	MARKET_RECHECK_BUY => 5,
	PLUGIN_NAME => 'BetterShopper',
	RECHECK_TIMEOUT => 10,
	MAX_ITEM_AMOUNT => 30000,
	MAX_SHOPPING_WEIGHT_PERCENT => 89,
	MAX_INVENTORY_SIZE => 100,
};

my @last_seller_buy_log;
my @last_seller_buyList;
my @last_buyer_buy_log;
my @last_buyer_buyList;

sub Unload {
	Plugins::delHook($basic_hooks);
	Plugins::delHook($market_hooks);
	Plugins::delHook($shopping_hooks);
	Plugins::delHook($buying_hooks);
	Plugins::delHook($extra_hooks);
	Plugins::delHook($buying_store_hooks);
	Plugins::delHook($storage_hooks);
	Commands::unregister($commands_hooks);
	message "[".PLUGIN_NAME."] Plugin unloading or reloading.\n", 'success';
}

sub mapchange {
	undef @last_seller_buy_log;
	undef @last_seller_buyList;
	undef @last_buyer_buy_log;
	undef @last_buyer_buyList;
}

my $query_time = 0;


my @sellers_query_queue;
my $market_time_seller = 0;
my $last_Shopper_seller_index = 0;
my $last_sell_query_item_id;
my $last_sell_query_minShopAmount;
my $last_sell_query_maxPrice;
my @sellers_found;
my %found_best_seller_shops;
my %last_recv_seller_query_time;
my $received_shop_list = 0;
my $itemList;
my $buy_from_player_sucess = 0;
my $buy_from_player_fail = 0;

my %shopper_npc_fallback_items;
my $buy_fallback_sucess = 0;
my $buy_fallback_fail = 0;

my @buyers_query_queue;
my $market_time_buyer = 0;
my $last_Shopper_buyer_index = 0;
my $last_buy_query_item_id;
my $last_buy_query_minBuyShopAmount;
my $last_buy_query_minPrice;
my @buyers_found;
my %found_best_buyer_shops;
my %last_recv_buyer_query_time;

my $received_start = 0;
my $received_first_item = 0;
my $receiving_Wbuy = 0;
my $receiving_Wsell = 0;

my $started_checking = 0;
my $ended_cheking = 0;
my $last_checked_id_bestSeller = 0;
my $current_buyer_item_id;

my $sell_to_player_sucess = 0;
my $sell_to_player_fail = 0;
my $received_buyshop_list = 0;
my $buystore_itemList;

sub GetItemName {
	my $itemID = shift;

	my $name = itemNameSimple($itemID);
	
	my $numSlots = $itemSlotCount_lut{$itemID};
	
	$name .= " [$numSlots]" if $numSlots;
	
	return $name;
}

sub manage_storage_buy_sell_hooks {
	my ($hook, $args) = @_;
	if(AI::inQueue("eventMacro", "Shopping", "Shopping_fallBack", "determine_selling", "BetterSeller", "teleport", "NPC", "skill_use")) {
		$args->{return} = 1;
	}
}

sub storage_buy_sell_clear_route {
	AI::clear("move", "route", "checkMonsters", "attack");
}

sub AI_pre {
	AI_pre_market();
	AI_pre_buying();
	AI_pre_fallback();
	AI_pre_buyer();
	AI_pre_determine_selling();
	AI_pre_selling();
}

sub sell_queue {
	AI::clear("move", "route", "checkMonsters", "attack");
	AI::clear("sellAuto");
	AI::queue("determine_selling");
}

sub cmdDS {
	AI::clear();
	AI::queue("determine_selling");
}

my $get_item;

sub AI_storage_done_after_getAuto {
	my ($hook, $retargs) = @_;
	
	#warning "[BetterSeller - Storage] AI_storage_done_after_getAuto\n";
	
	my $args = AI::args;
	return if ($args->{'forcedBySell'} == 1);
	
	$retargs->{return} = 1;
	
	if (!defined $get_item) {
		#warning "[BetterSeller - Storage] determine getting\n";
		
		my $prefix = 'BetterSeller_';
		my $item;
		if (!defined $current_buyer_item_id) {
			$started_checking = 0;
			$ended_cheking = 0;
			my $current_index = $last_checked_id_bestSeller;
			while (exists $config{$prefix.$current_index}) {
				if (defined $config{$prefix.$current_index}) {
					$item = $char->storage->getByNameID($config{$prefix.$current_index});
					if (defined $item) {
						$current_buyer_item_id = $config{$prefix.$current_index};
						warning "[BetterSeller - Storage] Next Query item: $current_buyer_item_id\n";
						last;
					}
				}
				
				
			} continue {
				$current_index++;
			}
			
			if (!defined $current_buyer_item_id) {
				warning "[BetterSeller - Storage] Ended\n";
				$retargs->{return} = 0;
				$last_checked_id_bestSeller = 0;
				return;
			}
			
			$last_checked_id_bestSeller = $current_index;
		}
		my $item_prefix = $prefix.$last_checked_id_bestSeller;
		
		
		$timeout{'ai_determine_selling'}{'time'} = time;
		$timeout{'ai_determine_selling'}{'timeout'} = 1;
		
		if (!$started_checking) {
			$started_checking = 1;
			push(@buyers_query_queue, $item_prefix);
			warning "[BetterSeller - Storage] Started Querying item $current_buyer_item_id.\n";
			
		} elsif ($started_checking && !$ended_cheking && @buyers_query_queue) {
			#warning "[BetterSeller - Storage] Still Querying, item $current_buyer_item_id.\n";
			
		} elsif ($started_checking && !$ended_cheking && !@buyers_query_queue && (!exists $last_recv_buyer_query_time{$current_buyer_item_id} || main::timeOut($last_recv_buyer_query_time{$current_buyer_item_id}, 60))) {
			#warning "[BetterSeller - Storage] Queryed item $current_buyer_item_id, waiting for answer.\n";
			
		} elsif ($started_checking && !$ended_cheking && !@buyers_query_queue && exists $last_recv_buyer_query_time{$current_buyer_item_id} && !main::timeOut($last_recv_buyer_query_time{$current_buyer_item_id}, 60)) {
			$ended_cheking = 1;
			warning "[BetterSeller - Storage] Ended Querying item $current_buyer_item_id.\n";
			$query_time = 0;
			$market_time_buyer = 0;
		}
		
		return unless ($ended_cheking);
		
		warning "[BetterSeller - Storage] after ended_cheking\n";
		
		if (!exists $found_best_buyer_shops{$current_buyer_item_id}) {
			warning "[BetterSeller - Storage] We have item $current_buyer_item_id but no one is buying it at a good price\n";
			undef $current_buyer_item_id;
			$last_checked_id_bestSeller++; #WTF?
			return;
		}
		
		warning "[BetterSeller - Storage] -- Setting getting for item ".$current_buyer_item_id."\n";
		$get_item = $current_buyer_item_id;
		$args->{retry} = 0;
	}

	my %item;
	my $invItem = $char->inventory->getByNameID($current_buyer_item_id);
	my $invAmount = $char->inventory->sumByNameID($current_buyer_item_id);
	my $storeItem = $char->storage->getByNameID($current_buyer_item_id);
	my $storeAmount = $char->storage->sumByNameID($current_buyer_item_id);
	
	$item{name} = $current_buyer_item_id;
	$item{inventory}{index} = $invItem ? $invItem->{binID} : undef;
	$item{inventory}{amount} = $invItem ? $invAmount : 0;
	$item{storage}{index} = $storeItem ? $storeItem->{binID} : undef;
	$item{storage}{amount} = $storeItem ? $storeAmount : 0;
	$item{max_amount} = $found_best_buyer_shops{$current_buyer_item_id}{quant};
	$item{amount_needed} = $item{max_amount} - $item{inventory}{amount};

	# Calculate the amount to get
	if ($item{amount_needed} > 0) {
		$item{amount_get} = ($item{storage}{amount} >= $item{amount_needed})? $item{amount_needed} : $item{storage}{amount};
	}

	# Try at most 3 times to get the item
	if (($item{amount_get} > 0) && ($args->{retry} < 3)) {

		$messageSender->sendStorageGet($storeItem->{ID}, $item{amount_get});
		$timeout{ai_storageAuto}{time} = time;
		$args->{retry}++;
		return;

		# we don't inc the index when amount_get is more then 0, this will enable a way of retrying
		# on next loop if it fails this time
	}

	# We got the item, or we tried 3 times to get it, but failed.
	undef $current_buyer_item_id;
	$last_checked_id_bestSeller++; #WTF?
	undef $get_item;
}

sub AI_pre_determine_selling {
	if (AI::action eq "determine_selling" && timeOut($timeout{'ai_determine_selling'}) && $char->inventory->isReady()) {
		
		#warning "[BetterSeller] determine_selling start\n";
		
		my $prefix = 'BetterSeller_';
		if (!defined $current_buyer_item_id) {
			$started_checking = 0;
			$ended_cheking = 0;
			my $current_index = $last_checked_id_bestSeller;
			while (exists $config{$prefix.$current_index}) {
				if (defined $config{$prefix.$current_index}) {
					my $item = $char->inventory->getByNameID($config{$prefix.$current_index});
					if (defined $item) {
						$current_buyer_item_id = $config{$prefix.$current_index};
						warning "[BetterSeller] Next Query item: $current_buyer_item_id\n";
						last;
					}
				}
			} continue {
				$current_index++;
			}
			if (!defined $current_buyer_item_id) {
				warning "[BetterSeller] Ended determine_selling logic\n";
				AI::clear("determine_selling");
				warning "[BetterSeller] Returning to sellauto\n";
				AI::queue("sellAuto");
				$last_checked_id_bestSeller = 0;
				return;
			}
			$last_checked_id_bestSeller = $current_index;
		}
		my $item_prefix = $prefix.$last_checked_id_bestSeller;
		$timeout{'ai_determine_selling'}{'time'} = time;
		$timeout{'ai_determine_selling'}{'timeout'} = 1;
		
		if (!$started_checking) {
			$started_checking = 1;
			push(@buyers_query_queue, $item_prefix);
			warning "[BetterSeller] Started Querying item $current_buyer_item_id.\n";
			
		} elsif ($started_checking && !$ended_cheking && @buyers_query_queue) {
			#warning "[BetterSeller] Still Querying, item $current_buyer_item_id.\n";
			
		} elsif ($started_checking && !$ended_cheking && !@buyers_query_queue && (!exists $last_recv_buyer_query_time{$current_buyer_item_id} || main::timeOut($last_recv_buyer_query_time{$current_buyer_item_id}, 60))) {
			#warning "[BetterSeller] Queryed item $current_buyer_item_id, waiting for answer.\n";
			
		} elsif ($started_checking && !$ended_cheking && !@buyers_query_queue && exists $last_recv_buyer_query_time{$current_buyer_item_id} && !main::timeOut($last_recv_buyer_query_time{$current_buyer_item_id}, 60)) {
			$ended_cheking = 1;
			warning "[BetterSeller] Ended Querying item $current_buyer_item_id.\n";
		}
		
		return unless ($ended_cheking);
		
		warning "[BetterSeller] after ended_cheking\n";
		
		if (!exists $found_best_buyer_shops{$current_buyer_item_id}) {
			warning "[BetterSeller] We have item $current_buyer_item_id but no one is buying it at a good price\n";
			undef $current_buyer_item_id;
			$last_checked_id_bestSeller++; #WTF?
			return;
		}
		
		warning "[BetterSeller] -- Setting seller for item ".$current_buyer_item_id."\n";
		my $tprice = $found_best_buyer_shops{$current_buyer_item_id}{Cost};
		
		AI::clear("move", "route", "checkMonsters", "determine_selling");
		AI::queue("BetterSeller", { BetterSeller_index => $last_checked_id_bestSeller, item => $current_buyer_item_id, price => $tprice });
		$sell_to_player_sucess = 0;
		$sell_to_player_fail = 0;
		undef $current_buyer_item_id;
		$last_checked_id_bestSeller++; #WTF?
	}
}

sub AI_pre_selling {
	if (AI::action eq "BetterSeller" && AI::args->{'done'}) {
		
		warning "[BetterSeller] AI Done\n";
		
		my $args = AI::args;
		my $prefixN = "BetterSeller_".$args->{BetterSeller_index};
		my $prefix = $config{$prefixN};

		if (exists AI::args->{'error'}) {
			error AI::args->{'error'}.".\n";
		}

		# BetterSeller finished
		AI::dequeue while AI::inQueue("BetterSeller");
		AI::queue("determine_selling");

	} elsif (AI::action eq "BetterSeller") {
		
		my $args = AI::args;
		
		$args->{index} = $args->{BetterSeller_index};
		#$args->{price}
		my $prefixN = "BetterSeller_".$args->{BetterSeller_index};
		my $prefix = $config{$prefixN};
		
		if (!exists $found_best_buyer_shops{$prefix}) {
			$args->{'error'} = 'Store does not exist anymore';
			$args->{'done'} = 1;
			return;
		}
		
		if ($args->{'buyer'} && $found_best_buyer_shops{$prefix}{'Buyer'} ne $args->{'buyer'}{'name'}) {
			$args->{'error'} = "[$prefix] Best buyer changed name";
			$args->{'done'} = 1;
			return;
		}
		
		if ($args->{'buyer'} && ($found_best_buyer_shops{$prefix}{'x'} != $args->{'buyer'}{'pos'}{'x'} || $found_best_buyer_shops{$prefix}{'y'} != $args->{'buyer'}{'pos'}{'y'})) {
			$args->{'error'} = "[$prefix] Best buyer changed position";
			$args->{'done'} = 1;
			return;
		}
		
		if ($args->{'buyer'} && $found_best_buyer_shops{$prefix}{'Cost'} ne $args->{'buyer'}{'Cost'}) {
			$args->{'error'} = "[$prefix] Best buyer changed Cost";
			$args->{'done'} = 1;
			return;
		}
		
		if ($sell_to_player_sucess == 1) {
			Log::warning "Sucesssssss CARAIO!!!\n";
			$args->{'done'} = 1;
			return;
		}
		
		if ($sell_to_player_fail == 1) {
			$args->{'error'} = "[$prefix] Sell failed";
			$args->{'done'} = 1;
			return;
		}
		
		if (exists $args->{sentBuyPacket_time}) {
			if (
				timeOut($args->{sentBuyPacket_time}, 5) &&
				!$sell_to_player_sucess &&
				!$sell_to_player_fail
			) {
				$args->{'error'} = 'Did not received the sell result from server after sell packet was sent';
				$args->{'done'} = 1;
			}
			return;
		}

		if (!exists $args->{lastIndex}) {
			$args->{'buyer'}{'map'} = $found_best_buyer_shops{$prefix}{Map};
			$args->{'buyer'}{'pos'}{'x'} = $found_best_buyer_shops{$prefix}{x};
			$args->{'buyer'}{'pos'}{'y'} = $found_best_buyer_shops{$prefix}{y};
			$args->{'buyer'}{'name'} = $found_best_buyer_shops{$prefix}{Buyer};
			$args->{'buyer'}{'Cost'} = $found_best_buyer_shops{$prefix}{Cost};
			$args->{'buyer'}{'id'} = $found_best_buyer_shops{$prefix}{id};
			
			#use Data::Dumper;
			#warning "found: ".Dumper \%found_best_buyer_shops;
			#warning "args: ".Dumper $args;

			# Failed to load any slots for BetterSeller (we're done or they're all invalid)
			if (!defined $args->{index}) {
				$args->{'done'} = 1;
				return;
			}

			undef $ai_v{'temp'}{'do_route'};
			if (!$args->{distance}) {
				# Calculate variable or fixed (old) distance
				if ($config{"BetterSeller_minDistance"} && $config{"BetterSeller_maxDistance"}) {
					$args->{distance} = $config{"BetterSeller_minDistance"} + round(rand($config{"BetterSeller_maxDistance"} - $config{"BetterSeller_minDistance"}));
				}
			}

			if ($field->baseName ne $args->{'buyer'}{'map'}) {
				$ai_v{'temp'}{'do_route'} = 1;
			} else {
				my $found = 0;
				foreach my $buyer_index (0..$#buyerListsID) {
					my $buyerID = $buyerListsID[$buyer_index];
					next unless (defined $buyerID);
					my $buyer = $venderLists{$buyerID};
					my $name = get_player_name($buyerID);
					if ($args->{'buyer'}{'name'} eq $name) {
						debug "[BetterSeller] Adding shop '".$buyer->{'title'}."' of player '$name' to AI queue check list from $config{BetterSeller_name}.\n", "shopper", 1;
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
				if ($args->{'buyer'}{'id'}) {
					$msgneeditem = "Auto-buy: $args->{'buyer'}{'id'}\n";
				}
				message TF($msgneeditem."Calculating BetterSeller route to: %s (%s): %s, %s\n", $maps_lut{$args->{'buyer'}{map}.'.rsw'}, $args->{'buyer'}{map}, $args->{'buyer'}{pos}{x}, $args->{'buyer'}{pos}{y}), "route";
				ai_route(
					$args->{'buyer'}{map}, $args->{'buyer'}{pos}{x}, $args->{'buyer'}{pos}{y},
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

			foreach my $buyer_index (0..$#buyerListsID) {
				my $buyerID = $buyerListsID[$buyer_index];
				next unless (defined $buyerID);
				my $buyer = $venderLists{$buyerID};
				my $name = get_player_name($buyerID);
				if ($args->{'buyer'}{'name'} eq $name) {
					debug "[BetterSeller] Openning buyshop '".$buyer->{'title'}."' of player ".get_player_name($buyerID).".\n", "shopper", 1;
					$received_buyshop_list = 0;
					undef $buystore_itemList;
					$sell_to_player_sucess = 0;
					$sell_to_player_fail = 0;
					$messageSender->sendEnteringBuyer($buyerID);
					last;
				}
			}

			$args->{'sentOpenShop'} = 1;
			$args->{'sentOpenShop_time'} = time;

			return;

		} elsif ($received_buyshop_list == 0) {
			if (main::timeOut($args->{'sentOpenShop_time'}, 7)) {
				$args->{'error'} = 'BuyStore did not respond';
				$args->{'done'} = 1;
			}
			return;

		} elsif (!exists $args->{'recv_buyList_time'}) {
			warning "[BetterSeller] Confirmed the receiving of buystore list in AI\n";
			$args->{'recv_buyList_time'} = time;
			return;

		} else {
			return unless (main::timeOut($args->{'recv_buyList_time'}, 2));
		}
		
		warning "[BetterSeller] Starting item sell logic\n";
		
		undef @last_buyer_buy_log;
		undef @last_buyer_buyList;
		
		my @current_sell_log;
		my @current_sellList;
		
		foreach my $item (@{$buystore_itemList}) {
			my $price = $item->{price};
			my $name = $item->{name};
			my $nameID = $item->{nameID};
			my $index = $item->{ID};
			my $store_amount = $item->{amount};
			
			next unless ($nameID == $args->{'buyer'}{'id'});
			next unless ($price >= $args->{'buyer'}{'Cost'});
			
			my $item_prefix = $prefixN;
			
			my $minPrice = $config{$item_prefix."_minPrice"};
			my $maxAmount = $config{$item_prefix."_maxAmount"};
			
			my $inv_amount = $char->inventory->sumByNameID($nameID);
			
			my $max_wanted = $inv_amount;
			
			my $max_possible_buy_by_store_amount = $store_amount >= $max_wanted ? $max_wanted : $store_amount;
			
			
			my $max_possible_buy_by_price_limit = floor($buyerPriceLimit/$price);
			
			$max_possible_buy_by_price_limit = $max_possible_buy_by_store_amount >= $max_possible_buy_by_price_limit ? $max_possible_buy_by_price_limit : $max_possible_buy_by_store_amount;
			
			my $will_buy = $max_possible_buy_by_price_limit;
			next if ($will_buy == 0);
			
			message "[".PLUGIN_NAME."] Found item $name with good buying price! Price is $price a piece, min price to sell is ".$minPrice."! The store is buying $store_amount of it. Selling $will_buy of it!\n";
			
			my $char_item = $char->inventory->getByNameID($nameID);
			my %buy = (
				ID => $char_item->{ID},
				itemID => $char_item->{nameID},
				amount => $will_buy
			);
			
			push(@current_sellList, \%buy);
			
			my $buy_string = "[".getFormattedDate(int(time))."] ". $name ." - ". $will_buy ." - ". $price ." - ". get_player_name($buyerID) ."\n";
			
			my %buy_log = (
				string   => $buy_string,
				name     => $name,
				buyerID => $args->{buyerID},
			);
			
			push(@current_sell_log, \%buy_log);
		}
		
		if (!scalar @current_sellList) {
			$args->{'error'} = 'Did not find anything to sell in store';
			$args->{'done'} = 1;
			return;
		}
		
		@last_buyer_buyList = @current_sellList;
		@last_buyer_buy_log = @current_sell_log;
		
		#$messageSender->sendBuyBulkVender($venderID, \@current_sellList, $venderCID);
		$messageSender->sendBuyBulkBuyer($buyerID, \@current_sellList, $buyingStoreID);
		warning "[".PLUGIN_NAME."] Sent Sell to player buystore!\n";
			
		delete $args->{'sentOpenShop'};
		delete $args->{'sentOpenShop_time'};
		delete $args->{'recv_buyList_time'};
		
		$args->{sentBuyPacket_time} = time;
	}
}

sub AI_pre_buyer {
	return unless (main::timeOut($query_time, QUERY_TIMEOUT));
	return unless (main::timeOut($market_time_buyer, MARKET_RECHECK_BUY));
	
	if (@buyers_query_queue) {
		sendNext_buyers_queue();
	}
}

sub sendNext_buyers_queue {
	my $item_prefix = shift @buyers_query_queue;
	sendBuyerQuery($item_prefix);
	$market_time_buyer = time;
}

sub create_buyers_query_queue {
	my $prefix = 'BetterSeller_';
	my $current_index = 0;
	
	while (exists $config{$prefix.$current_index}) {
		my $item_prefix = $prefix.$current_index;
		if (defined $config{$item_prefix}) {
			push(@buyers_query_queue, $item_prefix);
		}
	} continue {
		$current_index++;
	}
}

sub sendBuyerQuery {
	my ($item_prefix) = @_;
	warning "[BetterSeller] Sending Whobuy Query on item $config{$item_prefix} (".GetItemName($config{$item_prefix}).")\n";
	my $msg = '@wb '.$config{$item_prefix};
	sendMessage($messageSender, 'c', $msg);
	$last_buy_query_item_id = $config{$item_prefix};
	$last_buy_query_minBuyShopAmount = $config{$item_prefix.'_minBuyShopAmount'};
	$last_buy_query_minPrice = $config{$item_prefix.'_minPrice'};
	warning "[BetterSeller] Sent Whobuy Query, last_buy_query_item_id $last_buy_query_item_id, last_buy_query_minBuyShopAmount $last_buy_query_minBuyShopAmount, last_buy_query_minPrice $last_buy_query_minPrice\n";
	$query_time = time;
}

sub AI_pre_market {
	return unless (main::timeOut($query_time, QUERY_TIMEOUT));
	return unless (main::timeOut($market_time_seller, MARKET_RECHECK_TIMEOUT));
	return unless ($config{BetterShopper_on});
	return unless (exists $config{BetterShopper_0});
	return if (AI::inQueue("storageAuto", "determine_selling", "BetterSeller"));
	
	if (!@sellers_query_queue) {
		create_sellers_query_queue();
	} else {
		sendNext_sellers_queue();
	}
}

sub sendNext_sellers_queue {
	my $item_prefix = shift @sellers_query_queue;
	sendQuery($item_prefix);
	$market_time_seller = time;
}

sub sendQuery {
	my ($item_prefix) = @_;
	warning "[BetterShopper] Sending Whosell Query on item $config{$item_prefix} (".GetItemName($config{$item_prefix}).") Prefix $item_prefix\n";
	my $msg = '@ws '.$config{$item_prefix};
	sendMessage($messageSender, 'c', $msg);
	$last_sell_query_item_id = $config{$item_prefix};
	$last_sell_query_minShopAmount = $config{$item_prefix.'_minShopAmount'};
	$last_sell_query_maxPrice = $config{$item_prefix.'_maxPrice'};
	$query_time = time;
}

sub create_sellers_query_queue {
	my $prefix = 'BetterShopper_';
	my $current_index = 0;
	
	while (exists $config{$prefix.$current_index}) {
		my $item_prefix = $prefix.$current_index;
		if (defined $config{$item_prefix}) {
			push(@sellers_query_queue, $item_prefix);
		}
	} continue {
		$current_index++;
	}
}

sub on_force_check_market {
	my ($hook, $args) = @_;
	
	my $id = $args->{id};
	
	unshift(@sellers_query_queue, $id);
	warning "[BetterShopper] Force adding item $id (".GetItemName($id).") to the top of queue and reseting timeouts\n";
	$query_time = 0;
	$market_time_seller = 0;
}

sub check_market_found {
	my ($hook, $args) = @_;
	
	my $id = $args->{id};
	
	if(exists $found_best_seller_shops{$id} && exists $last_recv_seller_query_time{$id} && !main::timeOut($last_recv_seller_query_time{$id}, 60)) {
		warning "[BetterShopper] Sucess found seller for forced check id $id\n";
		$args->{return} = 1;
	} else {
		error "[BetterShopper] Did not find seller for forced check id $id\n";
	}
}

sub on_npc_chat {
	my ($hook, $args) = @_;
	return unless (
		($config{BetterShopper_on} && exists $config{BetterShopper_0} && defined $last_sell_query_item_id) ||
		($config{BetterSeller_on} && exists $config{BetterSeller_0} && defined $last_buy_query_item_id)
	);
	
	if ($args->{message} =~ /SHOPS CONTAINING YOUR QUERY/) {
		#//==SHOPS CONTAINING YOUR QUERY===================================//
		#warning "[BetterShopper] Started QUERY\n", "BetterShopper", 1;
		$received_start = 1;
		$received_first_item = 0;
		$receiving_Wbuy = 0;
		$receiving_Wsell = 0;
		
	} elsif (defined $last_sell_query_item_id && $received_start && $args->{message} =~ /Nobody is selling that item at this time/) {
		# Nobody is selling that item at this time.
		#warning "[BetterShopper] No one is selling item $last_sell_query_item_id\n", "BetterShopper", 1;
		$received_start = 0;
		$received_first_item = 0;
		$receiving_Wbuy = 0;
		$receiving_Wsell = 0;
		undef @sellers_found;
		delete $found_best_seller_shops{$last_sell_query_item_id} if (exists $found_best_seller_shops{$last_sell_query_item_id});;
		$last_recv_seller_query_time{$last_sell_query_item_id} = time;
		return;
		
	} elsif (defined $last_buy_query_item_id && $received_start && $args->{message} =~ /Nobody is buying that item at this time/) {
		# Nobody is buying that item at this time.
		#warning "[BetterShopper] No one is buying item $last_buy_query_item_id\n", "BetterShopper", 1;
		$received_start = 0;
		$received_first_item = 0;
		$receiving_Wbuy = 0;
		$receiving_Wsell = 0;
		undef @buyers_found;
		delete $found_best_buyer_shops{$last_buy_query_item_id} if (exists $found_best_buyer_shops{$last_buy_query_item_id});;
		$last_recv_buyer_query_time{$last_buy_query_item_id} = time;
		return;
		
	} elsif ($received_start && $args->{message} =~ /END OF SEARCH RESULTS/) {
		#//==END OF SEARCH RESULTS=========================================//
		
		if ($receiving_Wsell) {
			#warning "[BetterShopper] Ended QUERY for item $last_sell_query_item_id\n", "BetterShopper", 1;
			if (!scalar @sellers_found || !$received_first_item) {
				#warning "[BetterShopper] No one is selling item $last_sell_query_item_id in the right amount, price and place\n", "BetterShopper", 1;
				delete $found_best_seller_shops{$last_sell_query_item_id} if (exists $found_best_seller_shops{$last_sell_query_item_id});
				
			} else {
				@sellers_found = sort { $a->{Cost} <=> $b->{Cost} } @sellers_found;
				my $found = $sellers_found[0];
				$found_best_seller_shops{$found->{id}} = $found;
				warning "[BetterShopper] Found item $found->{id}, sold at $found->{Cost}, quant $found->{quant}, map $found->{Map} ($found->{x} $found->{y}), by seller $found->{Seller}\n", "BetterShopper", 1;
			}
			undef @sellers_found;
			$last_recv_seller_query_time{$last_sell_query_item_id} = time;
			
		} elsif ($receiving_Wbuy) {
			#warning "[BetterShopper] Ended QUERY for item $last_buy_query_item_id\n", "BetterShopper", 1;
			if (!scalar @buyers_found || !$received_first_item) {
				#warning "[BetterShopper] No one is buying item $last_buy_query_item_id in the right amount, price and place\n", "BetterShopper", 1;
				delete $found_best_buyer_shops{$last_buy_query_item_id} if (exists $found_best_buyer_shops{$last_buy_query_item_id});;
				
			} else {
				@buyers_found = reverse sort { $a->{Cost} <=> $b->{Cost} } @buyers_found;
				my $found = $buyers_found[0];
				$found_best_buyer_shops{$found->{id}} = $found;
				warning "[BetterShopper] Found item $found->{id}, being bought at at $found->{Cost}, quant $found->{quant}, map $found->{Map} ($found->{x} $found->{y}), by buyer $found->{Buyer}\n", "BetterShopper", 1;
			}
			undef @buyers_found;
			$last_recv_buyer_query_time{$last_buy_query_item_id} = time;
		}
		$received_start = 0;
		$received_first_item = 0;
		$receiving_Wbuy = 0;
		$receiving_Wsell = 0;
		
	} elsif ($received_start && $args->{message} =~ /Map/) {
		#warning "[BetterShopper] MAP\n";
		if (defined $last_sell_query_item_id && $received_start && $args->{message} =~ /Seller/) {
			
			my $error;
			my %store_found;
			if ($args->{message} =~ /^ID (\d+) \| Cost: (\d+)z \| Qty: (\d+) \| Map: (.+) \[(\d+), (\d+)\] \| Seller: (.+)$/) {
				#ID 958 | Cost: 1350z | Qty: 26 | Map: oldnewpayon [110, 96] | Seller: arnaldo
				$store_found{id} = $1;
				$store_found{Cost} = $2;
				$store_found{quant} = $3;
				$store_found{Map} = $4;
				$store_found{x} = $5;
				$store_found{y} = $6;
				$store_found{Seller} = $7;
			} elsif ($args->{message} =~ /^\+\d (\d+)\[\d\] \| Cost: (\d+)z \| Qty: (\d+) \| Map: (.+) \[(\d+) , (\d+)\] \| Seller: (.+)$/) {
				#+0 2339[0] | Cost: 9999z | Qty: 1 | Map: aldebaran [150 , 122] | Seller: Alfamart
				$store_found{id} = $1;
				$store_found{Cost} = $2;
				$store_found{quant} = $3;
				$store_found{Map} = $4;
				$store_found{x} = $5;
				$store_found{y} = $6;
				$store_found{Seller} = $7;
			} else {
				$error = "[BetterShopper] Could not parse npc_chat message for last seller sent $last_sell_query_item_id\n";
			}
			
			if ($store_found{id} != $last_sell_query_item_id) {
				$error = "[BetterShopper] Sent seller id $last_sell_query_item_id but received $store_found{id}\n";
			}
			
			if (defined $error) {
				error $error;
				$received_start = 0;
				$received_first_item = 0;
				undef @sellers_found;
				delete $found_best_seller_shops{$store_found{id}};
				return;
				
			} elsif (!$received_first_item) {
				$received_first_item = 1;
				undef @sellers_found;
				delete $found_best_seller_shops{$store_found{id}};
				$receiving_Wbuy = 0;
				$receiving_Wsell = 1;
			}
			
			return if ($store_found{Map} ne 'oldnewpayon' && $store_found{Map} ne 'aldebaran' && $store_found{Map} ne 'pay_fild01');
			
			if ($store_found{id} == $last_sell_query_item_id && $store_found{quant} >= $last_sell_query_minShopAmount && $store_found{Cost} <= $last_sell_query_maxPrice) {
				push(@sellers_found, \%store_found);
			}
			
		} elsif (defined $last_buy_query_item_id && $received_start && $args->{message} =~ /Buyer/) {
			#warning "[BetterShopper] BUYER id $last_buy_query_item_id | quant $last_buy_query_minBuyShopAmount | minPrice $last_buy_query_minPrice\n";
			
			my $error;
			my %store_found;
			if ($args->{message} =~ /^Price: (\d+) \| Qty: (\d+) \| Map: (.+) \[(\d+), (\d+)\] \| Buyer: (.+)$/) {
				#Price: 150 | Qty: 243 | Map: oldnewpayon [100, 146] | Buyer: Spread
				$store_found{id} = $last_buy_query_item_id;
				$store_found{Cost} = $1;
				$store_found{quant} = $2;
				$store_found{Map} = $3;
				$store_found{x} = $4;
				$store_found{y} = $5;
				$store_found{Buyer} = $6;
			} else {
				$error = "[BetterSeller] Could not parse npc_chat message for last buyer sent $last_buy_query_item_id\n";
			}
			
			if (defined $error) {
				error $error;
				$received_start = 0;
				$received_first_item = 0;
				undef @buyers_found;
				delete $found_best_buyer_shops{$store_found{id}};
				return;
				
			} elsif (!$received_first_item) {
				$received_first_item = 1;
				undef @buyers_found;
				delete $found_best_buyer_shops{$store_found{id}};
				$receiving_Wbuy = 1;
				$receiving_Wsell = 0;
			}
			
			return if ($store_found{Map} ne 'oldnewpayon' && $store_found{Map} ne 'aldebaran' && $store_found{Map} ne 'pay_fild01');
			
			if ($store_found{quant} >= $last_buy_query_minBuyShopAmount && $store_found{Cost} >= $last_buy_query_minPrice) {
				#warning "[BetterSeller] Found buyer $store_found{Buyer} for item $store_found{id}, paying $store_found{Cost} a piece, quant $store_found{quant}, map $store_found{Map} ($store_found{x} $store_found{y})\n", "BetterShopper", 1;
				push(@buyers_found, \%store_found);
			}
		}
	}
	
}

sub AI_pre_buying {
	if (
		   $char->inventory->isReady()
		&& $config{BetterShopper_on}
		&& (AI::isIdle || AI::action eq "route" || AI::action eq "move" || AI::action eq "checkMonsters" || AI::action eq "sitAuto")
		#&& !AI::inQueue("attack")
		&& !AI::inQueue("storageAuto")
		&& !AI::inQueue("buyAuto")
		&& !AI::inQueue("sellAuto")
		&& !AI::inQueue("teleport", "NPC")
		&& !AI::inQueue("skill_use")
		&& !AI::inQueue("eventMacro")
		&& !AI::inQueue("Shopping")
		&& !AI::inQueue("Shopping_fallBack")
		&& !AI::inQueue("determine_selling")
		&& !AI::inQueue("BetterSeller")
		&& main::timeOut($timeout{'Shopping'})
		&& (scalar keys %found_best_seller_shops)
	) {
		
		my $i = 0;
		my $bai;
		my $tprice;
		for($i = 0; exists $config{"BetterShopper_$i"}; $i++) {
			next if (!$config{"BetterShopper_$i"} || $config{"BetterShopper_${i}_disabled"});
			
			my $item_prefix = "BetterShopper_$i";
			my $itemID = $config{$item_prefix};
			
			my $amount;
			my $cart_amount;
			
			$amount = $char->inventory->sumByNameID($itemID);
			$cart_amount = $char->cart->sumByNameID($itemID);
			
			my $char_total = $amount + $cart_amount;
			
			next unless ($config{$item_prefix."_minInventoryAmount"} ne "" && defined $config{$item_prefix."_minInventoryAmount"} ne "");
			my $minInventoryAmount = $config{$item_prefix."_minInventoryAmount"};
			
			next unless ($config{$item_prefix."_maxAmount"} ne "" && defined $config{$item_prefix."_maxAmount"} ne "");
			my $maxAmount = $config{$item_prefix."_maxAmount"};
			
			#warning "[Better Test] (".GetItemName($itemID).") 2 - char_total $char_total | min $minInventoryAmount | max $maxAmount\n";
			if (exists $last_recv_seller_query_time{$itemID}) {
				#warning "[Better Test] (".GetItemName($itemID).") 21 - Exists\n";
				if (!main::timeOut($last_recv_seller_query_time{$itemID}, 60)) {
					#warning "[Better Test] (".GetItemName($itemID).") 22 - Recent\n";
				}
			}
			if (
				(checkSelfCondition($item_prefix)) &&
				$char_total <= $minInventoryAmount &&
				$char_total < $maxAmount &&
				exists $last_recv_seller_query_time{$itemID} &&
				!main::timeOut($last_recv_seller_query_time{$itemID}, 60)
			) {
				my $amount_want = $config{$item_prefix."_maxAmount"};
				my $amount_have = $char_total;
				my $amount_need_buy = $amount_want - $amount_have;
				#warning "[Better Test] (".GetItemName($itemID).") 3 - amount_need_buy $amount_need_buy\n";
				if (exists $found_best_seller_shops{$itemID} && $found_best_seller_shops{$itemID}) {
					my $price_per_amount = $found_best_seller_shops{$itemID}{Cost};
					my $total_price = $price_per_amount * $amount_need_buy;
					#warning "[Better Test] (".GetItemName($itemID).") 41 - char->{zeny} $char->{zeny} | total_price $total_price\n";
					if ($char->{zeny} >= $total_price) {
						$bai = $i;
						$tprice = $total_price;
						warning "Setting shopping for item ".$itemID."\n";
						last;
					}
				} elsif ($config{$item_prefix."_fallbackNpc"}) {
					my $price_per_amount = $config{$item_prefix."_price"};
					my $total_price = $price_per_amount * $amount_need_buy;
					#warning "[Better Test] (".GetItemName($itemID).") 42 - char->{zeny} $char->{zeny} | total_price $total_price\n";
					if ($char->{zeny} >= $total_price) {
						if (!exists $shopper_npc_fallback_items{$itemID}) {
							$shopper_npc_fallback_items{$itemID}{'index'} = $i;
							$shopper_npc_fallback_items{$itemID}{'item'} = $itemID;
							$shopper_npc_fallback_items{$itemID}{'npc'} = $config{$item_prefix."_fallbackNpc"};
							$shopper_npc_fallback_items{$itemID}{'totalprice'} = $total_price;
							warning "Adding item ".$itemID." to Fallback list\n";
						}
					}
				}
			}
		}
		return unless (defined $bai);
		AI::clear("move", "route", "checkMonsters");
		AI::queue("Shopping", { Better_index => $bai, item => $config{"BetterShopper_$bai"}, needed_zeny => $tprice });
		$buy_from_player_sucess = 0;
		$buy_from_player_fail = 0;
		$timeout{'Shopping'}{'time'} = time;
		$timeout{'Shopping'}{'timeout'} = 1;
	}

	if (AI::action eq "Shopping" && AI::args->{'done'}) {
		my $args = AI::args;
		my $prefixN = "BetterShopper_".$args->{Better_index};
		my $prefix = $config{$prefixN};

		if (exists AI::args->{'error'}) {
			error AI::args->{'error'}.".\n";
		}

		# Shopping finished
		AI::dequeue while AI::inQueue("Shopping");
		delete $last_recv_seller_query_time{$prefix} if (exists $last_recv_seller_query_time{$prefix});
		unshift(@sellers_query_queue, $prefix);

	} elsif (AI::action eq "Shopping") {
		my $args = AI::args;
		
		$args->{index} = $args->{Better_index};
		#$args->{needed_zeny}
		my $prefixN = "BetterShopper_".$args->{Better_index};
		my $prefix = $config{$prefixN};
		
		if (!exists $found_best_seller_shops{$prefix}) {
			$args->{'error'} = 'Store does not exist anymore';
			$args->{'done'} = 1;
			return;
		}
		
		if ($args->{'seller'} && $found_best_seller_shops{$prefix}{'Seller'} ne $args->{'seller'}{'name'}) {
			$args->{'error'} = "[$prefix] Best seller changed name";
			$args->{'done'} = 1;
			return;
		}
		
		if ($args->{'seller'} && ($found_best_seller_shops{$prefix}{'x'} != $args->{'seller'}{'pos'}{'x'} || $found_best_seller_shops{$prefix}{'y'} != $args->{'seller'}{'pos'}{'y'})) {
			$args->{'error'} = "[$prefix] Best seller changed position";
			$args->{'done'} = 1;
			return;
		}
		
		if ($args->{'seller'} && $found_best_seller_shops{$prefix}{'Cost'} ne $args->{'seller'}{'Cost'}) {
			$args->{'error'} = "[$prefix] Best seller changed Cost";
			$args->{'done'} = 1;
			return;
		}
		
		if ($buy_from_player_sucess == 1) {
			Log::warning "Sucesssssss CARAIO!!!\n";
			$args->{'done'} = 1;
			return;
		}
		
		if ($buy_from_player_fail == 1) {
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
				!$buy_from_player_sucess &&
				!$buy_from_player_fail
			) {
				$args->{'error'} = 'Did not received the buy result from server after buy packet was sent';
				$args->{'done'} = 1;
			}
			return;
		}

		if (!exists $args->{lastIndex}) {
			$args->{'seller'}{'map'} = $found_best_seller_shops{$prefix}{Map};
			$args->{'seller'}{'pos'}{'x'} = $found_best_seller_shops{$prefix}{x};
			$args->{'seller'}{'pos'}{'y'} = $found_best_seller_shops{$prefix}{y};
			$args->{'seller'}{'name'} = $found_best_seller_shops{$prefix}{Seller};
			$args->{'seller'}{'Cost'} = $found_best_seller_shops{$prefix}{Cost};
			$args->{'seller'}{'id'} = $found_best_seller_shops{$prefix}{id};
			
			#use Data::Dumper;
			#warning "found: ".Dumper \%found_best_seller_shops;
			#warning "args: ".Dumper $args;

			# Failed to load any slots for Shopping (we're done or they're all invalid)
			if (!defined $args->{index}) {
				$args->{'done'} = 1;
				return;
			}

			undef $ai_v{'temp'}{'do_route'};
			if (!$args->{distance}) {
				# Calculate variable or fixed (old) distance
				if ($config{"BetterShopper_minDistance"} && $config{"BetterShopper_maxDistance"}) {
					$args->{distance} = $config{"BetterShopper_minDistance"} + round(rand($config{"BetterShopper_maxDistance"} - $config{"BetterShopper_minDistance"}));
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
						debug "[".PLUGIN_NAME."] Adding shop '".$vender->{'title'}."' of player '$name' to AI queue check list.\n";
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
					$received_shop_list = 0;
					undef $itemList;
					$buy_from_player_sucess = 0;
					$buy_from_player_fail = 0;
					$messageSender->sendEnteringVender($venderID);
					last;
				}
			}

			$args->{'sentOpenShop'} = 1;
			$args->{'sentOpenShop_time'} = time;

			return;

		} elsif ($received_shop_list == 0) {
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
		
		undef @last_seller_buy_log;
		undef @last_seller_buyList;
		
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
		
		@last_seller_buyList = @current_buyList;
		@last_seller_buy_log = @current_buy_log;
		
		$messageSender->sendBuyBulkVender($venderID, \@current_buyList, $venderCID);
		warning "[".PLUGIN_NAME."] Sent Buy from player store!\n";
			
		delete $args->{'sentOpenShop'};
		delete $args->{'sentOpenShop_time'};
		delete $args->{'recv_buyList_time'};
		
		$args->{sentBuyPacket_time} = time;
	}
}

sub AI_pre_fallback {
	return if( $shopstarted || $buyershopstarted );
	if (
		   $char->inventory->isReady()
		&& $config{BetterShopper_on}
		&& (AI::isIdle || AI::action eq "route" || AI::action eq "move" || AI::action eq "checkMonsters" || AI::action eq "sitAuto")
		&& !AI::inQueue("storageAuto")
		&& !AI::inQueue("buyAuto")
		&& !AI::inQueue("sellAuto")
		&& !AI::inQueue("teleport", "NPC")
		&& !AI::inQueue("skill_use")
		&& !AI::inQueue("eventMacro")
		&& !AI::inQueue("Shopping")
		&& !AI::inQueue("Shopping_fallBack")
		&& !AI::inQueue("determine_selling")
		&& !AI::inQueue("BetterSeller")
		&& timeOut($timeout{'ai_Shopping_fallBack'})
	) {
		my @delete_ids;
		my $bai;
		my $tprice;
		foreach my $fallback_id (keys %shopper_npc_fallback_items) {
			my $fallback_item = $shopper_npc_fallback_items{$fallback_id};
			
			my $i = $fallback_item->{'index'};
			
			my $item_prefix = "BetterShopper_$i";
			my $itemID = $config{$item_prefix};
			
			my $amount;
			my $cart_amount;
			
			$amount = $char->inventory->sumByNameID($fallback_id);
			$cart_amount = $char->cart->sumByNameID($fallback_id);
			
			my $char_total = $amount + $cart_amount;
			
			next unless ($config{$item_prefix."_minInventoryAmount"} ne "" && defined $config{$item_prefix."_minInventoryAmount"} ne "");
			my $minInventoryAmount = $config{$item_prefix."_minInventoryAmount"};
			
			next unless ($config{$item_prefix."_maxAmount"} ne "" && defined $config{$item_prefix."_maxAmount"} ne "");
			my $maxAmount = $config{$item_prefix."_maxAmount"};
			
			#warning "[Fallback Test] (".GetItemName($itemID).") 2 - char_total $char_total | min $minInventoryAmount | max $maxAmount\n";
			
			if (
				(checkSelfCondition($item_prefix)) &&
				$char_total <= $config{$item_prefix."_minInventoryAmount"} &&
				$char_total < $config{$item_prefix."_maxAmount"}
			) {
				my $amount_want = $config{$item_prefix."_maxAmount"};
				my $amount_have = $char_total;
				my $amount_need_buy = $amount_want - $amount_have;
				my $price_per_amount = $config{$item_prefix."_price"};
				my $total_price = $price_per_amount * $amount_need_buy;
				#warning "[Fallback Test] (".GetItemName($itemID).") 3 - char->{zeny} $char->{zeny} | total_price $total_price\n";
				if ($char->{zeny} >= $total_price) {
					$bai = $i;
					$tprice = $total_price;
					warning "[SUCESS] fallback ".$itemID." being created\n";
				} else {
					#warning "[FAIL] fallback ".$itemID." failed money\n";
					push(@delete_ids, $fallback_id);
				}
			} else {
				#warning "[FAIL] fallback ".$itemID." failed amounts\n";
				push(@delete_ids, $fallback_id);
			}
		}
		foreach my $del (@delete_ids) {
			warning "Deleting fallback ".$del."\n";
			delete $shopper_npc_fallback_items{$del};
		}
		
		return unless (defined $bai);
		AI::clear("move", "route", "checkMonsters");
		AI::queue("Shopping_fallBack", { Better_index => $bai, item => $config{"BetterShopper_$bai"}, needed_zeny => $tprice });
		$buy_fallback_sucess = 0;
		$buy_fallback_fail = 0;
		$timeout{'ai_Shopping_fallBack'}{'time'} = time;
		$timeout{'ai_Shopping_fallBack'}{'timeout'} = 1;
	}

	if (AI::action eq "Shopping_fallBack" && AI::args->{'done'}) {

		if (exists AI::args->{'error'}) {
			error AI::args->{'error'}.".\n";
		}

		# Shopping_fallBack finished
		AI::dequeue while AI::inQueue("Shopping_fallBack");

	} elsif (AI::action eq "Shopping_fallBack" && timeOut($timeout{ai_Shopping_fallBack_wait}, $timeout{ai_buyAuto_wait}{timeout})) {
		my $args = AI::args;
		
		$args->{index} = $args->{Better_index};
		#$args->{needed_zeny}
		my $prefixN = "BetterShopper_".$args->{Better_index};
		my $prefix = $config{$prefixN};
		
		if ($buy_fallback_sucess == 1) {
			Log::warning "[$prefix] Sucesssssss CARAIO!!!\n";
			$args->{'done'} = 1;
			return;
		}
		
		if ($buy_fallback_fail == 1) {
			$args->{'error'} = "[$prefix] Buy failed";
			$args->{'done'} = 1;
			return;
		}
		
		if (exists $args->{sentBuyPacket_time}) {
			if (
				timeOut($args->{sentBuyPacket_time}, $timeout{ai_buyAuto_wait_after_packet_giveup}{timeout}) &&
				!$buy_fallback_sucess &&
				!$buy_fallback_fail
			) {
				$args->{'error'} = 'Did not received the buy result from server after buy packet was sent';
				$args->{'done'} = 1;
			}
			return;
		}
		
		if (!exists $args->{sentBuyPacket_time} && $char->{zeny} < $args->{needed_zeny}) {
			$args->{'error'} = 'We do not have enough zeny anymore';
			$args->{'done'} = 1;
			return;
		}

		if (!exists $args->{lastIndex}) {
			#warning "[test 0] args->{Better_index} $args->{Better_index} | prefixN $prefixN | prefix $prefix\n";
			
			$args->{npc} = {};
			my $destination = $config{$prefixN."_fallbackNpc"};
			getNPCInfo($destination, $args->{npc});

			undef $ai_v{'temp'}{'do_route'};
			if (!$args->{distance}) {
				# Calculate variable or fixed (old) distance
				if ($config{"BetterShopper_minDistance"} && $config{"BetterShopper_maxDistance"}) {
					$args->{distance} = $config{"BetterShopper_minDistance"} + round(rand($config{"BetterShopper_maxDistance"} - $config{"BetterShopper_minDistance"}));
				}
			}

			if ($field->baseName ne $args->{'npc'}{'map'}) {
				$ai_v{'temp'}{'do_route'} = 1;
			} else {
				my $found = 0;
				foreach my $actor (@{$npcsList->getItems()}) {
					my $pos = $actor->{pos};
					next if ($actor->{statuses}->{EFFECTSTATE_BURROW});
					if ($pos->{x} == $args->{npc}{pos}{x} && $pos->{y} == $args->{npc}{pos}{y}) {
						if (defined $actor->{name}) {
							$found = 1;
							last;
						}
					}
				}
				unless ($found) {
					$ai_v{'temp'}{'distance'} = blockDistance($args->{'npc'}{'pos'}, $chars[$config{'char'}]{'pos_to'});
					if (($ai_v{'temp'}{'distance'} > $args->{distance}) && !exists $args->{'sentNpcTalk'}) {
						$ai_v{'temp'}{'do_route'} = 1;
					}
				}
			}

			if ($ai_v{'temp'}{'do_route'}) {
				if ($args->{warpedToSave} && !$args->{mapChanged} && !timeOut($args->{warpStart}, 8)) {
					undef $args->{warpedToSave};
				}

				my $msgneeditem = "Auto-buy: $prefix\n";
				if (
					$config{'saveMap'} ne "" &&
					$config{'saveMap_warpToBuyOrSell'} &&
					!$args->{warpedToSave} &&
					!$field->isCity && $config{'saveMap'} ne $field->baseName
				) {
					if ($char->{sitting}) {
						message T($msgneeditem."Standing up to auto-buy\n"), "teleport";
						ai_setSuspend(0);
						stand();
					} else {
						$args->{warpedToSave} = 1;
						# If we still haven't warped after a certain amount of time, fallback to walking
						$args->{warpStart} = time unless $args->{warpStart};
						message T($msgneeditem."Teleporting to auto-buy\n"), "teleport";
						useTeleport(2);
					}
					$timeout{ai_Shopping_fallBack_wait}{time} = time;

				} else {
					message TF($msgneeditem."Calculating auto-buy route to: %s (%s): %s, %s\n", $maps_lut{$args->{npc}{map}.'.rsw'}, $args->{npc}{map}, $args->{npc}{pos}{x}, $args->{npc}{pos}{y}), "route";
					ai_route(
						$args->{npc}{map}, $args->{npc}{pos}{x}, $args->{npc}{pos}{y},
						attackOnRoute => 1,
						distFromGoal => $args->{distance}
					);
				}
				return;
			}
		}

		if (!exists $args->{lastIndex}) {
			$args->{lastIndex} = $args->{index};
			return;

		} elsif (!exists $args->{'sentNpcTalk'}) {
			# load the real npc location just in case we used standpoint
			my $realpos = {};
			my $destination = $config{"BetterShopper_".$args->{lastIndex}."_fallbackNpc"};
			#warning "[test 2] dest is $destination\n";
			getNPCInfo($destination, $realpos);

			ai_talkNPC($realpos->{pos}{x}, $realpos->{pos}{y}, $config{"BetterShopper_".$args->{lastIndex}."_npc_steps"} || 'b');

			$args->{'sentNpcTalk'} = 1;
			$args->{'sentNpcTalk_time'} = time;

			return;

		} elsif ($ai_v{'npc_talk'}{'talk'} ne 'store') {
			if (timeOut($args->{'sentNpcTalk_time'}, $timeout{ai_buyAuto_wait_giveup_npc}{timeout})) {
				$args->{'error'} = 'Npc did not respond';
				$args->{'done'} = 1;
			}
			return;

		} elsif (!exists $args->{'recv_buyList_time'}) {
			$buy_fallback_sucess = 0;
			$buy_fallback_fail = 0;
			$args->{'recv_buyList_time'} = time;
			return;

		} else {
			return unless (timeOut($args->{'recv_buyList_time'}, $timeout{ai_buyAuto_wait_before_buy}{timeout}));
		}

		my @buyList;

		my $item;
		if ($config{"BetterShopper_".$args->{lastIndex}} =~ /^\d{3,}$/) {
			$item = $storeList->getByNameID( $config{"BetterShopper_".$args->{lastIndex}} );
			$args->{'nameID'} = $config{"BetterShopper_".$args->{lastIndex}} if (defined $item);
		}
		else {
			$item = $storeList->getByName( $config{"BetterShopper_".$args->{lastIndex}} );
			$args->{'nameID'} = $item->{nameID} if (defined $item);
		}

		if (!exists $args->{'nameID'}) {
			$args->{index_failed}{$args->{lastIndex}} = 1;
			error "Shopping_fallBack index ".$args->{lastIndex}." (".$config{"BetterShopper_".$args->{lastIndex}}.") failed, item doesn't exist in npc sell list.\n", "npc";

		} else {
			my $maxbuy = ($config{"BetterShopper_".$args->{lastIndex}."_price"}) ? int($char->{zeny}/$config{"BetterShopper_$args->{index}"."_price"}) : 30000; # we assume we can buy 30000, when price of the item is set to 0 or undef
			my $needbuy = $config{"BetterShopper_".$args->{lastIndex}."_maxAmount"};

			my $inv_amount = $char->inventory->sumByNameID($args->{'nameID'}, $config{"BetterShopper_".$args->{lastIndex}."_onlyIdentified"});

			$needbuy -= $inv_amount;

			my $buy_amount = ($maxbuy > $needbuy) ? $needbuy : $maxbuy;

			# support to market
			if ($item->{amount} && $item->{amount} < $buy_amount) {
				$buy_amount = $item->{amount};
			}

			my $batchSize = $config{"BetterShopper_".$args->{lastIndex}."_batchSize"};

			if ($batchSize && $batchSize < $buy_amount) {

				while ($buy_amount > 0) {
					my $amount = ($buy_amount > $batchSize) ? $batchSize : $buy_amount;
					my %buy = (
						itemID  => $args->{'nameID'},
						amount => $amount
					);
					push(@buyList, \%buy);
					$buy_amount -= $amount;
				}

			} else {
				my %buy = (
					itemID  => $args->{'nameID'},
					amount => $buy_amount
				);
				push(@buyList, \%buy);
			}
		}

		completeNpcBuy(\@buyList);

		delete $args->{'nameID'};
		delete $args->{'sentNpcTalk'};
		delete $args->{'sentNpcTalk_time'};
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

# we're currently inside a buying store if we receive this packet
sub buying_store_item_list {
	my ($packet, $args) = @_;
	
	return unless (AI::action eq "BetterSeller");
	my $ai_args = AI::args;
	return unless (exists $ai_args->{'buyer'});
	my $pname = get_player_name($args->{buyerID});
	return unless ($pname eq $ai_args->{'buyer'}{'name'});
	$received_buyshop_list = 1;
	$buystore_itemList = \@{$args->{itemList}->getItems};
	
	warning "[Seller] Received Correct buystore item list\n";
}

sub buying_store_fail {
	my ($packet, $args) = @_;
	
	return unless (@last_buyer_buyList); # should never happen
	
	# Error messages for the items we could not buy
	my $ID;
	foreach my $item_index (0..$#last_buyer_buyList) {
		my $log = $last_buyer_buy_log[$item_index];
		$ID = $log->{buyerID};
		error "[Seller] Failed to buy ".$log->{name}.".\n";
	}
	
	## Re-add the shop to the top of the list if we could still want something from it
	#return unless ($args->{fail} == 4);
	$sell_to_player_fail = 1;
}

sub buying_store_item_delete {
	my ($packet, $args) = @_;
	return unless (@last_buyer_buyList);
	
	my $item = $char->inventory->getByID($args->{ID});
	my $amount = $args->{amount};
	
	my $item_name = $item->{name};
	
	my $found_index;
	foreach my $possible_item_index (0..$#last_buyer_buyList) {
		my $possible_item = $last_buyer_buyList[$possible_item_index];
		my $possible_item_log = $last_buyer_buy_log[$possible_item_index];
		if ($possible_item_log->{name} eq $item_name && $possible_item->{amount} eq $amount) {
			# We were able to sell the item
			message "[Seller] Successfully sold ".$possible_item_log->{name}." x $amount.\n";
			writter_sold($possible_item_log->{string});
			$found_index = $possible_item_index;
			last;
		}
	}
	return unless (defined $found_index);
	$sell_to_player_sucess = 1;
	splice(@last_buyer_buyList, $found_index, 1);
	splice(@last_buyer_buy_log, $found_index, 1);
}

sub writter_sold {
	my ($args, $self) = @_;
	my $tmp = "$Settings::logs_folder/Shopper_buyshops.txt";
	
	open my $out, '>>:utf8', $tmp or die "Erro ao Abrir Arquivo";
	print $out "[".getFormattedDate(int(time))."] $args  \n";
	warning "$args \n";
	close $out;
}

# we're currently inside a store if we receive this packet
sub storeList {
	my ($packet, $args) = @_;
	
	return unless (AI::action eq "Shopping");
	my $ai_args = AI::args;
	return unless (exists $ai_args->{'seller'});
	my $pname = get_player_name($args->{venderID});
	return unless ($pname eq $ai_args->{'seller'}{'name'});
	$received_shop_list = 1;
	$itemList = \@{$args->{itemList}->getItems};
	
	warning "[test] Received Correct item list\n";
}

sub on_buy_result {
	my ($packet, $args) = @_;
	return unless (AI::action eq "Shopping_fallBack");
	AI::args->{recv_buy_packet} = 1;
	if ($args->{fail} == 0) {
		warning "[".PLUGIN_NAME."] Successfully bought.\n";
		$buy_fallback_sucess = 1;
	} else {
		error "[".PLUGIN_NAME."] Failed to buy.\n";
		$buy_fallback_fail = 1;
	}
}

sub buy_from_player_fail {
	my ($packet, $args) = @_;
	
	return unless (@last_seller_buyList); # should never happen
	
	# Error messages for the items we could not buy
	my $ID;
	foreach my $item_index (0..$#last_seller_buyList) {
		my $log = $last_seller_buy_log[$item_index];
		$ID = $log->{venderID};
		error "[".PLUGIN_NAME."] Failed to buy ".$log->{name}.".\n";
	}
	
	# Re-add the shop to the top of the list if we could still want something from it
	return unless ($args->{fail} == 4);
	$buy_from_player_fail = 1;
}

sub possible_buy_success {
	my ($packet, $args) = @_;
	return unless (@last_seller_buyList);
	my $item_name = $args->{item};
	my $amount = $args->{amount};
	
	my $found_index;
	foreach my $possible_item_index (0..$#last_seller_buyList) {
		my $possible_item = $last_seller_buyList[$possible_item_index];
		my $possible_item_log = $last_seller_buy_log[$possible_item_index];
		if ($possible_item_log->{name} eq $item_name && $possible_item->{amount} eq $amount) {
			# We were able to buy the item
			message "[".PLUGIN_NAME."] Successfully bought ".$possible_item_log->{name}.".\n";
			writter_bought($possible_item_log->{string});
			$found_index = $possible_item_index;
			last;
		}
	}
	return unless (defined $found_index);
	$buy_from_player_sucess = 1;
	splice(@last_seller_buyList, $found_index, 1);
	splice(@last_seller_buy_log, $found_index, 1);
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

