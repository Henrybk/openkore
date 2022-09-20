# Leveling
automacro leveling_timer {
	timeout 180
	ConfigKey eventMacro_1_99_stage leveling
	exclusive 1
	priority 2
	call baseMacroUp
}

macro set_lockmap_mjolnir_09 {
	[
	do conf lockMap mjolnir_09
	
	do conf -f future_saveMap_map prt_fild05
	do conf -f future_saveMap_x 290
	do conf -f future_saveMap_y 224
	
	do conf -f future_saveMap_kafra_map prt_fild05
	do conf -f future_saveMap_kafra_x 290
	do conf -f future_saveMap_kafra_y 224
	do conf -f future_saveMap_save_sequence r~/Save/i
	]
}

macro set_lockmap_moc_fild04 {
	[
	do conf lockMap moc_fild04
	
	do mconf 1138 0 0 0 #Magnolia
	
	do conf -f future_saveMap_map prt_fild05
	do conf -f future_saveMap_x 290
	do conf -f future_saveMap_y 224
	
	do conf -f future_saveMap_kafra_map prt_fild05
	do conf -f future_saveMap_kafra_x 290
	do conf -f future_saveMap_kafra_y 224
	do conf -f future_saveMap_save_sequence r~/Save/i
	]
}

macro set_lockmap_cmd_fild07 {
	[
	do conf lockMap cmd_fild07
	
	do conf -f future_saveMap_map cmd_fild07
	do conf -f future_saveMap_x 136
	do conf -f future_saveMap_y 134
	
	do conf -f future_saveMap_kafra_map cmd_fild07
	do conf -f future_saveMap_kafra_x 136
	do conf -f future_saveMap_kafra_y 134
	do conf -f future_saveMap_save_sequence r~/Save/i
	]
}

macro set_lockmap_moc_fild18 {
	[
	do conf lockMap moc_fild18
	
	do conf -f future_saveMap_map cmd_fild07
	do conf -f future_saveMap_x 136
	do conf -f future_saveMap_y 134
	
	do conf -f future_saveMap_kafra_map cmd_fild07
	do conf -f future_saveMap_kafra_x 136
	do conf -f future_saveMap_kafra_y 134
	do conf -f future_saveMap_save_sequence r~/Save/i
	]
}

macro set_lockmap_prt_fild07 {
	[
	do conf lockMap prt_fild07
	
	do mconf 1031 0 0 0 #Poporing
	
	do conf -f future_saveMap_map prt_fild05
	do conf -f future_saveMap_x 290
	do conf -f future_saveMap_y 224
	
	do conf -f future_saveMap_kafra_map prt_fild05
	do conf -f future_saveMap_kafra_x 290
	do conf -f future_saveMap_kafra_y 224
	do conf -f future_saveMap_save_sequence r~/Save/i
	]
}

macro set_lockmap_prt_fild04 {
	[
	do conf lockMap prt_fild04
	
	do conf -f future_saveMap_map prt_fild05
	do conf -f future_saveMap_x 290
	do conf -f future_saveMap_y 224
	
	do conf -f future_saveMap_kafra_map prt_fild05
	do conf -f future_saveMap_kafra_x 290
	do conf -f future_saveMap_kafra_y 224
	do conf -f future_saveMap_save_sequence r~/Save/i
	]
}

macro set_lockmap_prt_fild05 {
	[
	do conf lockMap prt_fild05
	
	do conf -f future_saveMap_map prt_fild05
	do conf -f future_saveMap_x 290
	do conf -f future_saveMap_y 224
	
	do conf -f future_saveMap_kafra_map prt_fild05
	do conf -f future_saveMap_kafra_x 290
	do conf -f future_saveMap_kafra_y 224
	do conf -f future_saveMap_save_sequence r~/Save/i
	]
}

macro set_lockmap_prt_sewb2 {
	[
	do conf lockMap prt_sewb2
	
	do mconf 1031 1 0 0 #Poporing
	
	do conf -f future_saveMap_map prt_fild05
	do conf -f future_saveMap_x 290
	do conf -f future_saveMap_y 224
	
	do conf -f future_saveMap_kafra_map prt_fild05
	do conf -f future_saveMap_kafra_x 290
	do conf -f future_saveMap_kafra_y 224
	do conf -f future_saveMap_save_sequence r~/Save/i
	]
}

macro set_lockmap_pay_dun00 {
	[
	do conf lockMap pay_dun00
	
	do conf -f future_saveMap_map oldnewpayon
	do conf -f future_saveMap_x 98
	do conf -f future_saveMap_y 118
	
	do conf -f future_saveMap_kafra_map oldnewpayon
	do conf -f future_saveMap_kafra_x 98
	do conf -f future_saveMap_kafra_y 118
	do conf -f future_saveMap_save_sequence r~/Save/i
	]
}

