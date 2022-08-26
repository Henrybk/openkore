

## Rogue quest


automacro MovetoGuildsWoman {
	QuestInactive 2017
	exclusive 1
	ConfigKey eventMacro_1_99_stage turn_rogue_start
	NpcNotNear /Arruaceira da Guilda/
	priority 1
	call {
		do move in_rogue 363 122
	}
}

automacro TalktoGuildsWoman {
	QuestInactive 2017
	NpcNear /Arruaceira da Guilda/
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
	NpcMsg /E então, o que alguém jovem/
	call {
		do talk resp 0
	}
}

automacro AfterFailTalk {
	priority 0
	ConfigKey eventMacro_1_99_stage turn_rogue_start
	NpcMsg /Ok, você provavelmente fez tudo errado da última vez porque estava muito nervoso/
	call {
		do talk resp 0
	}
}

#########SET01
automacro RespQuestions01-01 {
	priority 0
	ConfigKey eventMacro_1_99_stage turn_rogue_start
	NpcMsg /Escolha a habilidade necessária para aprender Perseguir/
	call {
		do talk resp 0
	}
}


automacro RespQuestions01-02 {
	priority 0
	ConfigKey eventMacro_1_99_stage turn_rogue_start
	NpcMsg /Em comparação à habilidade Desconto/
	call {
		do talk resp 2
	}
}

automacro RespQuestions01-03 {
	priority 0
	ConfigKey eventMacro_1_99_stage turn_rogue_start
	NpcMsg /Qual é a descrição correta da habilidade Assaltar/
	call {
		do talk resp 2
	}
}


automacro RespQuestions01-04 {
	priority 0
	ConfigKey eventMacro_1_99_stage turn_rogue_start
	NpcMsg /ativar a habilidade Dissimulação/
	call {
		do talk resp 3
	}
}


automacro RespQuestions01-05 {
	priority 0
	ConfigKey eventMacro_1_99_stage turn_rogue_start
	NpcMsg /aprender no Nível 5 de Remover Elmo/
	call {
		do talk resp 3
	}
}


automacro RespQuestions01-06 {
	priority 0
	ConfigKey eventMacro_1_99_stage turn_rogue_start
	NpcMsg /permite que o personagem se mova enquanto estiver usando/
	call {
		do talk resp 2
	}
}


automacro RespQuestions01-07 {
	priority 0
	ConfigKey eventMacro_1_99_stage turn_rogue_start
	NpcMsg /Escolha a carta que aumenta a precisão/
	call {
		do talk resp 2
	}
}

automacro RespQuestions01-08 {
	priority 0
	ConfigKey eventMacro_1_99_stage turn_rogue_start
	NpcMsg /Escolha o monstro que sofre mais dano quando é atacado por uma arma/
	call {
		do talk resp 2
	}
}


automacro RespQuestions01-09 {
	priority 0
	ConfigKey eventMacro_1_99_stage turn_rogue_start
	NpcMsg /Quanto de SP a habilidade Ataque Duplo exige/
	call {
		do talk resp 1
	}
}


automacro RespQuestions01-10 {
	priority 0
	ConfigKey eventMacro_1_99_stage turn_rogue_start
	NpcMsg /Escolha a adaga mais eficiente para ser usada na Masmorra de Byalan/
	call {
		do talk resp 0
	}
}
############################






#########SET02
automacro RespQuestions02-01 {
	priority 0
	ConfigKey eventMacro_1_99_stage turn_rogue_start
	NpcMsg /Que monstro deixa cair um Gladius com slot/
	call {
		do talk resp 3
	}
}


automacro RespQuestions02-02 {
	priority 0
	ConfigKey eventMacro_1_99_stage turn_rogue_start
	NpcMsg /Que monstro deixa cair uma Main Gauche com slot/
	call {
		do talk resp 0
	}
}

automacro RespQuestions02-03 {
	priority 0
	ConfigKey eventMacro_1_99_stage turn_rogue_start
	NpcMsg /Escolha a classe capaz de criar poções únicas/
	call {
		do talk resp 1
	}
}


