
automacro Talk_to_Final_Tester {
	exclusive 1
	JobLevel 10
    QuestInactive 7122
    InMap new_1-4, new_2-4, new_3-4, new_4-4, new_5-4
	NpcNear /Final/
	ConfigKey eventMacro_1_99_stage turnswordman
    priority 1
	call {
		do talknpc &arg("$.NpcNearLastPos", 1) &arg("$.NpcNearLastPos", 2) r1 r0 r0 r0 r0 r0 r0 r0 r0 r0 r0 r0 r0 r0 r0 r0 r0 r0 r0 r0 r0 r0 r0 r0
	}
}

automacro moved_out_of_novice_grounds {
	exclusive 1
	JobID 0
    NotInMap new_1-4
    NotInMap new_2-4
    NotInMap new_3-4
    NotInMap new_4-4
    NotInMap new_5-4
    NotInMap new_1-3
    NotInMap new_2-3
    NotInMap new_3-3
    NotInMap new_4-3
    NotInMap new_5-3
	ConfigKey eventMacro_1_99_stage turnswordman
	priority 1
	call {
		do conf -f eventMacro_1_99_stage turnswordman_out
	}
}

automacro move_to_guild_outside_far {
	ConfigKey eventMacro_1_99_stage turnswordman_out
	exclusive 1
	JobID 0
	NotInMap izlude
	NotInMap job_sword1
	NotInMap sword_2-2
	NotInMap sword_2-1
	NotInMap sword_1-1
	NotInMap sword_3-1
	NotInMap izlude_in
	priority 1
	call {
		do is Novice Butterfly Wing
	}
}

automacro move_to_guild_outside {
	ConfigKey eventMacro_1_99_stage turnswordman_out
	JobID 0
	InMap izlude
	QuestInactive 1014
	exclusive 1
	priority 1
	call Move_to_swordman_place
}

automacro move_to_guild_inside {
	ConfigKey eventMacro_1_99_stage turnswordman_out
	JobID 0
	InMap izlude_in
	QuestInactive 1014
	NpcNotNear /Swordman/
	exclusive 1
	priority 1
	call Move_to_swordman_place
}

macro Move_to_swordman_place {
	do move izlude_in 74 172 6
}

automacro Talk_to_swordman_Swordman {
	ConfigKey eventMacro_1_99_stage turnswordman_out
	JobID 0
	InMap izlude_in
	QuestInactive 1014
	NpcNear /Swordman/
	exclusive 1
	priority 1
	call {
		do talknpc &arg("$.NpcNearLastPos", 1) &arg("$.NpcNearLastPos", 2) r0 r0 r0
	}
}

automacro move_to_test_outside {
	ConfigKey eventMacro_1_99_stage turnswordman_out
	JobID 0
	InMap izlude
	QuestActive 1014
	exclusive 1
	priority 1
	call Move_to_test_place
}

automacro move_to_test_inside {
	ConfigKey eventMacro_1_99_stage turnswordman_out
	JobID 0
	InMap izlude_in
	QuestActive 1014
	NpcNotNear /Test/
	exclusive 1
	priority 1
	call Move_to_test_place
}

macro Move_to_test_place {
	do move izlude_in 30 175 5
}

automacro Talk_to_swordman_test {
	exclusive 1
	JobID 0
	InMap izlude_in
	QuestActive 1014
	ConfigKey eventMacro_1_99_stage turnswordman_out
	NpcNear /Test/
	priority 1
	call {
		do talk $.NpcNearLastBinId
	}
}

automacro Got_into_test_map {
	exclusive 1
	JobID 0
	QuestActive 1014
	ConfigKey eventMacro_1_99_stage turnswordman_out
	InMap job_sword1, sword_2-2, sword_2-1, sword_1-1, sword_3-1
	priority 1
	call Ajust_to_test
}

macro Ajust_to_test {
	[
	do conf -f eventMacro_1_99_stage turnswordman_test
	do conf -f lockMap $.map
	
	do conf -f attackAuto 1
	do conf -f route_randomWalk 0
	do conf -f route_step 1
	do conf -f portalRecord 0
	]
}

automacro Got_out_of_test_map {
	exclusive 1
	JobID 0
	QuestActive 1014
	ConfigKey eventMacro_1_99_stage turnswordman_test
	NotInMap job_sword1
	NotInMap sword_2-2
	NotInMap sword_2-1
	NotInMap sword_1-1
	NotInMap sword_3-1
	priority 1
	call Ajust_to_move_to_test
}

