

automacro move_to_final_tester_outside {
	exclusive 1
	JobLevel 10
    QuestInactive 7122
    IsEquippedID rightHand 13040
    InMap new_1-3, new_2-3, new_3-3, new_4-3, new_5-3
    priority 1
	call move_to_final_tester_outside
}

macro move_to_final_tester_outside {
	$nextMap = nextMap("$.map")
	do move $nextMap 99 21
}

automacro move_to_final_tester_inside {
	exclusive 1
	JobLevel 10
    QuestInactive 7122
    InMap new_1-4, new_2-4, new_3-4, new_4-4, new_5-4
	NpcNotNear /Final/
    priority 1
	call move_to_final_tester_inside
}

macro move_to_final_tester_inside {
	do move 99 21
}