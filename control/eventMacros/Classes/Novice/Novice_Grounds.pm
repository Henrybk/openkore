
#Novice Camp

automacro moveToSprakkiOutside {
    exclusive 1
    InMap new_1-1, new_2-1, new_3-1, new_4-1, new_5-1
    BaseLevel = 1
    NpcNotNear /Sprakki/
    QuestInactive 7117
    call {
        do move 52 113
    }
}
 
automacro TalkSprakkiOutside {
    exclusive 1
    InMap new_1-1, new_2-1, new_3-1, new_4-1, new_5-1
    BaseLevel = 1
    NpcNear /Sprakki/
    QuestInactive 7117
    call {
		[
		call set_class_stats_and_skills
		
		do conf -f statsAddAuto 1
        do conf -f statsAddAuto_dontUseBonus 1
        do conf -f skillsAddAuto 1
		
        do conf -f autoMoveOnDeath 0
        do conf -f autoMoveOnDeath_x none
        do conf -f autoMoveOnDeath_y none
        do conf -f autoMoveOnDeath_map none
        do conf -f saveMap none
        do conf -f saveMap_warpToBuyOrSell 0
        do conf -f getAuto_0 none
        do conf -f sitAuto_idle 0
        do conf -f sitAuto_hp_lower 40
        do conf -f sitAuto_hp_upper 80
        do conf -f itemsTakeAuto 0
        do conf -f itemsGatherAuto 0
        do conf -f lockMap none
        do conf -f route_randomWalk 0
        do conf -f statsAddAuto 1
		do conf -f attackAuto 1
		
        do conf -f autoTalkCont 1
		
        do conf -f sellAuto 0
        do conf -f storageAuto 0
        do conf -f storageAuto_npc none
		do conf -f storageAuto_npc_type 3
		do conf -f storageAuto_npc_steps none
		do conf -f eventMacro_1_99_stage novice
		do conf -f current_event_include Novice_Grounds.pm
		
        do conf -f itemsMaxWeight 89
        do conf -f itemsMaxWeight_sellOrStore 48
        do conf -f itemsMaxNum_sellOrStore 99
        do iconf 12323 0 0 0
        do iconf 12324 0 0 0
        do iconf 569 0 0 0
        do iconf 7059 50 0 0
        do iconf 7060 50 0 0
        do iconf 13040 0 0 0
        do iconf 1243 0 0 0
        do iconf 2112 0 0 0
        do iconf 5055 0 0 0
        do iconf 2414 0 0 0
        do iconf 2510 0 0 0
        do iconf 2352 0 0 0
        do iconf 1201 0 0 0
        do iconf 13041 0 0 0
        do iconf 2393 0 0 0
        do iconf 2301 0 0 0
		]
        do talk $.NpcNearLastBinId
    }
}
 
automacro moveInside {
    exclusive 1
    QuestActive 7117
    InMap new_1-1, new_2-1, new_3-1, new_4-1, new_5-1
    priority 1
    call GotoInside
}
 
automacro moveInsideBugged1 {
    exclusive 1
    QuestInactive 7117
    BaseLevel = 2
    InMap new_1-1, new_2-1, new_3-1, new_4-1, new_5-1
    priority 1
    call GotoInside
}
 
automacro moveInsideBugged2 {
    exclusive 1
    QuestActive 7118
    BaseLevel = 2
    InMap new_1-1, new_2-1, new_3-1, new_4-1, new_5-1
    priority 1
    call GotoInside
}
 
macro GotoInside {
    $nextMap = nextMap("$.map")
    do move $nextMap 101 29
}
 
automacro moveNextToSprakki {
    exclusive 1
    QuestActive 7117
    NpcNotNear /Sprakki/
    BaseLevel = 1
    InMap new_1-2, new_2-2, new_3-2, new_4-2, new_5-2
    priority 1
    call GotoSpraki
}
 
automacro moveNextToSprakkiBugged1 {
    exclusive 1
    QuestInactive 7117
    BaseLevel = 2
    NpcNotNear /Sprakki/
    InMap new_1-2, new_2-2, new_3-2, new_4-2, new_5-2
    priority 1
    call GotoSpraki
}
 
automacro moveNextToSprakkiBugged2 {
    exclusive 1
    QuestActive 7118
    BaseLevel = 2
    NpcNotNear /Sprakki/
    InMap new_1-2, new_2-2, new_3-2, new_4-2, new_5-2
    priority 1
    call GotoSpraki
}
 
macro GotoSpraki {
    do move 101 29
}
 
