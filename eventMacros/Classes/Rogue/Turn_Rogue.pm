

## Rogue quest


automacro MovetoGuildsWoman {
	QuestInactive 2017
	exclusive 1
	ConfigKey eventMacro_1_99_stage turn_rogue_start
	NpcNotNear /(Arruaceira da Guilda|Rogue Guildsman)/
	priority 1
	call {
		do move in_rogue 363 122
	}
}

automacro TalktoGuildsWoman {
	QuestInactive 2017
	NpcNear /Arruaceira da Guilda|Rogue Guildsman/
	priority 1
	ConfigKey eventMacro_1_99_stage turn_rogue_start
	timeout 90
	call {
		do talk $.NpcNearLastBinId
	}
}

automacro FirstStartTalk {
	priority 0
	ConfigKey eventMacro_1_99_stage turn_rogue_start
	timeout 2
	NpcMsg /(E então, o que alguém jovem|Let's get started)/
	call {
		do talk resp 0
	}
}

automacro AfterFailTalk {
	priority 0
	ConfigKey eventMacro_1_99_stage turn_rogue_start
	NpcMsg /(Ok, você provavelmente fez tudo errado da última vez porque estava muito nervoso|you probably screwed up last time)/
	call {
		do talk resp 0
	}
}

#########SET01
automacro RespQuestions01-01 {
	priority 0
	ConfigKey eventMacro_1_99_stage turn_rogue_start
	NpcMsg /necessary for learning/
	call {
		do talk resp /Hiding/i
	}
}


automacro RespQuestions01-02 {
	priority 0
	ConfigKey eventMacro_1_99_stage turn_rogue_start
	NpcMsg /comparison to the Merchant/
	call {
		do talk resp /1/
	}
}

automacro RespQuestions01-03 {
	priority 0
	ConfigKey eventMacro_1_99_stage turn_rogue_start
	NpcMsg /correct description for the skill/
	call {
		do talk resp /Zeny.+monsters/i
	}
}


automacro RespQuestions01-04 {
	priority 0
	ConfigKey eventMacro_1_99_stage turn_rogue_start
	NpcMsg /How many Rogues does it require/
	call {
		do talk resp /(2.+Rogues)/i
	}
}


automacro RespQuestions01-05 {
	priority 0
	ConfigKey eventMacro_1_99_stage turn_rogue_start
	NpcMsg /Choose the skill that you can learn/
	call {
		do talk resp /Shield/i
	}
}


automacro RespQuestions01-06 {
	priority 0
	ConfigKey eventMacro_1_99_stage turn_rogue_start
	NpcMsg /Choose the skill which allows its user to move while hiding/
	call {
		do talk resp /Stalk/i
	}
}


automacro RespQuestions01-07 {
	priority 0
	ConfigKey eventMacro_1_99_stage turn_rogue_start
	NpcMsg /card that increases the accuracy rate of its owner/
	call {
		do talk resp /Mummy/i
	}
}

automacro RespQuestions01-08 {
	priority 0
	ConfigKey eventMacro_1_99_stage turn_rogue_start
	NpcMsg /weapon with the Vadon card/
	call {
		do talk resp /Elder/i
	}
}


automacro RespQuestions01-09 {
	priority 0
	ConfigKey eventMacro_1_99_stage turn_rogue_start
	NpcMsg /require when used with a Dagger/
	call {
		do talk resp /Passive/i
	}
}


automacro RespQuestions01-10 {
	priority 0
	ConfigKey eventMacro_1_99_stage turn_rogue_start
	NpcMsg /Choose the most efficient dagger to use in the Byalan Dungeon/
	call {
		do talk resp /Wind/i
	}
}

#########SET02
automacro RespQuestions02-01 {
	priority 0
	ConfigKey eventMacro_1_99_stage turn_rogue_start
	NpcMsg /Gladius/
	call {
		do talk resp /Kobold/i
	}
}


automacro RespQuestions02-02 {
	priority 0
	ConfigKey eventMacro_1_99_stage turn_rogue_start
	NpcMsg /(Main-Gauche|Main Gauche)/
	call {
		do talk resp /Hornet/i
	}
}

automacro RespQuestions02-03 {
	priority 0
	ConfigKey eventMacro_1_99_stage turn_rogue_start
	NpcMsg /is able to create unique potions/
	call {
		do talk resp /Alchemist/i
	}
}


automacro RespQuestions02-04 {
	priority 0
	ConfigKey eventMacro_1_99_stage turn_rogue_start
	NpcMsg /Choose the weapon that Rogues aren/
	call {
		do talk resp /Katar/i
	}
}


automacro RespQuestions02-05 {
	priority 0
	ConfigKey eventMacro_1_99_stage turn_rogue_start
	NpcMsg /Choose the property that the monster Hode possesses/
	call {
		do talk resp /Earth/i
	}
}


automacro RespQuestions02-06 {
	priority 0
	ConfigKey eventMacro_1_99_stage turn_rogue_start
	NpcMsg /Choose the monster that is unable to be tamed for as a Cute Pet/
	call {
		do talk resp /Creamy/i
	}
}


automacro RespQuestions02-07 {
	priority 0
	ConfigKey eventMacro_1_99_stage turn_rogue_start
	NpcMsg /Choose the monster that receives more damage from a Dagger with the Fire property/
	call {
		do talk resp /Hammer/i
	}
}

automacro RespQuestions02-08 {
	priority 0
	ConfigKey eventMacro_1_99_stage turn_rogue_start
	NpcMsg /Choose the town that doesn/
	call {
		do talk resp /Alberta/i
	}
}


automacro RespQuestions02-09 {
	priority 0
	ConfigKey eventMacro_1_99_stage turn_rogue_start
	NpcMsg /Choose the plant that drops Blue Herbs/
	call {
		do talk resp /Blue/i
	}
}


automacro RespQuestions02-10 {
	priority 0
	ConfigKey eventMacro_1_99_stage turn_rogue_start
	NpcMsg /Choose the monster that does not have the Undead property/
	call {
		do talk resp /Familiar/i
	}
}

#########SET03
automacro RespQuestions03-01 {
	priority 0
	ConfigKey eventMacro_1_99_stage turn_rogue_start
	NpcMsg /percentage is the flee rate/
	call {
		do talk resp /30/i
	}
}


automacro RespQuestions03-02 {
	priority 0
	ConfigKey eventMacro_1_99_stage turn_rogue_start
	NpcMsg /Choose the monster that detects a characters using the Hiding/
	call {
		do talk resp /Argos/i
	}
}

automacro RespQuestions03-03 {
	priority 0
	ConfigKey eventMacro_1_99_stage turn_rogue_start
	NpcMsg /Choose the location where Thieves can change their jobs to Rogues/
	call {
		do talk resp /Lighthouse/i
	}
}


automacro RespQuestions03-04 {
	priority 0
	ConfigKey eventMacro_1_99_stage turn_rogue_start
	NpcMsg /In which town can Novices change their jobs to Thieves/
	call {
		do talk resp /Morroc/i
	}
}


automacro RespQuestions03-05 {
	priority 0
	ConfigKey eventMacro_1_99_stage turn_rogue_start
	NpcMsg /Choose the card that does not affect the DEX stat/
	call {
		do talk resp /Mummy/i
	}
}


automacro RespQuestions03-06 {
	priority 0
	ConfigKey eventMacro_1_99_stage turn_rogue_start
	NpcMsg /cool about being a Rogue/
	call {
		do talk resp 0
	}
}


automacro RespQuestions03-07 {
	priority 0
	ConfigKey eventMacro_1_99_stage turn_rogue_start
	NpcMsg /possible to change jobs from Thief to Rogue/
	call {
		do talk resp /50/i
	}
}

automacro RespQuestions03-08 {
	priority 0
	ConfigKey eventMacro_1_99_stage turn_rogue_start
	NpcMsg /You want to dye your hair blue/
	call {
		do talk resp /Prontera.+7/i
	}
}


automacro RespQuestions03-09 {
	priority 0
	ConfigKey eventMacro_1_99_stage turn_rogue_start
	NpcMsg /Choose the mushroom that is required/
	call {
		do talk resp /Gooey/i
	}
}


automacro RespQuestions03-10 {
	priority 0
	ConfigKey eventMacro_1_99_stage turn_rogue_start
	NpcMsg /Choose the card that least benefits the Rogue class/
	call {
		do talk resp /Elder/i
	}
}

############################333

automacro ChangeToTurnRogueItems {
	exclusive 1
	priority 2
	QuestActive 2017
	ConfigKey eventMacro_1_99_stage turn_rogue_start
	call {
		do conf -f eventMacro_1_99_stage turn_rogue_items
	}
}

###########################

automacro moveSmithratoGetQuest {
	exclusive 1
	QuestActive 2017
	ConfigKey eventMacro_1_99_stage turn_rogue_items
	NpcNotNear /Smith/
	priority 1
	call {
		do move in_rogue 375 25
	}
}

automacro talkSmithratoGetQuest {
	exclusive 1
	QuestActive 2017
	ConfigKey eventMacro_1_99_stage turn_rogue_items
	NpcNear /Smith/
	priority 1
	call {
		do talk $.NpcNearLastBinId
	}
}

automacro GotSet1 {
	exclusive 1
	QuestActive 2021
	ConfigKey eventMacro_1_99_stage turn_rogue_items
	priority 1
	run-once 1
	call {
		#countitem(Chrysalis) > 4 && countitem(Empty_Bottle) > 4 && countitem(Iron_Ore) > 4 &&
		#	countitem(Stone_Heart) > 4 && countitem(Red_Herb) > 4 && countitem(Animals_Skin) > 4 && countitem(Yellow_Gemstone) > 4 &&
		#	countitem(Tooth_Of_Bat) > 4 && countitem(Scorpions_Tail) > 4 && countitem(Yoyo_Tail) > 4 && countitem(Monsters_Feed) > 4 &&
		#	countitem(Fluff) > 4 && countitem(Clover) > 4 && countitem(Feather_Of_Birds) > 4 && countitem(Talon) > 4 &&
		#	countitem(Spawn) > 4 && countitem(Raccoon_Leaf) > 4) {
		do conf -f eventMacro_1_99_stage turn_rogue_collect
	}
}

automacro GotSet2 {
	exclusive 1
	QuestActive 2020
	ConfigKey eventMacro_1_99_stage turn_rogue_items
	priority 1
	run-once 1
	call {
		#508,10,948,10,935,10,940,10;
		do conf -f eventMacro_1_99_stage turn_rogue_collect
	}
}

automacro GotSet3 {
	exclusive 1
	QuestActive 2019
	ConfigKey eventMacro_1_99_stage turn_rogue_items
	priority 1
	run-once 1
	call {
		#511,10,910,10,926,10,964,10;
		do conf -f eventMacro_1_99_stage turn_rogue_collect
	}
}

automacro GotSet4 {
	exclusive 1
	QuestActive 2018
	ConfigKey eventMacro_1_99_stage turn_rogue_items
	priority 1
	run-once 1
	call {
		#510,6,932,10,957,10,958,10;
		do conf -f eventMacro_1_99_stage turn_rogue_collect
	}
}

####################
#### Item set 1
automacro checkItemsSet1 {
	timeout 60
	exclusive 1
	priority 2
	QuestActive 2021
	ConfigKey eventMacro_1_99_stage turn_rogue_collect
	call OrganizeItems1
}


macro OrganizeItems1 {
	do relog 999999999
}

####################
#### Item set 2
automacro checkItemsSet2 {
	timeout 60
	exclusive 1
	priority 2
	QuestActive 2020
	ConfigKey eventMacro_1_99_stage turn_rogue_collect
	call OrganizeItems2
}

macro SetVarSet2 {
	[
	$saveParam = $.param[0]
	
	do conf -f turn_rogue_collect_set 2
	$id = 508
	$amount = 10
	$maxPrice = 2500
	$YellowHerb = GetNamebyNameID("$id")
	$YellowHerb = &invamount($YellowHerb)
	if ($saveParam == 0) {
		call set_BetterbuyAuto_item_quest $id $maxPrice $amount
		call set_getauto
	} else {
		call BetterbuyAuto_clear_item $id
		call clear_getauto
	}
	
	$id = 940
	$amount = 10
	$maxPrice = 1000
	$Grasshopper = GetNamebyNameID("$id")
	$Grasshopper = &invamount($Grasshopper)
	if ($saveParam == 0) {
		call set_BetterbuyAuto_item_quest $id $maxPrice $amount
		call set_getauto
	} else {
		call BetterbuyAuto_clear_item $id
		call clear_getauto
	}
	
	$id = 935
	$amount = 10
	$maxPrice = 500
	$Shell = GetNamebyNameID("$id")
	$Shell = &invamount($Shell)
	if ($saveParam == 0) {
		call set_BetterbuyAuto_item_quest $id $maxPrice $amount
		call set_getauto
	} else {
		call BetterbuyAuto_clear_item $id
		call clear_getauto
	}
	
	$id = 948
	$amount = 10
	$maxPrice = 500
	$BearFootskin = GetNamebyNameID("$id")
	$BearFootskin = &invamount($BearFootskin)
	if ($saveParam == 0) {
		call set_BetterbuyAuto_item_quest $id $maxPrice $amount
		call set_getauto
	} else {
		call BetterbuyAuto_clear_item $id
		call clear_getauto
	}
	]
}

macro OrganizeItems2 {
	[
	call SetVar
	call set_skills_stats
	call SetVarSet2 0
	$changed = 0
	
	if ($.zeny < 25000) {
		if ($testvar == 1) {
			if ($configlockMap != prt_fild05) {
				call set_lockmap_prt_fild05
				$changed = 1
			}
		} else {
			if ($configlockMap != lasa_dun01) {
				call set_lockmap_lasa_dun01
				$changed = 1
			}
		}
	
	} elsif ($BearFootskin < 10) {
		if ($configlockMap != mjolnir_09) {
			call set_lockmap_mjolnir_09
			$changed = 1
		}
	
	} elsif ($Grasshopper < 10 || $Shell < 10) {
		if ($configlockMap != moc_fild18) {
			call set_lockmap_moc_fild18
			do mconf 1127 0 0 0 #Hode
			do mconf 1055 0 0 0 #Muka
			do mconf 1138 0 0 0 #Magnolia
			do mconf 1030 0 0 0 #ANACONDAQ
			if ($Grasshopper < 10) {
				do mconf 1058 1 0 0 #Metaller
			} else {
				do mconf 1058 0 0 0 #Metaller
			}
			if ($Shell < 10) {
				do mconf 1042 1 0 0 #STEEL_CHONCHON
			} else {
				do mconf 1042 0 0 0 #STEEL_CHONCHON
			}
			$changed = 1
		}
		
	} elsif ($YellowHerb < 10) {
		if ($configlockMap != cmd_fild07) {
			# kafra cmd_fild07 136 134
			# sell cmd_fild07 257 126
			call set_lockmap_cmd_fild07
			do mconf 1266 1 0 0 #Aster
			do mconf 1073 0 0 0 #Crab
			do mconf 1074 0 0 0 #Shellfish
			do mconf 1067 0 0 0 #Cornutus
			do mconf 1066 0 0 0 #Vadon
			$changed = 1
		}
		
	} else {
		do conf -f lockMap none
		do conf -f eventMacro_1_99_stage turn_rogue_deliver
	}
	
	if ($changed == 1) {
		call after_lock_change
	} else {
		log [Rogue] Current lockmap $configlockMap is still good
	}
	]
}

####################
#### Item set 3
automacro checkItemsSet3 {
	timeout 60
	exclusive 1
	priority 2
	QuestActive 2019
	ConfigKey eventMacro_1_99_stage turn_rogue_collect
	call OrganizeItems3
}

macro SetVarSet3 {
	[
	$saveParam = $.param[0]
	
	do conf -f turn_rogue_collect_set 3
	$id = 910
	$amount = 10
	$maxPrice = 500
	$Garlet = GetNamebyNameID("$id")
	$Garlet = &invamount($Garlet)
	if ($saveParam == 0) {
		call set_BetterbuyAuto_item_quest $id $maxPrice $amount
		call set_getauto
	} else {
		call BetterbuyAuto_clear_item $id
		call clear_getauto
	}
	
	$id = 926
	$amount = 10
	$maxPrice = 300
	$SnakeScale = GetNamebyNameID("$id")
	$SnakeScale = &invamount($SnakeScale)
	if ($saveParam == 0) {
		call set_BetterbuyAuto_item_quest $id $maxPrice $amount
		call set_getauto
	} else {
		call BetterbuyAuto_clear_item $id
		call clear_getauto
	}
	
	$id = 511
	$amount = 10
	$maxPrice = 2500
	$GreenHerb = GetNamebyNameID("$id")
	$GreenHerb = &invamount($GreenHerb)
	if ($saveParam == 0) {
		call set_BetterbuyAuto_item_quest $id $maxPrice $amount
		call set_getauto
	} else {
		call BetterbuyAuto_clear_item $id
		call clear_getauto
	}
	
	$id = 964
	$amount = 10
	$maxPrice = 2500
	$CrabShell = GetNamebyNameID("$id")
	$CrabShell = &invamount($CrabShell)
	if ($saveParam == 0) {
		call set_BetterbuyAuto_item_quest $id $maxPrice $amount
		call set_getauto
	} else {
		call BetterbuyAuto_clear_item $id
		call clear_getauto
	}
	]
}

macro OrganizeItems3 {
	[
	call SetVar
	call set_skills_stats
	call SetVarSet3 0
	$changed = 0
	
	
	if ($.zeny < 25000) {
		if ($testvar == 1) {
			if ($configlockMap != prt_fild05) {
				call set_lockmap_prt_fild05
				$changed = 1
			}
		} else {
			if ($configlockMap != lasa_dun01) {
				call set_lockmap_lasa_dun01
				$changed = 1
			}
		}
		
	} elsif ($Garlet < 10 || $SnakeScale < 10) {
		if ($testvar == 1) {
			if ($configlockMap != prt_fild04) {
				call set_lockmap_prt_fild04
				$changed = 1
			}
		} else {
			if ($configlockMap != lasa_dun01) {
				# kafra aldebaran 143 119
				# sell aldeba_in 94 56
				call set_lockmap_lasa_dun01
				$changed = 1
			}
		}
	
	} elsif ($GreenHerb < 10) {
		if ($configlockMap != prt_fild07) {
			# kafra prt_fild05 290 224
			# sell prt_fild05 290 221
			call set_lockmap_prt_fild07
			$changed = 1
		}
	
	} elsif ($CrabShell < 10) {
		if ($configlockMap != cmd_fild07) {
			# kafra cmd_fild07 136 134
			# sell cmd_fild07 257 126
			call set_lockmap_cmd_fild07
			$changed = 1
		}
	
	} else {
		do conf -f lockMap none
		do conf -f eventMacro_1_99_stage turn_rogue_deliver
	}
	
	if ($changed == 1) {
		call after_lock_change
	} else {
		log [Rogue] Current lockmap $configlockMap is still good
	}
	]
}

####################
#### Item set 4
automacro checkItemsSet4 {
	timeout 60
	exclusive 1
	priority 2
	QuestActive 2018
	ConfigKey eventMacro_1_99_stage turn_rogue_collect
	call OrganizeItems4
}

macro SetVarSet4 {
	[
	$saveParam = $.param[0]
	
	do conf -f turn_rogue_collect_set 4
	$id = 510
	$maxPrice = 3500
	$amount = 6
	$ervaAzul = GetNamebyNameID("$id")
	$ervaAzul = &invamount($ervaAzul)
	if ($saveParam == 0) {
		call set_BetterbuyAuto_item_quest $id $maxPrice $amount
		call set_getauto
	} else {
		call BetterbuyAuto_clear_item $id
		call clear_getauto
	}
	
	$id = 932
	$maxPrice = 300
	$amount = 10
	$osso = GetNamebyNameID("$id")
	$osso = &invamount($osso)
	if ($saveParam == 0) {
		call set_BetterbuyAuto_item_quest $id $maxPrice $amount
		call set_getauto
	} else {
		call BetterbuyAuto_clear_item $id
		call clear_getauto
	}
	
	$id = 957
	$maxPrice = 300
	$amount = 10
	$unhaApodrecida = GetNamebyNameID("$id")
	$unhaApodrecida = &invamount($unhaApodrecida)
	if ($saveParam == 0) {
		call set_BetterbuyAuto_item_quest $id $maxPrice $amount
		call set_getauto
	} else {
		call BetterbuyAuto_clear_item $id
		call clear_getauto
	}
	
	$id = 958
	$maxPrice = 2500
	$amount = 10
	$mandibulaHorrenda = GetNamebyNameID("$id")
	$mandibulaHorrenda = &invamount($mandibulaHorrenda)
	if ($saveParam == 0) {
		call set_BetterbuyAuto_item_quest $id $maxPrice $amount
		call set_getauto
	} else {
		call BetterbuyAuto_clear_item $id
		call clear_getauto
	}
	]
	if ($mandibulaHorrenda < $amount) {
		[
		force_market_search("$id")
		]
		pause 3
		[
		$canBuyMadibula = check_MarketWatcher("$id")
		log [Mandibula] canBuyMadibula $canBuyMadibula
		]
	} else {
		call BetterbuyAuto_clear_item $id
	}
}

macro OrganizeItems4 {
	[
	call SetVar
	call set_skills_stats
	call SetVarSet4 0
	$changed = 0
	
	if ($.zeny < 25000) {
		if ($testvar == 1) {
			if ($configlockMap != prt_fild05) {
				call set_lockmap_prt_fild05
				$changed = 1
			}
		} else {
			if ($configlockMap != lasa_dun01) {
				call set_lockmap_lasa_dun01
				$changed = 1
			}
		}
		
	} elsif ($ervaAzul < 6) {
		if ($testvar == 1) {
			if ($configlockMap != prt_fild05) {
				call set_lockmap_prt_fild05
				$changed = 1
			}
		} else {
			if ($configlockMap != pay_fild01) {
				call set_lockmap_pay_fild01
				do mconf 1031 0 0 0 #Poporing
				do mconf 1010 0 0 0 #Willow
				do mconf 1002 0 0 0 #Poring
				do mconf 1014 1 0 0 #Spore
				$changed = 1
			}
		}
	
	} elsif ($osso < 10 || $unhaApodrecida < 10 || ($mandibulaHorrenda < 10 && $canBuyMadibula == 0)) {
		if ($testvar == 1) {
			if ($configlockMap != prt_fild07) {
				call set_lockmap_prt_fild07
				do mconf 1015 1 0 0
				do mconf 1076 1 0 0
				do mconf 1031 0 0 0
				do mconf 1005 0 0 0
				$changed = 1
			}
		} else {
			if ($configlockMap != pay_dun00) {
				call set_lockmap_pay_dun00
				do mconf 1015 1 0 0
				do mconf 1076 1 0 0
				do mconf 1031 0 0 0
				do mconf 1005 0 0 0
				$changed = 1
			}
		}
		if ($osso >= 10) {
			do mconf 1076 0 0 0
		}
	
	} elsif ($mandibulaHorrenda < 10 && $canBuyMadibula == 1) {
		if ($testvar == 1) {
			if ($configlockMap != prt_fild05) {
				call set_lockmap_prt_fild05
				$changed = 1
			}
		} else {
			if ($configlockMap != lasa_dun01) {
				call set_lockmap_lasa_dun01
				$changed = 1
			}
		}
	} else {
		do conf -f lockMap none
		do conf -f eventMacro_1_99_stage turn_rogue_deliver
	}
	
	if ($changed == 1) {
		call after_lock_change
	} else {
		log [Rogue] Current lockmap $configlockMap is still good
	}
	]
}

######################
#### Deliver
macro set_getauto {
	[
	log We need $amount of item $name ($id)
	do iconf $id $amount 1 0
	]
}

macro clear_getauto {
	[
	$name = GetNamebyNameID("$id")
	log Clearing getauto $name
	$foundSlot = find_key_in_block("getAuto","$name")
	if ($foundSlot != -1) {
		clear_common_getauto("$foundSlot")
	}
	do iconf $id 0 1 0
	]
} 

automacro moveSmithratoCompleteQuest {
	exclusive 1
	QuestActive 2018, 2019, 2020, 2021
	ConfigKey eventMacro_1_99_stage turn_rogue_deliver
	NpcNotNear /Smith/
	priority 1
	call {
		do move in_rogue 375 25
	}
}

automacro talkSmithratoCompleteQuest {
	exclusive 1
	QuestActive 2018, 2019, 2020, 2021
	ConfigKey eventMacro_1_99_stage turn_rogue_deliver
	NpcNear /Smith/
	priority 1
	call {
		do talk $.NpcNearLastBinId
	}
}

automacro talkSmithCompletedQuest {
	exclusive 1
	QuestActive 2022, 2023, 2024
	ConfigKey eventMacro_1_99_stage turn_rogue_deliver
	priority 1
	call {
		do conf -f eventMacro_1_99_stage turn_rogue_getToNpc_farming
		do conf -f turn_rogue_getToNpc_type $.QuestActiveLastID
		$collectset = &config(turn_rogue_collect_set)
		if ($collectset == 2) {
			call SetVarSet2 1
		} elsif ($collectset == 3) {
			call SetVarSet3 1
		} elsif ($collectset == 4) {
			call SetVarSet4 1
		}
	}
}

automacro return_rogue_getToNpc_farming {
	exclusive 1
	InSaveMap 1
	priority 0
	QuestActive 2022, 2023, 2024, 2026
	InInventoryID 502 < 30
	ConfigKey eventMacro_1_99_stage turn_rogue_getToNpc
	call {
		do conf -f eventMacro_1_99_stage turn_rogue_getToNpc_farming
	}
}

automacro turn_rogue_getToNpc_farming {
	timeout 60
	exclusive 1
	priority 2
	QuestActive 2022, 2023, 2024, 2026
	InInventoryID 502 < 30
	ConfigKey eventMacro_1_99_stage turn_rogue_getToNpc_farming
	call rogue_farming
}

macro rogue_farming {
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
		log [Rogue] Current lockmap $configlockMap is still good
	}
}

