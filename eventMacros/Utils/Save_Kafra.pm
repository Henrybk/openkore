

#### Kafra Save
automacro set_savemap_variables {
	exclusive 1
	run-once 1
	ConfigKey eventMacro_1_99_stage saving_in_kafra
	priority 0
	call {
		$saveMap = &config(future_saveMap_kafra_map)
		log [set_savemap_variables] future_saveMap_kafra_map is $saveMap
	}
}

automacro something_went_wrong_kafra {
	exclusive 1
	priority 1
	ConfigKey eventMacro_1_99_stage saving_in_kafra
	ConfigKey saveMap $saveMap
	call {
		call clear_saveMap_keys
		
		do conf -f eventMacro_1_99_stage &config(saveMap_stage_before)
		do conf -f saveMap_stage_before none
		
		include off Save_Kafra.pm
		include on &config(before_event_include)
		
		do conf -f current_event_include &config(before_event_include)
		do conf -f before_event_include none
		
		do reload eventMacros
	}
}

automacro moveLocKafraOutside {
	exclusive 1
	priority 1
	ConfigKey eventMacro_1_99_stage saving_in_kafra
	ConfigKeyNot future_saveMap_kafra_map none
	ConfigKeyNot saveMap $saveMap
	NotInMap $saveMap
	call move_to_near_kafra
}

automacro moveLocKafraInside {
	exclusive 1
	priority 1
	ConfigKeyNot saveMap $saveMap
	ConfigKeyNot future_saveMap_kafra_map none
	NpcNotNear /^Kafra Employee$/
	InMap $saveMap
	call move_to_near_kafra
}

macro move_to_near_kafra {
	do move &config(future_saveMap_kafra_map) &config(future_saveMap_kafra_x) &config(future_saveMap_kafra_y) &random("1","2","3","4","5","6")
}

automacro talkKafra {
	exclusive 0
	self_interruptible 0
	ConfigKey eventMacro_1_99_stage saving_in_kafra
	ConfigKeyNot saveMap $saveMap
	ConfigKeyNot future_saveMap_kafra_map none
	InMap $saveMap
	NpcNear /^Kafra Employee$/
	delay 2
	timeout 10
	call {
		log talking to kafra at '&arg("$.NpcNearLastPos", 1) &arg("$.NpcNearLastPos", 2)' using sequence '&config(future_saveMap_save_sequence)'
		do talknpc &arg("$.NpcNearLastPos", 1) &arg("$.NpcNearLastPos", 2) &config(future_saveMap_save_sequence)
	}
}

macro set_Redpotion {
	[
	$item{id} = 501
	$item{price} = 50
	$item{maxPrice} = 45
	$item{minInventoryAmount} = 5
	$item{maxAmount} = 30
	$item{minLevel} = 1
	$item{maxLevel} = 55
	call set_item_usable
	call set_buy_item_usable
	
	do iconf $item{id} $item{maxAmount} 1 0
	
	$name = GetNamebyNameID("$item{id}")
	$nextFreeSlot = get_free_slot_index_for_key("useSelf_item","$name")
	do conf -f useSelf_item_$nextFreeSlot $name
	do conf -f useSelf_item_$nextFreeSlot_disabled 0
	do conf -f useSelf_item_$nextFreeSlot_hp < 70%
	]
}

macro set_Orangepotion {
	[
	$item{id} = 502
	$item{price} = 200
	$item{maxPrice} = 190
	$item{minInventoryAmount} = 5
	$item{maxAmount} = 30
	$item{minLevel} = 22
	$item{maxLevel} = 99
	call set_item_usable
	call set_buy_item_usable
	
	do iconf $item{id} $item{maxAmount} 1 0
	
	$name = GetNamebyNameID("$item{id}")
	$nextFreeSlot = get_free_slot_index_for_key("useSelf_item","$name")
	do conf -f useSelf_item_$nextFreeSlot $name
	do conf -f useSelf_item_$nextFreeSlot_disabled 0
	do conf -f useSelf_item_$nextFreeSlot_hp < 60%
	]
}

macro set_Concentrationpotion {
	[
	$item{id} = 645
	$item{price} = 800
	$item{maxPrice} = 760
	$item{minInventoryAmount} = 0
	$item{maxAmount} = 2
	$item{minLevel} = 1
	$item{maxLevel} = 39
	call set_item_usable
	call set_buy_item_usable
	
	do iconf $item{id} $item{maxAmount} 1 0
	
	$name = GetNamebyNameID("$item{id}")
	$nextFreeSlot = get_free_slot_index_for_key("useSelf_item","$name")
	do conf -f useSelf_item_$nextFreeSlot $name
	do conf -f useSelf_item_$nextFreeSlot_disabled 0
	do conf -f useSelf_item_$nextFreeSlot_whenStatusInactive EFST_ATTHASTE_POTION1,EFST_ATTHASTE_POTION2
	do conf -f useSelf_item_$nextFreeSlot_inLockOnly 1
	do conf -f useSelf_item_$nextFreeSlot_notWhileSitting 1
	do conf -f useSelf_item_$nextFreeSlot_timeout 5
	]
}

