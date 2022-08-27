
# Join Oranpere
automacro moveRecOutside {
	exclusive 1
	ConfigKey eventMacro_1_99_stage Join_Oranpere
	NotInMap prontera
	call gotoRec
}

automacro moveRecInside {
	exclusive 1
	ConfigKey eventMacro_1_99_stage Join_Oranpere
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
	ConfigKey eventMacro_1_99_stage Join_Oranpere
	InMap prontera
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
	ConfigKey eventMacro_1_99_stage Join_Oranpere
	NpcMsgName /(Welcome to Sword Clan|mess with me)/ /Oranpere/
	call {
		do conf -f Joined_Oranpere true
		do conf -f eventMacro_1_99_stage &config(Join_Oranpere_before)
		do conf -f Join_Oranpere_before none
		
		include off Join_Oranpere.pm
		include on &config(before_event_include)
		
		do conf -f current_event_include &config(before_event_include)
		do conf -f before_event_include none
		
		do reload eventMacros
	}
}