automacro Return_To_Job_Change_Orange_Potion {
	ConfigKey eventMacro_1_99_stage turn_rogue_getToNpc_farming
	QuestActive 2022, 2023, 2024, 2026
	InInventoryID 502 >= 30 
	exclusive 1
	priority 0
	call {
		[
		do conf -f eventMacro_1_99_stage turn_rogue_getToNpc
		do conf -f itemsTakeAuto 0
		do conf -f teleportAuto_maxDmg 900
		do conf -f lockMap none
		]
	}
}

###############

automacro GotaMoveToAraghanPortal {
	ConfigKey eventMacro_1_99_stage turn_rogue_getToNpc
	ConfigKey turn_rogue_getToNpc_type 2022
	QuestActive 2022, 2026
	priority 2
	timeout 10
	NotInMap in_rogue
	call MoveToAraghanPortal
}

macro MoveToAraghanPortal {
	do move cmd_fild09 107 195
}

automacro GotaTalkToAraghanPortal {
	ConfigKey eventMacro_1_99_stage turn_rogue_getToNpc
	ConfigKey turn_rogue_getToNpc_type 2022
	QuestActive 2022, 2026
	NpcMsg /(invadir o meu território|intrude my territory)/
	priority 0
	exclusive 1
	call TalkToAraghanPortal
}

