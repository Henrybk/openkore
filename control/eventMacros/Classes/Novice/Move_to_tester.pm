
automacro moveToTest {
    exclusive 1
    JobLevel = 10
    priority 0
	ConfigKey eventMacro_1_99_stage novice_2
    InMap new_1-3, new_2-3, new_3-3, new_4-3, new_5-3
    NpcNotNear /Test/
    call MoveTest
}

macro MoveTest {
    do move 28 178
}

automacro talkGuyTest {
    exclusive 1
    JobLevel = 10
    priority 0
	ConfigKey eventMacro_1_99_stage novice_2
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
	ConfigKey eventMacro_1_99_stage novice_2
    InMap new_1-4, new_2-4, new_3-4, new_4-4, new_5-4
	NpcNotNear /Bruce/
    priority 1
	call move_to_Bruce
}

macro move_to_Bruce {
	do move 99 20
}

automacro talkBruce {
    exclusive 1
    JobLevel = 10
    priority 0
	ConfigKey eventMacro_1_99_stage novice_2
    InMap new_1-3, new_2-3, new_3-3, new_4-3, new_5-3
    NpcNear /Bruce/
    call TalkBruce
}

macro TalkBruce {
    do talknpc &arg("$.NpcNearLastPos", 1) &arg("$.NpcNearLastPos", 2) r0 r6
}

automacro move_to_Hanson {
    exclusive 1
    JobLevel = 10
    priority 0
	ConfigKey eventMacro_1_99_stage novice_2
    InMap new_1-4, new_2-4, new_3-4, new_4-4, new_5-4
	NpcNotNear /Hanson/
    priority 1
	call move_to_Hanson
}

macro move_to_Hanson {
	do move 99 20
}

automacro talkHanson {
    exclusive 1
    JobLevel = 10
    priority 0
	ConfigKey eventMacro_1_99_stage novice_2
    InMap new_1-3, new_2-3, new_3-3, new_4-3, new_5-3
    NpcNear /Hanson/
    call TalkHanson
}

macro TalkHanson {
    do talknpc &arg("$.NpcNearLastPos", 1) &arg("$.NpcNearLastPos", 2) r0 r1 r1 r1 r1 r1 r1 r1 r1 r0 r0 r1 r0 r1 r1 r1 r0 r2 r0 r1 r1 r1 r1 r0
}