automacro talkSprakkiBugged1 {
    exclusive 1
    QuestInactive 7117
    BaseLevel = 2
    NpcNear /Sprakki/
    InMap new_1-2, new_2-2, new_3-2, new_4-2, new_5-2
    priority 0
    call talkSprakkiInside
}
 
automacro talkSprakkiBugged2 {
    exclusive 1
    QuestActive 7118
    BaseLevel = 2
    NpcNear /Sprakki/
    InMap new_1-2, new_2-2, new_3-2, new_4-2, new_5-2
    priority 0
    call talkSprakkiInside
}
 
automacro talkSprakki {
    exclusive 1
    QuestActive 7117
    BaseLevel = 1
    NpcNear /Sprakki/
    InMap new_1-2, new_2-2, new_3-2, new_4-2, new_5-2
    priority 0
    call talkSprakkiInside
}

macro talkSprakkiInside {
	do talknpc &arg("$.NpcNearLastPos", 1) &arg("$.NpcNearLastPos", 2) r0
}
 
automacro moveNextToBrade1 {
    exclusive 1
    QuestActive 7118
    NpcNotNear /Brade/
    InMap new_1-2, new_2-2, new_3-2, new_4-2, new_5-2
    priority 2
    call MoveToBrade
}
 
automacro moveNextToBrade2 {
    exclusive 1
    QuestActive 7119
    NpcNotNear /Brade/
    InMap new_1-2, new_2-2, new_3-2, new_4-2, new_5-2
    priority 2
    call MoveToBrade
}
 
macro MoveToBrade {
    do move 103 105
}
 
automacro talkBrade {
    exclusive 1
    QuestActive 7118
    BaseLevel = 2
    NpcNear /Brade/
    InMap new_1-2, new_2-2, new_3-2, new_4-2, new_5-2
    priority 0
    call {
        do talk $.NpcNearLastBinId
    }
}
 
 
automacro moveNextToBradeBugged {
    exclusive 1
    QuestInactive 7118
    QuestInactive 7119
    BaseLevel = 3
    InInventoryID 5055 = 0
    NpcNotNear /Brade/
    InMap new_1-2, new_2-2, new_3-2, new_4-2, new_5-2
    priority 1
    call MoveToBrade
}
 
automacro talkBradeBugged {
    exclusive 1
    QuestInactive 7118
    QuestInactive 7119
    BaseLevel = 3
    InInventoryID 5055 = 0
    NpcNear /Brade/
    InMap new_1-2, new_2-2, new_3-2, new_4-2, new_5-2
    priority 0
    call {
        do talk $.NpcNearLastBinId
    }
}
 
automacro equipStuffForBrade {
    exclusive 1
    QuestActive 7119
	ConfigKey eventMacro_1_99_stage novice
    IsNotEquippedID topHead 5055, leftHand 2112, robe 2510, shoes 2414, armor 2352, rightHand 1243
    call {
		%toequip = (topHead => 5055, robe => 2510, shoes => 2414, armor => 2352, leftHand => 2112, rightHand => 1243)
        call start_equipping
    }
}

automacro talkBradeSecond {
    exclusive 1
    QuestActive 7119
    BaseLevel = 3
    IsEquippedID topHead 5055
    IsEquippedID leftHand 2112
    IsEquippedID rightHand 1243
    IsEquippedID robe 2510
    IsEquippedID armor 2352
    IsEquippedID shoes 2414
    NpcNear /Brade/
    call {
        do talk $.NpcNearLastBinId
    }
}
 
automacro BradeBuggedNo7120MoveJinha {
    exclusive 1
    QuestInactive 7119
    QuestInactive 7120
    BaseLevel = 4
    InInventoryID 12324 > 0
    IsEquippedID topHead 5055
    IsEquippedID leftHand 2112
    IsEquippedID rightHand 1243
    IsEquippedID robe 2510
    IsEquippedID armor 2352
    IsEquippedID shoes 2414
    SkillLevel NV_FIRSTAID = 0
    NpcNotNear /Jinha/
    call MoveJinha
}
 
automacro moveToGirlSkill {
    exclusive 1
    QuestActive 7120
    NpcNotNear /Jinha/
    SkillLevel NV_FIRSTAID = 0
    priority 0
    call MoveJinha
}
 
macro MoveJinha {
    do move 107 108
}
 