macro TalkToAraghanPortal {
	do talk resp 1
	do talk resp 2
	do talk resp 1
	do talk resp 0
	release GotaMoveToAraghan
}

automacro GotaMoveToAraghan {
	ConfigKey eventMacro_1_99_stage turn_rogue_getToNpc
	ConfigKey turn_rogue_getToNpc_type 2022
	QuestActive 2022, 2026
	InMap in_rogue
	NpcNotNear /ragham/
	exclusive 1
	disabled 1
	call MoveToAraghan
}

macro MoveToAraghan {
	do move in_rogue 244 33
}

automacro GotaTalkToAraghan {
	ConfigKey eventMacro_1_99_stage turn_rogue_getToNpc
	ConfigKey turn_rogue_getToNpc_type 2022
	QuestActive 2022, 2026
	InMap in_rogue
	NpcNear /ragham/
	exclusive 1
	call TalkToAraghan
}

macro TalkToAraghan {
	lock GotaMoveToAraghan
	do talknpc &arg("$.NpcNearLastPos", 1) &arg("$.NpcNearLastPos", 2) r0
}

###############

automacro GotaMoveToAntonioPortal {
	ConfigKey eventMacro_1_99_stage turn_rogue_getToNpc
	ConfigKey turn_rogue_getToNpc_type 2023
	QuestActive 2023, 2026
	priority 2
	timeout 10
	NotInMap in_rogue
	call MoveToAntonioPortal
}

