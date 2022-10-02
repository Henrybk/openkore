# Leveling
automacro leveling_timer {
	timeout 600
	ConfigKey eventMacro_1_99_stage leveling
	exclusive 1
	priority 2
	call baseMacroUp
}

macro set_savemap_aldebaran {
	[
	do conf -f future_saveMap_map aldebaran
	do conf -f future_saveMap_x 143
	do conf -f future_saveMap_y 119
	
	do conf -f future_saveMap_kafra_map aldebaran
	do conf -f future_saveMap_kafra_x 143
	do conf -f future_saveMap_kafra_y 119
	do conf -f future_saveMap_save_sequence r~/Save/i
	]
}

macro set_savemap_oldnewpayon {
	[
	do conf -f future_saveMap_map oldnewpayon
	do conf -f future_saveMap_x 98
	do conf -f future_saveMap_y 118
	
	do conf -f future_saveMap_kafra_map oldnewpayon
	do conf -f future_saveMap_kafra_x 98
	do conf -f future_saveMap_kafra_y 118
	do conf -f future_saveMap_save_sequence r~/Save/i
	]
}

macro set_savemap_cmd_fild07 {
	[
	do conf -f future_saveMap_map cmd_fild07
	do conf -f future_saveMap_x 136
	do conf -f future_saveMap_y 134
	
	do conf -f future_saveMap_kafra_map cmd_fild07
	do conf -f future_saveMap_kafra_x 136
	do conf -f future_saveMap_kafra_y 134
	do conf -f future_saveMap_save_sequence r~/Save/i
	]
}

macro set_savemap_prt_fild05 {
	[
	do conf -f future_saveMap_map prt_fild05
	do conf -f future_saveMap_x 290
	do conf -f future_saveMap_y 224
	
	do conf -f future_saveMap_kafra_map prt_fild05
	do conf -f future_saveMap_kafra_x 290
	do conf -f future_saveMap_kafra_y 224
	do conf -f future_saveMap_save_sequence r~/Save/i
	]
}

macro set_lockmap_lasa_dun01 {
	[
	do conf lockMap lasa_dun01
	
	do mconf 1031 1 0 0 #Poporing
	do mconf 1018 1 0 0 #Creamy
	
	call set_config_class
	call set_global_iconf
	
	call set_savemap_aldebaran
	]
}

macro set_lockmap_lasa_dun02 {
	[
	do conf lockMap lasa_dun02
	
	do mconf 1368 0 0 0 #Geographer
	do mconf 3988 0 0 0 #Protoring
	do mconf 3989 1 0 0 #Abomring
	
	call set_config_class
	call set_global_iconf
	
	set_savemap_aldebaran
	]
}

macro set_lockmap_mjolnir_09 {
	[
	do conf lockMap mjolnir_09
	
	call set_config_class
	call set_global_iconf
	
	call set_savemap_prt_fild05
	]
}

macro set_lockmap_moc_fild04 {
	[
	do conf lockMap moc_fild04
	
	call set_config_class
	call set_global_iconf
	
	do mconf 1138 0 0 0 #Magnolia
	
	call set_savemap_prt_fild05
	]
}

macro set_lockmap_cmd_fild07 {
	[
	do conf lockMap cmd_fild07
	
	call set_config_class
	call set_global_iconf
	
	call set_savemap_cmd_fild07
	]
}

macro set_lockmap_moc_fild18 {
	[
	do conf lockMap moc_fild18
	
	call set_config_class
	call set_global_iconf
	
	call set_savemap_cmd_fild07
	]
}

macro set_lockmap_prt_fild07 {
	[
	do conf lockMap prt_fild07
	
	call set_config_class
	call set_global_iconf
	
	do mconf 1031 0 0 0 #Poporing
	
	call set_savemap_prt_fild05
	]
}

macro set_lockmap_prt_fild04 {
	[
	do conf lockMap prt_fild04
	
	call set_config_class
	call set_global_iconf
	
	call set_savemap_prt_fild05
	]
}

macro set_lockmap_prt_fild05 {
	[
	do conf lockMap prt_fild05
	
	call set_config_class
	call set_global_iconf
	
	call set_savemap_prt_fild05
	]
}

macro set_lockmap_prt_sewb2 {
	[
	do conf lockMap prt_sewb2
	
	call set_config_class
	call set_global_iconf
	
	do mconf 1031 1 0 0 #Poporing
	
	call set_savemap_prt_fild05
	]
}

macro set_lockmap_pay_dun00 {
	[
	do conf lockMap pay_dun00
	
	call set_config_class
	call set_global_iconf
	
	call set_savemap_oldnewpayon
	]
}

macro set_lockmap_pay_fild01 {
	[
	do conf lockMap pay_fild01
	
	call set_config_class
	call set_global_iconf
	
	do mconf 1031 1 0 0 #Poporing
	
	call set_savemap_oldnewpayon
	]
}

macro set_lockmap_pay_fild05 {
	[
	do conf lockMap pay_fild05
	
	call set_config_class
	call set_global_iconf
	
	call set_savemap_oldnewpayon
	]
}

macro set_lockmap_pay_fild08 {
	[
	do conf lockMap pay_fild08
	
	call set_config_class
	call set_global_iconf
	
	do mconf 1031 0 0 0 #Poporing
	do mconf 1018 0 0 0 #Creamy
	
	call set_savemap_oldnewpayon
	]
}

