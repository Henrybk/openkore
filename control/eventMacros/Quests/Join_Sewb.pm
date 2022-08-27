
# Join Sewb
automacro moveRecOutside {
	exclusive 1
	ConfigKey eventMacro_1_99_stage join_sewb
	NotInMap prt_in
	call gotoRec
}

automacro moveRecInside {
	exclusive 1
	ConfigKey eventMacro_1_99_stage join_sewb
	NpcNotNear /(Recrutador|Recruiter)/
	InMap prt_in
	call gotoRec
}

macro gotoRec {
	do move prt_in 83 104
}

automacro talkRec {
    exclusive 0
	self_interruptible 0
	NpcNear /(Recrutador|Recruiter)/
	ConfigKey eventMacro_1_99_stage join_sewb
	InMap prt_in
	call {
		do talk $.NpcNearLastBinId
		do talk resp /Volunteer/
	}
}

automacro RecOver {
	exclusive 1
	priority 0
	ConfigKey eventMacro_1_99_stage join_sewb
	NpcMsgName /(Eu te mandarei imediatamente|I will now warp you)/ /(Recrutador|Recruiter)/
	call {
		do conf -f Joined_Sewb true
		do conf -f eventMacro_1_99_stage &config(Join_Sewb_before)
		do conf -f Join_Sewb_before none
		
		include off Join_Sewb.pm
		include on &config(before_event_include)
		
		do conf -f current_event_include &config(before_event_include)
		do conf -f before_event_include none
		
		do reload eventMacros
	}
}

automacro RecOverbug {
	exclusive 1
	priority 0
	ConfigKey eventMacro_1_99_stage join_sewb
	NpcMsgName /Would you let me warp/ /(Recrutador|Recruiter)/
	call {
		do talk resp /Warp/
		
		do conf -f Joined_Sewb true
		do conf -f eventMacro_1_99_stage &config(Join_Sewb_before)
		do conf -f Join_Sewb_before none
		
		include off Join_Sewb.pm
		include on &config(before_event_include)
		
		do conf -f current_event_include &config(before_event_include)
		do conf -f before_event_include none
		
		do reload eventMacros
	}
}