macro MoveToAntonioPortal {
	do move cmd_fild04 304 180
}

automacro GotaTalkToAntonioPortal {
	ConfigKey eventMacro_1_99_stage turn_rogue_getToNpc
	ConfigKey turn_rogue_getToNpc_type 2023
	QuestActive 2023, 2026
	NpcMsg /(invadir o meu território|intrude my territory)/
	priority 0
	exclusive 1
	call TalkToAntonioPortal
}

macro TalkToAntonioPortal {
	do talk resp 2
	do talk resp 1
	do talk resp 1
	do talk resp 2
	release GotaMoveToAntonio
}

automacro GotaMoveToAntonio {
	ConfigKey eventMacro_1_99_stage turn_rogue_getToNpc
	ConfigKey turn_rogue_getToNpc_type 2023
	QuestActive 2023, 2026
	InMap in_rogue
	NpcNotNear /ntonio/
	exclusive 1
	disabled 1
	call MoveToAntonio
}

macro MoveToAntonio {
	do move in_rogue 172 108
}

automacro GotaTalkToAntonio {
	ConfigKey eventMacro_1_99_stage turn_rogue_getToNpc
	ConfigKey turn_rogue_getToNpc_type 2023
	QuestActive 2023, 2026
	InMap in_rogue
	NpcNear /ntonio/
	exclusive 1
	call TalkToAntonio
}

