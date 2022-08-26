
#Novice Camp

automacro moveToShionOutside {
    exclusive 1
    BaseLevel = 1
    InMap new_1-1, new_2-1, new_3-1, new_4-1, new_5-1
	ConfigKey eventMacro_1_99_stage start
    NpcNotNear /Shion/
    call {
        do move 52 113
    }
}

automacro moveToShionOutside2_bug {
    exclusive 1
    BaseLevel = 1
    InMap new_1-1, new_2-1, new_3-1, new_4-1, new_5-1
	ConfigKey eventMacro_1_99_stage novice_1
    NpcNotNear /Shion/
    call {
        do move 52 113
    }
}

automacro Conf_Stuff_auto_2 {
    exclusive 1
    BaseLevel = 2
    InMap new_1-1, new_2-1, new_3-1, new_4-1, new_5-1
	ConfigKey eventMacro_1_99_stage start
     call Conf_Stuff
}
 
automacro Conf_Stuff_auto_1 {
    exclusive 1
    BaseLevel = 1
    InMap new_1-1, new_2-1, new_3-1, new_4-1, new_5-1
	ConfigKey eventMacro_1_99_stage start
    NpcNear /Shion/
    call Conf_Stuff
}
	
macro Conf_Stuff {
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
		
		 do conf -f clientSight 30
		
        do conf -f sellAuto 0
        do conf -f storageAuto 0
        do conf -f storageAuto_npc none
		do conf -f storageAuto_npc_type 3
		do conf -f storageAuto_npc_steps none
		do conf -f eventMacro_1_99_stage novice_1
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
    }
 
automacro TalkShionOutside {
    exclusive 1
    BaseLevel = 1
    InMap new_1-1, new_2-1, new_3-1, new_4-1, new_5-1
	ConfigKey eventMacro_1_99_stage novice_1
    NpcNear /Shion/
    call {
		do talknpc &arg("$.NpcNearLastPos", 1) &arg("$.NpcNearLastPos", 2) r0
    }
}
 
automacro moveInside {
    exclusive 1
	BaseLevel = 2
    InMap new_1-1, new_2-1, new_3-1, new_4-1, new_5-1
	ConfigKey eventMacro_1_99_stage novice_1
    priority 1
    call GotoInside
}

macro GotoInside {
    $nextMap = nextMap("$.map")
    do move $nextMap 101 29
}

automacro moveNextToReceptionist {
    exclusive 1
    BaseLevel = 2
    NpcNotNear /Receptionist/
    InMap new_1-2, new_2-2, new_3-2, new_4-2, new_5-2
    priority 1
    call GotoReceptionist
}

macro GotoReceptionist {
    do move 101 29
}

automacro talkReceptionist {
    exclusive 0
	self_interruptible 0
    BaseLevel = 2
    NpcNear /Receptionist/
    InMap new_1-2, new_2-2, new_3-2, new_4-2, new_5-2
    priority 0
    call talkReceptionistInside
}

macro talkReceptionistInside {
	do talk $.NpcNearLastBinId
	do talk text $.name
	do talk resp 0
}
 
automacro detect_receptionist_teleport {
    exclusive 1
    IsInCoordinate 100 70
    InMap new_1-2, new_2-2, new_3-2, new_4-2, new_5-2
	ConfigKey eventMacro_1_99_stage novice_1
    priority 0
    call {
		do conf -f eventMacro_1_99_stage novice_2
	}
}

automacro moveNextToInterfaces1 {
    exclusive 1
    NpcNotNear /Interfaces/
	ConfigKey eventMacro_1_99_stage novice_2
    InMap new_1-2, new_2-2, new_3-2, new_4-2, new_5-2
    priority 2
    call MoveToInterfaces
}
 
macro MoveToInterfaces {
    do move 99 102
}
 
automacro talkInterfaces {
    exclusive 1
    BaseLevel = 2
    priority 0
	ConfigKey eventMacro_1_99_stage novice_2
    InMap new_1-2, new_2-2, new_3-2, new_4-2, new_5-2
    NpcNear /Interfaces/
    call {
        do talk $.NpcNearLastBinId
        do talk resp 0
    }
}
 
automacro moveToGirlSkill {
    exclusive 1
    BaseLevel < 4
    priority 0
	ConfigKey eventMacro_1_99_stage novice_2
    InMap new_1-2, new_2-2, new_3-2, new_4-2, new_5-2
    NpcNotNear /Skill/
    call MoveSkill
}
 
macro MoveSkill {
    do move 84 107
}
 
automacro talkGirlSkill {
    exclusive 1
    BaseLevel < 4
    priority 0
	ConfigKey eventMacro_1_99_stage novice_2
    InMap new_1-2, new_2-2, new_3-2, new_4-2, new_5-2
    NpcNear /Skill/
    call TalkSkill
}

macro TalkSkill {
    do talknpc &arg("$.NpcNearLastPos", 1) &arg("$.NpcNearLastPos", 2) r0 r0
}
 
automacro moveToGirlItem {
    exclusive 1
    BaseLevel = 4
    JobLevel < 6
    priority 0
	ConfigKey eventMacro_1_99_stage novice_2
    InMap new_1-2, new_2-2, new_3-2, new_4-2, new_5-2
    NpcNotNear /Item/
    call MoveItem
}
 
