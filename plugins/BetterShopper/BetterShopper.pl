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
#	autoRefine_on 1
#	autoRefine_weaponLevel 1
#	autoRefine_wantedRefine 7
#	autoRefine_npc prontera 1 1
#	autoRefine_commandOnSuccess c deu certo
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
#	# Awakening Potion
#	BetterShopper 656 {
#		price 1500
#		maxPrice 1400
#		minInventoryAmount 0
#		minShopAmount 2
#		maxAmount 2
#		fallbackNpcShop aldeba_in 94 56
#		fallbackNpcTalk
#		fallbackNpcTSequence
#		commandAfterBuy
#	}
#		
#	# Strawberry
#	BetterSeller 578 {
#		minPrice 900
#		minBuyShopAmount 3
#	}
#
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
	['item_gathered',			\&possible_buy_success_talk],
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

my $eventMacro_hooks = Plugins::addHooks(
	['eventMacro_before_call_check',				\&manage_eventMacro_hooks],
);

my $storage_hooks = Plugins::addHooks(
	['AI_storage_done_after_getAuto',							\&AI_storage_done_after_getAuto],
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
	Plugins::delHook($eventMacro_hooks);
	Plugins::delHook($storage_hooks);
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

my %shopper_npcTalk_fallback_items;
my %sent_buy_talk;
my $buy_Talk_fallback_sucess = 0;
my $buy_Talk_fallback_fail = 0;

my $refine_sucess = 0;
my $refine_fail = 0;

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

sub manage_eventMacro_hooks {
	my ($hook, $args) = @_;
	if(AI::inQueue("Shopping", "Shopping_fallBack", "Shopping_Talk_fallBack", "autoRefine", "determine_selling", "BetterSeller", "storageAuto", "buyAuto", "sellAuto")) {
		$args->{return} = 1;
	}
}

sub manage_storage_buy_sell_hooks {
	my ($hook, $args) = @_;
	if(AI::inQueue("eventMacro", "Shopping", "Shopping_fallBack", "Shopping_Talk_fallBack", "autoRefine", "determine_selling", "BetterSeller", "teleport", "NPC", "skill_use")) {
		$args->{return} = 1;
	}
	if(%talk) {
		$args->{return} = 1;
	}
	if(exists $ai_v{'npc_talk'}) {
		$args->{return} = 1;
	}
}

sub storage_buy_sell_clear_route {
	AI::clear("move", "route", "checkMonsters", "attack", "items_take", "take", "items_gather");
}

sub AI_pre {
	AI_pre_market();
	AI_pre_buying();
	AI_pre_fallback();
	AI_pre_Talk_fallback();
	AI_pre_autoRefine();
	AI_pre_buyer();
	AI_pre_determine_selling();
	AI_pre_selling();
}

sub sell_queue {
	storage_buy_sell_clear_route();
	AI::clear("sellAuto");
	AI::queue("determine_selling");
}

sub AI_storage_done_after_getAuto {
	my ($hook, $retargs) = @_;
	
	my $args = AI::args;
	
	my %internal_args = ( return => 0 );
	
	if (!exists $args->{end_passiveGetAuto}) {
		$args->{end_passiveGetAuto} = 0;
		warning "[Storage] Start AI_storage_done_after_getAuto_passiveGetAuto\n";
	}
	if ($args->{end_passiveGetAuto} == 0) {
		AI_storage_done_after_getAuto_passiveGetAuto(\%internal_args);
		if ($internal_args{return} == 1) {
			$retargs->{return} = 1;
			return;
		} else {
			$args->{end_passiveGetAuto} = 1;
			warning "[Storage] End AI_storage_done_after_getAuto_passiveGetAuto\n";
		}
	}
	
	unless ($args->{'forcedBySell'} == 1) {
		if (!exists $args->{end_BetterSeller}) {
			$args->{end_BetterSeller} = 0;
			warning "[Storage] Start AI_storage_done_after_getAuto Betterseller\n";
		}
		if ($args->{end_BetterSeller} == 0) {
			AI_storage_done_after_getAuto_BetterSeller(\%internal_args);
			if ($internal_args{return} == 1) {
				$retargs->{return} = 1;
				return;
			} else {
				$args->{end_BetterSeller} = 1;
				warning "[Storage] End AI_storage_done_after_getAuto Betterseller\n";
			}
		}
		
		if (!exists $args->{end_scourgeStorage}) {
			$args->{end_scourgeStorage} = 0;
			warning "[Storage] Start AI_storage_done_after_getAuto_scourgeStorage\n";
		}
		if ($args->{end_scourgeStorage} == 0) {
			AI_storage_done_after_getAuto_scourgeStorage(\%internal_args);
			if ($internal_args{return} == 1) {
				$retargs->{return} = 1;
				return;
			} else {
				$args->{end_scourgeStorage} = 1;
				warning "[Storage] End AI_storage_done_after_getAuto_scourgeStorage\n";
			}
		}
	}
}

sub AI_storage_done_after_getAuto_scourgeStorage {
	my ($retargs) = @_;
	
	
	my $args = AI::args;
	$retargs->{return} = 1;
	
	$args->{scourgeStorageNextItem} = 0 unless $args->{scourgeStorageNextItem};
	for (my $i = $args->{scourgeStorageNextItem}; $i < $char->storage->size; $i++) {
		my $item = $char->storage->[$i];
		#warning "[Storage] [scourgeStorage] $i - $item\n";
		
		my $control = items_control($item->{name}, $item->{nameID});
		
		next unless ($control->{'sell'});
		#warning "[Storage] [scourgeStorage] control is sell\n";
		
		my $nameID = $item->{nameID};
		
		my $invItem = $char->inventory->getByNameID($nameID);
		my $invAmount = $char->inventory->sumByNameID($nameID);
		my $storeItem = $char->storage->getByNameID($nameID);
		my $storeAmount = $storeItem->{amount};
		#warning "[Storage] [scourgeStorage] invAmount $invAmount | storeAmount $storeAmount\n";
		
		my %item;
		$item{name} = Misc::itemName($item);
		$item{inventory}{index} = $invItem ? $invItem->{binID} : undef;
		$item{inventory}{amount} = $invItem ? $invAmount : 0;
		$item{storage}{index} = $storeItem ? $storeItem->{binID} : undef;
		$item{storage}{amount} = $storeItem ? $storeAmount : 0;
		$item{max_amount} = MAX_ITEM_AMOUNT;
		$item{amount_needed} = $item{max_amount} - $item{inventory}{amount};
		$item{amount_get} = 0;
		$args->{retry} = 0;
	
		if ($item{amount_needed} > 0) {
			$item{amount_get} = ($item{storage}{amount} >= $item{amount_needed})? $item{amount_needed} : $item{storage}{amount};
		}
		
		my $current_weight = $char->{weight};
		my $weight_cap = ($char->{weight_max}*(80/100));
		my $current_inv_size = $char->inventory->size();

		# Calculate the amount to get
		
		if (($item{amount_get} > 0) && $current_inv_size == MAX_INVENTORY_SIZE) {
			$item{amount_get} = 0;
		}
		
		if (($item{amount_get} > 0) && $invAmount == MAX_ITEM_AMOUNT) {
			$item{amount_get} = 0;
			
		} elsif (($item{amount_get} > 0) && (($item{amount_get} + $invAmount) > MAX_ITEM_AMOUNT)) {
			$item{amount_get} = (MAX_ITEM_AMOUNT - $invAmount);
		}
		
		if (($item{amount_get} > 0) && $storeAmount > 0) {
			my $item_weight = $storeItem->weight;
			if (defined $item_weight) {
				$item_weight = $item_weight/10;
				if (((($item{amount_get} * $item_weight) + $current_weight) > $weight_cap)) {
					$item{amount_get} = (floor($weight_cap - $current_weight/$item_weight));
				}
			}
		}
		#warning "[Storage] [scourgeStorage] item{amount_get} $item{amount_get}\n";
		
		if (($item{amount_get} > 0) && ($args->{retry} < 3)) {
			warning "[Storage] [scourgeStorage] send get $item{name} x $item{amount_get}\n";
			$messageSender->sendStorageGet($storeItem->{ID}, $item{amount_get});
			$timeout{ai_storageAuto}{time} = time;
			$args->{retry}++;
			$args->{scourgeStorageNextItem} = $i;
			return;
		}
	}
	$retargs->{return} = 0;
}

sub AI_storage_done_after_getAuto_passiveGetAuto {
	my ($retargs) = @_;
	
	my $args = AI::args;
	$retargs->{return} = 1;
	
	$args->{passiveGetAutoNextItem} = 0 unless $args->{passiveGetAutoNextItem};
	for (my $i = $args->{passiveGetAutoNextItem}; $i < $char->storage->size; $i++) {
		my $item = $char->storage->[$i];
		my $control = items_control($item->{name}, $item->{nameID});
		
		next unless ($control->{keep} > 0);
		
		my $nameID = $item->{nameID};
		
		my $invItem = $char->inventory->getByNameID($nameID);
		my $invAmount = $char->inventory->sumByNameID($nameID);
		my $storeItem = $char->storage->getByNameID($nameID);
		my $storeAmount = $char->storage->sumByNameID($nameID);
		
		next unless ($control->{keep} > $invAmount);
		
		my %item;
		$item{name} = Misc::itemName($item);
		$item{inventory}{index} = $invItem ? $invItem->{binID} : undef;
		$item{inventory}{amount} = $invItem ? $invAmount : 0;
		$item{storage}{index} = $storeItem ? $storeItem->{binID} : undef;
		$item{storage}{amount} = $storeItem ? $storeAmount : 0;
		$item{max_amount} = $control->{keep};
		$item{amount_needed} = $item{max_amount} - $item{inventory}{amount};
		$item{amount_get} = 0;
		$args->{retry} = 0;
	
		if ($item{amount_needed} > 0) {
			$item{amount_get} = ($item{storage}{amount} >= $item{amount_needed})? $item{amount_needed} : $item{storage}{amount};
		}
		
		my $current_weight = $char->{weight};
		my $weight_cap = ($char->{weight_max}*(80/100));
		my $current_inv_size = $char->inventory->size();

		# Calculate the amount to get
		
		if (($item{amount_get} > 0) && $current_inv_size == MAX_INVENTORY_SIZE) {
			$item{amount_get} = 0;
		}
		
		if (($item{amount_get} > 0) && $invAmount == MAX_ITEM_AMOUNT) {
			$item{amount_get} = 0;
			
		} elsif (($item{amount_get} > 0) && (($item{amount_get} + $invAmount) > MAX_ITEM_AMOUNT)) {
			$item{amount_get} = (MAX_ITEM_AMOUNT - $invAmount);
		}
		
		if (($item{amount_get} > 0) && $storeAmount > 0) {
			my $item_weight = $storeItem->weight;
			if (defined $item_weight) {
				$item_weight = $item_weight/10;
				if (((($item{amount_get} * $item_weight) + $current_weight) > $weight_cap)) {
					$item{amount_get} = (floor($weight_cap - $current_weight/$item_weight));
				}
			}
		}
		
		if (($item{amount_get} > 0) && ($args->{retry} < 3)) {
			warning "[Storage] [passiveGetAuto] send get $item{name} x $item{amount_get}\n";
			$messageSender->sendStorageGet($storeItem->{ID}, $item{amount_get});
			$timeout{ai_storageAuto}{time} = time;
			$args->{retry}++;
			$args->{passiveGetAutoNextItem} = $i;
			return;
		}
	}
	$retargs->{return} = 0;
}

sub AI_storage_done_after_getAuto_BetterSeller {
	my ($retargs) = @_;
	
	my $args = AI::args;
	
	$retargs->{return} = 1;
	
	if (!defined $args->{GetAutoBetterSeller}) {
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
		$args->{GetAutoBetterSeller} = $current_buyer_item_id;
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
	$item{amount_get} = 0;
	
	if ($item{amount_needed} > 0) {
		$item{amount_get} = ($item{storage}{amount} >= $item{amount_needed})? $item{amount_needed} : $item{storage}{amount};
	}
	
	my $current_weight = $char->{weight};
	my $weight_cap = ($char->{weight_max}*(80/100));
	my $current_inv_size = $char->inventory->size();

	# Calculate the amount to get
	
	if (($item{amount_get} > 0) && $current_inv_size == MAX_INVENTORY_SIZE) {
		$item{amount_get} = 0;
	}
	
	if (($item{amount_get} > 0) && $invAmount == MAX_ITEM_AMOUNT) {
		$item{amount_get} = 0;
		
	} elsif (($item{amount_get} > 0) && (($item{amount_get} + $invAmount) > MAX_ITEM_AMOUNT)) {
		$item{amount_get} = (MAX_ITEM_AMOUNT - $invAmount);
	}
	
	if (($item{amount_get} > 0) && $storeAmount > 0) {
		my $item_weight = $storeItem->weight;
		if (defined $item_weight) {
			$item_weight = $item_weight/10;
			if (((($item{amount_get} * $item_weight) + $current_weight) > $weight_cap)) {
				$item{amount_get} = (floor($weight_cap - $current_weight/$item_weight));
			}
		}
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
	undef $args->{GetAutoBetterSeller};
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
	return unless (exists $config{$item_prefix} && defined $config{$item_prefix});
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
	return unless (exists $config{$item_prefix} && defined $config{$item_prefix});
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
			} elsif ($args->{message} =~ /^\+\d (\d+)\[\d+\] \| Cost: (\d+)z \| Qty: (\d+) \| Map: (.+) \[(\d+) , (\d+)\] \| Seller: (.+)$/) {
				#+0 2339[0] | Cost: 9999z | Qty: 1 | Map: aldebaran [150 , 122] | Seller: Alfamart
				$store_found{id} = $1;
				$store_found{Cost} = $2;
				$store_found{quant} = $3;
				$store_found{Map} = $4;
				$store_found{x} = $5;
				$store_found{y} = $6;
				$store_found{Seller} = $7;
			} elsif ($args->{message} =~ /^\+\d (\d+)\[\d+,\d+,\d+,\d+\] \| Cost: (\d+)z \| Qty: (\d+) \| Map: (.+) \[(\d+)\s?,\s?(\d+)\] \| Seller: (.+)$/) {
				#+0 1222[255,2564,26473,2] | Cost: 1800000z | Qty: 1 | Map: aldebaran [119, 124] | Seller: inday garutay
				#+0 1220[0,0,0,0] | Cost: 450000z | Qty: 1 | Map: oldnewpayon [42, 142] | Seller: Nieglueck
				#+0 1216[255,2561,27755,2] | Cost: 866900z | Qty: 1 | Map: aldebaran [150, 116] | Seller: Elbenpath
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
		&& !%talk
		&& !exists $ai_v{'npc_talk'}
		&& !AI::inQueue("skill_use")
		&& !AI::inQueue("eventMacro")
		&& !AI::inQueue("Shopping")
		&& !AI::inQueue("Shopping_fallBack")
		&& !AI::inQueue("Shopping_Talk_fallBack")
		&& !AI::inQueue("autoRefine")
		&& !AI::inQueue("determine_selling")
		&& !AI::inQueue("BetterSeller")
		&& main::timeOut($timeout{'Shopping'})
	) {
		$timeout{'Shopping'}{'time'} = time;
		$timeout{'Shopping'}{'timeout'} = 1;
		my $i = 0;
		my $bai;
		my $tprice;
		for($i = 0; exists $config{"BetterShopper_$i"}; $i++) {
			next if (!$config{"BetterShopper_$i"} || $config{"BetterShopper_${i}_disabled"});
			
			my $item_prefix = "BetterShopper_$i";
			my $itemID = $config{$item_prefix};
			
			my $amount;
			my $cart_amount;
			
			$amount = $char->inventory->sumByNameID($itemID, 1);
			$cart_amount = $char->cart->sumByNameID($itemID, 1);
			
			my $char_total = $amount + $cart_amount;
			
			next unless ($config{$item_prefix."_minInventoryAmount"} ne "" && defined $config{$item_prefix."_minInventoryAmount"});
			my $minInventoryAmount = $config{$item_prefix."_minInventoryAmount"};
			
			next unless ($config{$item_prefix."_maxAmount"} ne "" && defined $config{$item_prefix."_maxAmount"});
			my $maxAmount = $config{$item_prefix."_maxAmount"};
			
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
				} elsif ($config{$item_prefix."_fallbackNpcShop"}) {
					my $price_per_amount = $config{$item_prefix."_price"};
					my $total_price = $price_per_amount * $amount_need_buy;
					#warning "[Better Test] (".GetItemName($itemID).") 42 - char->{zeny} $char->{zeny} | total_price $total_price\n";
					if ($char->{zeny} >= $total_price) {
						if (!exists $shopper_npc_fallback_items{$itemID}) {
							$shopper_npc_fallback_items{$itemID}{'index'} = $i;
							$shopper_npc_fallback_items{$itemID}{'item'} = $itemID;
							$shopper_npc_fallback_items{$itemID}{'npc'} = $config{$item_prefix."_fallbackNpcShop"};
							$shopper_npc_fallback_items{$itemID}{'totalprice'} = $total_price;
							warning "Adding item ".$itemID." to fallbackNpcShop list\n";
						}
					}
				} elsif ($config{$item_prefix."_fallbackNpcTalk"}) {
					my $price_per_amount = $config{$item_prefix."_price"};
					my $total_price = $price_per_amount * $amount_need_buy;
					#warning "[Better Test fallbackNpcTalk] (".GetItemName($itemID).") - char->{zeny} $char->{zeny} | total_price $total_price\n";
					if ($char->{zeny} >= $total_price) {
						if (!exists $shopper_npcTalk_fallback_items{$itemID}) {
							$shopper_npcTalk_fallback_items{$itemID}{'index'} = $i;
							$shopper_npcTalk_fallback_items{$itemID}{'item'} = $itemID;
							$shopper_npcTalk_fallback_items{$itemID}{'npc'} = $config{$item_prefix."_fallbackNpcTalk"};
							$shopper_npcTalk_fallback_items{$itemID}{'sequence'} = $config{$item_prefix."_fallbackNpcTSequence"};
							$shopper_npcTalk_fallback_items{$itemID}{'totalprice'} = $total_price;
							warning "Adding item ".$itemID." to fallbackNpcTalk list\n";
						}
					}
				}
			}
		}
		return unless (defined $bai);
		AI::clear("move", "route", "checkMonsters");
		
		my $command = $config{"BetterShopper_".$bai."_commandAfterBuy"};
		AI::queue("Shopping", { Better_index => $bai, item => $config{"BetterShopper_$bai"}, needed_zeny => $tprice, command => $command });
		$buy_from_player_sucess = 0;
		$buy_from_player_fail = 0;
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
		unshift(@sellers_query_queue, $prefixN);
		
		return unless (defined $args->{command});
		Log::warning "[".PLUGIN_NAME."] Running command on end: '$args->{command}'\n";
		Commands::run($args->{command}) if (defined $args->{command});

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
			
			my $inv_amount = $char->inventory->sumByNameID($nameID, 1);
			next if ($inv_amount == MAX_ITEM_AMOUNT);
			
			my $cart_amount = $char->cart->sumByNameID($nameID, 1);
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
		&& !%talk
		&& !exists $ai_v{'npc_talk'}
		&& !AI::inQueue("skill_use")
		&& !AI::inQueue("eventMacro")
		&& !AI::inQueue("Shopping")
		&& !AI::inQueue("Shopping_fallBack")
		&& !AI::inQueue("Shopping_Talk_fallBack")
		&& !AI::inQueue("autoRefine")
		&& !AI::inQueue("determine_selling")
		&& !AI::inQueue("BetterSeller")
		&& timeOut($timeout{'ai_Shopping_fallBack'})
	) {
		$timeout{'ai_Shopping_fallBack'}{'time'} = time;
		$timeout{'ai_Shopping_fallBack'}{'timeout'} = 1;
		my @delete_ids;
		my $bai;
		my $tprice;
		my $found_fallback_id;
		foreach my $fallback_id (keys %shopper_npc_fallback_items) {
			my $fallback_item = $shopper_npc_fallback_items{$fallback_id};
			
			my $i = $fallback_item->{'index'};
			
			my $item_prefix = "BetterShopper_$i";
			my $itemID = $config{$item_prefix};
			
			my $savedID = $fallback_item->{'item'};
			
			unless (exists $config{$item_prefix} && defined $config{$item_prefix} && $config{$item_prefix} == $savedID) {
				push(@delete_ids, $fallback_id);
				next;
			}
			
			unless ($config{$item_prefix."_minInventoryAmount"} ne "" && defined $config{$item_prefix."_minInventoryAmount"} ne "") {
				push(@delete_ids, $fallback_id);
				next;
			}
			my $minInventoryAmount = $config{$item_prefix."_minInventoryAmount"};
			
			unless ($config{$item_prefix."_maxAmount"} ne "" && defined $config{$item_prefix."_maxAmount"} ne "") {
				push(@delete_ids, $fallback_id);
				next;
			}
			my $maxAmount = $config{$item_prefix."_maxAmount"};
			
			my $amount;
			my $cart_amount;
			
			$amount = $char->inventory->sumByNameID($fallback_id, 1);
			$cart_amount = $char->cart->sumByNameID($fallback_id, 1);
			
			my $char_total = $amount + $cart_amount;
			
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
					$found_fallback_id = $fallback_id;
					warning "[SUCESS] fallback ".$itemID." being created\n";
					last;
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
		
		my $command = $config{"BetterShopper_".$bai."_commandAfterBuy"};
		AI::queue("Shopping_fallBack", { Better_index => $bai, item => $config{"BetterShopper_$bai"}, needed_zeny => $tprice, command => $command });
		$buy_fallback_sucess = 0;
		$buy_fallback_fail = 0;
		delete $shopper_npc_fallback_items{$found_fallback_id}; #TODO: Should we delete here?
		warning "Deleting fallback ".$found_fallback_id." on success\n";
	}

	if (AI::action eq "Shopping_fallBack" && AI::args->{'done'}) {
		my $args = AI::args;

		if (exists AI::args->{'error'}) {
			error AI::args->{'error'}.".\n";
		}

		# Shopping_fallBack finished
		AI::dequeue while AI::inQueue("Shopping_fallBack");
		
		return unless (defined $args->{command});
		Log::warning "[".PLUGIN_NAME."] Running command on end: '$args->{command}'\n";
		Commands::run($args->{command}) if (defined $args->{command});

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
		
		unless (exists $config{$prefixN} && defined $config{$prefixN} && $config{$prefixN} == $args->{item}) {
			$args->{'error'} = 'Config key '.$prefixN.' is not defined anymore';
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
			my $destination = $config{$prefixN."_fallbackNpcShop"};
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
			my $destination = $config{"BetterShopper_".$args->{lastIndex}."_fallbackNpcShop"};
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

			my $inv_amount = $char->inventory->sumByNameID($args->{'nameID'}, 1);

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

sub AI_pre_Talk_fallback {
	if (
		   $char->inventory->isReady()
		&& $config{BetterShopper_on}
		&& (AI::isIdle || AI::action eq "route" || AI::action eq "move" || AI::action eq "checkMonsters" || AI::action eq "sitAuto")
		&& !AI::inQueue("storageAuto")
		&& !AI::inQueue("buyAuto")
		&& !AI::inQueue("sellAuto")
		&& !AI::inQueue("teleport", "NPC")
		&& !%talk
		&& !exists $ai_v{'npc_talk'}
		&& !AI::inQueue("skill_use")
		&& !AI::inQueue("eventMacro")
		&& !AI::inQueue("Shopping")
		&& !AI::inQueue("Shopping_fallBack")
		&& !AI::inQueue("Shopping_Talk_fallBack")
		&& !AI::inQueue("autoRefine")
		&& !AI::inQueue("determine_selling")
		&& !AI::inQueue("BetterSeller")
		&& timeOut($timeout{'ai_Shopping_Talk_fallBack'})
	) {
		$timeout{'ai_Shopping_Talk_fallBack'}{'time'} = time;
		$timeout{'ai_Shopping_Talk_fallBack'}{'timeout'} = 1;
		my @delete_ids;
		my $bai;
		my $tprice;
		my $tamount_need_buy;
		my $found_fallback_id;
		foreach my $fallback_id (keys %shopper_npcTalk_fallback_items) {
			my $fallback_item = $shopper_npcTalk_fallback_items{$fallback_id};
			
			my $i = $fallback_item->{'index'};
			
			my $item_prefix = "BetterShopper_$i";
			my $itemID = $config{$item_prefix};
			
			my $savedID = $fallback_item->{'item'};
			
			unless (exists $config{$item_prefix} && defined $config{$item_prefix} && $config{$item_prefix} == $savedID) {
				push(@delete_ids, $fallback_id);
				next;
			}
			
			unless ($config{$item_prefix."_minInventoryAmount"} ne "" && defined $config{$item_prefix."_minInventoryAmount"} ne "") {
				push(@delete_ids, $fallback_id);
				next;
			}
			my $minInventoryAmount = $config{$item_prefix."_minInventoryAmount"};
			
			unless ($config{$item_prefix."_maxAmount"} ne "" && defined $config{$item_prefix."_maxAmount"} ne "") {
				push(@delete_ids, $fallback_id);
				next;
			}
			my $maxAmount = $config{$item_prefix."_maxAmount"};
			
			my $amount;
			my $cart_amount;
			
			$amount = $char->inventory->sumByNameID($fallback_id, 1);
			$cart_amount = $char->cart->sumByNameID($fallback_id, 1);
			
			my $char_total = $amount + $cart_amount;
			
			#warning "[fallbackNpcTalk Test] (".GetItemName($itemID).") 2 - char_total $char_total | min $minInventoryAmount | max $maxAmount\n";
			
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
				#warning "[fallbackNpcTalk Test] (".GetItemName($itemID).") 3 - char->{zeny} $char->{zeny} | total_price $total_price\n";
				if ($char->{zeny} >= $total_price) {
					$bai = $i;
					$tprice = $total_price;
					$tamount_need_buy = $amount_need_buy;
					$found_fallback_id = $fallback_id;
					warning "[SUCESS] fallbackNpcTalk ".$itemID." being created\n";
					last;
				} else {
					#warning "[FAIL] fallbackNpcTalk ".$itemID." failed money\n";
					push(@delete_ids, $fallback_id);
				}
			} else {
				#warning "[FAIL] fallbackNpcTalk ".$itemID." failed amounts\n";
				push(@delete_ids, $fallback_id);
			}
		}
		foreach my $del (@delete_ids) {
			warning "Deleting fallbackNpcTalk ".$del."\n";
			delete $shopper_npcTalk_fallback_items{$del};
		}
		
		return unless (defined $bai);
		AI::clear("move", "route", "checkMonsters");
		
		my $command = $config{"BetterShopper_".$bai."_commandAfterBuy"};
		AI::queue("Shopping_Talk_fallBack", { Better_index => $bai, item => $config{"BetterShopper_$bai"}, needed_zeny => $tprice, amount => $tamount_need_buy, command => $command });
		$buy_Talk_fallback_sucess = 0;
		$buy_Talk_fallback_fail = 0;
		delete $shopper_npcTalk_fallback_items{$found_fallback_id}; #TODO: Should we delete here?
		warning "Deleting fallbackNpcTalk ".$found_fallback_id." on success\n";
	}

	if (AI::action eq "Shopping_Talk_fallBack" && AI::args->{'done'}) {
		my $args = AI::args;

		if (exists AI::args->{'error'}) {
			error AI::args->{'error'}.".\n";
		}

		# Shopping_Talk_fallBack finished
		AI::dequeue while AI::inQueue("Shopping_Talk_fallBack");
		
		return unless (defined $args->{command});
		Log::warning "[".PLUGIN_NAME."] Running command on end: '$args->{command}'\n";
		Commands::run($args->{command}) if (defined $args->{command});

	} elsif (AI::action eq "Shopping_Talk_fallBack" && timeOut($timeout{ai_Shopping_Talk_fallBack_wait}, $timeout{ai_buyAuto_wait}{timeout})) {
		my $args = AI::args;
		
		$args->{index} = $args->{Better_index};
		#$args->{needed_zeny}
		my $prefixN = "BetterShopper_".$args->{Better_index};
		my $prefix = $config{$prefixN};
		
		if ($buy_Talk_fallback_sucess == 1) {
			Log::warning "[$prefix] Sucesssssss CARAIO!!!\n";
			$args->{'done'} = 1;
			return;
		}
		
		if ($buy_Talk_fallback_fail == 1) {
			$args->{'error'} = "[$prefix] Buy failed";
			$args->{'done'} = 1;
			return;
		}
		
		if ($char->{zeny} < $args->{needed_zeny}) {
			$args->{'error'} = 'We do not have enough zeny anymore';
			$args->{'done'} = 1;
			return;
		}
		
		unless (exists $config{$prefixN} && defined $config{$prefixN} && $config{$prefixN} == $args->{item}) {
			$args->{'error'} = 'Config key '.$prefixN.' is not defined anymore';
			$args->{'done'} = 1;
			return;
		}
		
		if (exists $args->{sentNpcTalk}) {
			if (
				timeOut($args->{sentNpcTalk_time}, 15) &&
				!$buy_Talk_fallback_sucess &&
				!$buy_Talk_fallback_fail
			) {
				$args->{'error'} = 'Did not received the buy result from server after buy packet was sent';
				$args->{'done'} = 1;
			}
			return;
		}

		if (!exists $args->{lastIndex}) {
			#warning "[test 0] args->{Better_index} $args->{Better_index} | prefixN $prefixN | prefix $prefix\n";
			
			$args->{npc} = {};
			my $destination = $config{$prefixN."_fallbackNpcTalk"};
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
					$timeout{ai_Shopping_Talk_fallBack_wait}{time} = time;

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
			my $destination = $config{"BetterShopper_".$args->{lastIndex}."_fallbackNpcTalk"};
			#warning "[test 2] dest is $destination\n";
			getNPCInfo($destination, $realpos);
			
			my $sequence = $config{"BetterShopper_".$args->{lastIndex}."_fallbackNpcTSequence"};
			$sequence =~ s/-amount-/ d$args->{amount} /;
			$sequence =~ s/ $//g;
			
			undef %sent_buy_talk;
			$buy_Talk_fallback_sucess = 0;
			$buy_Talk_fallback_fail = 0;
			
			$sent_buy_talk{item} = GetItemName($args->{item});
			$sent_buy_talk{amount} = $args->{amount};
			
			warning "[BS Talk] Sending talk to buy $sent_buy_talk{item} ($args->{item}) x $args->{amount}. Sequence '$sequence'.";

			ai_talkNPC($realpos->{pos}{x}, $realpos->{pos}{y}, $sequence);

			$args->{'sentNpcTalk'} = 1;
			$args->{'sentNpcTalk_time'} = time;

			return;

		}
	}
}

sub AI_pre_autoRefine {
	if (
		   $char->inventory->isReady()
		&& $config{autoRefine_on}
		&& (AI::isIdle || AI::action eq "route" || AI::action eq "move" || AI::action eq "checkMonsters" || AI::action eq "sitAuto")
		&& !AI::inQueue("storageAuto")
		&& !AI::inQueue("buyAuto")
		&& !AI::inQueue("sellAuto")
		&& !AI::inQueue("teleport", "NPC")
		&& !%talk
		&& !exists $ai_v{'npc_talk'}
		&& !AI::inQueue("skill_use")
		&& !AI::inQueue("eventMacro")
		&& !AI::inQueue("Shopping")
		&& !AI::inQueue("Shopping_fallBack")
		&& !AI::inQueue("Shopping_Talk_fallBack")
		&& !AI::inQueue("autoRefine")
		&& !AI::inQueue("determine_selling")
		&& !AI::inQueue("BetterSeller")
		&& timeOut($timeout{'ai_autoRefine'})
	) {
		$timeout{'ai_autoRefine'}{'time'} = time;
		$timeout{'ai_autoRefine'}{'timeout'} = 1;
		
		my $weapon_level = $config{autoRefine_weaponLevel};
		my $wanted_refine = $config{autoRefine_wantedRefine};
		my $current_refine = $char->{equipment}{'rightHand'}{upgrade};
		#warning "[autoRefine Test] weapon_level $weapon_level | wanted_refine $wanted_refine | current_refine $current_refine\n";
		
		return if ($current_refine >= $wanted_refine);
		
		my $need_refine_count = $wanted_refine - $current_refine;
		#warning "[autoRefine Test] need_refine_count $need_refine_count\n";
		
		my $price_per_refine;
		if ($weapon_level == 1) {
			$price_per_refine = 50;
		} elsif ($weapon_level == 2) {
			$price_per_refine = 200;
		} elsif ($weapon_level == 3) {
			$price_per_refine = 5000;
		} elsif ($weapon_level == 4) {
			$price_per_refine = 20000;
		}
		my $total_cost = $price_per_refine * $need_refine_count;
		#warning "[autoRefine Test] total_cost $total_cost\n";
		
		return unless ($char->{zeny} >= $total_cost);
		
		my $id;
		if ($weapon_level == 1) {
			$id = 1010;
		} elsif ($weapon_level == 2) {
			$id = 1011;
		} elsif ($weapon_level == 3) {
			$id = 984;
		} elsif ($weapon_level == 4) {
			$id = 984;
		}
		my $refine_item_amount = $char->inventory->sumByNameID($id);
		#warning "[autoRefine Test] refine_item_amount $refine_item_amount\n";
		
		return unless ($refine_item_amount >= $need_refine_count);
		
		my $command = $config{autoRefine_commandOnSuccess};
		my $npc_config = $config{autoRefine_npc};
		
		AI::clear("move", "route", "checkMonsters");
		AI::queue("autoRefine", { 
			needed_zeny => $total_cost,
			weapon_id => $char->{equipment}{'rightHand'}{nameID},
			weapon_refine_original => $current_refine,
			weapon_refine_wanted => $wanted_refine,
			refine_id => $id,
			refine_amount_needed => $need_refine_count,
			command => $command,
			weaponLevel => $weapon_level,
			npc_config => $npc_config
		});
		
		$refine_sucess = 0;#check
		$refine_fail = 0;#check
	}

	if (AI::action eq "autoRefine" && AI::args->{'done'}) {
		my $args = AI::args;

		if (exists AI::args->{'error'}) {
			error AI::args->{'error'}.".\n";
		}

		# autoRefine finished
		AI::dequeue while AI::inQueue("autoRefine");
		
		return unless (defined $args->{command});
		Log::warning "[autoRefine] Running command on end: '$args->{command}'\n";
		Commands::run($args->{command}) if (defined $args->{command});

	} elsif ($char->inventory->isReady() && AI::action eq "autoRefine" && timeOut($timeout{ai_autoRefine_wait}, $timeout{ai_buyAuto_wait}{timeout})) {
		my $args = AI::args;
		
		$args->{index} = 1;
		my $prefix = 'autoRefine';
		
		my $weapon = $char->{equipment}{'rightHand'};
		
		unless (exists $config{autoRefine_on} && defined $config{autoRefine_on} && $config{autoRefine_on} == 1) {
			$args->{'error'} = 'Config key autoRefine_on is not 1 anymore';
			$args->{'done'} = 1;
			return;
		}
		
		unless ($config{autoRefine_weaponLevel} == $args->{weaponLevel}) {
			$args->{'error'} = 'Config key autoRefine_weaponLevel changed';
			$args->{'done'} = 1;
			return;
		}
		
		unless ($config{autoRefine_wantedRefine} == $args->{weapon_refine_wanted}) {
			$args->{'error'} = 'Config key autoRefine_wantedRefine changed';
			$args->{'done'} = 1;
			return;
		}
		
		unless ($config{autoRefine_commandOnSuccess} eq $args->{command}) {
			$args->{'error'} = 'Config key autoRefine_commandOnSuccess changed';
			$args->{'done'} = 1;
			return;
		}
		
		unless ($config{autoRefine_npc} eq $args->{npc_config}) {
			$args->{'error'} = 'Config key autoRefine_npc changed ('.$args->{npc_config}.') -> ('.$config{autoRefine_npc}.')';
			$args->{'done'} = 1;
			return;
		}
		
		unless ($weapon && $weapon->{nameID} == $args->{weapon_id}) {
			$args->{'error'} = 'Weapon changed';
			$args->{'done'} = 1;
			return;
		}
		
		my $current_refine = $weapon->{upgrade};
		
		if ($current_refine >= $args->{weapon_refine_wanted}) {
			Log::warning "[$prefix] Sucesssssss CARAIO!!!\n";
			$args->{'done'} = 1;
			return;
		}
		
		my $refine_item_amount = $char->inventory->sumByNameID($args->{refine_id});
		
		unless ($refine_item_amount >= $args->{refine_amount_needed}) {
			$args->{'error'} = 'We do not have enough refine materials anymore';
			$args->{'done'} = 1;
			return;
		}
		
		if ($refine_sucess == 1) {
			Log::warning "[$prefix] Sucesssssss CARAIO!!!\n";
			$args->{'done'} = 1;
			return;
		}
		
		if ($refine_fail == 1) {
			$args->{'error'} = "[$prefix] Buy failed";
			$args->{'done'} = 1;
			return;
		}
		
		if ($char->{zeny} < $args->{needed_zeny}) {
			$args->{'error'} = 'We do not have enough zeny anymore';
			$args->{'done'} = 1;
			return;
		}
		
		if (exists $args->{sentNpcTalk}) {
			if (
				timeOut($args->{sentNpcTalk_time}, 15) &&
				!$refine_sucess &&
				!$refine_fail
			) {
				$args->{'error'} = 'Did not received the buy result from server after buy packet was sent';
				$args->{'done'} = 1;
			}
			return;
		}

		if (!exists $args->{lastIndex}) {
			
			$args->{npc} = {};
			my $destination = $config{autoRefine_npc};
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
					$timeout{ai_autoRefine_wait}{time} = time;

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
			my $destination = $config{autoRefine_npc};
			getNPCInfo($destination, $realpos);
			
			my $sequence = 'r~/Right/i r~/Safe/i r~/Yes/i';
			#talk resp~/2  Right hand-[Stiletto]/
			#0  To the safe limit, please.
			#0  Yes
			
			$refine_sucess = 0;
			$refine_fail = 0;
			
			warning "[BS Talk] Sending talk to refine. Sequence '$sequence'.";

			ai_talkNPC($realpos->{pos}{x}, $realpos->{pos}{y}, $sequence);

			$args->{'sentNpcTalk'} = 1;
			$args->{'sentNpcTalk_time'} = time;

			return;

		}
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

sub possible_buy_success_talk {
	my ($packet, $args) = @_;
	return unless (keys %sent_buy_talk);
	my $item_name = $args->{item};
	my $amount = $args->{amount};
	
	my $b_item_name = $sent_buy_talk{item};
	my $b_amount = $sent_buy_talk{amount};
	
	if ($b_item_name eq $item_name && $b_amount == $amount) {
		message "[".PLUGIN_NAME."] Successfully bought ".$b_item_name." x $amount.\n";
		$buy_Talk_fallback_sucess = 1;
	}
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