macro TalkToAntonio {
	lock GotaMoveToAntonio
	do talknpc &arg("$.NpcNearLastPos", 1) &arg("$.NpcNearLastPos", 2) r0
}

###############

automacro GotaMoveToHollgrehenPortal {
	ConfigKey eventMacro_1_99_stage turn_rogue_getToNpc
	ConfigKey turn_rogue_getToNpc_type 2024
	QuestActive 2024, 2026
	priority 2
	timeout 10
	NotInMap in_rogue
	call MoveToHollgrehenPortal
}

macro MoveToHollgrehenPortal {
	do move cmd_fild09 335 143
}

automacro GotaTalkToHollgrehenPortal {
	ConfigKey eventMacro_1_99_stage turn_rogue_getToNpc
	ConfigKey turn_rogue_getToNpc_type 2024
	QuestActive 2024, 2026
	NpcMsg /(invadir o meu território|intrude my territory)/
	priority 0
	exclusive 1
	call TalkToHollgrehenPortal
}

macro TalkToHollgrehenPortal {
	do talk resp 0
	do talk resp 2
	do talk resp 4
	do talk resp 0
	release GotaMoveToHollgrehen
}

automacro GotaMoveToHollgrehen {
	ConfigKey eventMacro_1_99_stage turn_rogue_getToNpc
	ConfigKey turn_rogue_getToNpc_type 2024
	QuestActive 2024, 2026
	InMap in_rogue
	NpcNotNear /lgrehe/
	exclusive 1
	disabled 1
	call MoveToHollgrehen
}