macro MoveItem {
    do move 112 107
}
 
automacro talkGirlItem {
    exclusive 1
    BaseLevel = 4
    JobLevel < 6
    priority 0
	ConfigKey eventMacro_1_99_stage novice_2
    InMap new_1-2, new_2-2, new_3-2, new_4-2, new_5-2
    NpcNear /Item/
    call TalkItem
}

macro TalkItem {
    do talknpc &arg("$.NpcNearLastPos", 1) &arg("$.NpcNearLastPos", 2) r0 r0
}
 
automacro moveToGirlItem_teleport_ask {
    exclusive 1
    BaseLevel = 4
    JobLevel = 6
    priority 0
	ConfigKey eventMacro_1_99_stage novice_2
    InMap new_1-2, new_2-2, new_3-2, new_4-2, new_5-2
    NpcNotNear /Item/
    call MoveItem
}
 
automacro talkGirlItem_teleport_ask {
    exclusive 1
    BaseLevel = 4
    JobLevel = 6
    priority 0
	ConfigKey eventMacro_1_99_stage novice_2
    InMap new_1-2, new_2-2, new_3-2, new_4-2, new_5-2
    NpcNear /Item/
    call TalkItem_teleport_ask
}

macro TalkItem_teleport_ask {
    do talknpc &arg("$.NpcNearLastPos", 1) &arg("$.NpcNearLastPos", 2) r0
}

# Got items
# 1-2 28 178
# Next to helper and entrance (and potato lady lol)
 
automacro moveToGuyHelper {
    exclusive 1
    BaseLevel < 5
    JobLevel = 6
    priority 0
	ConfigKey eventMacro_1_99_stage novice_2
    InMap new_1-2, new_2-2, new_3-2, new_4-2, new_5-2
    NpcNotNear /Helper/
    call MoveHelper
}

macro MoveHelper {
    do move 28 178
}

automacro talkGuyHelper {
    exclusive 1
    BaseLevel < 5
    JobLevel = 6
    priority 0
	ConfigKey eventMacro_1_99_stage novice_2
    InMap new_1-2, new_2-2, new_3-2, new_4-2, new_5-2
    NpcNear /Helper/
    call TalkHelper
}

macro TalkHelper {
    do talknpc &arg("$.NpcNearLastPos", 1) &arg("$.NpcNearLastPos", 2) r0 r3
}
 
automacro moveToGuyEntrance {
    exclusive 1
    BaseLevel = 5
    JobLevel = 6
    priority 0
	ConfigKey eventMacro_1_99_stage novice_2
    InMap new_1-2, new_2-2, new_3-2, new_4-2, new_5-2
    NpcNotNear /Entrance/
    call MoveEntrance
}

macro MoveEntrance {
    do move 28 178
}

automacro talkGuyEntrance {
    exclusive 1
    BaseLevel = 5
    JobLevel = 6
    priority 0
	ConfigKey eventMacro_1_99_stage novice_2
    InMap new_1-2, new_2-2, new_3-2, new_4-2, new_5-2
    NpcNear /Entrance/
    call TalkEntrance
}

macro TalkEntrance {
    do talknpc &arg("$.NpcNearLastPos", 1) &arg("$.NpcNearLastPos", 2) r0
}

# Teleportado pra 1-3

automacro talkBradeonGroundsAdjustToQuest {
    exclusive 1
    BaseLevel = 5
    JobLevel = 6
    priority 0
	ConfigKey eventMacro_1_99_stage novice_2
	ConfigKeyNot attackAuto 2
    InMap new_1-3, new_2-3, new_3-3, new_4-3, new_5-3
    call AdjustConfigForGrounds
}

macro AdjustConfigForGrounds {
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
	
	do conf -f lockMap $.map
	do conf -f attackAuto 2
	do conf -f route_randomWalk 1
	$potName = GetNamebyNameID(569)
	do conf -f useSelf_item_0 $potName
	do conf -f useSelf_item_0_disabled 0
	do conf -f useSelf_item_0_hp < 80%
	do conf -f useSelf_item_0_timeout 1
	]
}
 
automacro equipStuffForGrounds {
    exclusive 1
    BaseLevel = 5
    JobLevel = 6
    priority 0
	ConfigKey eventMacro_1_99_stage novice_2
	ConfigKey attackAuto 2
    InInventoryID 13040 = 1
    IsNotEquippedID topHead 5055, leftHand 2112, robe 2393, shoes 2414, armor 2352, rightHand 13040
    InMap new_1-3, new_2-3, new_3-3, new_4-3, new_5-3
    call {
		%toequip = (topHead => 5055, robe => 2393, shoes => 2414, armor => 2352, leftHand => 2112, rightHand => 13040)
        call start_equipping
    }
}

automacro Change_to_class_selection {
    exclusive 1
    JobLevel = 10
    priority 0
    InMap new_1-3, new_2-3, new_3-3, new_4-3, new_5-3
	ConfigKey eventMacro_1_99_stage novice_2
	call {
		do conf -f attackAuto 0
		do conf -f route_randomWalk 0
		do conf -f lockMap none
		
		include off Novice_Grounds.pm
		
		include on Move_to_tester.pm
		
		call set_class_answer_novice
		
		do reload eventMacros
	}
}