automacro BradeBuggedNo7120TalkJinha {
    exclusive 1
    QuestInactive 7119
    QuestInactive 7120
    BaseLevel = 4
    InInventoryID 12324 > 0
    IsEquippedID topHead 5055
    IsEquippedID leftHand 2112
    IsEquippedID rightHand 1243
    IsEquippedID robe 2510
    IsEquippedID armor 2352
    IsEquippedID shoes 2414
    SkillLevel NV_FIRSTAID = 0
    NpcNear /Jinha/
    call TalkJinha
}
 
automacro talkGirlSkill {
    exclusive 1
    QuestActive 7120
    NpcNear /Jinha/
    SkillLevel NV_FIRSTAID = 0
    priority 0
    call TalkJinha
}
 
macro TalkJinha {
    do talknpc &arg("$.NpcNearLastPos", 1) &arg("$.NpcNearLastPos", 2) r0
}
 
automacro BradeBuggedNo7120MoveBrade {
    exclusive 1
    QuestInactive 7119
    QuestInactive 7120
    BaseLevel = 4
    InInventoryID 12324 > 0
    InInventoryID 2393 = 0
    IsEquippedID topHead 5055
    IsEquippedID leftHand 2112
    IsEquippedID rightHand 1243
    IsEquippedID robe 2510
    IsEquippedID armor 2352
    IsEquippedID shoes 2414
    SkillLevel NV_FIRSTAID = 1
    NpcNotNear /Brade/
    call MoveToBrade
}
 
automacro BradeBuggedNo7120TalkBrade {
    exclusive 1
    QuestInactive 7119
    QuestInactive 7120
    BaseLevel = 4
    InInventoryID 12324 > 0
    InInventoryID 2393 = 0
    IsEquippedID topHead 5055
    IsEquippedID leftHand 2112
    IsEquippedID rightHand 1243
    IsEquippedID robe 2510
    IsEquippedID armor 2352
    IsEquippedID shoes 2414
    SkillLevel NV_FIRSTAID = 1
    NpcNear /Brade/
    call TalkBradeGetTunic
}
 
automacro talkBradeThird {
    exclusive 1
    QuestActive 7120
    SkillLevel NV_FIRSTAID = 1
    NpcNear /Brade/
    priority 0
    call TalkBradeGetTunic
}
 
macro TalkBradeGetTunic {
    do talk $.NpcNearLastBinId
}
 
automacro equipStuffForGirl {
    exclusive 1
    QuestInactive 7120
    InInventoryID 2393 = 1
	ConfigKey eventMacro_1_99_stage novice
    InMap new_1-2, new_2-2, new_3-2, new_4-2, new_5-2
    IsNotEquippedID armor 2393
    call {
		%toequip = (armor => 2393)
        call start_equipping
    }
}
 
automacro moveNextToChoco {
    exclusive 1
    IsEquippedID armor 2393
	ConfigKey eventMacro_1_99_stage novice
    InMap new_1-2, new_2-2, new_3-2, new_4-2, new_5-2
    NpcNotNear /Choco/
    priority 1
    call {
        do move 32 171
    }
}
 
automacro talkChoco {
    exclusive 1
    QuestInactive 7120
    QuestInactive 7121
    IsEquippedID armor 2393
	ConfigKey eventMacro_1_99_stage novice
    InMap new_1-2, new_2-2, new_3-2, new_4-2, new_5-2
    NpcNear /Choco/
    call {
        do talk $.NpcNearLastBinId
        do conf -f novice_land_current_npc kafra
    }
}
 
automacro moveNextToGuys {
    exclusive 1
    QuestActive 7121
    NpcNotNear /(Choco|Kafra|Staff|Soldier)/
    priority 0
    call {
        do move 32 171
    }
}
 
automacro talkKafraNovice {
    timeout 50
    QuestActive 7121
    ConfigKey novice_land_current_npc kafra
    NpcNear /Kafra/
    call {
       do talknpc &arg("$.NpcNearLastPos", 1) &arg("$.NpcNearLastPos", 2) r4
    }
}

automacro EndedKafra {
	exclusive 1
	QuestActive 7121
    ConfigKey novice_land_current_npc kafra
	NpcMsgName /(Quer ouvir novamente|Do you want to hear another)/ /Kafra/
	call {
		do conf -f novice_land_current_npc Staff
	}
}
 
automacro talkStaff {
    timeout 50
    QuestActive 7121
    ConfigKey novice_land_current_npc Staff
    NpcNear /Staff/
    call {
		log next binID is $.NpcNearLastBinId
        do talk $.NpcNearLastBinId
    }
}