macro MoveToHollgrehen {
	do move in_rogue 161 33
}

automacro GotaTalkToHollgrehen {
	ConfigKey eventMacro_1_99_stage turn_rogue_getToNpc
	ConfigKey turn_rogue_getToNpc_type 2024
	QuestActive 2024, 2026
	InMap in_rogue
	NpcNear /lgrehe/
	exclusive 1
	call TalkToHollgrehen
}

macro TalkToHollgrehen {
	lock GotaMoveToHollgrehen
	do talknpc &arg("$.NpcNearLastPos", 1) &arg("$.NpcNearLastPos", 2) r0
}

###############

#Labirinto
automacro DoMaze {
	ConfigKey eventMacro_1_99_stage turn_rogue_getToNpc
	exclusive 1
	IsInMapAndCoordinate in_rogue 15 105
	priority 0
	timeout 10
	call {
		[
		do conf -f attackAuto -1
		do conf -f attackCheckLOS 1
		do conf -f attackRouteMaxPathDistance 28
		do conf -f route_randomWalk 1
		
		do conf -f itemsTakeAuto 0
		do conf -f sellAuto 0
		do conf -f storageAuto 0
		
		do conf -f teleportAuto_minAggressives none
		do conf -f teleportAuto_hp none
		do conf -f teleportAuto_maxDmg none
		do conf -f teleportAuto_deadly 0
		
		do eval AI::clear(qw/storageAuto/)
		
		do conf -f eventMacro_1_99_stage turn_rogue_maze
		do move in_rogue 359 117
		]
	}
}

