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
	['AI_pre',					\&AI_pre_fallback],
);

use constant {
	MARKET_RECHECK_TIMEOUT => 10,
	PLUGIN_NAME => 'BetterShopper',
	RECHECK_TIMEOUT => 10,
	MAX_ITEM_AMOUNT => 30000,
	MAX_SHOPPING_WEIGHT_PERCENT => 89,
	MAX_INVENTORY_SIZE => 100,
};

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
my %fallback;
my %last_recv_query_time;

sub GetItemName {
	my $itemID = shift;

	my $name = itemNameSimple($itemID);
	
	my $numSlots = $itemSlotCount_lut{$itemID};
	
	$name .= " [$numSlots]" if $numSlots;
	
	return $name;
}

sub AI_pre_market {
	my ($hook) = @_;
	return unless ($hook eq 'force_check_market' || main::timeOut($market_time, MARKET_RECHECK_TIMEOUT));
	return unless ($config{BetterShopper_on});
	return unless (exists $config{BetterShopper_0});
	
	my $prefix = PLUGIN_NAME.'_';
	my $current = $lastIndex;
	my $item_prefix = $prefix.$current;
	
	if (defined $config{$item_prefix}) {
		warning "[BetterShopper] Sending WS Query on block $current: item $config{$item_prefix} (".GetItemName($config{$item_prefix}).")\n", "BetterShopper", 1;
		my $msg = '@ws '.$config{$item_prefix};
		sendMessage($messageSender, 'c', $msg);
		$lastSentID = $config{$item_prefix};
		$last_minShopAmount = $config{$item_prefix.'_minShopAmount'};
		$last_maxPrice = $config{$item_prefix.'_maxPrice'};
		$market_time = time;
	}
	
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
		#warning "[BetterShopper] Started QUERY for item $lastSentID\n", "BetterShopper", 1;
		
		
	} elsif (defined $lastSentID && $started && $args->{message} =~ /Nobody is selling that item at this time/) {
		#//==END OF SEARCH RESULTS=========================================//
		$started = 0;
		undef @found;
		delete $found_best_shops{$lastSentID};
		$last_recv_query_time{$lastSentID} = time;
		#warning "[BetterShopper] No one is selling item $lastSentID\n", "BetterShopper", 1;
		return;
		
	} elsif (defined $lastSentID && $started && $args->{message} =~ /END OF SEARCH RESULTS/) {
		#//==END OF SEARCH RESULTS=========================================//
		$started = 0;
		#warning "[BetterShopper] Ended QUERY for item $lastSentID\n", "BetterShopper", 1;
		
		@found = sort { $a->{Cost} <=> $b->{Cost} } @found;
		
		if (!scalar @found) {
			delete $found_best_shops{$lastSentID};
			#warning "[BetterShopper] No one is selling item $lastSentID in the right amount, price and place\n", "BetterShopper", 1;
			return;
		} else {
			my $first = 0;
			foreach my $found (@found) {
				if ($first == 0) {
					$first = 1;
					$found_best_shops{$found->{id}} = $found;
					warning "[BetterShopper] Found item $found->{id}, sold at $found->{Cost}, quant $found->{quant}, map $found->{Map} ($found->{x} $found->{y}), by $found->{Seller}\n", "BetterShopper", 1;
				}
			}
		}
		undef @found;
		$last_recv_query_time{$lastSentID} = time;
		
		
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
	} elsif (defined $lastSentID && $started && $args->{message} =~ /^\+\d (\d+)\[\d\] \| Cost: (\d+)z \| Qty: (\d+) \| Map: (.+) \[(\d+) , (\d+)\] \| Seller: (.+)$/) {
		#+0 2339[0] | Cost: 9999z | Qty: 1 | Map: aldebaran [150 , 122] | Seller: Alfamart
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

sub AI_pre_fallback {
	return if( $shopstarted || $buyershopstarted );
	my $needitem;
	if (
		   (AI::isIdle || AI::action eq "route" || AI::action eq "move" || AI::action eq "follow")
		&& $config{BetterShopper_on}
		&& !AI::inQueue("eventMacro") && !AI::inQueue("Shopping")
		&& timeOut($timeout{'ai_buyAuto'})
		&& $char->inventory->isReady()
	) {
		undef $ai_v{'temp'}{'found'};
		my @delete_ids;
		foreach my $fallback_id (keys %fallback) {
			my $fallback_item = $fallback{$fallback_id};
			
			my $i = $fallback_item->{'index'};
			
			my $item_prefix = "BetterShopper_$i";
			my $itemID = $config{$item_prefix};
			
			my $amount;
			my $cart_amount;
			if ($itemID =~ /^\d{3,}$/) {
				$amount = $char->inventory->sumByNameID($fallback_id);
				$cart_amount = $char->cart->sumByNameID($fallback_id);
			}
			my $char_total = $amount + $cart_amount;
			if (
				$config{$item_prefix."_minInventoryAmount"} ne "" &&
				$config{$item_prefix."_maxAmount"} ne "" &&
				(checkSelfCondition($item_prefix)) &&
				$char_total <= $config{$item_prefix."_minInventoryAmount"} &&
				$char_total < $config{$item_prefix."_maxAmount"}
			) {
				my $amount_want = $config{$item_prefix."_maxAmount"};
				my $amount_have = $char_total;
				my $amount_need_buy = $amount_want - $amount_have;
				my $price_per_amount = $config{$item_prefix."_price"};
				my $total_price = $price_per_amount * $amount_need_buy;
				if ($char->{zeny} >= $total_price) {
					$ai_v{'temp'}{'found'} = 1;
					my $bai = $itemID;
					if ($needitem eq "") {
						$needitem = "$bai";
					} else {
						$needitem = "$needitem, $bai";
					}
				} else {
					push(@delete_ids, $fallback_id);
				}
			} else {
				push(@delete_ids, $fallback_id);
			}
		}
		foreach my $del (@delete_ids) {
			delete $fallback{$del};
		}
		$ai_v{'temp'}{'ai_route_index'} = AI::findAction("route");
		if ($ai_v{'temp'}{'ai_route_index'} ne "") {
			$ai_v{'temp'}{'ai_route_attackOnRoute'} = AI::args($ai_v{'temp'}{'ai_route_index'})->{'attackOnRoute'};
		}
		if (!($ai_v{'temp'}{'ai_route_index'} ne "" && AI::findAction("buyAuto")) && $ai_v{'temp'}{'found'}) {
			AI::queue("buyAuto");
		}
		$timeout{'ai_buyAuto'}{'time'} = time;
	}

	if (AI::action eq "buyAuto" && AI::args->{'done'}) {

		if (exists AI::args->{'error'}) {
			error AI::args->{'error'}.".\n";
		}

		# buyAuto finished
		$ai_v{'temp'}{'var'} = AI::args->{'forcedBySell'};
		$ai_v{'temp'}{'var2'} = AI::args->{'forcedByStorage'};
		AI::dequeue;
		Plugins::callHook('AI_buy_auto_done');

		if ($ai_v{'temp'}{'var'} && $config{storageAuto}) {
			AI::queue("storageAuto", {forcedBySell => 1});
		} elsif (!$ai_v{'temp'}{'var2'} && $config{storageAuto}) {
			AI::queue("storageAuto", {forcedByBuy => 1});
		}

	} elsif (AI::action eq "buyAuto" && timeOut($timeout{ai_buyAuto_wait})) {
		Plugins::callHook('AI_buy_auto');
		my $args = AI::args;

		if (exists $args->{sentBuyPacket_time} && exists $args->{index_failed}{$args->{lastIndex}}) {
			if (timeOut($args->{sentBuyPacket_time}, $timeout{ai_buyAuto_wait_after_restart}{timeout})) {
				delete $args->{sentBuyPacket_time};
				delete $args->{lastIndex};
				delete $args->{distance};
			}
			return;

		} elsif (exists $args->{sentBuyPacket_time} && !exists $args->{index_failed}{$args->{lastIndex}}) {
			if (exists $args->{recv_buy_packet}) {
				delete $args->{sentBuyPacket_time};
				delete $args->{recv_buy_packet};
				$args->{recv_buy_packet_time} = time;

			} elsif (timeOut($args->{sentBuyPacket_time}, $timeout{ai_buyAuto_wait_after_packet_giveup}{timeout})) {
				$args->{'error'} = 'Did not received the buy result from server after buy packet was sent';
				$args->{'done'} = 1;
			}
			return;

		} elsif (exists $args->{recv_buy_packet_time}) {
			if (timeOut($args->{recv_buy_packet_time}, $timeout{ai_buyAuto_wait_after_restart}{timeout})) {
				delete $args->{recv_buy_packet_time};
				delete $args->{lastIndex};
				delete $args->{distance};
			}
			return;

		}

		if (!exists $args->{lastIndex}) {

			delete $args->{index};
			for (my $i = 0; exists $config{"BetterShopper_$i"}; $i++) {
				next if (!$config{"BetterShopper_$i"} || $config{"BetterShopper_${i}_disabled"});
				next unless (!exists $fallback{$config{"BetterShopper_$i"}});
				next if ($config{"BetterShopper_${i}_maxBase"} =~ /^\d{1,}$/ && $char->{lv} > $config{"BetterShopper_${i}_maxBase"});
				next if ($config{"BetterShopper_${i}_minBase"} =~ /^\d{1,}$/ && $char->{lv} < $config{"BetterShopper_${i}_minBase"});
				# did we already fail to do this buyAuto slot? (only fails in this way if the item is nonexistant)
				next if (exists $args->{index_failed}{$i});

				my $amount;
				if ($config{"BetterShopper_$i"} =~ /^\d{3,}$/) {
					$amount = $char->inventory->sumByNameID($config{"BetterShopper_$i"}, $config{"BetterShopper_${i}_onlyIdentified"});
				}
				else {
					$amount = $char->inventory->sumByName($config{"BetterShopper_$i"}, $config{"BetterShopper_${i}_onlyIdentified"});
				}

				if ($config{"BetterShopper_$i"."_maxAmount"} ne "" && $amount < $config{"BetterShopper_$i"."_maxAmount"}) {
					next if (($config{"BetterShopper_$i"."_price"} && ($char->{zeny} < $config{"BetterShopper_$i"."_price"})) || ($config{"BetterShopper_$i"."_zeny"} && !inRange($char->{zeny}, $config{"BetterShopper_$i"."_zeny"})));

					# get NPC info, use standpoint if provided
					$args->{npc} = {};
					my $destination = $config{"BetterShopper_$i"."_fallbackNpc"};
					getNPCInfo($destination, $args->{npc});

					# did we succeed to load NPC info from this slot?
					if ($args->{npc}{ok}) {
						$args->{index} = $i;
					}
					last;
				}
			}

			# Failed to load any slots for buyAuto (we're done or they're all invalid)
			if (!exists $args->{index}) {
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

				my $msgneeditem;
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
						if ($needitem ne "") {
							$msgneeditem = "Auto-buy: $needitem\n";
						}
						# If we still haven't warped after a certain amount of time, fallback to walking
						$args->{warpStart} = time unless $args->{warpStart};
						message T($msgneeditem."Teleporting to auto-buy\n"), "teleport";
						useTeleport(2);
					}
					$timeout{ai_buyAuto_wait}{time} = time;

				} else {
					if ($needitem ne "") {
						$msgneeditem = "Auto-buy: $needitem\n";
					}
					message TF($msgneeditem."Calculating auto-buy route to: %s (%s): %s, %s\n", $maps_lut{$args->{npc}{map}.'.rsw'}, $args->{npc}{map}, $args->{npc}{pos}{x}, $args->{npc}{pos}{y}), "route";
					ai_route($args->{npc}{map}, $args->{npc}{pos}{x}, $args->{npc}{pos}{y},
						attackOnRoute => 1,
						distFromGoal => $args->{distance});
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
			getNPCInfo($config{"BetterShopper_".$args->{lastIndex}."_fallbackNpc"}, $realpos);

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
			error "buyAuto index ".$args->{lastIndex}." (".$config{"BetterShopper_".$args->{lastIndex}}.") failed, item doesn't exist in npc sell list.\n", "npc";

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
		&& main::timeOut($timeout{'Shopping'})
		&& (scalar keys %found_best_shops)
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
			
			if (
				$config{$item_prefix."_minInventoryAmount"} ne "" &&
				$config{$item_prefix."_maxAmount"} ne "" &&
				(checkSelfCondition($item_prefix)) &&
				$char_total <= $config{$item_prefix."_minInventoryAmount"} &&
				$char_total < $config{$item_prefix."_maxAmount"} &&
				exists $last_recv_query_time{$itemID} &&
				!main::timeOut($last_recv_query_time{$itemID}, 60)
			) {
				my $amount_want = $config{$item_prefix."_maxAmount"};
				my $amount_have = $char_total;
				my $amount_need_buy = $amount_want - $amount_have;
				if (exists $found_best_shops{$itemID} && $found_best_shops{$itemID}) {
					my $price_per_amount = $found_best_shops{$itemID}{Cost};
					my $total_price = $price_per_amount * $amount_need_buy;
					if ($char->{zeny} >= $total_price) {
						$bai = $i;
						$tprice = $total_price;
						warning "Setting shopping for item ".$itemID."\n";
						last;
					}
				} elsif ($config{$item_prefix."_fallbackNpc"}) {
					my $price_per_amount = $config{$item_prefix."_price"};
					my $total_price = $price_per_amount * $amount_need_buy;
					if ($char->{zeny} >= $total_price) {
						if (!exists $fallback{$itemID}) {
							$fallback{$itemID}{'index'} = $i;
							$fallback{$itemID}{'item'} = $itemID;
							$fallback{$itemID}{'npc'} = $config{$item_prefix."_fallbackNpc"};
							$fallback{$itemID}{'totalprice'} = $total_price;
							warning "Adding item ".$itemID." to Fallback list\n";
						}
					}
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
		my $args = AI::args;
		my $prefixN = "BetterShopper_".$args->{Better_index};
		my $prefix = $config{$prefixN};

		if (exists AI::args->{'error'}) {
			error AI::args->{'error'}.".\n";
			delete $last_recv_query_time{$prefix} if (exists $last_recv_query_time{$prefix});
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
		
		$messageSender->sendBuyBulkVender($venderID, \@current_buyList, $venderCID);
		warning "[".PLUGIN_NAME."] Sent Buy!\n";
			
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

