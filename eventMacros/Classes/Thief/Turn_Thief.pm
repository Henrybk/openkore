
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
	do talknpc &arg("$.NpcNearLastPos", 1) &arg("$.NpcNearLastPos", 2) r0 r1 r0 r0 r0 r1 r1 r0 r0 r0 r1 r0 r1 r1 r1 r2 r2 r2 r0 r2 r2 r0 r1 r0
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
		
		do conf -f eventMacro_1_99_stage turnthief_out
		
		do reload eventMacros
	}
}

automacro move_to_piramid_outside_far {
	exclusive 1
	JobID 0
	NotInMap moc_ruins
	NotInMap moc_pryd01
	NotInMap morocc
	NotInMap moc_prydb1
	QuestInactive 1013
	ConfigKey eventMacro_1_99_stage turnthief_out
	priority 1
	call {
		do is Novice Butterfly Wing
	}
}

automacro move_to_piramid_outside {
	exclusive 1
	JobID 0
	InMap moc_ruins, moc_pryd01, morocc
	QuestInactive 1013
	ConfigKey eventMacro_1_99_stage turnthief_out
	priority 1
	call Move_to_thief_place
}

automacro move_to_piramid_inside {
	exclusive 1
	JobID 0
	InMap moc_prydb1
	QuestInactive 1013
	ConfigKey eventMacro_1_99_stage turnthief_out
	NpcNotNear /Guide/
	priority 1
	call Move_to_thief_place
}

macro Move_to_thief_place {
	do move moc_prydb1 44 124
}

automacro Talk_to_Thief_Guide {
	exclusive 0
	self_interruptible 0
	JobID 0
	InMap moc_prydb1
	QuestInactive 1013
	ConfigKey eventMacro_1_99_stage turnthief_out
	NpcNear /Guide/
	priority 1
	call {
		do talknpc &arg("$.NpcNearLastPos", 1) &arg("$.NpcNearLastPos", 2) r0 r0 r0 r0 r0
	}
}

automacro Move_to_mush_guy {
	exclusive 1
	JobID 0
	QuestActive 1013
	ConfigKey eventMacro_1_99_stage turnthief_out
	NpcNotNear /Irrelevant/
	NotInMap job_thief1
	priority 1
	call {
		do move moc_ruins 139 122
	}
}

automacro Talk_to_mush_guy {
	exclusive 1
	JobID 0
	QuestActive 1013
	ConfigKey eventMacro_1_99_stage turnthief_out
	InMap moc_ruins
	NpcNear /Irrelevant/
	priority 1
	call {
		do talk $.NpcNearLastBinId
	}
}

automacro Got_into_mush_map {
	exclusive 1
	JobID 0
	QuestActive 1013
	ConfigKey eventMacro_1_99_stage turnthief_out
	InMap job_thief1
	priority 1
	call Ajust_to_kill_mush
}

macro Ajust_to_kill_mush {
	[
	do conf -f eventMacro_1_99_stage turnthief_mush
	do conf -f lockMap $.map
	
	do conf -f attackAuto 2
	do conf -f attackAuto_inLockOnly 2
	do conf -f attackCheckLOS 1
	do conf -f attackRouteMaxPathDistance 28
	do conf -f route_randomWalk 1
	
	do conf -f itemsGatherAuto 0
	do conf -f itemsTakeAuto 2
	# Mobs
	do mconf Poporing 0 0 0
	do mconf Spore 0 0 0
	do mconf Mushroom 1 0 1
	]
}

automacro Got_out_of_mush_map {
	exclusive 1
	JobID 0
	QuestActive 1013
	ConfigKey eventMacro_1_99_stage turnthief_mush
	NotInMap job_thief1
	priority 1
	call Ajust_to_move_to_mush
}

macro Ajust_to_move_to_mush {
	[
	do conf -f eventMacro_1_99_stage turnthief_out
	do conf -f lockMap none
	do conf -f attackAuto 0
	do conf -f attackCheckLOS 1
	do conf -f attackRouteMaxPathDistance 28
	do conf -f route_randomWalk 0
	do conf -f itemsGatherAuto 0
	do conf -f itemsTakeAuto 2
	]
}

# Leveling
automacro Check_mush_timer {
	timeout 60
	JobID 0
	QuestActive 1013
	ConfigKey eventMacro_1_99_stage turnthief_mush
	exclusive 1
	priority 2
	call Check_mush
}

