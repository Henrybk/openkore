
# Knight Chief

macro Move_to_knight_place_chief {
	do move prt_in 88 101 7
}

automacro move_to_guild_outside_start {
	ConfigKey eventMacro_1_99_stage turning_knight_true_start
	JobID 1
	NotInMap prt_in
	QuestInactive 9000
	exclusive 1
	priority 1
	call Move_to_knight_place_chief
}

automacro move_to_guild_inside_start {
	ConfigKey eventMacro_1_99_stage turning_knight_true_start
	JobID 1
	InMap prt_in
	QuestInactive 9000
	NpcNotNear /Chivalry Captain/i
	exclusive 1
	priority 1
	call Move_to_knight_place_chief
}

automacro Talk_to_knight_chief {
	ConfigKey eventMacro_1_99_stage turning_knight_true_start
	JobID 1
	InMap prt_in
	QuestInactive 9000
	NpcNear /Chivalry Captain/i
	exclusive 1
	priority 1
	call {
		do talknpc &arg("$.NpcNearLastPos", 1) &arg("$.NpcNearLastPos", 2) r0 r0
	}
}

automacro Started_knight_quests {
	ConfigKey eventMacro_1_99_stage turning_knight_true_start
	JobID 1
	QuestActive 9000
	exclusive 1
	priority 0
	call {
		do conf -f eventMacro_1_99_stage turning_knight_start
	}
}

# Knight Andrew

macro Move_to_knight_place_andrew {
	do move prt_in 75 107 5
}

automacro move_to_guild_outside_andrew {
	ConfigKey eventMacro_1_99_stage turning_knight_start
	JobID 1
	NotInMap prt_in
	QuestActive 9000
	exclusive 1
	priority 1
	call Move_to_knight_place_andrew
}

automacro move_to_guild_inside_andrew {
	ConfigKey eventMacro_1_99_stage turning_knight_start
	JobID 1
	InMap prt_in
	QuestActive 9000
	NpcNotNear /Sir Andrew/i
	exclusive 1
	priority 1
	call Move_to_knight_place_andrew
}

automacro Talk_to_knight_andrew {
	ConfigKey eventMacro_1_99_stage turning_knight_start
	JobID 1
	InMap prt_in
	QuestActive 9000
	NpcNear /Sir Andrew/i
	exclusive 1
	priority 1
	call {
		do talknpc &arg("$.NpcNearLastPos", 1) &arg("$.NpcNearLastPos", 2) r0
	}
}

# Knight Siracuse

macro Move_to_knight_place_Siracuse {
	do move prt_in 71 91 5
}

automacro move_to_guild_outside_Siracuse {
	ConfigKey eventMacro_1_99_stage turning_knight_start
	JobID 1
	NotInMap prt_in
	QuestActive 9003
	exclusive 1
	priority 1
	call Move_to_knight_place_Siracuse
}

automacro move_to_guild_inside_Siracuse {
	ConfigKey eventMacro_1_99_stage turning_knight_start
	JobID 1
	InMap prt_in
	QuestActive 9003
	NpcNotNear /Sir Siracuse/i
	exclusive 1
	priority 1
	call Move_to_knight_place_Siracuse
}

automacro Talk_to_knight_Siracuse {
	ConfigKey eventMacro_1_99_stage turning_knight_start
	JobID 1
	InMap prt_in
	QuestActive 9003
	NpcNear /Sir Siracuse/i
	exclusive 1
	priority 1
	call {
		do talknpc &arg("$.NpcNearLastPos", 1) &arg("$.NpcNearLastPos", 2) r0 r3 r2 r2 r0 r1 r0 r0 r0
	}
}

# Knight Windsor

automacro set_update_turning_knight {
	ConfigKey eventMacro_1_99_stage turning_knight_start
	JobID 1
	QuestActive 9004
	exclusive 1
	priority 1
	call update_turning_knight
}

macro update_turning_knight {
	[
	do conf -f eventMacro_1_99_stage turning_knight_farming
	do conf -f doing_knight_job_change windsor
	]
}

automacro turning_knight_farming {
	timeout 60
	exclusive 1
	priority 2
	QuestActive 9004, 9005, 9006
	InInventoryID 502 < 30
	ConfigKey eventMacro_1_99_stage turning_knight_farming
	ConfigKey doing_knight_job_change windsor
	call knight_farming
}