automacro EndedStaff {
	exclusive 1
	QuestActive 7121
    ConfigKey novice_land_current_npc Staff
	NpcMsgName /(A maior parte de nós trabalha|Most of our services|Mostly all of us wear)/ /Staff/
	call {
		 do conf -f novice_land_current_npc Soldier
	}
}
 
automacro talkSoldier {
    timeout 50
    QuestActive 7121
    ConfigKey novice_land_current_npc Soldier
    NpcNear /Soldier/
    call {
        do talk $.NpcNearLastBinId
    }
}

automacro EndedSoldier {
	exclusive 1
	QuestActive 7121
    ConfigKey novice_land_current_npc Soldier
	NpcMsgName /(Se quiser ir para uma vila|If you want to go to your first town)/ /Soldier/
	call {
        do conf -f novice_land_current_npc choco
		do conf -f eventMacro_1_99_stage choco2
	}
}

automacro SoldierBug {
	timeout 50
	QuestActive 7121
    ConfigKey novice_land_current_npc Soldier
	NpcMsgName /(Em que posso ajudar?|What can I help you with)/ /Soldier/
	call {
		do talk resp 2
        do conf -f novice_land_current_npc choco
		do conf -f eventMacro_1_99_stage choco2
	}
}
 
automacro talkChocoAgain {
    exclusive 1
    QuestActive 7121
    ConfigKey novice_land_current_npc choco
	ConfigKey eventMacro_1_99_stage choco2
    NpcNear /Choco/
    call {
        do talk $.NpcNearLastBinId
    }
}

automacro clearConfig {
    exclusive 1
	QuestInactive 7121
    QuestInactive 7122
	ConfigKey novice_land_current_npc choco
    InMap new_1-3, new_2-3, new_3-3, new_4-3, new_5-3
    priority 0
    call {
		do conf -f eventMacro_1_99_stage novice
		do conf -f novice_land_current_npc none
	}
}
 
automacro moveBradeGrounds {
    exclusive 1
    QuestInactive 7122
    InInventoryID 13040 = 0
    InMap new_1-3, new_2-3, new_3-3, new_4-3, new_5-3
	ConfigKey novice_land_current_npc none
	ConfigKey eventMacro_1_99_stage novice
    NpcNotNear /Brade/
    priority 1
    call moveBradeGrounds
}

automacro talkBradeonGroundsGetQuest {
    exclusive 1
    QuestInactive 7122
    InInventoryID 13040 = 0
	ConfigKey eventMacro_1_99_stage novice
    InMap new_1-3, new_2-3, new_3-3, new_4-3, new_5-3
    NpcNear /Brade/
    call {
        do talk $.NpcNearLastBinId
    }
}

automacro talkBradeonGroundsAdjustToQuest {
    exclusive 1
    QuestActive 7122
    QuestHuntOngoing 7122 712200000
	ConfigKey eventMacro_1_99_stage novice
	ConfigKeyNot attackAuto 2
    InMap new_1-3, new_2-3, new_3-3, new_4-3, new_5-3
    call AdjustConfigForBrade
}

macro AdjustConfigForBrade {
	[
	do mconf 1002 1 0 0 #Poring
	do mconf 1113 0 0 0 #Drops
	do mconf 1063 0 0 0 #Lunatico
	do mconf 1010 0 0 0 #Salgueiro
	do mconf 1014 0 0 0 #Sporo
	do mconf 1007 0 0 0 #Fabre
	do mconf 1049 0 0 0 #Picky
	do mconf 1011 0 0 0 #Chon chon
	do mconf 1042 0 0 0 #Steel chon chon
	do mconf 1012 0 0 0 #Rodda
	
	do conf -f lockMap $.map
	do conf -f attackAuto 2
	do conf -f route_randomWalk 1
	$potName = GetNamebyNameID(569)
	do conf -f useSelf_item_0 $potName
	do conf -f useSelf_item_0_disabled 0
	do conf -f useSelf_item_0_hp < 80%
	do conf -f useSelf_item_0_timeout 1
	do conf -f itemsTakeAuto 1
	do conf -f itemsGatherAuto 0
	]
}

automacro moveBradeCompleteQuest {
    exclusive 1
    QuestHuntCompleted 7122 712200000
	ConfigKey eventMacro_1_99_stage novice
    InMap new_1-3, new_2-3, new_3-3, new_4-3, new_5-3
    NpcNotNear /Brade/
    priority 1
    call moveBradeGrounds
}
 
macro moveBradeGrounds {
    do move 99 31
}
 
