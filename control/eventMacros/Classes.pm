
macro set_config_class {
	$configClass = &config(eventMacro_goal_class)
}

macro set_class_stats_and_skills {
	call set_config_class
	if ($configClass = rogue) {
		do conf -f statsAddAuto_list 15 agi, 20 dex, 20 agi, 9 str, 9 vit, 25 agi, 25 dex, 30 agi, 30 dex, 50 agi, 19 str, 35 dex, 65 agi, 19 vit, 30 int, 70 agi, 29 str, 40 int, 50 dex, 99 agi, 70 int
        do conf -f skillsAddAuto_list NV_BASIC 9, TF_MISS 10, TF_DOUBLE 10, TF_STEAL 10, TF_HIDING 10, TF_POISON 8, TF_DETOXIFY 1
		
	} elsif ($configClass = knight) {
		do conf -f statsAddAuto_list 10 agi, 10 dex, 10 str, 10 vit, 15 agi, 15 dex, 15 str, 15 vit, 25 agi, 25 dex, 20 str, 20 vit, 50 agi, 25 vit, 15 luk, 35 dex, 35 str, 35 vit, 70 agi, 50 str, 50 dex, 45 vit, 75 agi, 55 str, 50 vit, 80 agi, 65 str, 60 vit, 70 str, 90 agi
        do conf -f skillsAddAuto_list NV_BASIC 9, SM_SWORD 1, SM_RECOVERY 10, SM_TWOHAND 10, SM_PROVOKE 5, SM_ENDURE 10, SM_BASH 10, SM_MAGNUM 3, KN_TWOHANDQUICKEN 10, KN_RIDING 1, KN_CAVALIERMASTERY 5, KN_AUTOCOUNTER 5, KN_BOWLINGBASH 10
	}
}

macro set_class_answer_novice {
	call set_config_class
	if ($configClass = rogue) {
		do conf -f current_event_include Turn_Thief.pm
		include on Turn_Thief.pm
		
	} elsif ($configClass = knight) {
		do conf -f current_event_include Turn_Swordman.pm
		include on Turn_Swordman.pm
	}
}

macro set_class_leveling {
	call set_config_class
	if ($configClass = rogue) {
		do conf -f eventMacro_1_99_stage leveling
		do conf -f current_event_include Leveling.pm
		include on Leveling.pm
		include on Rogue_Equips.pm
		
	} elsif ($configClass = knight) {
		do conf -f eventMacro_1_99_stage leveling
		do conf -f current_event_include Leveling.pm
		include on Leveling.pm
		include on Knight_Equips.pm
	}
	include on Achieve_Rewards.pm
}

macro set_buyauto_equipment {
	call set_config_class
	if ($configClass = rogue) {
		call rogue_set_buyauto_equipment
		
	} elsif ($configClass = knight) {
		call knight_set_buyauto_equipment
	}
}