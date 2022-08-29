
# Join Haleigh
automacro moveRecOutside {
	exclusive 1
	ConfigKey eventMacro_1_99_stage Join_Haleigh
	NotInMap aldebaran
	call gotoRec
}

automacro moveRecInside {
	exclusive 1
	ConfigKey eventMacro_1_99_stage Join_Haleigh
	NpcNotNear /Haleigh/
	InMap aldebaran
	call gotoRec
}

macro gotoRec {
	do move aldebaran 228 165 5
}

automacro talkRec {
    exclusive 0
	self_interruptible 0
	NpcNear /Haleigh/
	ConfigKey eventMacro_1_99_stage Join_Haleigh
	InMap aldebaran
	call {
		do talk $.NpcNearLastBinId
		do talk resp 0 #sure am
	}
}

automacro RecOver {
	exclusive 1
	priority 0
	ConfigKey eventMacro_1_99_stage Join_Haleigh
	NpcMsgName /please speak to my assistant/i /Haleigh/
	call {
		do conf -f Joined_Haleigh true
		do conf -f eventMacro_1_99_stage &config(Join_Haleigh_before)
		do conf -f Join_Haleigh_before none
		
		include off Join_Haleigh.pm
		include on &config(before_event_include)
		
		do conf -f current_event_include &config(before_event_include)
		do conf -f before_event_include none
		
		do reload eventMacros
	}
}