automacro InsideMaze {
	ConfigKey eventMacro_1_99_stage turn_rogue_maze
	InMap in_rogue
	priority 2
	exclusive 1
	call {
		do move in_rogue 359 117
	}
}

automacro DiedInMaze {
	ConfigKey eventMacro_1_99_stage turn_rogue_maze
	NotInMap in_rogue
	exclusive 1
	call {
		do conf -f attackAuto 2
		do conf -f itemsTakeAuto 2
		do conf -f attackCheckLOS 1
		do conf -f attackRouteMaxPathDistance 28
		do conf -f route_randomWalk 1
		
		do conf -f teleportAuto_minAggressives 4
		do conf -f teleportAuto_hp 10
		do conf -f teleportAuto_maxDmg 500
		do conf -f teleportAuto_deadly 1
		
		do conf -f sellAuto 1
		do conf -f storageAuto 1
		
		do conf -f eventMacro_1_99_stage turn_rogue_getToNpc_farming
	}
}

automacro EndMaze {
	ConfigKey eventMacro_1_99_stage turn_rogue_maze
	exclusive 1
	priority 0
	IsInMapAndCoordinate in_rogue 359 117
	run-once 1
	call {
		[
		do conf -f attackAuto 2
		do conf -f itemsTakeAuto 2
		do conf -f attackCheckLOS 1
		do conf -f attackRouteMaxPathDistance 28
		do conf -f route_randomWalk 1
		
		do conf -f teleportAuto_minAggressives 4
		do conf -f teleportAuto_hp 10
		do conf -f teleportAuto_maxDmg 500
		do conf -f teleportAuto_deadly 1
		
		do conf -f sellAuto 1
		do conf -f storageAuto 1
		
		do conf -f eventMacro_1_99_stage turn_rogue_end
		]
	}
}

automacro MovetoGuildsWomanEnd {
	ConfigKey eventMacro_1_99_stage turn_rogue_end
	JobID 6
	NpcNotNear /Arruaceira da Guilda|Rogue Guildsman/
	priority 1
	exclusive 1
	call {
		do move in_rogue 363 122
	}
}

automacro TalktoGuildsWomanEnd {
	NpcNear /Arruaceira da Guilda|Rogue Guildsman/
	ConfigKey eventMacro_1_99_stage turn_rogue_end
	JobID 6
	priority 1
	exclusive 1
	call {
		do talk $.NpcNearLastBinId
	}
}

automacro TurnRogueAfterEquipped {
	JobID 17
	priority 2
	exclusive 1
	call {
		do conf -f eventMacro_1_99_stage leveling
		
		include off Turn_Rogue.pm
		include on Leveling.pm
		
		do conf -f current_event_include Leveling.pm
		
		do reload eventMacros
	}
}