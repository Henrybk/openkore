
#Savepoint configurations
macro get_best_savepoint {
	$savepoint = set_nearest_savepoint("&config(lockMap)", "none", "none")
	[
	if ($savepoint == 1) {
		log Everything went fine with the auto save find savemap function
	} else {
		log There was a problem with the auto find savemap function
		do quit
		stop
	}
	call SetVar
	if ($configsaveMap != &config(future_saveMap_map)) {
		do conf -f saveMap_stage_before &config(eventMacro_1_99_stage)
		do conf -f eventMacro_1_99_stage saving_in_kafra
		do conf -f before_event_include &config(current_event_include)
		do conf -f current_event_include Save_Kafra.pm
		include off &config(before_event_include)
		include on Save_Kafra.pm
		do reload eventMacros
	} else {
		call clear_saveMap_keys
	}
	]
}

macro clear_saveMap_keys {
	[
	do conf -f future_saveMap_map none
	do conf -f future_saveMap_x none
	do conf -f future_saveMap_y none
	
	do conf -f future_saveMap_kafra_map none
	do conf -f future_saveMap_kafra_x none
	do conf -f future_saveMap_kafra_y none
	do conf -f future_saveMap_save_sequence none
	]
}

macro SetVar {
	$configlockMap = &config(lockMap)
	$configsaveMap = &config(saveMap)
	$joinedSewb = &config(Joined_Sewb)
}
