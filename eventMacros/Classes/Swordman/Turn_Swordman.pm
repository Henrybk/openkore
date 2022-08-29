
automacro move_to_Hanson {
    exclusive 1
    JobLevel = 10
    priority 0
	ConfigKey eventMacro_1_99_stage novice_4
    InMap new_1-4, new_2-4, new_3-4, new_4-4, new_5-4
	NpcNotNear /Hanson/
	call move_to_Hanson
}

macro move_to_Hanson {
	do move 99 20
}

automacro talkHanson {
    exclusive 1
    JobLevel = 10
    priority 0
	ConfigKey eventMacro_1_99_stage novice_4
    InMap new_1-4, new_2-4, new_3-4, new_4-4, new_5-4
    NpcNear /Hanson/
    call TalkHanson
}

macro TalkHanson {
    do talknpc &arg("$.NpcNearLastPos", 1) &arg("$.NpcNearLastPos", 2) r0 r1 r1 r1 r1 r1 r1 r1 r1 r0 r0 r1 r0 r1 r1 r1 r0 r2 r0 r1 r1 r1 r1 r0
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
	ConfigKey eventMacro_1_99_stage novice_4
	priority 1
	call {
		include off Move_to_tester.pm
		
		do conf -f eventMacro_1_99_stage turnswordman_out
		
		do reload eventMacros
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
	NpcNotNear /Swordman#swd_1/
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
	NpcNear /Swordman#swd_1/
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
	NpcNotNear /Swordman#swd_2/
	exclusive 1
	priority 1
	call Move_to_test_place
}

macro Move_to_test_place {
	do move izlude_in 84 169
}

automacro talk_to_move_test_area {
    exclusive 0
	self_interruptible 0
	timeout 5
	ConfigKey eventMacro_1_99_stage turnswordman_out
	JobID 0
	InMap izlude_in
	QuestActive 1014
	NpcNotNear /Test/
	NpcNear /Swordman#swd_2/
	priority 1
	call {
		do talk $.NpcNearLastBinId
	}
}

automacro end_bug {
    exclusive 1
	ConfigKey eventMacro_1_99_stage turnswordman_out
	QuestActive 1014
	NpcMsgName /You need to talk to the Swordman in the center of the room/i /Swordman#swd_2/i
	JobID 0
	priority 0
	call ended_test
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
	do conf -f lockMap none
	
	do conf -f attackAuto -1
	do conf -f attackCheckLOS 1
	do conf -f attackRouteMaxPathDistance 28
	do conf -f route_randomWalk 0
	do conf -f route_step 1
	do conf -f portalRecord 0
	do conf -f route_avoidWalls 0
	]
}

automacro Got_out_of_test_map {
	exclusive 1
	JobID 0
	QuestActive 1014
	ConfigKey eventMacro_1_99_stage turnswordman_test
	NotInMap job_sword1
	priority 1
	call Ajust_to_move_to_test
}

macro Ajust_to_move_to_test {
	[
	do conf -f eventMacro_1_99_stage turnswordman_out
	do conf -f lockMap none
	do conf -f attackAuto 0
	do conf -f attackCheckLOS 1
	do conf -f attackRouteMaxPathDistance 28
	do conf -f route_randomWalk 0
	do conf -f itemsGatherAuto 0
	do conf -f route_step 15
	do conf -f portalRecord 2
	do conf -f route_avoidWalls 1
	]
}

automacro do_test {
	ConfigKey eventMacro_1_99_stage turnswordman_test
	InMap job_sword1
	QuestActive 1014
	NpcNotNear /Mae/
	JobID 0
	exclusive 1
	priority 1
	call do_test
}

macro do_test {
	do move job_sword1 215 167
}

automacro Talk_to_mae_end_test {
    exclusive 0
	self_interruptible 0
	ConfigKey eventMacro_1_99_stage turnswordman_test
	InMap job_sword1
	QuestActive 1014
	NpcNear /Mae/
	JobID 0
	priority 2
	call {
		do talk $.NpcNearLastBinId
	}
}

automacro mae_text_end {
    exclusive 1
	ConfigKey eventMacro_1_99_stage turnswordman_test
	QuestActive 1014
	NpcMsgName /congratulate/i /(Mae)/i
	JobID 0
	priority 0
	call ended_test
}

macro ended_test {
	[
	do conf -f eventMacro_1_99_stage turnswordman_after_test
	do conf -f lockMap none
	do conf -f attackAuto 0
	do conf -f attackCheckLOS 1
	do conf -f attackRouteMaxPathDistance 28
	do conf -f route_randomWalk 0
	do conf -f itemsGatherAuto 0
	do conf -f route_step 15
	do conf -f portalRecord 2
	do conf -f route_avoidWalls 1
	]
}

automacro move_to_guild_outside_far_end {
	ConfigKey eventMacro_1_99_stage turnswordman_after_test
	QuestActive 1014
	NotInMap izlude
	NotInMap job_sword1
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
	NpcNotNear /Swordman#swd_1/
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
	NpcNear /Swordman#swd_1/
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
	IsNotEquippedID rightHand 1104
	JobLevel = 1
	JobID 1
	exclusive 1
	timeout 10
	call {
		[
		call clear_equipauto
		do conf -f equipAuto_0_rightHand GetNamebyNameID(1104)
		]
	}
}

automacro EquipSwordmanStuffEnd {
	ConfigKey eventMacro_1_99_stage turnswordman_after_change
	IsEquippedID rightHand 1104
	JobLevel = 1
	JobID 1
	exclusive 1
	call {
		[
		do iconf 1104 1 0 0
		do iconf 1243 0 0 1
		do iconf 2112 0 0 1
		do iconf 5055 0 0 1
		do iconf 2393 0 0 1
		do iconf 2414 0 0 1
		do iconf 2510 0 0 1
		do iconf 2352 0 0 1
		do iconf 1201 0 0 1
		do iconf 13040 0 0 1
		do iconf 2301 0 0 1
		do iconf 713 50 1 0
		do iconf 1058 1 1 0
		do conf -f useSelf_item_0_hp < 75%
		do conf -f attackAuto 2
		do conf -f attackAuto_inLockOnly 2
		do conf -f attackCheckLOS 1
		do conf -f attackRouteMaxPathDistance 28
		do conf -f route_randomWalk 1
        do conf -f itemsGatherAuto 0
        do conf -f itemsTakeAuto 2
		do conf -f route_step 15
		do conf -f portalRecord 2
		do conf -f route_avoidWalls 1
		
		do conf -f teleportAuto_minAggressives 4
		do conf -f saveMap_warpToBuyOrSell 1
		
		include off Turn_Swordman.pm
		
		call set_class_leveling
		
		do reload eventMacros
		]
	}
}