automacro RespQuestions02-04 {
	priority 0
	ConfigKey eventMacro_1_99_stage turn_rogue_start
	NpcMsg /Escolha a arma que os Arruaceiros não têm permissão para usar/
	call {
		do talk resp 3
	}
}


automacro RespQuestions02-05 {
	priority 0
	ConfigKey eventMacro_1_99_stage turn_rogue_start
	NpcMsg /Escolha a propriedade que o monstro Hode possui/
	call {
		do talk resp 3
	}
}


automacro RespQuestions02-06 {
	priority 0
	ConfigKey eventMacro_1_99_stage turn_rogue_start
	NpcMsg /Escolha o monstro que não pode ser domado para se tornar um Bichinho Fofinho/
	call {
		do talk resp 1
	}
}


automacro RespQuestions02-07 {
	priority 0
	ConfigKey eventMacro_1_99_stage turn_rogue_start
	NpcMsg /Escolha o monstro que sofre mais dano quando é atacado por uma Adaga com a propriedade Fogo/
	call {
		do talk resp 1
	}
}

automacro RespQuestions02-08 {
	priority 0
	ConfigKey eventMacro_1_99_stage turn_rogue_start
	NpcMsg /Escolha a cidade que não tem castelos de guilda/
	call {
		do talk resp 2
	}
}


automacro RespQuestions02-09 {
	priority 0
	ConfigKey eventMacro_1_99_stage turn_rogue_start
	NpcMsg /Escolha a planta que deixa cair Ervas Azuis/
	call {
		do talk resp 2
	}
}


automacro RespQuestions02-10 {
	priority 0
	ConfigKey eventMacro_1_99_stage turn_rogue_start
	NpcMsg /Escolha um monstro que não tem a propriedade Morto-vivo/
	call {
		do talk resp 2
	}
}
############################222













#########SET03
automacro RespQuestions03-01 {
	priority 0
	ConfigKey eventMacro_1_99_stage turn_rogue_start
	NpcMsg /Qual é o percentual de aumento da velocidade de fuga quando um Gatuno domina Perícia em Esquiva/
	call {
		do talk resp 0
	}
}


automacro RespQuestions03-02 {
	priority 0
	ConfigKey eventMacro_1_99_stage turn_rogue_start
	NpcMsg /Escolha o monstro que identifica quando o personagem está usando a habilidade Esconderijo ou Furtividade/
	call {
		do talk resp 0
	}
}

automacro RespQuestions03-03 {
	priority 0
	ConfigKey eventMacro_1_99_stage turn_rogue_start
	NpcMsg /Escolha o local onde os Gatunos podem passar para a classe Arruaceiro/
	call {
		do talk resp 2
	}
}


automacro RespQuestions03-04 {
	priority 0
	ConfigKey eventMacro_1_99_stage turn_rogue_start
	NpcMsg /Em qual cidade os Aprendizes podem passar para a classe Gatuno/
	call {
		do talk resp 3
	}
}


automacro RespQuestions03-05 {
	priority 0
	ConfigKey eventMacro_1_99_stage turn_rogue_start
	NpcMsg /Escolha a carta que não afeta o atributo DES/
	call {
		do talk resp 1
	}
}


automacro RespQuestions03-06 {
	priority 0
	ConfigKey eventMacro_1_99_stage turn_rogue_start
	NpcMsg /Por que ser um Arruaceiro é tão legal/
	call {
		do talk resp 3
	}
}


automacro RespQuestions03-07 {
	priority 0
	ConfigKey eventMacro_1_99_stage turn_rogue_start
	NpcMsg /Quando é possível passar da classe Gatuno para Arruaceiro/
	call {
		do talk resp 2
	}
}

automacro RespQuestions03-08 {
	priority 0
	ConfigKey eventMacro_1_99_stage turn_rogue_start
	NpcMsg /Você quer tingir o seu cabelo de azul. Para que cidade você vai e em qual direção/
	call {
		do talk resp 1
	}
}