macro Ajust_to_move_to_test {
	[
	do conf -f eventMacro_1_99_stage turnswordman_out
	do conf -f lockMap none
	do conf -f attackAuto 0
	do conf -f route_randomWalk 0
	do conf -f itemsGatherAuto 0
	do conf -f route_step 15
	do conf -f portalRecord 2
	]
}

automacro do_test {
	ConfigKey eventMacro_1_99_stage turnswordman_test
	InMap job_sword1, sword_2-2, sword_2-1, sword_1-1, sword_3-1
	QuestActive 1014
	NpcNotNear /Mae/
	JobID 0
	exclusive 1
	priority 1
	call do_test
}

macro do_test {
	do move 218 165
}

automacro Talk_to_mae_end_test {
	ConfigKey eventMacro_1_99_stage turnswordman_test
	InMap job_sword1, sword_2-2, sword_2-1, sword_1-1, sword_3-1
	QuestActive 1014
	NpcNear /Mae/
	JobID 0
	timeout 20
	priority 2
	call {
		do talk $.NpcNearLastBinId
	}
}

automacro mae_text_end {
	ConfigKey eventMacro_1_99_stage turnswordman_test
	QuestActive 1014
	NpcMsgName /congratulate/i /(Mae)/i
	JobID 0
	exclusive 1
	priority 0
	call {
		[
		do conf -f eventMacro_1_99_stage turnswordman_after_test
		do conf -f lockMap none
		do conf -f attackAuto 0
		do conf -f route_randomWalk 0
		do conf -f itemsGatherAuto 0
		do conf -f route_step 15
		do conf -f portalRecord 2
		]
	}
}

automacro move_to_guild_outside_far_end {
	ConfigKey eventMacro_1_99_stage turnswordman_after_test
	QuestActive 1014
	NotInMap izlude
	NotInMap job_sword1
	NotInMap sword_2-2
	NotInMap sword_2-1
	NotInMap sword_1-1
	NotInMap sword_3-1
	NotInMap izlude_in
	JobID 0
	exclusive 1
	priority 1
	call {
		do is Novice Butterfly Wing
	}
}

automacro move_to_guild_outside_end {
	ConfigKey eventMacro_1_99_stage turnswordman_after_test
	QuestActive 1014
	exclusive 1
	JobID 0
	InMap izlude
	priority 1
	call Move_to_swordman_place
}

automacro move_to_guild_inside_end {
	ConfigKey eventMacro_1_99_stage turnswordman_after_test
	QuestActive 1014
	InMap izlude_in
	NpcNotNear /Swordman/
	JobID 0
	exclusive 1
	priority 1
	call Move_to_swordman_place
}

automacro Talk_to_swordman_Swordman_end {
	ConfigKey eventMacro_1_99_stage turnswordman_after_test
	QuestActive 1014
	InMap izlude_in
	JobID 0
	NpcNear /Swordman/
	priority 1
	exclusive 1
	call {
		do talknpc &arg("$.NpcNearLastPos", 1) &arg("$.NpcNearLastPos", 2) r0
	}
}

automacro Changed_to_Swordman {
	ConfigKey eventMacro_1_99_stage turnswordman_after_test
	JobLevel = 1
	JobID 1
	exclusive 1
	priority 1
	call {
		do conf -f eventMacro_1_99_stage turnswordman_after_change
	}
}

automacro EquipSwordmanStuff {
	ConfigKey eventMacro_1_99_stage turnswordman_after_change
	IsNotEquippedID rightHand 13415, armor 2393
	InInventoryID 13415 = 1
	JobLevel = 1
	JobID 1
	exclusive 1
	call {
		%toequip = (rightHand => 13415, armor => 2393)
        call start_equipping
	}
}

automacro EquipSwordmanStuffEnd {
	ConfigKey eventMacro_1_99_stage turnswordman_after_change
	IsEquippedID rightHand 13415
	IsEquippedID armor 2393
	InInventoryID 13415 = 1
	JobLevel = 1
	JobID 1
	exclusive 1
	call {
		[
		do iconf 1243 0 0 1
		do iconf 2112 0 0 1
		do iconf 5055 0 0 1
		do iconf 2414 0 0 1
		do iconf 2510 0 0 1
		do iconf 2352 0 0 1
		do iconf 1201 0 0 1
		do iconf 13040 0 0 1
		do iconf 2301 0 0 1
		do conf -f useSelf_item_0_hp < 75%
		do conf -f attackAuto 2
		do conf -f route_randomWalk 1
		
		do conf -f teleportAuto_minAggressives 4
		do conf -f saveMap_warpToBuyOrSell 1
		
		include off Turn_Swordman.pm
		include off Brade_Bug.pm
		include off Move_to_tester.pm
		
		call set_class_leveling
		
		do reload eventMacros
		]
	}
}