macro knight_farming {
	call SetVar
	call set_skills_stats
	$changed = 0
	
	if ($testvar == 1) {
		do mconf 1052 0 0 0 #Rocker
		do mconf 1014 0 0 0 #Spore
		do mconf 1127 1 0 0 #Hode
		if ($configlockMap != prt_fild05) {
			# kafra prt_fild05 290 224
			# sell prt_fild05 290 221
			call set_lockmap_prt_fild05
			$changed = 1
		}
	
	} elsif ($configlockMap != lasa_dun01) {
		# kafra aldebaran 143 119
		# sell aldeba_in 94 56
		call set_lockmap_lasa_dun01
		$changed = 1
	}
	
	if ($changed == 1) {
		call after_lock_change
	} else {
		log [Knight] Current lockmap $configlockMap is still good
	}
}

automacro Return_To_Job_Change_Orange_Potion {
	ConfigKey eventMacro_1_99_stage turning_knight_farming
	ConfigKey doing_knight_job_change windsor
	QuestActive 9004, 9005, 9006
	InInventoryID 502 >= 30 
	exclusive 1
	priority 0
	call {
		[
		do conf -f eventMacro_1_99_stage turning_knight_windsor
		do conf -f lockMap none
		]
	}
}

macro Move_to_knight_place_Windsor {
	do move prt_in 79 94 5
}

automacro move_to_guild_outside_Windsor {
	ConfigKey eventMacro_1_99_stage turning_knight_windsor
	JobID 1
	NotInMap prt_in
	NotInMap job_knt
	QuestActive 9004, 9005, 9006
	exclusive 1
	priority 1
	call Move_to_knight_place_Windsor
}

automacro move_to_guild_inside_Windsor {
	ConfigKey eventMacro_1_99_stage turning_knight_windsor
	JobID 1
	InMap prt_in
	QuestActive 9004, 9005, 9006
	NpcNotNear /Sir Windsor/i
	exclusive 1
	priority 1
	call Move_to_knight_place_Windsor
}

automacro Talk_to_knight_Windsor {
	ConfigKey eventMacro_1_99_stage turning_knight_windsor
	JobID 1
	InMap prt_in
	QuestActive 9004, 9005, 9006
	NpcNear /Sir Windsor/i
	timeout 30
	priority 1
	call {
		do talknpc &arg("$.NpcNearLastPos", 1) &arg("$.NpcNearLastPos", 2) r0
	}
}

automacro Got_To_Waiting_Room {
	ConfigKey eventMacro_1_99_stage turning_knight_windsor
	JobID 1
	InMap job_knt
	NpcNear /Windsor/i
	exclusive 1
	priority 1
	call {
		do ai manual
		do conf eventMacro_1_99_stage turning_knight_windsor_waiting_room
	}
}

automacro Got_Out_Of_Waiting_Room {
	ConfigKey eventMacro_1_99_stage turning_knight_windsor_waiting_room
	CheckOnAI auto, manual
	JobID 1
	NotInMap job_knt
	exclusive 1
	priority 1
	call {
		[
		do ai auto
		call update_turning_knight
		]
	}
}

automacro Get_into_waiting_Chat {
	ConfigKey eventMacro_1_99_stage turning_knight_windsor_waiting_room
	CheckOnAI auto, manual
	JobID 1
	InMap job_knt
	NpcNear /Windsor/i
	InChatRoom 0
	ChatRoomNear /wait/i
	timeout 60
	exclusive 1
	priority 1
	call {
		do chat join $.ChatRoomNearLastBinID
	}
}

automacro Got_into_waiting_Chat {
	ConfigKey eventMacro_1_99_stage turning_knight_windsor_waiting_room
	CheckOnAI auto, manual
	JobID 1
	InMap job_knt
	NpcNear /Windsor/i
	InChatRoom 1
	exclusive 1
	priority 1
	call {
		do conf eventMacro_1_99_stage turning_knight_windsor_waiting_room_chat
	}
}

automacro Got_Out_Of_Waiting_Room_chat {
	ConfigKey eventMacro_1_99_stage turning_knight_windsor_waiting_room_chat
	CheckOnAI auto, manual
	JobID 1
	NotInMap job_knt
	exclusive 1
	priority 1
	call {
		[
		do ai auto
		call update_turning_knight
		]
	}
}

automacro Moved_to_test_area_fast {
	ConfigKey eventMacro_1_99_stage turning_knight_windsor_waiting_room
	CheckOnAI auto, manual
	JobID 1
	InMap job_knt
	NpcNotNear /Windsor/i
	InChatRoom 0
	exclusive 1
	priority 1
	call adapt_to_test_windsor
}

