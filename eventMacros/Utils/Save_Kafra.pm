

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

automacro SavedAtKafra {
	exclusive 1
	priority 0
	NpcMsgName /(O seu Ponto de Retorno foi salvo|has been saved here)/i /^Kafra Employee$/i
	ConfigKeyNot saveMap $saveMap
	ConfigKey eventMacro_1_99_stage saving_in_kafra
	InMap $saveMap
	call {
		do conf -f saveMap $saveMap
		
		if ($saveMap == prt_fild05) {
			[
			do conf -f minStorageZeny 100
			do conf -f storageAuto_npc prt_fild05 290 224
			do conf -f storageAuto_npc_steps r~/storage/i
			do conf -f storageAuto 1
			
			do conf -f sellAuto 1
			do conf -f sellAuto_npc prt_fild05 290 221
			
			# Fly wing
			$name = GetNamebyNameID(601)
			$nextFreeSlot = get_free_slot_index_for_key("buyAuto","$name")
			do conf -f buyAuto_$nextFreeSlot $name
			do conf -f buyAuto_$nextFreeSlot_npc prt_fild05 290 221
			do conf -f buyAuto_$nextFreeSlot_minAmount 0
			do conf -f buyAuto_$nextFreeSlot_maxAmount 5
			do conf -f buyAuto_$nextFreeSlot_minDistance 1
			do conf -f buyAuto_$nextFreeSlot_maxDistance 10
			do conf -f buyAuto_$nextFreeSlot_zeny > 300
			do conf -f buyAuto_$nextFreeSlot_maxBase 99
			do conf -f buyAuto_$nextFreeSlot_minBase 1
			do conf -f buyAuto_$nextFreeSlot_disabled 0
			do iconf 601 5 1 0
			
			# Butterly wing
			$name = GetNamebyNameID(602)
			$nextFreeSlot = get_free_slot_index_for_key("buyAuto","$name")
			do conf -f buyAuto_$nextFreeSlot $name
			do conf -f buyAuto_$nextFreeSlot_npc prt_fild05 290 221
			do conf -f buyAuto_$nextFreeSlot_minAmount 0
			do conf -f buyAuto_$nextFreeSlot_maxAmount 1
			do conf -f buyAuto_$nextFreeSlot_minDistance 1
			do conf -f buyAuto_$nextFreeSlot_maxDistance 10
			do conf -f buyAuto_$nextFreeSlot_zeny > 300
			do conf -f buyAuto_$nextFreeSlot_maxBase 99
			do conf -f buyAuto_$nextFreeSlot_minBase 1
			do conf -f buyAuto_$nextFreeSlot_disabled 0
			do iconf 602 1 1 0
			
			# Red potion
			$name = GetNamebyNameID(501)
			$nextFreeSlot = get_free_slot_index_for_key("buyAuto","$name")
			do conf -f buyAuto_$nextFreeSlot $name
			do conf -f buyAuto_$nextFreeSlot_npc prt_fild05 290 221
			do conf -f buyAuto_$nextFreeSlot_minAmount 5
			do conf -f buyAuto_$nextFreeSlot_maxAmount 50
			do conf -f buyAuto_$nextFreeSlot_minDistance 1
			do conf -f buyAuto_$nextFreeSlot_maxDistance 10
			do conf -f buyAuto_$nextFreeSlot_zeny > 2500
			do conf -f buyAuto_$nextFreeSlot_maxBase 30
			do conf -f buyAuto_$nextFreeSlot_minBase 1
			do conf -f buyAuto_$nextFreeSlot_disabled 0
			do iconf 501 50 1 0
			
			$nextFreeSlot = get_free_slot_index_for_key("useSelf_item","$name")
			do conf -f useSelf_item_$nextFreeSlot $name
			do conf -f useSelf_item_$nextFreeSlot_disabled 0
			do conf -f useSelf_item_$nextFreeSlot_hp < 70%
			
			# Orange potion
			$name = GetNamebyNameID(502)
			$nextFreeSlot = get_free_slot_index_for_key("buyAuto","$name")
			do conf -f buyAuto_$nextFreeSlot $name
			do conf -f buyAuto_$nextFreeSlot_npc prt_fild05 290 221
			do conf -f buyAuto_$nextFreeSlot_minAmount 5
			do conf -f buyAuto_$nextFreeSlot_maxAmount 50
			do conf -f buyAuto_$nextFreeSlot_minDistance 1
			do conf -f buyAuto_$nextFreeSlot_maxDistance 10
			do conf -f buyAuto_$nextFreeSlot_zeny > 10000
			do conf -f buyAuto_$nextFreeSlot_maxBase 99
			do conf -f buyAuto_$nextFreeSlot_minBase 25
			do conf -f buyAuto_$nextFreeSlot_disabled 0
			do iconf 502 50 1 0
			
			$nextFreeSlot = get_free_slot_index_for_key("useSelf_item","$name")
			do conf -f useSelf_item_$nextFreeSlot $name
			do conf -f useSelf_item_$nextFreeSlot_disabled 0
			do conf -f useSelf_item_$nextFreeSlot_hp < 60%
			
			# Concentration potion
			$name = GetNamebyNameID(645)
			$nextFreeSlot = get_free_slot_index_for_key("buyAuto","$name")
			do conf -f buyAuto_$nextFreeSlot $name
			do conf -f buyAuto_$nextFreeSlot_npc prt_fild05 290 221
			do conf -f buyAuto_$nextFreeSlot_minAmount 1
			do conf -f buyAuto_$nextFreeSlot_maxAmount 5
			do conf -f buyAuto_$nextFreeSlot_minDistance 1
			do conf -f buyAuto_$nextFreeSlot_maxDistance 10
			do conf -f buyAuto_$nextFreeSlot_zeny > 5000
			do conf -f buyAuto_$nextFreeSlot_maxBase 39
			do conf -f buyAuto_$nextFreeSlot_minBase 1
			do conf -f buyAuto_$nextFreeSlot_disabled 0
			do iconf 645 5 1 0
			
			$nextFreeSlot = get_free_slot_index_for_key("useSelf_item","$name")
			do conf -f useSelf_item_$nextFreeSlot $name
			do conf -f useSelf_item_$nextFreeSlot_disabled 0
			do conf -f useSelf_item_$nextFreeSlot_whenStatusInactive EFST_ATTHASTE_POTION1
			do conf -f useSelf_item_$nextFreeSlot_inLockOnly 1
			do conf -f useSelf_item_$nextFreeSlot_notWhileSitting 1
			do conf -f useSelf_item_$nextFreeSlot_timeout 5
			
			# Awakening Potion
			$name = GetNamebyNameID(656)
			$nextFreeSlot = get_free_slot_index_for_key("buyAuto","$name")
			do conf -f buyAuto_$nextFreeSlot $name
			do conf -f buyAuto_$nextFreeSlot_npc prt_in 126 76
			do conf -f buyAuto_$nextFreeSlot_minAmount 1
			do conf -f buyAuto_$nextFreeSlot_maxAmount 5
			do conf -f buyAuto_$nextFreeSlot_minDistance 1
			do conf -f buyAuto_$nextFreeSlot_maxDistance 10
			do conf -f buyAuto_$nextFreeSlot_zeny > 8000
			do conf -f buyAuto_$nextFreeSlot_maxBase 99
			do conf -f buyAuto_$nextFreeSlot_minBase 40
			do conf -f buyAuto_$nextFreeSlot_disabled 0
			do iconf 656 5 1 0
			
			$nextFreeSlot = get_free_slot_index_for_key("useSelf_item","$name")
			do conf -f useSelf_item_$nextFreeSlot $name
			do conf -f useSelf_item_$nextFreeSlot_disabled 0
			do conf -f useSelf_item_$nextFreeSlot_whenStatusInactive EFST_ATTHASTE_POTION2
			do conf -f useSelf_item_$nextFreeSlot_inLockOnly 1
			do conf -f useSelf_item_$nextFreeSlot_notWhileSitting 1
			do conf -f useSelf_item_$nextFreeSlot_timeout 5
			]
			
		} elsif ($saveMap == oldnewpayon) {
			[
			do conf -f minStorageZeny 100
			do conf -f storageAuto_npc oldnewpayon 98 118
			do conf -f storageAuto_npc_steps r~/storage/i
			do conf -f storageAuto 1
			
			$toolDealer = oldnewpayon 69 117
			
			do conf -f sellAuto 1
			do conf -f sellAuto_npc $toolDealer
			
			# Fly wing
			$name = GetNamebyNameID(601)
			$nextFreeSlot = get_free_slot_index_for_key("buyAuto","$name")
			do conf -f buyAuto_$nextFreeSlot $name
			do conf -f buyAuto_$nextFreeSlot_npc $toolDealer
			do conf -f buyAuto_$nextFreeSlot_minAmount 0
			do conf -f buyAuto_$nextFreeSlot_maxAmount 5
			do conf -f buyAuto_$nextFreeSlot_minDistance 1
			do conf -f buyAuto_$nextFreeSlot_maxDistance 10
			do conf -f buyAuto_$nextFreeSlot_zeny > 300
			do conf -f buyAuto_$nextFreeSlot_maxBase 99
			do conf -f buyAuto_$nextFreeSlot_minBase 1
			do conf -f buyAuto_$nextFreeSlot_disabled 0
			do iconf 601 5 1 0
			
			# Butterly wing
			$name = GetNamebyNameID(602)
			$nextFreeSlot = get_free_slot_index_for_key("buyAuto","$name")
			do conf -f buyAuto_$nextFreeSlot $name
			do conf -f buyAuto_$nextFreeSlot_npc $toolDealer
			do conf -f buyAuto_$nextFreeSlot_minAmount 0
			do conf -f buyAuto_$nextFreeSlot_maxAmount 1
			do conf -f buyAuto_$nextFreeSlot_minDistance 1
			do conf -f buyAuto_$nextFreeSlot_maxDistance 10
			do conf -f buyAuto_$nextFreeSlot_zeny > 300
			do conf -f buyAuto_$nextFreeSlot_maxBase 99
			do conf -f buyAuto_$nextFreeSlot_minBase 1
			do conf -f buyAuto_$nextFreeSlot_disabled 0
			do iconf 602 1 1 0
			
			# Red potion
			$name = GetNamebyNameID(501)
			$nextFreeSlot = get_free_slot_index_for_key("buyAuto","$name")
			do conf -f buyAuto_$nextFreeSlot $name
			do conf -f buyAuto_$nextFreeSlot_npc $toolDealer
			do conf -f buyAuto_$nextFreeSlot_minAmount 5
			do conf -f buyAuto_$nextFreeSlot_maxAmount 50
			do conf -f buyAuto_$nextFreeSlot_minDistance 1
			do conf -f buyAuto_$nextFreeSlot_maxDistance 10
			do conf -f buyAuto_$nextFreeSlot_zeny > 2500
			do conf -f buyAuto_$nextFreeSlot_maxBase 30
			do conf -f buyAuto_$nextFreeSlot_minBase 1
			do conf -f buyAuto_$nextFreeSlot_disabled 0
			do iconf 501 50 1 0
			
			$nextFreeSlot = get_free_slot_index_for_key("useSelf_item","$name")
			do conf -f useSelf_item_$nextFreeSlot $name
			do conf -f useSelf_item_$nextFreeSlot_disabled 0
			do conf -f useSelf_item_$nextFreeSlot_hp < 70%
			
			# Orange potion
			$name = GetNamebyNameID(502)
			$nextFreeSlot = get_free_slot_index_for_key("buyAuto","$name")
			do conf -f buyAuto_$nextFreeSlot $name
			do conf -f buyAuto_$nextFreeSlot_npc $toolDealer
			do conf -f buyAuto_$nextFreeSlot_minAmount 5
			do conf -f buyAuto_$nextFreeSlot_maxAmount 50
			do conf -f buyAuto_$nextFreeSlot_minDistance 1
			do conf -f buyAuto_$nextFreeSlot_maxDistance 10
			do conf -f buyAuto_$nextFreeSlot_zeny > 10000
			do conf -f buyAuto_$nextFreeSlot_maxBase 99
			do conf -f buyAuto_$nextFreeSlot_minBase 25
			do conf -f buyAuto_$nextFreeSlot_disabled 0
			do iconf 502 50 1 0
			
			$nextFreeSlot = get_free_slot_index_for_key("useSelf_item","$name")
			do conf -f useSelf_item_$nextFreeSlot $name
			do conf -f useSelf_item_$nextFreeSlot_disabled 0
			do conf -f useSelf_item_$nextFreeSlot_hp < 60%
			
			# Concentration potion
			$name = GetNamebyNameID(645)
			$nextFreeSlot = get_free_slot_index_for_key("buyAuto","$name")
			do conf -f buyAuto_$nextFreeSlot $name
			do conf -f buyAuto_$nextFreeSlot_npc $toolDealer
			do conf -f buyAuto_$nextFreeSlot_minAmount 1
			do conf -f buyAuto_$nextFreeSlot_maxAmount 5
			do conf -f buyAuto_$nextFreeSlot_minDistance 1
			do conf -f buyAuto_$nextFreeSlot_maxDistance 10
			do conf -f buyAuto_$nextFreeSlot_zeny > 5000
			do conf -f buyAuto_$nextFreeSlot_maxBase 39
			do conf -f buyAuto_$nextFreeSlot_minBase 1
			do conf -f buyAuto_$nextFreeSlot_disabled 0
			do iconf 645 5 1 0
			
			$nextFreeSlot = get_free_slot_index_for_key("useSelf_item","$name")
			do conf -f useSelf_item_$nextFreeSlot $name
			do conf -f useSelf_item_$nextFreeSlot_disabled 0
			do conf -f useSelf_item_$nextFreeSlot_whenStatusInactive EFST_ATTHASTE_POTION1
			do conf -f useSelf_item_$nextFreeSlot_inLockOnly 1
			do conf -f useSelf_item_$nextFreeSlot_notWhileSitting 1
			do conf -f useSelf_item_$nextFreeSlot_timeout 5
			
			# Awakening Potion
			$name = GetNamebyNameID(656)
			$nextFreeSlot = get_free_slot_index_for_key("buyAuto","$name")
			do conf -f buyAuto_$nextFreeSlot $name
			do conf -f buyAuto_$nextFreeSlot_npc $toolDealer
			do conf -f buyAuto_$nextFreeSlot_minAmount 1
			do conf -f buyAuto_$nextFreeSlot_maxAmount 5
			do conf -f buyAuto_$nextFreeSlot_minDistance 1
			do conf -f buyAuto_$nextFreeSlot_maxDistance 10
			do conf -f buyAuto_$nextFreeSlot_zeny > 8000
			do conf -f buyAuto_$nextFreeSlot_maxBase 99
			do conf -f buyAuto_$nextFreeSlot_minBase 40
			do conf -f buyAuto_$nextFreeSlot_disabled 0
			do iconf 656 5 1 0
			
			$nextFreeSlot = get_free_slot_index_for_key("useSelf_item","$name")
			do conf -f useSelf_item_$nextFreeSlot $name
			do conf -f useSelf_item_$nextFreeSlot_disabled 0
			do conf -f useSelf_item_$nextFreeSlot_whenStatusInactive EFST_ATTHASTE_POTION2
			do conf -f useSelf_item_$nextFreeSlot_inLockOnly 1
			do conf -f useSelf_item_$nextFreeSlot_notWhileSitting 1
			do conf -f useSelf_item_$nextFreeSlot_timeout 5
			]
		
		} elsif ($saveMap == aldebaran) {
			[
			do conf -f minStorageZeny 100
			do conf -f storageAuto_npc aldebaran 143 119
			do conf -f storageAuto_npc_steps r~/storage/i
			do conf -f storageAuto 1
			
			$toolDealer = aldeba_in 94 56
			
			do conf -f sellAuto 1
			do conf -f sellAuto_npc $toolDealer
			
			# Fly wing
			$name = GetNamebyNameID(601)
			$nextFreeSlot = get_free_slot_index_for_key("buyAuto","$name")
			do conf -f buyAuto_$nextFreeSlot $name
			do conf -f buyAuto_$nextFreeSlot_npc $toolDealer
			do conf -f buyAuto_$nextFreeSlot_minAmount 0
			do conf -f buyAuto_$nextFreeSlot_maxAmount 5
			do conf -f buyAuto_$nextFreeSlot_minDistance 1
			do conf -f buyAuto_$nextFreeSlot_maxDistance 10
			do conf -f buyAuto_$nextFreeSlot_zeny > 300
			do conf -f buyAuto_$nextFreeSlot_maxBase 99
			do conf -f buyAuto_$nextFreeSlot_minBase 1
			do conf -f buyAuto_$nextFreeSlot_disabled 0
			do iconf 601 5 1 0
			
			# Butterly wing
			$name = GetNamebyNameID(602)
			$nextFreeSlot = get_free_slot_index_for_key("buyAuto","$name")
			do conf -f buyAuto_$nextFreeSlot $name
			do conf -f buyAuto_$nextFreeSlot_npc $toolDealer
			do conf -f buyAuto_$nextFreeSlot_minAmount 0
			do conf -f buyAuto_$nextFreeSlot_maxAmount 1
			do conf -f buyAuto_$nextFreeSlot_minDistance 1
			do conf -f buyAuto_$nextFreeSlot_maxDistance 10
			do conf -f buyAuto_$nextFreeSlot_zeny > 300
			do conf -f buyAuto_$nextFreeSlot_maxBase 99
			do conf -f buyAuto_$nextFreeSlot_minBase 1
			do conf -f buyAuto_$nextFreeSlot_disabled 0
			do iconf 602 1 1 0
			
			# Red potion
			$name = GetNamebyNameID(501)
			$nextFreeSlot = get_free_slot_index_for_key("buyAuto","$name")
			do conf -f buyAuto_$nextFreeSlot $name
			do conf -f buyAuto_$nextFreeSlot_npc $toolDealer
			do conf -f buyAuto_$nextFreeSlot_minAmount 5
			do conf -f buyAuto_$nextFreeSlot_maxAmount 50
			do conf -f buyAuto_$nextFreeSlot_minDistance 1
			do conf -f buyAuto_$nextFreeSlot_maxDistance 10
			do conf -f buyAuto_$nextFreeSlot_zeny > 2500
			do conf -f buyAuto_$nextFreeSlot_maxBase 50
			do conf -f buyAuto_$nextFreeSlot_minBase 1
			do conf -f buyAuto_$nextFreeSlot_disabled 0
			do iconf 501 50 1 0
			
			$nextFreeSlot = get_free_slot_index_for_key("useSelf_item","$name")
			do conf -f useSelf_item_$nextFreeSlot $name
			do conf -f useSelf_item_$nextFreeSlot_disabled 0
			do conf -f useSelf_item_$nextFreeSlot_hp < 70%
			
			# Orange potion
			$name = GetNamebyNameID(502)
			$nextFreeSlot = get_free_slot_index_for_key("buyAuto","$name")
			do conf -f buyAuto_$nextFreeSlot $name
			do conf -f buyAuto_$nextFreeSlot_npc $toolDealer
			do conf -f buyAuto_$nextFreeSlot_minAmount 5
			do conf -f buyAuto_$nextFreeSlot_maxAmount 50
			do conf -f buyAuto_$nextFreeSlot_minDistance 1
			do conf -f buyAuto_$nextFreeSlot_maxDistance 10
			do conf -f buyAuto_$nextFreeSlot_zeny > 10000
			do conf -f buyAuto_$nextFreeSlot_maxBase 99
			do conf -f buyAuto_$nextFreeSlot_minBase 25
			do conf -f buyAuto_$nextFreeSlot_disabled 0
			do iconf 502 50 1 0
			
			$nextFreeSlot = get_free_slot_index_for_key("useSelf_item","$name")
			do conf -f useSelf_item_$nextFreeSlot $name
			do conf -f useSelf_item_$nextFreeSlot_disabled 0
			do conf -f useSelf_item_$nextFreeSlot_hp < 60%
			
			# Concentration potion
			$name = GetNamebyNameID(645)
			$nextFreeSlot = get_free_slot_index_for_key("buyAuto","$name")
			do conf -f buyAuto_$nextFreeSlot $name
			do conf -f buyAuto_$nextFreeSlot_npc $toolDealer
			do conf -f buyAuto_$nextFreeSlot_minAmount 1
			do conf -f buyAuto_$nextFreeSlot_maxAmount 5
			do conf -f buyAuto_$nextFreeSlot_minDistance 1
			do conf -f buyAuto_$nextFreeSlot_maxDistance 10
			do conf -f buyAuto_$nextFreeSlot_zeny > 5000
			do conf -f buyAuto_$nextFreeSlot_maxBase 39
			do conf -f buyAuto_$nextFreeSlot_minBase 1
			do conf -f buyAuto_$nextFreeSlot_disabled 0
			do iconf 645 5 1 0
			
			$nextFreeSlot = get_free_slot_index_for_key("useSelf_item","$name")
			do conf -f useSelf_item_$nextFreeSlot $name
			do conf -f useSelf_item_$nextFreeSlot_disabled 0
			do conf -f useSelf_item_$nextFreeSlot_whenStatusInactive EFST_ATTHASTE_POTION1
			do conf -f useSelf_item_$nextFreeSlot_inLockOnly 1
			do conf -f useSelf_item_$nextFreeSlot_notWhileSitting 1
			do conf -f useSelf_item_$nextFreeSlot_timeout 5
			
			# Awakening Potion
			$name = GetNamebyNameID(656)
			$nextFreeSlot = get_free_slot_index_for_key("buyAuto","$name")
			do conf -f buyAuto_$nextFreeSlot $name
			do conf -f buyAuto_$nextFreeSlot_npc $toolDealer
			do conf -f buyAuto_$nextFreeSlot_minAmount 1
			do conf -f buyAuto_$nextFreeSlot_maxAmount 5
			do conf -f buyAuto_$nextFreeSlot_minDistance 1
			do conf -f buyAuto_$nextFreeSlot_maxDistance 10
			do conf -f buyAuto_$nextFreeSlot_zeny > 8000
			do conf -f buyAuto_$nextFreeSlot_maxBase 99
			do conf -f buyAuto_$nextFreeSlot_minBase 40
			do conf -f buyAuto_$nextFreeSlot_disabled 0
			do iconf 656 5 1 0
			
			$nextFreeSlot = get_free_slot_index_for_key("useSelf_item","$name")
			do conf -f useSelf_item_$nextFreeSlot $name
			do conf -f useSelf_item_$nextFreeSlot_disabled 0
			do conf -f useSelf_item_$nextFreeSlot_whenStatusInactive EFST_ATTHASTE_POTION2
			do conf -f useSelf_item_$nextFreeSlot_inLockOnly 1
			do conf -f useSelf_item_$nextFreeSlot_notWhileSitting 1
			do conf -f useSelf_item_$nextFreeSlot_timeout 5
			]
		}
		
		[
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