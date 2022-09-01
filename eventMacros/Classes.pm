
macro set_config_class {
	$configClass = &config(eventMacro_goal_class)
}

macro set_class_Settings_include {
	[
	call set_config_class
	if ($configClass = rogue) {
		include on Rogue_Settings.pm
		
	} elsif ($configClass = knight) {
		include on Knight_Settings.pm
	}
	]
}

macro set_class_turn_1_1_include {
	[
	call set_config_class
	if ($configClass = rogue) {
		do conf -f current_event_include Turn_Thief.pm
		include on Turn_Thief.pm
		
	} elsif ($configClass = knight) {
		do conf -f current_event_include Turn_Swordman.pm
		include on Turn_Swordman.pm
	}
	]
}

macro set_class_leveling {
	[
	call set_config_class
	if ($configClass = rogue) {
		do conf -f eventMacro_1_99_stage leveling
		do conf -f current_event_include Leveling.pm
		include on Leveling.pm
		
	} elsif ($configClass = knight) {
		do conf -f eventMacro_1_99_stage leveling
		do conf -f current_event_include Leveling.pm
		include on Leveling.pm
	}
	]
}