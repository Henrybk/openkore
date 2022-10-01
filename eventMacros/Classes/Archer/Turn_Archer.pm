
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
	do talknpc &arg("$.NpcNearLastPos", 1) &arg("$.NpcNearLastPos", 2) r0 r~/Exercise/i r~/Change/i r~/Seller/i r~/Prudence/i r~/Experience/i r~/Future/i r~/No/i r~/No/i r~/Yes/i r~/No/i r~/Yes/i r~/Yes/i r~/Yes/i r~/No/i r~/Schedule/i r~/Check/i r~/Don/i r~/Ask/i r~/Assess/i r~/Leave/i r~/Change/i r~/Promise/i r0
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
		
		do conf -f eventMacro_1_99_stage turnarcher_out
		
		do reload eventMacros
	}
}

automacro move_to_guild_outside_far {
	exclusive 1
	JobID 0
	NotInMap oldnewpayon
	NotInMap payon
	NotInMap pay_arche
	NotInMap payon_in01
	NotInMap payon_in02
	QuestInactive 1004
	ConfigKey eventMacro_1_99_stage turnarcher_out
	priority 1
	call {
		do is Novice Butterfly Wing
	}
}

automacro move_to_guild_outside {
	exclusive 1
	JobID 0
	InMap oldnewpayon, payon, pay_arche, payon_in01
	QuestInactive 1004
	ConfigKey eventMacro_1_99_stage turnarcher_out
	priority 1
	call Move_to_archer_place
}

automacro move_to_guild_inside {
	exclusive 1
	JobID 0
	InMap payon_in02
	QuestInactive 1004
	ConfigKey eventMacro_1_99_stage turnarcher_out
	NpcNotNear /Guildsman/
	priority 1
	call Move_to_archer_place
}

macro Move_to_archer_place {
	do move payon_in02 65 65
}

automacro Talk_to_Archer_Guildsman {
	exclusive 0
	self_interruptible 0
	JobID 0
	InMap payon_in02
	QuestInactive 1004
	ConfigKey eventMacro_1_99_stage turnarcher_out
	NpcNear /Guildsman/
	priority 1
	call {
		do talknpc &arg("$.NpcNearLastPos", 1) &arg("$.NpcNearLastPos", 2) r0 r0 r0
	}
}

automacro Move_to_trunk_guy {
	exclusive 1
	JobID 0
	QuestActive 1004
	ConfigKey eventMacro_1_99_stage turnarcher_out
	priority 1
	call {
		do conf -f eventMacro_1_99_stage turnarcher_give_trunk
	}
}

automacro Move_to_end_quest_outside {
	exclusive 1
	JobID 0
	QuestActive 1004
	ConfigKey eventMacro_1_99_stage turnarcher_give_trunk
	NotInMap payon_in02
	priority 1
	call Move_to_archer_place
}

automacro Move_to_end_quest_inside {
	exclusive 1
	JobID 0
	QuestActive 1004
	ConfigKey eventMacro_1_99_stage turnarcher_give_trunk
	InMap payon_in02
	NpcNotNear /Guildsman/
	priority 1
	call Move_to_archer_place
}

automacro Talk_to_end_quest_guy {
	exclusive 1
	JobID 0
	QuestActive 1004
	ConfigKey eventMacro_1_99_stage turnarcher_give_trunk
	InMap payon_in02
	NpcNear /Guildsman/
	priority 1
	call {
		do talknpc &arg("$.NpcNearLastPos", 1) &arg("$.NpcNearLastPos", 2) r0
	}
}

automacro Changed_to_Archer {
	exclusive 1
	JobID 3
	JobLevel = 1
	ConfigKey eventMacro_1_99_stage turnarcher_give_trunk
	priority 1
	call {
		do conf -f eventMacro_1_99_stage turnarcher_after_change
	}
}

automacro EquipArcherStuff {
	ConfigKey eventMacro_1_99_stage turnarcher_after_change
	IsNotEquippedID rightHand 1702
	JobLevel = 1
	JobID 3
	exclusive 1
	timeout 10
	call {
		[
		call clear_equipauto
		do conf -f equipAuto_0_rightHand GetNamebyNameID(1702)
		]
	}
}

automacro EquipArcherStuffEnd {
	ConfigKey eventMacro_1_99_stage turnarcher_after_change
	IsEquippedID rightHand 1702
	JobLevel = 1
	JobID 3
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
		do conf -f attackDistanceAuto 1
		do conf -f attackCanSnipe 1
		do conf -f attackCheckLOS 1
		do conf -f attackRouteMaxPathDistance 28
		do conf -f route_randomWalk 1
		do conf -f itemsGatherAuto 0
		do conf -f itemsTakeAuto 2
		do conf -f route_step 9
		
		do conf -f teleportAuto_minAggressives 4
		do conf -f saveMap_warpToBuyOrSell 0
		
		include off Turn_Archer.pm
		
		call set_class_leveling
		
		do reload eventMacros
		]
	}
}

automacro bug_skills {
	exclusive 1
	JobID 0
	InMap payon_in02
	NpcMsgName /Please check the requirements again/ /Guildsman/
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