macro set_lockmap_pay_fild01 {
	[
	do conf lockMap pay_fild01
	
	call set_config_class
	if ($configClass = knight) {
		do iconf 713 50 1 0
		do iconf 1058 1 1 0
	}
	do mconf 1031 1 0 0 #Poporing
	
	do conf -f future_saveMap_map oldnewpayon
	do conf -f future_saveMap_x 98
	do conf -f future_saveMap_y 118
	
	do conf -f future_saveMap_kafra_map oldnewpayon
	do conf -f future_saveMap_kafra_x 98
	do conf -f future_saveMap_kafra_y 118
	do conf -f future_saveMap_save_sequence r~/Save/i
	]
}

macro set_lockmap_pay_fild05 {
	[
	do conf lockMap pay_fild05
	
	do conf -f future_saveMap_map oldnewpayon
	do conf -f future_saveMap_x 98
	do conf -f future_saveMap_y 118
	
	do conf -f future_saveMap_kafra_map oldnewpayon
	do conf -f future_saveMap_kafra_x 98
	do conf -f future_saveMap_kafra_y 118
	do conf -f future_saveMap_save_sequence r~/Save/i
	]
}

macro set_lockmap_yuno_fild01 {
	[
	do conf lockMap yuno_fild01
	
	call set_config_class
	if ($configClass = knight) {
		do iconf 713 50 1 0
		do iconf 1058 1 1 0
	}
	
	do mconf 1369 0 0 0 #Grand Peco
	
	do conf -f future_saveMap_map aldebaran
	do conf -f future_saveMap_x 143
	do conf -f future_saveMap_y 119
	
	do conf -f future_saveMap_kafra_map aldebaran
	do conf -f future_saveMap_kafra_x 143
	do conf -f future_saveMap_kafra_y 119
	do conf -f future_saveMap_save_sequence r~/Save/i
	]
}

macro set_lockmap_lasa_dun01 {
	[
	do conf lockMap lasa_dun01
	
	call set_config_class
	if ($configClass = knight) {
		do iconf 713 50 1 0
		do iconf 1058 1 1 0
	}
	
	do conf -f future_saveMap_map aldebaran
	do conf -f future_saveMap_x 143
	do conf -f future_saveMap_y 119
	
	do conf -f future_saveMap_kafra_map aldebaran
	do conf -f future_saveMap_kafra_x 143
	do conf -f future_saveMap_kafra_y 119
	do conf -f future_saveMap_save_sequence r~/Save/i
	]
}

macro after_lock_change {
	call SetVar
	call basic_config_leveling_settings
	if ($configsaveMap != &config(future_saveMap_map)) {
		call change_savemap
	} else {
		call clear_saveMap_keys
	}
}

macro change_savemap {
	[
	do conf -f saveMap_stage_before &config(eventMacro_1_99_stage)
	do conf -f eventMacro_1_99_stage saving_in_kafra
	do conf -f before_event_include &config(current_event_include)
	do conf -f current_event_include Save_Kafra.pm
	]
	include off &config(before_event_include)
	include on Save_Kafra.pm
	do reload eventMacros
}

automacro need_to_configure_Sewb {
	exclusive 1
	priority 1
	ConfigKey eventMacro_test 0
	ConfigKeyNot Joined_Sewb true
	ConfigKeyNot Joined_Sewb false
	ConfigKey eventMacro_1_99_stage leveling
	call {
		do conf -f Joined_Sewb false
	}
}

automacro need_to_configure_Sewb_2 {
	exclusive 1
	priority 1
	ConfigKey eventMacro_test 0
	ConfigKey Joined_Sewb true
	ConfigKey eventMacro_1_99_stage leveling
	NpcMsgName /we can only allow volunteers for the Culvert Campaign to enter/ /Culvert Guardian/
	call {
		do conf -f Joined_Sewb false
	}
}

automacro need_to_Join_Sewb {
	exclusive 1
	priority 1
	ConfigKey eventMacro_test 0
	ConfigKey Joined_Sewb false
	ConfigKey eventMacro_1_99_stage leveling
	call {
		do conf -f Join_Sewb_before &config(eventMacro_1_99_stage)
		do conf -f eventMacro_1_99_stage Join_Sewb
		do conf -f before_event_include &config(current_event_include)
		do conf -f current_event_include Join_Sewb.pm
		include off &config(before_event_include)
		include on Join_Sewb.pm
		
		do reload eventMacros
	}
}

automacro need_to_configure_Oranpere {
	exclusive 1
	priority 0
	ConfigKey eventMacro_test 0
	ConfigKeyNot Joined_Oranpere true
	ConfigKeyNot Joined_Oranpere false
	ConfigKey eventMacro_1_99_stage leveling
	call {
		do conf -f Joined_Oranpere false
	}
}

automacro need_to_configure_Oranpere_2 {
	exclusive 1
	priority 0
	ConfigKey eventMacro_test 0
	ConfigKey Joined_Oranpere true
	StatusInactiveHandle EFST_SWORDCLAN
	ConfigKey eventMacro_1_99_stage leveling
	call {
		do conf -f Joined_Oranpere false
	}
}

