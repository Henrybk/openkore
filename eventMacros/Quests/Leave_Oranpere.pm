
# Leave Oranpere
automacro moveRecOutside {
	exclusive 1
	ConfigKey eventMacro_1_99_stage Leave_Oranpere
	NotInMap prontera
	call gotoRec
}

automacro moveRecInside {
	exclusive 1
	ConfigKey eventMacro_1_99_stage Leave_Oranpere
	NpcNotNear /Oranpere/
	InMap prontera
	call gotoRec
}

macro gotoRec {
	do move prontera 60 340
}

automacro talkRec {
	exclusive 0
	self_interruptible 0
	NpcNear /Oranpere/
	ConfigKey eventMacro_1_99_stage Leave_Oranpere
	InMap prontera
	call {
		do talk $.NpcNearLastBinId
		do talk resp /Leave/
		do talk resp /Continue/
	}
}

automacro RecOver {
	exclusive 1
	priority 0
	ConfigKey eventMacro_1_99_stage Leave_Oranpere
	StatusInactiveHandle EFST_SWORDCLAN
	call {
		do conf -f Joined_Oranpere false
		do conf -f eventMacro_1_99_stage &config(Leave_Oranpere_before)
		do conf -f Leave_Oranpere_before none
		
		include off Leave_Oranpere.pm
		include on &config(before_event_include)
		
		do conf -f current_event_include &config(before_event_include)
		do conf -f before_event_include none
		
		do reload eventMacros
	}
}