automacro talkBradeonGroundsCompleteQuest {
    exclusive 1
    QuestHuntCompleted 7122 712200000
	ConfigKey eventMacro_1_99_stage novice
    InMap new_1-3, new_2-3, new_3-3, new_4-3, new_5-3
    NpcNear /Brade/
    call {
        do talk $.NpcNearLastBinId
    }
}
 
automacro equipStuffForBradeGrounds {
    exclusive 1
    QuestInactive 7122
    InInventoryID 13040 = 1
    IsNotEquippedID rightHand 13040
	ConfigKey eventMacro_1_99_stage novice
    InMap new_1-3, new_2-3, new_3-3, new_4-3, new_5-3
    call {
		%toequip = (rightHand => 13040)
        call start_equipping
    }
}

automacro Adjust_after_brade_quest {
	exclusive 1
    QuestInactive 7122
    IsEquippedID rightHand 13040
    InMap new_1-3, new_2-3, new_3-3, new_4-3, new_5-3
	ConfigKey eventMacro_1_99_stage novice
    priority 1
	call {
		[
		do conf -f eventMacro_1_99_stage novice_after_brade_quest
		]
	}
}

macro move_job_guys {
	do move 103 40
}

automacro move_merch_job {
	ConfigKey eventMacro_1_99_stage novice_after_brade_quest
    InMap new_1-3, new_2-3, new_3-3, new_4-3, new_5-3
    NpcNotNear /Merchant Guide/
    exclusive 1
    priority 1
    call move_job_guys
}

automacro talk_merch_job_get_quest {
	ConfigKey eventMacro_1_99_stage novice_after_brade_quest
    InMap new_1-3, new_2-3, new_3-3, new_4-3, new_5-3
	QuestInactive 7126
    NpcNear /Merchant Guide/
    priority 1
    exclusive 1
	delay 2
    call {
       do talknpc &arg("$.NpcNearLastPos", 1) &arg("$.NpcNearLastPos", 2) r2
    }
}

automacro talk_merch_job_get_manual {
	ConfigKey eventMacro_1_99_stage novice_after_brade_quest
    InMap new_1-3, new_2-3, new_3-3, new_4-3, new_5-3
	QuestActive 7126
	InInventoryID 2823 = 0
    NpcNear /Merchant Guide/
    priority 1
    exclusive 1
	delay 2
    call {
       do talknpc &arg("$.NpcNearLastPos", 1) &arg("$.NpcNearLastPos", 2) r0 r0
    }
}

automacro equip_merch_manual {
	ConfigKey eventMacro_1_99_stage novice_after_brade_quest
    InMap new_1-3, new_2-3, new_3-3, new_4-3, new_5-3
	QuestActive 7126
	InInventoryID 2823 = 1
    IsNotEquippedID rightAccessory 2823
    priority 1
    exclusive 1
    call {
       %toequip = (rightHand => 13040, armor => 2393, topHead => 5055, robe => 2510, shoes => 2414, leftHand => 2112, rightAccessory => 2823)
        call start_equipping
    }
}

automacro adjust_merchant_quest {
    QuestActive 7126
    IsEquippedID topHead 5055
    IsEquippedID leftHand 2112
    IsEquippedID rightHand 13040
    IsEquippedID robe 2510
    IsEquippedID armor 2393
    IsEquippedID shoes 2414
    IsEquippedID rightAccessory 2823
	ConfigKey eventMacro_1_99_stage novice_after_brade_quest
    InMap new_1-3, new_2-3, new_3-3, new_4-3, new_5-3
	QuestActive 7126
    exclusive 1
    call set_merchant_quest_stuff
}

macro set_merchant_quest_stuff {
	[
	do mconf 1002 0 0 0 #Poring
	do mconf 1113 0 0 0 #Drops
	do mconf 1063 0 0 0 #Lunatico
	do mconf 1010 1 0 0 #Salgueiro
	do mconf 1014 0 0 0 #Sporo
	do mconf 1007 0 0 0 #Fabre
	do mconf 1049 1 0 0 #Picky
	do mconf 1011 0 0 0 #Chon chon
	do mconf 1042 0 0 0 #Steel chon chon
	do mconf 1012 1 0 0 #Rodda
		
	do iconf 949 0 0 1 #Feather
	do iconf 916 0 0 1 #Feather of Birds
	do iconf 516 0 0 1 #Potato
	do iconf 907 0 0 1 #Resin
	do iconf 902 0 0 1 #Tree Root
	do iconf 713 0 0 1 #Empty Bottle
	do iconf 908 0 0 1 #Spawn
	do iconf 918 0 0 1 #Sticky Webfoot
		
	do conf -f itemsTakeAuto 2
		
	do conf -f sellAuto 1
	do conf -f sellAuto_npc $.map 100 50
	do pconf all 1
		
	do conf -f eventMacro_1_99_stage novice_doing_merchant_quest
	]
}

