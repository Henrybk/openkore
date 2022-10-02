

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

macro set_tooldealers_and_kafra2 {
	$configsaveMap = $saveMap
	call set_tooldealers_and_kafra
	$cleartool = clear_hifens("$tooldealer")
	$clearkafra = clear_hifens("$kafra")
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
		
		call set_tooldealers_and_kafra2
		
		do conf -f minStorageZeny 100
		do conf -f storageAuto 1
		do conf -f sellAuto 1
		do conf -f sellAuto_npc $cleartool
		
		do conf -f storageAuto_npc $clearkafra
		do conf -f storageAuto_npc_steps $storageSequence
		
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