
# SM_MOVINGRECOVERY_Quest
automacro moveRecOutside {
	exclusive 1
	ConfigKey eventMacro_1_99_stage SM_MOVINGRECOVERY_Quest
	NotInMap izlude_in
	call gotoRec
}

automacro moveRecInside {
	exclusive 1
	ConfigKey eventMacro_1_99_stage SM_MOVINGRECOVERY_Quest
	NpcNotNear /Thomas/
	InMap izlude_in
	call gotoRec
}

macro gotoRec {
	do move izlude_in 117 172
}

automacro talkRec {
    exclusive 1
	NpcNear /Thomas/
	ConfigKey eventMacro_1_99_stage SM_MOVINGRECOVERY_Quest
	InMap izlude_in
	call {
		do talk $.NpcNearLastBinId
		do talk resp 0
		do talk resp 0
		do talk resp 0
	}
}

automacro RecOver {
	exclusive 1
	priority 0
	SkillLevel SM_MOVINGRECOVERY = 1
	ConfigKey eventMacro_1_99_stage SM_MOVINGRECOVERY_Quest
	call {
		do conf -f Joined_Oranpere true
		do conf -f eventMacro_1_99_stage &config(SM_MOVINGRECOVERY_Quest_before)
		do conf -f SM_MOVINGRECOVERY_Quest_before none
		
		include off SM_MOVINGRECOVERY_Quest.pm
		include on &config(before_event_include)
		
		do conf -f current_event_include &config(before_event_include)
		do conf -f before_event_include none
		
		do reload eventMacros
	}
}

automacro RecOver2 {
	exclusive 1
	priority 0
	SkillLevel SM_MOVINGRECOVERY = 0
    InInventoryID 713 < 50
    InInventoryID 1058 < 1
	ConfigKey eventMacro_1_99_stage SM_MOVINGRECOVERY_Quest
	call {
		do conf -f Joined_Oranpere true
		do conf -f eventMacro_1_99_stage &config(SM_MOVINGRECOVERY_Quest_before)
		do conf -f SM_MOVINGRECOVERY_Quest_before none
		
		include off SM_MOVINGRECOVERY_Quest.pm
		include on &config(before_event_include)
		
		do conf -f current_event_include &config(before_event_include)
		do conf -f before_event_include none
		
		do reload eventMacros
	}
}