automacro Check_sell_timer {
	timeout 150
	QuestActive 7126
	Zeny < 300
	ConfigKey eventMacro_1_99_stage novice_doing_merchant_quest
	exclusive 1
	priority 2
	call do_sell
}

macro do_sell {
	do autosell
}

automacro move_merch_job_end_quest {
    InMap new_1-3, new_2-3, new_3-3, new_4-3, new_5-3
	QuestActive 7126
	Zeny >= 300
	ConfigKey eventMacro_1_99_stage novice_doing_merchant_quest
    NpcNotNear /Merchant Guide/
    exclusive 1
    priority 1
    call move_job_guys
}

automacro talk_merch_job_end_quest {
    InMap new_1-3, new_2-3, new_3-3, new_4-3, new_5-3
	QuestActive 7126
	Zeny >= 300
	ConfigKey eventMacro_1_99_stage novice_doing_merchant_quest
    NpcNear /Merchant Guide/
    priority 1
    exclusive 1
    call {
       do talknpc &arg("$.NpcNearLastPos", 1) &arg("$.NpcNearLastPos", 2) r3
    }
}

automacro adjust_after_merchant_quest {
    InMap new_1-3, new_2-3, new_3-3, new_4-3, new_5-3
	QuestInactive 7126
	ConfigKey eventMacro_1_99_stage novice_doing_merchant_quest
	InInventoryID 1010 = 7
    priority 1
    exclusive 1
    call {
		[
		do iconf 713 0 1 0 #Empty Bottle
		do iconf 1010 0 1 0 #Phracon
		
		do conf -f itemsTakeAuto 1
		
		do conf -f sellAuto 0
		do conf -f sellAuto_npc none
		
		do conf -f eventMacro_1_99_stage novice_after_merchant_quest
		]
    }
}

automacro move_thief_job {
	ConfigKey eventMacro_1_99_stage novice_after_merchant_quest
    InMap new_1-3, new_2-3, new_3-3, new_4-3, new_5-3
    NpcNotNear /Thief/
    exclusive 1
    priority 1
    call move_job_guys
}

automacro talk_thief_job_get_manual {
	ConfigKey eventMacro_1_99_stage novice_after_merchant_quest
    InMap new_1-3, new_2-3, new_3-3, new_4-3, new_5-3
	InInventoryID 2820 = 0
    NpcNear /Thief/
    priority 1
    exclusive 1
	delay 2
    call {
       do talknpc &arg("$.NpcNearLastPos", 1) &arg("$.NpcNearLastPos", 2) r0 r0
    }
}

automacro equip_thief_manual {
	ConfigKey eventMacro_1_99_stage novice_after_merchant_quest
    InMap new_1-3, new_2-3, new_3-3, new_4-3, new_5-3
	InInventoryID 2820 = 1
    IsNotEquippedID rightAccessory 2820
    priority 1
    exclusive 1
    call {
       %toequip = (rightHand => 13040, armor => 2393, topHead => 5055, robe => 2510, shoes => 2414, leftHand => 2112, rightAccessory => 2820)
        call start_equipping
    }
}

automacro adjust_thief_manual {
    IsEquippedID topHead 5055
    IsEquippedID leftHand 2112
    IsEquippedID rightHand 13040
    IsEquippedID robe 2510
    IsEquippedID armor 2393
    IsEquippedID shoes 2414
    IsEquippedID rightAccessory 2820
	ConfigKey eventMacro_1_99_stage novice_after_merchant_quest
    InMap new_1-3, new_2-3, new_3-3, new_4-3, new_5-3
    exclusive 1
    call {
		do conf -f eventMacro_1_99_stage novice_after_thief_manual
    }
}

automacro move_sword_job {
    InMap new_1-3, new_2-3, new_3-3, new_4-3, new_5-3
	ConfigKey eventMacro_1_99_stage novice_after_thief_manual
    NpcNotNear /Swordman/
    exclusive 1
    priority 1
    call move_job_guys
}

automacro talk_sword_job_get_quest {
    InMap new_1-3, new_2-3, new_3-3, new_4-3, new_5-3
	ConfigKey eventMacro_1_99_stage novice_after_thief_manual
	QuestInactive 7123
    NpcNear /Swordman/
    priority 1
    exclusive 1
    call {
		do talknpc &arg("$.NpcNearLastPos", 1) &arg("$.NpcNearLastPos", 2) r2
    }
}