macro Check_mush {
	$badMush = GetNamebyNameID(1070)
	$badMush = &invamount($badMush)
	
	$goodMush = GetNamebyNameID(1069)
	$goodMush = &invamount($goodMush)
	
	$mushPoints = &eval($badMush + ($goodMush * 3))
	
	#Class Change
	if ($mushPoints >= 25) {
		log We have $mushPoints mush points, which is enough! Hooray!
		call End_mush_Farm
	} else {
		log We only have $mushPoints mush points so we must farm more
	}
}

macro End_mush_Farm {
	[
	do conf -f eventMacro_1_99_stage turnthief_give_mush
	do conf -f lockMap none
	do conf -f attackAuto 0
	do conf -f attackCheckLOS 1
	do conf -f attackRouteMaxPathDistance 28
	do conf -f route_randomWalk 0
	do conf -f itemsGatherAuto 0
	do conf -f itemsTakeAuto 2
	do mconf Poporing 1 0 0
	do mconf Spore 1 0 0
	do mconf Mushroom 0 0 0
	]
}

automacro Get_out_mush_map {
	exclusive 1
	JobID 0
	timeout 15
	QuestActive 1013
	ConfigKey eventMacro_1_99_stage turnthief_give_mush
	InMap job_thief1
	priority 1
	call Get_out_of_mush_map
}

macro Get_out_of_mush_map {
	log We are leaving the mush map because we finished farming
	do tele 2
}

automacro Move_to_end_quest_outside {
	exclusive 1
	JobID 0
	QuestActive 1013
	ConfigKey eventMacro_1_99_stage turnthief_give_mush
	NotInMap job_thief1
	NotInMap moc_prydb1
	priority 1
	call Move_to_thief_place
}

automacro Move_to_end_quest_inside {
	exclusive 1
	JobID 0
	QuestActive 1013
	ConfigKey eventMacro_1_99_stage turnthief_give_mush
	InMap moc_prydb1
	NpcNotNear /Comrade/
	priority 1
	call Move_to_thief_place
}

automacro Talk_to_end_quest_guy {
	exclusive 1
	JobID 0
	QuestActive 1013
	ConfigKey eventMacro_1_99_stage turnthief_give_mush
	InMap moc_prydb1
	NpcNear /Comrade/
	priority 1
	call {
		do talk $.NpcNearLastBinId
	}
}

automacro Changed_to_Thief {
	exclusive 1
	JobID 6
	JobLevel = 1
	ConfigKey eventMacro_1_99_stage turnthief_give_mush
	priority 1
	call {
		do conf -f eventMacro_1_99_stage turnthief_after_change
	}
}

automacro EquipThiefStuff {
	ConfigKey eventMacro_1_99_stage turnthief_after_change
	IsNotEquippedID rightHand 1207
	JobLevel = 1
	JobID 6
	exclusive 1
	timeout 10
	call {
		[
		call clear_equipauto
		do conf -f equipAuto_0_rightHand GetNamebyNameID(1207)
		]
	}
}

automacro EquipThiefStuffEnd {
	ConfigKey eventMacro_1_99_stage turnthief_after_change
	IsEquippedID rightHand 1207
	JobLevel = 1
	JobID 6
	exclusive 1
	call {
		[
		do iconf 1207 1 0 0
		do iconf 1243 0 0 1
		do iconf 2112 0 0 1
		do iconf 5055 0 0 1
		do iconf 2414 0 0 1
		do iconf 2510 0 0 1
		do iconf 2352 0 0 1
		do iconf 1201 0 0 1
		do iconf 13040 0 0 1
		do iconf 2301 0 0 1
		do conf -f useSelf_item_0_hp < 70%
		do conf -f attackAuto 2
		do conf -f attackAuto_inLockOnly 2
		do conf -f attackCheckLOS 1
		do conf -f attackRouteMaxPathDistance 28
		do conf -f route_randomWalk 1
		do conf -f itemsGatherAuto 0
		do conf -f itemsTakeAuto 2
		do conf -f route_step 15
		
		do conf -f teleportAuto_minAggressives 4
		do conf -f saveMap_warpToBuyOrSell 1
		
		include off Turn_Thief.pm
		
		call set_class_leveling
		
		do reload eventMacros
		]
	}
}

automacro bug_skills {
	exclusive 1
	JobID 0
	InMap moc_prydb1
	NpcMsgName /gotta learn all of the Basic Skills/ /Guide/
	priority 0
	call  {
		[
		call set_skills_stats
		do conf -f statsAddAuto 1
		do conf -f statsAddAuto_dontUseBonus 1
		do conf -f skillsAddAuto 1
		]
	}
}