automacro need_to_Join_Oranpere {
	exclusive 1
	priority 0
	ConfigKey eventMacro_test 0
	ConfigKey Joined_Oranpere false
	ConfigKey eventMacro_1_99_stage leveling
	call {
		do conf -f Join_Oranpere_before &config(eventMacro_1_99_stage)
		do conf -f eventMacro_1_99_stage Join_Oranpere
		do conf -f before_event_include &config(current_event_include)
		do conf -f current_event_include Join_Oranpere.pm
		include off &config(before_event_include)
		include on Join_Oranpere.pm
		
		do reload eventMacros
	}
}

automacro need_to_configure_Haleigh {
	exclusive 1
	priority 0
	ConfigKey eventMacro_test 0
	ConfigKey lockMap lasa_dun01
	ConfigKey eventMacro_1_99_stage leveling
	ConfigKeyNot Joined_Haleigh true
	ConfigKeyNot Joined_Haleigh false
	call {
		do conf -f Joined_Haleigh false
	}
}

automacro need_to_Join_Haleigh {
	exclusive 1
	priority 0
	ConfigKey eventMacro_test 0
	ConfigKey lockMap lasa_dun01
	ConfigKey eventMacro_1_99_stage leveling
	ConfigKey Joined_Haleigh false
	call {
		do conf -f Join_Haleigh_before &config(eventMacro_1_99_stage)
		do conf -f eventMacro_1_99_stage Join_Haleigh
		do conf -f before_event_include &config(current_event_include)
		do conf -f current_event_include Join_Haleigh.pm
		include off &config(before_event_include)
		include on Join_Haleigh.pm
		
		do reload eventMacros
	}
}

automacro need_to_configure_Haleigh_2 {
	exclusive 1
	priority 1
	ConfigKey eventMacro_test 0
	ConfigKey Joined_Haleigh true
	ConfigKey eventMacro_1_99_stage leveling
	NpcMsgName /Are you here to help the Professor/i /Assistant Eryn/
	call {
		do conf -f Joined_Haleigh false
	}
}

automacro test_zenyman_1 {
	exclusive 1
	priority 3
	ConfigKey eventMacro_test 1
	InMap prt_fild05
	ConfigKey eventMacro_1_99_stage leveling
	Zeny < 100000
	call {
		do move prt_fild05 283 223
		do talknpc 290 219 r0
	}
}

automacro test_zenyman_2 {
	exclusive 1
	priority 3
	ConfigKey eventMacro_test 1
	InMap prt_fild05
	ConfigKey eventMacro_1_99_stage leveling
	StatusInactiveHandle EFST_BLESSING
	call {
		do move prt_fild05 283 223
		do talknpc 290 219 r0
	}
}

automacro test_zenyman_3 {
	exclusive 1
	priority 3
	ConfigKey eventMacro_test 1
	InMap prt_fild05
	ConfigKey eventMacro_1_99_stage leveling
	CurrentHP < 50%
	call {
		do move prt_fild05 283 223
		do talknpc 290 219 r0
	}
}

automacro test_zenyman_4 {
	exclusive 1
	priority 3
	ConfigKey eventMacro_test 1
	InMap prt_fild05
	ConfigKey eventMacro_1_99_stage turn_rogue_getToNpc_farming
	Zeny < 100000
	call {
		do move prt_fild05 283 223
		do talknpc 290 219 r0
	}
}

automacro test_zenyman_5 {
	exclusive 1
	priority 3
	ConfigKey eventMacro_test 1
	InMap prt_fild05
	ConfigKey eventMacro_1_99_stage turn_rogue_getToNpc_farming
	StatusInactiveHandle EFST_BLESSING
	call {
		do move prt_fild05 283 223
		do talknpc 290 219 r0
	}
}

automacro test_zenyman_6 {
	exclusive 1
	priority 3
	ConfigKey eventMacro_test 1
	InMap prt_fild05
	ConfigKey eventMacro_1_99_stage turn_rogue_getToNpc_farming
	CurrentHP < 50%
	call {
		do move prt_fild05 283 223
		do talknpc 290 219 r0
	}
}

automacro test_zenyman_7 {
	exclusive 1
	priority 3
	ConfigKey eventMacro_test 1
	InMap prt_fild05
	ConfigKey eventMacro_1_99_stage turning_knight_farming
	Zeny < 100000
	call {
		do move prt_fild05 283 223
		do talknpc 290 219 r0
	}
}

automacro test_zenyman_8 {
	exclusive 1
	priority 3
	ConfigKey eventMacro_test 1
	InMap prt_fild05
	ConfigKey eventMacro_1_99_stage turning_knight_farming
	StatusInactiveHandle EFST_BLESSING
	call {
		do move prt_fild05 283 223
		do talknpc 290 219 r0
	}
}

automacro test_zenyman_9 {
	exclusive 1
	priority 3
	ConfigKey eventMacro_test 1
	InMap prt_fild05
	ConfigKey eventMacro_1_99_stage turning_knight_farming
	CurrentHP < 50%
	call {
		do move prt_fild05 283 223
		do talknpc 290 219 r0
	}
}