automacro Adjust_for_sword_quest {
    InMap new_1-3, new_2-3, new_3-3, new_4-3, new_5-3
    QuestActive 7123
	ConfigKey eventMacro_1_99_stage novice_after_thief_manual
	exclusive 1
    priority 1
	call {
		[
		do mconf 1002 0 0 0 #Poring
		do mconf 1113 0 0 0 #Drops
		do mconf 1063 0 0 0 #Lunatico
		do mconf 1010 0 0 0 #Salgueiro
		do mconf 1014 0 0 0 #Sporo
		do mconf 1007 0 0 0 #Fabre
		do mconf 1049 1 0 0 #Picky
		do mconf 1011 0 0 0 #Chon chon
		do mconf 1042 0 0 0 #Steel chon chon
		do mconf 1012 0 0 0 #Rodda
		
		do conf -f eventMacro_1_99_stage novice_doing_sword_quest
		]
	}
}

automacro move_sword_job_end_quest {
    InMap new_1-3, new_2-3, new_3-3, new_4-3, new_5-3
	ConfigKey eventMacro_1_99_stage novice_doing_sword_quest
    QuestHuntCompleted 7123 712300000
    NpcNotNear /Swordman/
    priority 1
    exclusive 1
    call move_job_guys
}
 
automacro talk_sword_job_end_quest {
    InMap new_1-3, new_2-3, new_3-3, new_4-3, new_5-3
	ConfigKey eventMacro_1_99_stage novice_doing_sword_quest
    QuestHuntCompleted 7123 712300000
    NpcNear /Swordman/
    priority 1
    exclusive 1
    call {
        do talknpc &arg("$.NpcNearLastPos", 1) &arg("$.NpcNearLastPos", 2) r3
    }
}

automacro adjust_after_sword_quest {
    InMap new_1-3, new_2-3, new_3-3, new_4-3, new_5-3
	ConfigKey eventMacro_1_99_stage novice_doing_sword_quest
    QuestInactive 7123
    priority 1
	exclusive 1
	call {
		[
		do conf -f eventMacro_1_99_stage novice_after_sword_quest
		]
	}
}

automacro move_mage_job {
    InMap new_1-3, new_2-3, new_3-3, new_4-3, new_5-3
	ConfigKey eventMacro_1_99_stage novice_after_sword_quest
    NpcNotNear /Mage/
    exclusive 1
    priority 1
    call move_job_guys
}

automacro talk_mage_job_get_quest {
    InMap new_1-3, new_2-3, new_3-3, new_4-3, new_5-3
	ConfigKey eventMacro_1_99_stage novice_after_sword_quest
	QuestInactive 7124
    NpcNear /Mage/
    priority 1
    exclusive 1
    call {
		do talknpc &arg("$.NpcNearLastPos", 1) &arg("$.NpcNearLastPos", 2) r2
    }
}

automacro Adjust_for_mage_quest {
    InMap new_1-3, new_2-3, new_3-3, new_4-3, new_5-3
    QuestActive 7124
	ConfigKey eventMacro_1_99_stage novice_after_sword_quest
	exclusive 1
    priority 1
	call {
		[
		do mconf 1002 0 0 0 #Poring
		do mconf 1113 0 0 0 #Drops
		do mconf 1063 1 0 0 #Lunatico
		do mconf 1010 0 0 0 #Salgueiro
		do mconf 1014 0 0 0 #Sporo
		do mconf 1007 0 0 0 #Fabre
		do mconf 1049 0 0 0 #Picky
		do mconf 1011 0 0 0 #Chon chon
		do mconf 1042 0 0 0 #Steel chon chon
		do mconf 1012 0 0 0 #Rodda
		do conf -f eventMacro_1_99_stage novice_doing_mage_quest
		]
	}
}

automacro move_mage_job_end_quest {
    InMap new_1-3, new_2-3, new_3-3, new_4-3, new_5-3
	ConfigKey eventMacro_1_99_stage novice_doing_mage_quest
    QuestHuntCompleted 7124 712400000
    NpcNotNear /Mage/
    priority 1
    exclusive 1
    call move_job_guys
}
 
automacro talk_mage_job_end_quest {
    InMap new_1-3, new_2-3, new_3-3, new_4-3, new_5-3
	ConfigKey eventMacro_1_99_stage novice_doing_mage_quest
    QuestHuntCompleted 7124 712400000
    NpcNear /Mage/
    priority 1
    exclusive 1
    call {
        do talknpc &arg("$.NpcNearLastPos", 1) &arg("$.NpcNearLastPos", 2) r3
    }
}