automacro Moved_to_test_area {
	ConfigKey eventMacro_1_99_stage turning_knight_windsor_waiting_room_chat
	CheckOnAI auto, manual
	JobID 1
	InMap job_knt
	NpcNotNear /Windsor/i
	InChatRoom 0
	exclusive 1
	priority 1
	call adapt_to_test_windsor
}

macro adapt_to_test_windsor {
	[
		do ai auto
		
		do conf eventMacro_1_99_stage turning_knight_windsor_test
		do conf -f lockMap $.map
		
		do conf -f attackAuto 2
		do conf -f attackCheckLOS 1
		do conf -f attackRouteMaxPathDistance 28
		do conf -f route_randomWalk 1
		
		do conf -f itemsTakeAuto 0
		do conf -f sellAuto 0
		do conf -f storageAuto 0
		
		do conf -f teleportAuto_minAggressives none
		do conf -f teleportAuto_hp none
		do conf -f teleportAuto_maxDmg none
		
		do eval AI::clear(qw/storageAuto/)
	]
}

macro out_of_test {
	[
	do conf -f attackAuto 2
	do conf -f itemsTakeAuto 2
	do conf -f attackCheckLOS 1
	do conf -f attackRouteMaxPathDistance 28
	do conf -f route_randomWalk 1
	
	do conf -f teleportAuto_minAggressives 4
	do conf -f teleportAuto_hp 10
	do conf -f teleportAuto_maxDmg 500
	
	do conf -f sellAuto 1
	do conf -f storageAuto 1
	]
}

automacro Windsor_praised_us {
	ConfigKey eventMacro_1_99_stage turning_knight_windsor_test
	JobID 1
	NpcMsg /Very good/i
	NpcNotNear /Windsor/i
	InMap job_knt
	exclusive 1
	priority 0
	call finished_test
}

automacro Got_Out_Of_test {
	ConfigKey eventMacro_1_99_stage turning_knight_windsor_test
	JobID 1
	QuestInactive 9007
	NotInMap job_knt
	exclusive 1
	priority 1
	call {
		[
		call out_of_test
		call update_turning_knight
		]
	}
}

automacro Finished_test {
	ConfigKey eventMacro_1_99_stage turning_knight_windsor_test
	JobID 1
	QuestActive 9007
	NotInMap job_knt
	exclusive 1
	priority 1
	call finished_test
}

automacro Windsor_is_angry_at_us {
	ConfigKey eventMacro_1_99_stage turning_knight_windsor
	JobID 1
	InMap prt_in
	NpcMsgName /done here/i /Windsor/
	exclusive 1
	priority 0
	call {
		do conf eventMacro_1_99_stage turning_knight_post_test
	}
}

macro finished_test {
	[
	call out_of_test
	do conf eventMacro_1_99_stage turning_knight_post_test
	do conf -f lockMap none
	]
}

# Lady Amy

macro Move_to_knight_place_amy {
	do move prt_in 70 107 5
}

automacro move_to_guild_outside_amy {
	ConfigKey eventMacro_1_99_stage turning_knight_post_test
	JobID 1
	NotInMap prt_in
	QuestActive 9006, 9007, 9008
	exclusive 1
	priority 1
	call Move_to_knight_place_amy
}

automacro move_to_guild_inside_amy {
	ConfigKey eventMacro_1_99_stage turning_knight_post_test
	JobID 1
	InMap prt_in
	QuestActive 9006, 9007, 9008
	NpcNotNear /Lady Amy/i
	exclusive 1
	priority 1
	call Move_to_knight_place_amy
}

automacro Talk_to_knight_amy {
	ConfigKey eventMacro_1_99_stage turning_knight_post_test
	JobID 1
	InMap prt_in
	QuestActive 9006, 9007, 9008
	NpcNear /Lady Amy/i
	exclusive 1
	priority 1
	call {
		do talknpc &arg("$.NpcNearLastPos", 1) &arg("$.NpcNearLastPos", 2) r0 r1 r0 r0 r0 r0 r2 r2 r1 r0 r1
	}
}

# Sir Edmond

macro Move_to_knight_place_edmond {
	do move prt_in 70 99 5
}

automacro move_to_guild_outside_edmond {
	ConfigKey eventMacro_1_99_stage turning_knight_post_test
	JobID 1
	NotInMap prt_in
	QuestActive 9009, 9010
	exclusive 1
	priority 1
	call Move_to_knight_place_edmond
}

automacro move_to_guild_inside_edmond {
	ConfigKey eventMacro_1_99_stage turning_knight_post_test
	JobID 1
	InMap prt_in
	QuestActive 9009, 9010
	NpcNotNear /Edmond/i
	exclusive 1
	priority 1
	call Move_to_knight_place_edmond
}

