# Leveling
automacro leveling_timer {
	timeout 180
	ConfigKey eventMacro_1_99_stage leveling
	exclusive 1
	priority 2
	call baseMacroUp
}

macro baseMacroUp {
	[
	log Here we would set lockmap and savemap
	
	call SetVar
	call set_buyauto_equipment
	
	$changed = 0
	$HPRecoveryWhileMovingLevel = getSkillLevelByHandle("SM_MOVINGRECOVERY")
	
	if ($configlockMap == yuno_fild01 && $HPRecoveryWhileMovingLevel == 1) {
		do conf lockMap none
	}
	
	#Leveling
	if ($.lvl <= 22) {
		if ($configlockMap != prt_sewb2) {
			# kafra prt_fild05 290 224
			# sell prt_fild05 290 221
			call set_lockmap_prt_sewb2
			$changed = 1
		}
	
	} elsif ($.lvl <= 35) {
		if ($configlockMap != pay_fild01) {
			# kafra oldnewpayon 98 118
			# sell oldnewpayon 69 117
			call set_lockmap_pay_fild01
			$changed = 1
		}
		
	} elsif ($.joblvl >= 35 && $HPRecoveryWhileMovingLevel == 0) {
		if ($configlockMap != yuno_fild01) {
			# kafra aldebaran 143 119
			# sell aldeba_in 94 56
			call set_lockmap_yuno_fild01
			$changed = 1
		}
		
	}
	
	if ($changed == 1) {
		call after_lock_change
	}
	]
}

macro set_lockmap_prt_sewb2 {
	[
	do conf lockMap prt_sewb2
	
	do conf -f future_saveMap_map prt_fild05
	do conf -f future_saveMap_x 290
	do conf -f future_saveMap_y 224
	
	do conf -f future_saveMap_kafra_map prt_fild05
	do conf -f future_saveMap_kafra_x 290
	do conf -f future_saveMap_kafra_y 224
	do conf -f future_saveMap_save_sequence r~/Save/i
	]
}

macro set_lockmap_pay_fild01 {
	[
	do conf lockMap pay_fild01
	do iconf 713 50 1 0
	do iconf 1058 1 1 0
	
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
	do iconf 713 50 1 0
	do iconf 1058 1 1 0
	
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