automacro adjust_after_mage_quest {
    InMap new_1-3, new_2-3, new_3-3, new_4-3, new_5-3
	ConfigKey eventMacro_1_99_stage novice_doing_mage_quest
    QuestInactive 7124
    priority 1
	exclusive 1
	call {
		[
		do conf -f eventMacro_1_99_stage novice_after_mage_quest
		]
	}
}

automacro move_thief_job_get_quest {
    InMap new_1-3, new_2-3, new_3-3, new_4-3, new_5-3
	ConfigKey eventMacro_1_99_stage novice_after_mage_quest
    NpcNotNear /Thief/
    exclusive 1
    priority 1
    call move_job_guys
}

automacro talk_thief_job_get_quest {
    InMap new_1-3, new_2-3, new_3-3, new_4-3, new_5-3
	ConfigKey eventMacro_1_99_stage novice_after_mage_quest
	QuestInactive 7127
    NpcNear /Thief/
    priority 1
    exclusive 1
    call {
		do talknpc &arg("$.NpcNearLastPos", 1) &arg("$.NpcNearLastPos", 2) r2
    }
}

automacro Adjust_for_thief_quest {
    InMap new_1-3, new_2-3, new_3-3, new_4-3, new_5-3
    QuestActive 7127
	ConfigKey eventMacro_1_99_stage novice_after_mage_quest
	exclusive 1
    priority 1
	call {
		[
		do mconf 1002 0 0 0 #Poring
		do mconf 1113 0 0 0 #Drops
		do mconf 1063 0 0 0 #Lunatico
		do mconf 1010 1 0 0 #Salgueiro
		do mconf 1014 0 0 0 #Sporo
		do mconf 1007 0 0 0 #Fabre
		do mconf 1049 0 0 0 #Picky
		do mconf 1011 0 0 0 #Chon chon
		do mconf 1042 0 0 0 #Steel chon chon
		do mconf 1012 0 0 0 #Rodda
		do conf -f eventMacro_1_99_stage novice_doing_thief_quest
		]
	}
}

automacro move_thief_job_end_quest {
    InMap new_1-3, new_2-3, new_3-3, new_4-3, new_5-3
	ConfigKey eventMacro_1_99_stage novice_doing_thief_quest
    QuestHuntCompleted 7127 712700000
    NpcNotNear /Thief/
    priority 1
    exclusive 1
    call move_job_guys
}
 
automacro talk_thief_job_end_quest {
    InMap new_1-3, new_2-3, new_3-3, new_4-3, new_5-3
	ConfigKey eventMacro_1_99_stage novice_doing_thief_quest
    QuestHuntCompleted 7127 712700000
    NpcNear /Thief/
    priority 1
    exclusive 1
    call {
        do talknpc &arg("$.NpcNearLastPos", 1) &arg("$.NpcNearLastPos", 2) r3
    }
}

automacro adjust_after_thief_quest {
    InMap new_1-3, new_2-3, new_3-3, new_4-3, new_5-3
	ConfigKey eventMacro_1_99_stage novice_doing_thief_quest
    QuestInactive 7127
    priority 1
	exclusive 1
	call {
		[
		do mconf 1002 1 0 0 #Poring
		do mconf 1113 1 0 0 #Drops
		do mconf 1063 1 0 0 #Lunatico
		do mconf 1010 1 0 0 #Salgueiro
		do mconf 1014 1 0 0 #Sporo
		do mconf 1007 1 0 0 #Fabre
		do mconf 1049 1 0 0 #Picky
		do mconf 1011 1 0 0 #Chon chon
		do mconf 1042 0 0 0 #Steel chon chon
		do mconf 1012 1 0 0 #Rodda
		do conf -f eventMacro_1_99_stage novice_after_thief_quest
		]
	}
}

automacro Change_to_class_selection {
    InMap new_1-3, new_2-3, new_3-3, new_4-3, new_5-3
	ConfigKey eventMacro_1_99_stage novice_after_thief_quest
	JobLevel 10
    priority 1
	exclusive 1
	call {
		do conf -f attackAuto 0
		do conf -f route_randomWalk 0
		do conf -f lockMap none
		
		include off Novice_Grounds.pm
		
		include on Brade_Bug.pm
		include on Move_to_tester.pm
		
		call set_class_answer_novice
		
		do reload eventMacros
	}
}