automacro RespQuestions03-09 {
	priority 0
	ConfigKey eventMacro_1_99_stage turn_rogue_start
	NpcMsg /Escolha o cogumelo necessário à missão para mudar para a classe Gatuno/
	call {
		do talk resp 0
	}
}


automacro RespQuestions03-10 {
	priority 0
	ConfigKey eventMacro_1_99_stage turn_rogue_start
	NpcMsg /Escolha a carta que menos beneficia a classe Arruaceiro/
	call {
		do talk resp 1
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

automacro GotFirstSet {
	exclusive 1
	QuestActive 2018
	ConfigKey eventMacro_1_99_stage turn_rogue_items
	priority 1
	run-once 1
	call set_first_set_configs
}

macro set_first_set_configs {
	[
	$id = 510
	$quant = 6
	call set_getauto_x
	
	
	$id = 932
	$quant = 10
	call set_getauto_x
	
	
	$id = 957
	$quant = 10
	call set_getauto_x
	
	
	$id = 958
	$quant = 10
	call set_getauto_x
	
	$id = undef
	$quant = undef
	$name = undef
	$nextFreeGetAutoSlot = undef
	
	do conf -f eventMacro_1_99_stage turn_rogue_collect
	]
	do autostorage
}

macro set_getauto_x {
	$name = GetNamebyNameID("$id")
	$nextFreeGetAutoSlot = get_free_slot_index_for_key("getAuto","$name")
	do iconf $id $quant 1 0
	do pconf $id 2
	do conf -f getAuto_$nextFreeGetAutoSlot $name
	do conf -f getAuto_$nextFreeGetAutoSlot_minAmount &eval($quant-1)
	do conf -f getAuto_$nextFreeGetAutoSlot_maxAmount $quant
	do conf -f getAuto_$nextFreeGetAutoSlot_passive 1
}

automacro checkItemsMapsFirst {
	timeout 60
	exclusive 1
	priority 2
	QuestActive 2018
	ConfigKey eventMacro_1_99_stage turn_rogue_collect
	call OrganizeItemsGatherFirstSet
}

macro SetVarFirstSet {
	$configlockMap = &config(lockMap)
	$configsaveMap = &config(saveMap)
	
	if (config_time_not_set("turn_rogue_shopping_end_time") = 1) {
		do conf -f turn_rogue_shopping_end_time $.time
	}

	$ervaAzul = GetNamebyNameID(510)
	$ervaAzul = &invamount($ervaAzul)
	
	$osso = GetNamebyNameID(932)
	$osso = &invamount($osso)
	
	$unhaApodrecida = GetNamebyNameID(957)
	$unhaApodrecida = &invamount($unhaApodrecida)
	
	$mandibulaHorrenda = GetNamebyNameID(958)
	$mandibulaHorrenda = &invamount($mandibulaHorrenda)
}

macro OrganizeItemsGatherFirstSet {
	call SetVarFirstSet
	
	if (&config(adjustRoutes_last) != $.lvl) {
		do adjustRoutes $.lvl
		do conf -f adjustRoutes_last $.lvl
	}
	
	if (check_tickets_and_potions() = 1) {
		log Creating novice
		# Make novices
		$slot = find_free_slot()
		if ($slot != -1) {
			log New slot is $slot
			call create_novice
		} else {
			log Could not find a free slot
		}
		
	} elsif (&config(doing_novice) = 1) {
		log Return from creating novice
		do conf -f doing_novice 0
		do dcstop remove_last
		delete_novice()
		do autostorage
		stop
	}
	
	if ($ervaAzul < 6 || ($mandibulaHorrenda < 7 && $.zeny < 15000) || ($mandibulaHorrenda >= 10 && $.zeny < 10000)) {
		if ($configlockMap != cmd_fild02) {
			do mconf 1073 0 0 0
			do mconf 1391 0 0 0
			do mconf 1317 1 0 0
			do mconf 1226 0 0 0
			do mconf 1074 0 0 0
			do mconf 1313 0 0 0
			do iconf 7053 0 0 1
			do pconf 7053 2
			do iconf 912 0 0 1
			do conf -f lockMap cmd_fild02
			call get_best_savepoint
		}
	
	} elsif ($mandibulaHorrenda < 10 && $.zeny >= 2000 && time_passed("&config(turn_rogue_shopping_end_time)", "3600") = 1) {
		call set_shopper_rogue
		stop
	
	} elsif ($osso < 10 || $unhaApodrecida < 10 || $mandibulaHorrenda < 10) {
		if ($osso >= 10) {
			do mconf 1076 0 0 0
		}
		if ($configlockMap != pay_dun00) {
			do mconf 1015 1 0 0
			do mconf 1076 1 0 0
			do mconf 1031 0 0 0
			do mconf 1005 0 0 0
			do conf -f lockMap pay_dun00
			call get_best_savepoint
		}
		
	} else {
		do conf -f lockMap none
		do conf -f eventMacro_1_99_stage turn_rogue_deliver
	}
}

macro create_novice {
	$profile = set_novice_folder("$slot")
	log Profile name will be $profile
	do conf -f deleteCharacter 0
	do conf -f characterToDelete 0

	do conf -f createCharacter 1
	do conf -f characterToCreate $slot

	do conf -f loginCharacter 1
	do conf -f characterToLogin $slot

	do conf -f characterToCreateInfo 9 9 1 1 9 1 2 3
	
	do conf -f doing_novice 1
	
	$char = &config(char)
	
	do activateCDaL
	
	do conf -f char $char
	
	do changeProfile &config(username)_novice
}

macro set_shopper_rogue {
	[
	do conf -f eventMacro_1_99_stage turn_rogue_shopping
	
	$mandName = GetNamebyNameID(958)
	
	$neededAmount = &eval(10 - &invamount($mandibulaHorrenda))
	
	do conf -f shopper_0 $mandName
	do conf -f shopper_0_maxPrice 2100
	do conf -f shopper_0_maxAmount $neededAmount
	do conf -f shopper_0_disabled 0
	do conf -f shopper_on 1
	
	do conf -f turn_rogue_shopping_start_time $.time
	
	do conf -f route_randomWalk_inTown 1
	
	do conf -f lockMap prontera
	call get_best_savepoint
	]
}

automacro set_shopper_on {
	exclusive 1
	ConfigKey eventMacro_1_99_stage turn_rogue_shopping
	ConfigKeyNot shopper_on 1
	priority 0
	call {
		do conf -f shopper_on 1
	}
}

automacro set_shopper_off {
	exclusive 1
	ConfigKeyNot eventMacro_1_99_stage turn_rogue_shopping
	ConfigKeyNot shopper_on 0
	priority 0
	call {
		do conf -f shopper_on 0
	}
}

automacro check_rogue_shopping {
	timeout 360
	ConfigKey eventMacro_1_99_stage turn_rogue_shopping
	exclusive 1
	priority 2
	call check_shopping
}

macro check_shopping {
	[
	$starttime = &config(turn_rogue_shopping_start_time)
	$endtime = &eval($starttime + 3600)
	$mandibulaHorrenda = GetNamebyNameID(958)
	$mandibulaHorrenda = &invamount($mandibulaHorrenda)
	
	if ($mandibulaHorrenda >= 10 || $endtime < $.time || $.zeny < 2000) {
		do conf -f route_randomWalk_inTown 0
		do conf -f eventMacro_1_99_stage turn_rogue_collect
		do conf -f turn_rogue_shopping_end_time $.time
		do conf -f lockMap none
		do conf -f shopper_on 0
	}
	]
}

automacro moveSmithratoCompleteQuest {
	exclusive 1
	QuestActive 2018
	ConfigKey eventMacro_1_99_stage turn_rogue_deliver
	NpcNotNear /Smith/
	priority 1
	call {
		do move in_rogue 375 25
	}
}

automacro talkSmithratoCompleteQuest {
	exclusive 1
	QuestActive 2018
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
		do conf -f eventMacro_1_99_stage turn_rogue_getToNpc
		do conf -f turn_rogue_getToNpc_type $.QuestActiveLastID
		do relog
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
	NpcMsg /invadir o meu territ/
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
	NpcMsg /invadir o meu território/
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
	NpcMsg /invadir o meu território/
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
	priority -25
	timeout 10
	call {
		[
		do conf -f attackAuto 0
		do conf -f attackAuto_party 0
		do conf -f attackAuto_onlyWhenSafe 1
		do conf -f attackAuto_followTarget 0
		do conf -f attackUseWeapon 0
		do conf -f attackChangeTarget 0
		do conf -f route_randomWalk 0
		do conf -f eventMacro_1_99_stage turn_rogue_maze
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
		do conf -f attackAuto_party 1
		do conf -f attackAuto_onlyWhenSafe 0
		do conf -f attackAuto_followTarget 1
		do conf -f attackUseWeapon 1
		do conf -f attackChangeTarget 1
		do conf -f route_randomWalk 1
		do conf -f eventMacro_1_99_stage turn_rogue_getToNpc
	}
}

automacro EndMaze {
	ConfigKey eventMacro_1_99_stage turn_rogue_maze
	exclusive 1
	priority 0
	IsInMapAndCoordinate in_rogue 359 117
	run-once 1
	call {
		do conf -f attackAuto 2
		do conf -f attackAuto_party 1
		do conf -f attackAuto_onlyWhenSafe 0
		do conf -f attackAuto_followTarget 1
		do conf -f attackUseWeapon 1
		do conf -f attackChangeTarget 1
		do conf -f route_randomWalk 1
		do conf -f eventMacro_1_99_stage turn_rogue_end
	}
}

automacro MovetoGuildsWomanEnd {
	ConfigKey eventMacro_1_99_stage turn_rogue_end
	JobID 6
	NpcNotNear /Arruaceira da Guilda/
	priority 1
	exclusive 1
	call {
		do move in_rogue 363 122
	}
}

automacro TalktoGuildsWomanEnd {
	NpcNear /Arruaceira da Guilda/
	ConfigKey eventMacro_1_99_stage turn_rogue_end
	JobID 6
	priority 1
	exclusive 1
	call {
		set_equips_in_config()
		do talk $.NpcNearLastBinId
	}
}

sub set_equips_in_config {
	foreach my $slot (keys %{$char->{equipment}}) {
		my $equipment = $char->{equipment}{$slot};
		my $was_equipped_id = $equipment->{nameID};
		configModify('to_be_equipped_'.$slot, "$was_equipped_id");
	}
}

automacro ChangedToRogue {
	ConfigKey eventMacro_1_99_stage turn_rogue_end
	JobID 17
	priority 1
	exclusive 1
	run-once 1
	call {
		[
		do conf -f equipItems_stage_before &config(eventMacro_1_99_stage)
		do conf -f eventMacro_1_99_stage equipping_items
		]
	}
}

automacro TurnRogueAfterEquipped {
	ConfigKey eventMacro_1_99_stage turn_rogue_end
	JobID 17
	priority 2
	exclusive 1
	run-once 1
	call {
		do conf -f skillsAddAuto_list RG_SNATCHER 10, RG_STEALCOIN 10, RG_BACKSTAP 4, RG_TUNNELDRIVE 5, RG_RAID 5, RG_INTIMIDATE 5, RG_PLAGIARISM 10
		do conf -f eventMacro_1_99_stage leveling
		
		include off Turn_Rogue.pm
		include on Main.pm
		include on Wait_Steal_Coin_level.pm
		
		do conf -f current_event_include Main.pm
		
		do reload eventMacros
	}
}