automacro Talk_to_knight_edmond {
	ConfigKey eventMacro_1_99_stage turning_knight_post_test
	JobID 1
	InMap prt_in
	QuestActive 9009, 9010
	CheckOnAI auto, manual
	NpcNear /Edmond/i
	exclusive 1
	priority 1
	call {
		do ai manual
		do talknpc &arg("$.NpcNearLastPos", 1) &arg("$.NpcNearLastPos", 2) r0
	}
}

automacro Got_To_Sitting_Room {
	ConfigKey eventMacro_1_99_stage turning_knight_post_test
	CheckOnAI auto, manual
	JobID 1
	InMap job_knt
	exclusive 1
	priority 1
	call {
		[
		do ai manual
		do conf -f attackAuto -1
		do conf -f route_randomWalk 0
		do conf eventMacro_1_99_stage turning_knight_sitting
		]
	}
}

automacro Got_Out_Of_Sitting_Room {
	ConfigKey eventMacro_1_99_stage turning_knight_sitting
	CheckOnAI auto, manual
	JobID 1
	NotInMap job_knt
	exclusive 1
	priority 1
	call {
		[
		do ai auto
		do conf -f attackAuto 2
		do conf -f attackCheckLOS 1
		do conf -f attackRouteMaxPathDistance 28
		do conf -f route_randomWalk 1
		do conf eventMacro_1_99_stage turning_knight_post_test
		]
	}
}

# Sir gray

macro Move_to_knight_place_gray {
	do move prt_in 87 92 5
}

automacro move_to_guild_outside_gray {
	ConfigKey eventMacro_1_99_stage turning_knight_post_test
	JobID 1
	NotInMap prt_in
	QuestActive 9011
	exclusive 1
	priority 1
	call Move_to_knight_place_gray
}

automacro move_to_guild_inside_gray {
	ConfigKey eventMacro_1_99_stage turning_knight_post_test
	JobID 1
	InMap prt_in
	QuestActive 9011
	NpcNotNear /gray/i
	exclusive 1
	priority 1
	call Move_to_knight_place_gray
}

automacro Talk_to_knight_gray {
	ConfigKey eventMacro_1_99_stage turning_knight_post_test
	JobID 1
	InMap prt_in
	QuestActive 9011
	NpcNear /gray/i
	exclusive 1
	priority 1
	call {
		do talknpc &arg("$.NpcNearLastPos", 1) &arg("$.NpcNearLastPos", 2) r0 r0 r2 r1 r0
	}
}

# Captain

automacro move_to_guild_outside_end {
	ConfigKey eventMacro_1_99_stage turning_knight_post_test
	JobID 1
	NotInMap prt_in
	QuestActive 9012
	exclusive 1
	priority 1
	call Move_to_knight_place_chief
}

automacro move_to_guild_inside_end {
	ConfigKey eventMacro_1_99_stage turning_knight_post_test
	JobID 1
	InMap prt_in
	QuestActive 9012
	NpcNotNear /Chivalry Captain/i
	exclusive 1
	priority 1
	call Move_to_knight_place_chief
}

automacro Talk_to_knight_end {
	ConfigKey eventMacro_1_99_stage turning_knight_post_test
	JobID 1
	InMap prt_in
	QuestActive 9012
	NpcNear /Chivalry Captain/i
	exclusive 1
	priority 1
	call {
		do talk $.NpcNearLastBinId
	}
}

automacro Changed_to_knight {
	ConfigKey eventMacro_1_99_stage turning_knight_post_test
	JobLevel = 1
	JobID 7
	exclusive 1
	priority 1
	call {
		do conf -f eventMacro_1_99_stage turning_knight_after_change
	}
}

automacro EquipknightStuff {
	ConfigKey eventMacro_1_99_stage turning_knight_after_change
	IsNotEquippedID rightHand 1157
	JobLevel = 1
	JobID 7
	exclusive 1
	call {
		do conf -f equipAuto_0_rightHand GetNamebyNameID(1157)
	}
}

automacro EquipknightStuffEnd {
	ConfigKey eventMacro_1_99_stage turning_knight_after_change
	IsEquippedID rightHand 1157
	JobLevel = 1
	JobID 7
	exclusive 1
	call {
		[
		do conf -f lockMap none
		
		include off Turn_Knight.pm
		
		do conf -f eventMacro_1_99_stage leveling
		
		do reload eventMacros
		]
	}
}
