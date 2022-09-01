

automacro moveToGuyEntrance_again {
	exclusive 1
	priority 0
	ConfigKey eventMacro_1_99_stage novice_3
	InMap new_1-2, new_2-2, new_3-2, new_4-2, new_5-2
	NpcNotNear /Entrance/
	call MoveEntrance
}

macro MoveEntrance {
	do move 28 178
}

automacro talkGuyEntrance_again {
	exclusive 1
	priority 0
	ConfigKey eventMacro_1_99_stage novice_3
	InMap new_1-2, new_2-2, new_3-2, new_4-2, new_5-2
	NpcNear /Entrance/
	call TalkEntrance
}

macro TalkEntrance {
	do talknpc &arg("$.NpcNearLastPos", 1) &arg("$.NpcNearLastPos", 2) r0
}

automacro moveToTest {
	exclusive 1
	JobLevel = 10
	priority 0
	ConfigKey eventMacro_1_99_stage novice_3
	InMap new_1-3, new_2-3, new_3-3, new_4-3, new_5-3
	NpcNotNear /Test/
	call MoveTest
}

macro MoveTest {
	do move 100 170
}

automacro talkGuyTest {
	exclusive 1
	JobLevel = 10
	priority 0
	ConfigKey eventMacro_1_99_stage novice_3
	InMap new_1-3, new_2-3, new_3-3, new_4-3, new_5-3
	NpcNear /Test/
	call TalkTest
}

macro TalkTest {
	do talknpc &arg("$.NpcNearLastPos", 1) &arg("$.NpcNearLastPos", 2) r0
}

automacro move_to_Bruce {
	exclusive 1
	JobLevel = 10
	priority 0
	ConfigKey eventMacro_1_99_stage novice_3
	InMap new_1-4, new_2-4, new_3-4, new_4-4, new_5-4
	NpcNotNear /Bruce/
	call move_to_Bruce
}

macro move_to_Bruce {
	do move 99 20
}

automacro talkBruce {
	exclusive 0
	self_interruptible 0
	JobLevel = 10
	priority 0
	ConfigKey eventMacro_1_99_stage novice_3
	InMap new_1-4, new_2-4, new_3-4, new_4-4, new_5-4
	NpcNear /Bruce/
	call TalkBruce
}

macro TalkBruce {
	do talknpc &arg("$.NpcNearLastPos", 1) &arg("$.NpcNearLastPos", 2) r0 r6
}

automacro detect_Bruce_end {
	exclusive 1
	priority 0
	NpcMsg /Hanson is waiting/
	InMap new_1-4, new_2-4, new_3-4, new_4-4, new_5-4
	ConfigKey eventMacro_1_99_stage novice_3
	call {
		do conf -f eventMacro_1_99_stage novice_4
	}
}