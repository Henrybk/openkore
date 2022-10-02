
# Join VileWind
automacro moveRecOutside {
	exclusive 1
	ConfigKey eventMacro_1_99_stage Join_VileWind
	NotInMap morocc
	call gotoRec
}

automacro moveRecInside {
	exclusive 1
	ConfigKey eventMacro_1_99_stage Join_VileWind
	NpcNotNear /Nathanos/
	InMap morocc
	call gotoRec
}

macro gotoRec {
	do move morocc 140 159
}

automacro talkRec {
	exclusive 0
	self_interruptible 0
	NpcNear /Nathanos/
	ConfigKey eventMacro_1_99_stage Join_VileWind
	InMap morocc
	call {
		do talk $.NpcNearLastBinId
		do talk resp /Join/
		do talk resp /Yes/
		do talk resp /Yes/
		do talk text $.name
	}
}

automacro RecOver {
	exclusive 1
	priority 0
	ConfigKey eventMacro_1_99_stage Join_VileWind
	StatusActiveHandle UNKNOWN_STATUS_1351
	call {
		do conf -f Joined_VileWind true
		do conf -f eventMacro_1_99_stage &config(Join_VileWind_before)
		do conf -f Join_VileWind_before none
		
		include off Join_VileWind.pm
		include on &config(before_event_include)
		
		do conf -f current_event_include &config(before_event_include)
		do conf -f before_event_include none
		
		do reload eventMacros
	}
}