macro set_AwakeningPotion {
	[
	$item{id} = 656
	$item{price} = 1500
	$item{maxPrice} = 1400
	$item{minInventoryAmount} = 0
	$item{maxAmount} = 2
	$item{minLevel} = 40
	$item{maxLevel} = 99
	call set_item_usable
	call set_buy_item_usable
	
	do iconf $item{id} $item{maxAmount} 1 0
	
	$name = GetNamebyNameID("$item{id}")
	$nextFreeSlot = get_free_slot_index_for_key("useSelf_item","$name")
	do conf -f useSelf_item_$nextFreeSlot $name
	do conf -f useSelf_item_$nextFreeSlot_disabled 0
	do conf -f useSelf_item_$nextFreeSlot_whenStatusInactive EFST_ATTHASTE_POTION1,EFST_ATTHASTE_POTION2
	do conf -f useSelf_item_$nextFreeSlot_inLockOnly 1
	do conf -f useSelf_item_$nextFreeSlot_notWhileSitting 1
	do conf -f useSelf_item_$nextFreeSlot_timeout 5
	]
}

macro set_Flywing {
	[
	$item{id} = 601
	$item{price} = 60
	$item{maxPrice} = 55
	$item{minInventoryAmount} = 0
	$item{maxAmount} = 10
	$item{minLevel} = 1
	$item{maxLevel} = 99
	call set_item_usable
	call set_buy_item_usable
	
	do iconf $item{id} $item{maxAmount} 1 0
	]
}

macro set_Butterlywing {
	[
	$item{id} = 602
	$item{price} = 300
	$item{maxPrice} = 285
	$item{minInventoryAmount} = 0
	$item{maxAmount} = 2
	$item{minLevel} = 1
	$item{maxLevel} = 99
	call set_item_usable
	call set_buy_item_usable
	
	do iconf $item{id} $item{maxAmount} 1 0
	]
}

macro set_tooldealers {
	if ($saveMap == prt_fild05) {
		$tooldealer = prt_fild05-290-221
	} elsif ($saveMap == oldnewpayon) {
		$tooldealer = oldnewpayon-69-117
	} elsif ($saveMap == aldebaran) {
		$tooldealer = aldeba_in-94-56
	} elsif ($saveMap == cmd_fild07) {
		$tooldealer = cmd_fild07-257-126
	}
	$cleartool = clear_hifens("$tooldealer")
}

automacro SavedAtKafra {
	exclusive 1
	priority 0
	NpcMsgName /(O seu Ponto de Retorno foi salvo|has been saved here)/i /^Kafra Employee$/i
	ConfigKeyNot saveMap $saveMap
	ConfigKey eventMacro_1_99_stage saving_in_kafra
	InMap $saveMap
	call {
		[
		do conf -f saveMap $saveMap
		
		call set_tooldealers
		
		do conf -f minStorageZeny 100
		do conf -f storageAuto 1
		do conf -f sellAuto 1
		do conf -f sellAuto_npc $cleartool
		
		call set_Redpotion
		call set_Orangepotion
		call set_Concentrationpotion
		call set_AwakeningPotion
		call set_Flywing
		call set_Butterlywing
		
		if ($saveMap == prt_fild05) {
			do conf -f storageAuto_npc prt_fild05 290 224
			do conf -f storageAuto_npc_steps r~/storage/i
		} elsif ($saveMap == oldnewpayon) {
			do conf -f storageAuto_npc oldnewpayon 98 118
			do conf -f storageAuto_npc_steps r~/storage/i
		} elsif ($saveMap == aldebaran) {
			do conf -f storageAuto_npc aldebaran 143 119
			do conf -f storageAuto_npc_steps r~/storage/i
		} elsif ($saveMap == cmd_fild07) {
			do conf -f storageAuto_npc cmd_fild07 136 134
			do conf -f storageAuto_npc_steps r~/storage/i
		}
		
		do conf -f saveMap_map &config(future_saveMap_map)
		do conf -f saveMap_x &config(future_saveMap_x)
		do conf -f saveMap_y &config(future_saveMap_y)
		
		do conf -f saveMap_kafra_map &config(future_saveMap_kafra_map)
		do conf -f saveMap_kafra_x &config(future_saveMap_kafra_x)
		do conf -f saveMap_kafra_y &config(future_saveMap_kafra_y)
		do conf -f saveMap_save_sequence &config(future_saveMap_save_sequence)
		
		call clear_saveMap_keys
		
		$storage = undef
		$sellauto = undef
		$saveMap = undef
		
		do conf -f eventMacro_1_99_stage &config(saveMap_stage_before)
		do conf -f saveMap_stage_before none
		
		include off Save_Kafra.pm
		include on &config(before_event_include)
		
		do conf -f current_event_include &config(before_event_include)
		do conf -f before_event_include none
		
		do reload eventMacros
		
		]
		release set_savemap_variables
	}
}