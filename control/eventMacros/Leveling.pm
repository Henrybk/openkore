# Leveling
automacro leveling_timer {
	timeout 180
	ConfigKey eventMacro_1_99_stage leveling
	exclusive 1
	priority 2
	call baseMacroUp
}

macro baseMacroUp {
	re_add_skipped_lockMaps()

	if (check_current_lockMap("&config(lockMap)", "&config(lockMap_index)", "&config(eventMacro_goal_class)", "$.job", "$.lvl", "$.joblvl", "&config(lockMap_skip)")) {
		stop
	}
		
	$lockMap = set_best_lockMap("&config(eventMacro_goal_class)", "$.job", "$.lvl", "$.joblvl", "&config(lockMap_skip)")
	[
		if ($lockMap == 1) {
			log Everything went fine with the auto find lockMap function
		} else {
			log There was a problem with the auto find lockMap function
			do quit
			stop
		}
	]
	
	call get_best_savepoint
}