macro set_lockmap_yuno_fild01 {
	[
	do conf lockMap yuno_fild01
	
	call set_config_class
	call set_global_iconf
	
	do mconf 1369 0 0 0 #Grand Peco
	
	call set_savemap_oldnewpayon
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






macro set_global_iconf {
	[
	do iconf 1058 0 1 0
	do iconf 713 0 1 0
	do iconf 578 0 1 0
	do iconf 1019 0 1 0 # Trunk
	do iconf 7053 0 1 0 # Cyfar
	do iconf 7126 0 1 0 # Large Jellopy
	do iconf 909 0 1 0 # Jellopy
	do iconf 912 0 1 0 # Zargon
	do iconf 582 0 1 0 # Orange
	do iconf 568 0 1 0 # Lemon
	do iconf 514 0 1 0 # Grape
	do iconf 518 0 1 0 # Honey
	do iconf 999 0 1 0 # Steel
	do iconf 998 0 1 0 # Iron
	do iconf 1000 0 1 0 # Star Crumb
	do iconf 1001 0 1 0 # Star Dust
	do iconf 1002 0 1 0 # Iron Ore
	do iconf 1003 0 1 0 # Coal
	do iconf 984 0 1 0 # Oridecon
	do iconf 985 0 1 0 # Elunium
	do iconf 1061 0 1 0 # Witch Starsand
	do iconf 644 0 1 0 # Gift Box
	do iconf 603 0 1 0 # Old Blue Box
	do iconf 617 0 1 0 # Old Purple Box
	do iconf 662 0 1 0 # Authoritative Badge
	do iconf 993 0 1 0 # Green Live
	do iconf 994 0 1 0 # Flame Heart
	do iconf 995 0 1 0 # Mystic Frozen
	do iconf 996 0 1 0 # Rough Wind
	do iconf 997 0 1 0 # Great Nature
	do iconf 715 0 1 0 # Yellow Gemstone
	do iconf 716 0 1 0 # Red Gemstone
	do iconf 717 0 1 0 # Blue Gemstone
	do iconf 507 0 1 0 # Red Herb
	do iconf 508 0 1 0 # Yellow Herb
	do iconf 509 0 1 0 # White Herb
	do iconf 510 0 1 0 # Blue Herb
	do iconf 511 0 1 0 # Green Herb

	do iconf 7312 0 0 1 #Jubilee
	do iconf 1602 0 0 1 #Bastão [4]
	do iconf 1105 0 0 1 #Falchion [4]
	do iconf 516 0 0 1 #batata
	do iconf 580 0 0 1 #pao
	do iconf 700 0 0 1 #Cold_Scroll
	
	if ($configClass = knight) {
		do iconf 713 50 1 0
		do iconf 1058 1 1 0
	}
	]
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
	ConfigKey eventMacro_goal_class knight
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
	ConfigKey eventMacro_goal_class knight
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
	ConfigKey eventMacro_goal_class knight
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

automacro need_to_Leave_Oranpere1 {
	exclusive 1
	priority 0
	ConfigKey eventMacro_goal_class rogue
	ConfigKey Joined_Oranpere true
	ConfigKey eventMacro_1_99_stage leveling
	call {
		do conf -f Leave_Oranpere_before &config(eventMacro_1_99_stage)
		do conf -f eventMacro_1_99_stage Leave_Oranpere
		do conf -f before_event_include &config(current_event_include)
		do conf -f current_event_include Leave_Oranpere.pm
		include off &config(before_event_include)
		include on Leave_Oranpere.pm
		
		do reload eventMacros
	}
}

automacro need_to_Leave_Oranpere2 {
	exclusive 1
	priority 0
	ConfigKey eventMacro_goal_class rogue
	StatusActiveHandle EFST_SWORDCLAN
	ConfigKey eventMacro_1_99_stage leveling
	call {
		do conf -f Leave_Oranpere_before &config(eventMacro_1_99_stage)
		do conf -f eventMacro_1_99_stage Leave_Oranpere
		do conf -f before_event_include &config(current_event_include)
		do conf -f current_event_include Leave_Oranpere.pm
		include off &config(before_event_include)
		include on Leave_Oranpere.pm
		
		do reload eventMacros
	}
}

automacro need_to_configure_VileWind {
	exclusive 1
	priority 0
	ConfigKey eventMacro_goal_class rogue
	ConfigKey eventMacro_test 0
	ConfigKeyNot Joined_VileWind true
	ConfigKeyNot Joined_VileWind false
	ConfigKey eventMacro_1_99_stage leveling
	call {
		do conf -f Joined_VileWind false
	}
}

automacro need_to_configure_VileWind_2 {
	exclusive 1
	priority 0
	ConfigKey eventMacro_goal_class rogue
	ConfigKey eventMacro_test 0
	ConfigKey Joined_VileWind true
	StatusInactiveHandle UNKNOWN_STATUS_1351
	ConfigKey eventMacro_1_99_stage leveling
	call {
		do conf -f Joined_VileWind false
	}
}

automacro need_to_Join_VileWind {
	exclusive 1
	priority 0
	ConfigKey eventMacro_goal_class rogue
	ConfigKey eventMacro_test 0
	ConfigKey Joined_VileWind false
	ConfigKey eventMacro_1_99_stage leveling
	call {
		do conf -f Join_VileWind_before &config(eventMacro_1_99_stage)
		do conf -f eventMacro_1_99_stage Join_VileWind
		do conf -f before_event_include &config(current_event_include)
		do conf -f current_event_include Join_VileWind.pm
		include off &config(before_event_include)
		include on Join_VileWind.pm
		
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