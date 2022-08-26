
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
	NpcNear /(Recrutador|Recruiter)/
	ConfigKey eventMacro_1_99_stage join_sewb
	InMap prt_in
	timeout 40
	call {
		do talknpc &arg("$.NpcNearLastPos", 1) &arg("$.NpcNearLastPos", 2) r0
	}
}

automacro RecOver {
	exclusive 1
	priority -5
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