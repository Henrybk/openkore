
macro knight_set_buyauto_equipment {
	[
	$currentZeny = $.zeny
	call knight_set_buyauto_weapon
	call knight_set_buyauto_armor
	call knight_set_buyauto_shoes
	call knight_set_buyauto_robe
	call knight_set_buyauto_topHead
	]
}

macro knight_set_buyauto_weapon {
	call knight_set_Katana
	call knight_set_Scimiter
	call knight_set_TwoHandedSword
	[
	if ($TwoHandedSwordEquipped == 1) {
		log TwoHandedSword is equipped DAMNN
		
	} elsif ($ScimiterEquipped == 1 && $TwoHandedSwordCanEquip == 0) {
		log Scimiter is equipped and cannot equip TwoHandedSword DAMNN
		
	} elsif ($ScimiterEquipped == 1 && $TwoHandedSwordCanEquip == 1 && $TwoHandedSwordCanBuy == 0) {
		log Scimiter is equipped, can equip TwoHandedSword but cannot buy it DAMNN
		
	} elsif ($KatanaEquipped == 1 && $TwoHandedSwordCanEquip == 0 && $ScimiterCanEquip == 0) {
		log Katana is equipped and cannot equip TwoHandedSword or Scimiter DAMNN
		
	} elsif ($KatanaEquipped == 1 && ($TwoHandedSwordCanEquip == 1 || $ScimiterCanEquip == 1) && $TwoHandedSwordCanBuy == 0 && $ScimiterCanBuy == 0) {
		log Katana is equipped, can equip better stuff but not buy it DAMNN
		
	} elsif ($KatanaEquipped == 0 && $KatanaCanBuy == 0) {
		log Katana is not equipped, cannot buy it
		
	} elsif ($TwoHandedSwordEquipped == 0 && $TwoHandedSwordCanEquip == 1 && $TwoHandedSwordHas >= 1) {
		call clear_Katana_buyAuto
		call clear_Scimiter_buyAuto
		$name = GetNamebyNameID(1157)
		log Setting equipauto $name
		do iconf 1116 0 0 1
		do iconf 1113 0 0 1
		do iconf 1157 1 0 0
		do conf -f equipAuto_0_rightHand GetNamebyNameID(1157)
		
	} elsif ($TwoHandedSwordEquipped == 0 && $TwoHandedSwordCanEquip == 1 && $TwoHandedSwordHas == 0 && $TwoHandedSwordCanBuy == 1) {
		call clear_Katana_buyAuto
		call clear_Scimiter_buyAuto
		$name = GetNamebyNameID(1157)
		log Setting buyAuto $name
		$nextFreeSlot = get_free_slot_index_for_key("buyAuto","$name")
		do conf -f buyAuto_$nextFreeSlot $name
		do conf -f buyAuto_$nextFreeSlot_npc izlude_in 60 127
		do conf -f buyAuto_$nextFreeSlot_minAmount 0
		do conf -f buyAuto_$nextFreeSlot_maxAmount 1
		do conf -f buyAuto_$nextFreeSlot_minDistance 1
		do conf -f buyAuto_$nextFreeSlot_maxDistance 10
		do conf -f buyAuto_$nextFreeSlot_zeny > 65000
		$currentZeny = $currentZeny - 65000
		
	} elsif ($TwoHandedSwordCanEquip == 0 && $ScimiterEquipped == 0 && $ScimiterCanEquip == 1 && $ScimiterHas >= 1) {
		call clear_Katana_buyAuto
		$name = GetNamebyNameID(1157)
		log Setting equipauto $name
		do iconf 1116 0 0 1
		do iconf 1113 1 0 0
		do conf -f equipAuto_0_rightHand GetNamebyNameID(1113)
		
	} elsif ($TwoHandedSwordCanEquip == 0 && $ScimiterEquipped == 0 && $ScimiterCanEquip == 1 && $ScimiterHas == 0 && $ScimiterCanBuy == 1) {
		call clear_Katana_buyAuto
		$name = GetNamebyNameID(1113)
		log Setting buyAuto $name
		$nextFreeSlot = get_free_slot_index_for_key("buyAuto","$name")
		do conf -f buyAuto_$nextFreeSlot $name
		do conf -f buyAuto_$nextFreeSlot_npc prt_in 172 130
		do conf -f buyAuto_$nextFreeSlot_minAmount 0
		do conf -f buyAuto_$nextFreeSlot_maxAmount 1
		do conf -f buyAuto_$nextFreeSlot_minDistance 1
		do conf -f buyAuto_$nextFreeSlot_maxDistance 10
		do conf -f buyAuto_$nextFreeSlot_zeny > 20000
		$currentZeny = $currentZeny - 20000
		
	} elsif ($TwoHandedSwordCanEquip == 0 && $ScimiterCanEquip == 0 && $KatanaEquipped == 0 && $KatanaCanEquip == 1 && $KatanaHas >= 1) {
		$name = GetNamebyNameID(1116)
		log Setting equipauto $name
		do iconf 1116 1 0 0
		do conf -f equipAuto_0_rightHand GetNamebyNameID(1116)
		
	} elsif ($TwoHandedSwordCanEquip == 0 && $ScimiterCanEquip == 0 && $KatanaEquipped == 0 && $KatanaCanEquip == 1 && $KatanaHas == 0 && $KatanaCanBuy == 1) {
		$name = GetNamebyNameID(1116)
		log Setting buyAuto $name
		$nextFreeSlot = get_free_slot_index_for_key("buyAuto","$name")
		do conf -f buyAuto_$nextFreeSlot $name
		do conf -f buyAuto_$nextFreeSlot_npc prt_in 172 130
		do conf -f buyAuto_$nextFreeSlot_minAmount 0
		do conf -f buyAuto_$nextFreeSlot_maxAmount 1
		do conf -f buyAuto_$nextFreeSlot_minDistance 1
		do conf -f buyAuto_$nextFreeSlot_maxDistance 10
		do conf -f buyAuto_$nextFreeSlot_zeny > 2500
		$currentZeny = $currentZeny - 2500
	}
	]
}

macro knight_set_Katana {
	[
	$KatanaHas = &invamount(1116)
	$KatanaEquipped = isEquippedInSlotNameID('rightHand', '1116')
	if ($.lvl >= 4) {
		$KatanaCanEquip = 1
	} else {
		$KatanaCanEquip = 0
	}
	if ($currentZeny >= 2500) {
		$KatanaCanBuy = 1
	} else {
		$KatanaCanBuy = 0
	}
	]
}

macro clear_Katana_buyAuto {
	[
	$name = GetNamebyNameID(1116)
	log Clearing buyAuto $name
	$foundSlot = get_free_slot_index_for_key("buyAuto","$name")
	do conf -f buyAuto_$foundSlot none
	]
}

macro knight_set_Scimiter {
	[
	$ScimiterHas = &invamount(1113)
	$ScimiterEquipped = isEquippedInSlotNameID('rightHand', '1113')
	if ($.lvl >= 14) {
		$ScimiterCanEquip = 1
	} else {
		$ScimiterCanEquip = 0
	}
	if ($currentZeny >= 20000) {
		$ScimiterCanBuy = 1
	} else {
		$ScimiterCanBuy = 0
	}
	]
}

macro clear_Scimiter_buyAuto {
	[
	$name = GetNamebyNameID(1113)
	log Clearing buyAuto $name
	$foundSlot = get_free_slot_index_for_key("buyAuto","$name")
	do conf -f buyAuto_$foundSlot none
	]
}

macro knight_set_TwoHandedSword {
	[
	$TwoHandedSwordHas = &invamount(1157)
	$TwoHandedSwordEquipped = isEquippedInSlotNameID('rightHand', '1157')
	if ($.lvl >= 33) {
		$TwoHandedSwordCanEquip = 1
	} else {
		$TwoHandedSwordCanEquip = 0
	}
	if ($currentZeny >= 65000) {
		$TwoHandedSwordCanBuy = 1
	} else {
		$TwoHandedSwordCanBuy = 0
	}
	]
}

macro knight_set_buyauto_armor {
	call knight_set_AdventureSuit
	call knight_set_PaddedArmor
	call knight_set_PlateArmor
	[
	if ($PlateArmorEquipped == 1) {
		log PlateArmor is equipped DAMNN
		
	} elsif ($PaddedArmorEquipped == 1 && $PlateArmorCanEquip == 0) {
		log PaddedArmor is equipped and cannot equip PlateArmor DAMNN
		
	} elsif ($PaddedArmorEquipped == 1 && $PlateArmorCanEquip == 1 && $PlateArmorCanBuy == 0) {
		log PaddedArmor is equipped, can equip PlateArmor but cannot buy it DAMNN
		
	} elsif ($AdventureSuitEquipped == 1 && $PlateArmorCanEquip == 0 && $PaddedArmorCanEquip == 0) {
		log AdventureSuit is equipped and cannot equip PlateArmor or PaddedArmor DAMNN
		
	} elsif ($AdventureSuitEquipped == 1 && ($PlateArmorCanEquip == 1 || $PaddedArmorCanEquip == 1) && $PlateArmorCanBuy == 0 && $PaddedArmorCanBuy == 0) {
		log AdventureSuit is equipped, can equip better stuff but not buy it DAMNN
		
	} elsif ($AdventureSuitEquipped == 0 && $AdventureSuitCanBuy == 0) {
		log AdventureSuit is not equipped, cannot buy it
		
	} elsif ($PlateArmorEquipped == 0 && $PlateArmorCanEquip == 1 && $PlateArmorHas >= 1) {
		call clear_AdventureSuit_buyAuto
		call clear_PaddedArmor_buyAuto
		$name = GetNamebyNameID(2316)
		log Setting equipauto $name
		do iconf 2305 0 0 1
		do iconf 2312 0 0 1
		do iconf 2316 1 0 0
		do conf -f equipAuto_0_armor GetNamebyNameID(2316)
		
	} elsif ($PlateArmorEquipped == 0 && $PlateArmorCanEquip == 1 && $PlateArmorHas == 0 && $PlateArmorCanBuy == 1) {
		call clear_AdventureSuit_buyAuto
		call clear_PaddedArmor_buyAuto
		$name = GetNamebyNameID(2316)
		log Setting buyAuto $name
		$nextFreeSlot = get_free_slot_index_for_key("buyAuto","$name")
		do conf -f buyAuto_$nextFreeSlot $name
		do conf -f buyAuto_$nextFreeSlot_npc izlude_in 70 127
		do conf -f buyAuto_$nextFreeSlot_minAmount 0
		do conf -f buyAuto_$nextFreeSlot_maxAmount 1
		do conf -f buyAuto_$nextFreeSlot_minDistance 1
		do conf -f buyAuto_$nextFreeSlot_maxDistance 10
		do conf -f buyAuto_$nextFreeSlot_zeny > 85000
		$currentZeny = $currentZeny - 85000
		
	} elsif ($PlateArmorCanEquip == 0 && $PaddedArmorEquipped == 0 && $PaddedArmorCanEquip == 1 && $PaddedArmorHas >= 1) {
		call clear_AdventureSuit_buyAuto
		$name = GetNamebyNameID(2316)
		log Setting equipauto $name
		do iconf 2305 0 0 1
		do iconf 2312 1 0 0
		do conf -f equipAuto_0_armor GetNamebyNameID(2312)
		
	} elsif ($PlateArmorCanEquip == 0 && $PaddedArmorEquipped == 0 && $PaddedArmorCanEquip == 1 && $PaddedArmorHas == 0 && $PaddedArmorCanBuy == 1) {
		call clear_AdventureSuit_buyAuto
		$name = GetNamebyNameID(2312)
		log Setting buyAuto $name
		$nextFreeSlot = get_free_slot_index_for_key("buyAuto","$name")
		do conf -f buyAuto_$nextFreeSlot $name
		do conf -f buyAuto_$nextFreeSlot_npc prt_in 172 132
		do conf -f buyAuto_$nextFreeSlot_minAmount 0
		do conf -f buyAuto_$nextFreeSlot_maxAmount 1
		do conf -f buyAuto_$nextFreeSlot_minDistance 1
		do conf -f buyAuto_$nextFreeSlot_maxDistance 10
		do conf -f buyAuto_$nextFreeSlot_zeny > 50000
		$currentZeny = $currentZeny - 50000
		
	} elsif ($PlateArmorCanEquip == 0 && $PaddedArmorCanEquip == 0 && $AdventureSuitEquipped == 0 && $AdventureSuitCanEquip == 1 && $AdventureSuitHas >= 1) {
		$name = GetNamebyNameID(2305)
		log Setting equipauto $name
		do iconf 2305 1 0 0
		do conf -f equipAuto_0_armor GetNamebyNameID(2305)
		
	} elsif ($PlateArmorCanEquip == 0 && $PaddedArmorCanEquip == 0 && $AdventureSuitEquipped == 0 && $AdventureSuitCanEquip == 1 && $AdventureSuitHas == 0 && $AdventureSuitCanBuy == 1) {
		$name = GetNamebyNameID(2305)
		log Setting buyAuto $name
		$nextFreeSlot = get_free_slot_index_for_key("buyAuto","$name")
		do conf -f buyAuto_$nextFreeSlot $name
		do conf -f buyAuto_$nextFreeSlot_npc prt_in 172 132
		do conf -f buyAuto_$nextFreeSlot_minAmount 0
		do conf -f buyAuto_$nextFreeSlot_maxAmount 1
		do conf -f buyAuto_$nextFreeSlot_minDistance 1
		do conf -f buyAuto_$nextFreeSlot_maxDistance 10
		do conf -f buyAuto_$nextFreeSlot_zeny > 1500
		$currentZeny = $currentZeny - 1500
	}
	]
}

macro knight_set_AdventureSuit {
	[
	$AdventureSuitHas = &invamount(2305)
	$AdventureSuitEquipped = isEquippedInSlotNameID('armor', '2305')
	if ($.lvl >= 4) {
		$AdventureSuitCanEquip = 1
	} else {
		$AdventureSuitCanEquip = 0
	}
	if ($currentZeny >= 1500) {
		$AdventureSuitCanBuy = 1
	} else {
		$AdventureSuitCanBuy = 0
	}
	]
}

macro clear_AdventureSuit_buyAuto {
	[
	$name = GetNamebyNameID(2305)
	log Clearing buyAuto $name
	$foundSlot = get_free_slot_index_for_key("buyAuto","$name")
	do conf -f buyAuto_$foundSlot none
	]
}

macro knight_set_PaddedArmor {
	[
	$PaddedArmorHas = &invamount(2312)
	$PaddedArmorEquipped = isEquippedInSlotNameID('armor', '2312')
	if ($.lvl >= 14) {
		$PaddedArmorCanEquip = 1
	} else {
		$PaddedArmorCanEquip = 0
	}
	if ($currentZeny >= 50000) {
		$PaddedArmorCanBuy = 1
	} else {
		$PaddedArmorCanBuy = 0
	}
	]
}

macro clear_PaddedArmor_buyAuto {
	[
	$name = GetNamebyNameID(2312)
	log Clearing buyAuto $name
	$foundSlot = get_free_slot_index_for_key("buyAuto","$name")
	do conf -f buyAuto_$foundSlot none
	]
}

macro knight_set_PlateArmor {
	[
	$PlateArmorHas = &invamount(2316)
	$PlateArmorEquipped = isEquippedInSlotNameID('armor', '2316')
	if ($.lvl >= 33) {
		$PlateArmorCanEquip = 1
	} else {
		$PlateArmorCanEquip = 0
	}
	if ($currentZeny >= 85000) {
		$PlateArmorCanBuy = 1
	} else {
		$PlateArmorCanBuy = 0
	}
	]
}
macro knight_set_buyauto_shoes {
	call knight_set_Sandals
	call knight_set_Shoes
	call knight_set_Boots
	[
	if ($BootsEquipped == 1) {
		log Boots is equipped DAMNN
		
	} elsif ($ShoesEquipped == 1 && $BootsCanEquip == 0) {
		log Shoes is equipped and cannot equip Boots DAMNN
		
	} elsif ($ShoesEquipped == 1 && $BootsCanEquip == 1 && $BootsCanBuy == 0) {
		log Shoes is equipped, can equip Boots but cannot buy it DAMNN
		
	} elsif ($SandalsEquipped == 1 && $BootsCanEquip == 0 && $ShoesCanEquip == 0) {
		log Sandals is equipped and cannot equip Boots or Shoes DAMNN
		
	} elsif ($SandalsEquipped == 1 && ($BootsCanEquip == 1 || $ShoesCanEquip == 1) && $BootsCanBuy == 0 && $ShoesCanBuy == 0) {
		log Sandals is equipped, can equip better stuff but not buy it DAMNN
		
	} elsif ($SandalsEquipped == 0 && $SandalsCanBuy == 0) {
		log Sandals is not equipped, cannot buy it
		
	} elsif ($BootsEquipped == 0 && $BootsCanEquip == 1 && $BootsHas >= 1) {
		call clear_Sandals_buyAuto
		call clear_Shoes_buyAuto
		$name = GetNamebyNameID(2405)
		log Setting equipauto $name
		do iconf 2401 0 0 1
		do iconf 2403 0 0 1
		do iconf 2405 1 0 0
		do conf -f equipAuto_0_shoes GetNamebyNameID(2405)
		
	} elsif ($BootsEquipped == 0 && $BootsCanEquip == 1 && $BootsHas == 0 && $BootsCanBuy == 1) {
		call clear_Sandals_buyAuto
		call clear_Shoes_buyAuto
		$name = GetNamebyNameID(2405)
		log Setting buyAuto $name
		$nextFreeSlot = get_free_slot_index_for_key("buyAuto","$name")
		do conf -f buyAuto_$nextFreeSlot $name
		do conf -f buyAuto_$nextFreeSlot_npc izlude_in 70 127
		do conf -f buyAuto_$nextFreeSlot_minAmount 0
		do conf -f buyAuto_$nextFreeSlot_maxAmount 1
		do conf -f buyAuto_$nextFreeSlot_minDistance 1
		do conf -f buyAuto_$nextFreeSlot_maxDistance 10
		do conf -f buyAuto_$nextFreeSlot_zeny > 20000
		$currentZeny = $currentZeny - 20000
		
	} elsif ($BootsCanEquip == 0 && $ShoesEquipped == 0 && $ShoesCanEquip == 1 && $ShoesHas >= 1) {
		call clear_Sandals_buyAuto
		$name = GetNamebyNameID(2405)
		log Setting equipauto $name
		do iconf 2401 0 0 1
		do iconf 2403 1 0 0
		do conf -f equipAuto_0_shoes GetNamebyNameID(2403)
		
	} elsif ($BootsCanEquip == 0 && $ShoesEquipped == 0 && $ShoesCanEquip == 1 && $ShoesHas == 0 && $ShoesCanBuy == 1) {
		call clear_Sandals_buyAuto
		$name = GetNamebyNameID(2403)
		log Setting buyAuto $name
		$nextFreeSlot = get_free_slot_index_for_key("buyAuto","$name")
		do conf -f buyAuto_$nextFreeSlot $name
		do conf -f buyAuto_$nextFreeSlot_npc prt_in 172 132
		do conf -f buyAuto_$nextFreeSlot_minAmount 0
		do conf -f buyAuto_$nextFreeSlot_maxAmount 1
		do conf -f buyAuto_$nextFreeSlot_minDistance 1
		do conf -f buyAuto_$nextFreeSlot_maxDistance 10
		do conf -f buyAuto_$nextFreeSlot_zeny > 4000
		$currentZeny = $currentZeny - 4000
		
	} elsif ($BootsCanEquip == 0 && $ShoesCanEquip == 0 && $SandalsEquipped == 0 && $SandalsCanEquip == 1 && $SandalsHas >= 1) {
		$name = GetNamebyNameID(2401)
		log Setting equipauto $name
		do iconf 2401 1 0 0
		do conf -f equipAuto_0_shoes GetNamebyNameID(2401)
		
	} elsif ($BootsCanEquip == 0 && $ShoesCanEquip == 0 && $SandalsEquipped == 0 && $SandalsCanEquip == 1 && $SandalsHas == 0 && $SandalsCanBuy == 1) {
		$name = GetNamebyNameID(2401)
		log Setting buyAuto $name
		$nextFreeSlot = get_free_slot_index_for_key("buyAuto","$name")
		do conf -f buyAuto_$nextFreeSlot $name
		do conf -f buyAuto_$nextFreeSlot_npc prt_in 172 132
		do conf -f buyAuto_$nextFreeSlot_minAmount 0
		do conf -f buyAuto_$nextFreeSlot_maxAmount 1
		do conf -f buyAuto_$nextFreeSlot_minDistance 1
		do conf -f buyAuto_$nextFreeSlot_maxDistance 10
		do conf -f buyAuto_$nextFreeSlot_zeny > 500
		$currentZeny = $currentZeny - 500
	}
	]
}

macro knight_set_Sandals {
	[
	$SandalsHas = &invamount(2401)
	$SandalsEquipped = isEquippedInSlotNameID('shoes', '2401')
	if ($.lvl >= 4) {
		$SandalsCanEquip = 1
	} else {
		$SandalsCanEquip = 0
	}
	if ($currentZeny >= 500) {
		$SandalsCanBuy = 1
	} else {
		$SandalsCanBuy = 0
	}
	]
}

macro clear_Sandals_buyAuto {
	[
	$name = GetNamebyNameID(2401)
	log Clearing buyAuto $name
	$foundSlot = get_free_slot_index_for_key("buyAuto","$name")
	do conf -f buyAuto_$foundSlot none
	]
}

macro knight_set_Shoes {
	[
	$ShoesHas = &invamount(2403)
	$ShoesEquipped = isEquippedInSlotNameID('shoes', '2403')
	if ($.lvl >= 14) {
		$ShoesCanEquip = 1
	} else {
		$ShoesCanEquip = 0
	}
	if ($currentZeny >= 4000) {
		$ShoesCanBuy = 1
	} else {
		$ShoesCanBuy = 0
	}
	]
}

macro clear_Shoes_buyAuto {
	[
	$name = GetNamebyNameID(2403)
	log Clearing buyAuto $name
	$foundSlot = get_free_slot_index_for_key("buyAuto","$name")
	do conf -f buyAuto_$foundSlot none
	]
}

macro knight_set_Boots {
	[
	$BootsHas = &invamount(2405)
	$BootsEquipped = isEquippedInSlotNameID('shoes', '2405')
	if ($.lvl >= 33) {
		$BootsCanEquip = 1
	} else {
		$BootsCanEquip = 0
	}
	if ($currentZeny >= 20000) {
		$BootsCanBuy = 1
	} else {
		$BootsCanBuy = 0
	}
	]
}

macro knight_set_buyauto_robe {
	call knight_set_Muffler
	call knight_set_Manteau
	[
	if ($ManteauEquipped == 1) {
		log Manteau is equipped DAMNN
		
	} elsif ($MufflerEquipped == 1 && $ManteauCanEquip == 0) {
		log Muffler is equipped and cannot equip Manteau
		
	} elsif ($MufflerEquipped == 1 && $ManteauCanEquip == 1 && $ManteauCanBuy == 0) {
		log Muffler is equipped, can equip better stuff but not buy it DAMNN
		
	} elsif ($MufflerEquipped == 0 && $MufflerCanBuy == 0) {
		log Muffler is not equipped, cannot buy it
		
	} elsif ($ManteauEquipped == 0 && $ManteauCanEquip == 1 && $ManteauHas >= 1) {
		call clear_Muffler_buyAuto
		$name = GetNamebyNameID(2505)
		log Setting equipauto $name
		do iconf 2503 0 0 1
		do iconf 2312 0 0 1
		do iconf 2505 1 0 0
		do conf -f equipAuto_0_robe GetNamebyNameID(2505)
		
	} elsif ($ManteauEquipped == 0 && $ManteauCanEquip == 1 && $ManteauHas == 0 && $ManteauCanBuy == 1) {
		call clear_Muffler_buyAuto
		$name = GetNamebyNameID(2505)
		log Setting buyAuto $name
		$nextFreeSlot = get_free_slot_index_for_key("buyAuto","$name")
		do conf -f buyAuto_$nextFreeSlot $name
		do conf -f buyAuto_$nextFreeSlot_npc izlude_in 70 127
		do conf -f buyAuto_$nextFreeSlot_minAmount 0
		do conf -f buyAuto_$nextFreeSlot_maxAmount 1
		do conf -f buyAuto_$nextFreeSlot_minDistance 1
		do conf -f buyAuto_$nextFreeSlot_maxDistance 10
		do conf -f buyAuto_$nextFreeSlot_zeny > 35000
		$currentZeny = $currentZeny - 35000
		
	} elsif ($ManteauCanEquip == 0 && $MufflerEquipped == 0 && $MufflerCanEquip == 1 && $MufflerHas >= 1) {
		$name = GetNamebyNameID(2503)
		log Setting equipauto $name
		do iconf 2503 1 0 0
		do conf -f equipAuto_0_robe GetNamebyNameID(2503)
		
	} elsif ($ManteauCanEquip == 0 && $MufflerEquipped == 0 && $MufflerCanEquip == 1 && $MufflerHas == 0 && $MufflerCanBuy == 1) {
		$name = GetNamebyNameID(2503)
		log Setting buyAuto $name
		$nextFreeSlot = get_free_slot_index_for_key("buyAuto","$name")
		do conf -f buyAuto_$nextFreeSlot $name
		do conf -f buyAuto_$nextFreeSlot_npc prt_in 172 132
		do conf -f buyAuto_$nextFreeSlot_minAmount 0
		do conf -f buyAuto_$nextFreeSlot_maxAmount 1
		do conf -f buyAuto_$nextFreeSlot_minDistance 1
		do conf -f buyAuto_$nextFreeSlot_maxDistance 10
		do conf -f buyAuto_$nextFreeSlot_zeny > 1500
		$currentZeny = $currentZeny - 1500
	}
	]
}

macro knight_set_Muffler {
	[
	$MufflerHas = &invamount(2503)
	$MufflerEquipped = isEquippedInSlotNameID('robe', '2503')
	if ($.lvl >= 4) {
		$MufflerCanEquip = 1
	} else {
		$MufflerCanEquip = 0
	}
	if ($currentZeny >= 1500) {
		$MufflerCanBuy = 1
	} else {
		$MufflerCanBuy = 0
	}
	]
}

macro clear_Muffler_buyAuto {
	[
	$name = GetNamebyNameID(2503)
	log Clearing buyAuto $name
	$foundSlot = get_free_slot_index_for_key("buyAuto","$name")
	do conf -f buyAuto_$foundSlot none
	]
}

macro knight_set_Manteau {
	[
	$ManteauHas = &invamount(2505)
	$ManteauEquipped = isEquippedInSlotNameID('robe', '2505')
	if ($.lvl >= 33) {
		$ManteauCanEquip = 1
	} else {
		$ManteauCanEquip = 0
	}
	if ($currentZeny >= 35000) {
		$ManteauCanBuy = 1
	} else {
		$ManteauCanBuy = 0
	}
	]
}

macro knight_set_buyauto_topHead {
	call knight_set_Hat
	call knight_set_Cap
	call knight_set_Helm
	[
	if ($HelmEquipped == 1) {
		log Helm is equipped DAMNN
		
	} elsif ($CapEquipped == 1 && $HelmCanEquip == 0) {
		log Cap is equipped and cannot equip Helm DAMNN
		
	} elsif ($CapEquipped == 1 && $HelmCanEquip == 1 && $HelmCanBuy == 0) {
		log Cap is equipped, can equip Helm but cannot buy it DAMNN
		
	} elsif ($HatEquipped == 1 && $HelmCanEquip == 0 && $CapCanEquip == 0) {
		log Hat is equipped and cannot equip Helm or Cap DAMNN
		
	} elsif ($HatEquipped == 1 && ($HelmCanEquip == 1 || $CapCanEquip == 1) && $HelmCanBuy == 0 && $CapCanBuy == 0) {
		log Hat is equipped, can equip better stuff but not buy it DAMNN
		
	} elsif ($HatEquipped == 0 && $HatCanBuy == 0) {
		log Hat is not equipped, cannot buy it
		
	} elsif ($HelmEquipped == 0 && $HelmCanEquip == 1 && $HelmHas >= 1) {
		call clear_Hat_buyAuto
		call clear_Cap_buyAuto
		$name = GetNamebyNameID(2228)
		log Setting equipauto $name
		do iconf 2220 0 0 1
		do iconf 2226 0 0 1
		do iconf 2228 1 0 0
		do conf -f equipAuto_0_topHead GetNamebyNameID(2228)
		
	} elsif ($HelmEquipped == 0 && $HelmCanEquip == 1 && $HelmHas == 0 && $HelmCanBuy == 1) {
		call clear_Hat_buyAuto
		call clear_Cap_buyAuto
		$name = GetNamebyNameID(2228)
		log Setting buyAuto $name
		$nextFreeSlot = get_free_slot_index_for_key("buyAuto","$name")
		do conf -f buyAuto_$nextFreeSlot $name
		do conf -f buyAuto_$nextFreeSlot_npc izlude_in 70 127
		do conf -f buyAuto_$nextFreeSlot_minAmount 0
		do conf -f buyAuto_$nextFreeSlot_maxAmount 1
		do conf -f buyAuto_$nextFreeSlot_minDistance 1
		do conf -f buyAuto_$nextFreeSlot_maxDistance 10
		do conf -f buyAuto_$nextFreeSlot_zeny > 45000
		$currentZeny = $currentZeny - 45000
		
	} elsif ($HelmCanEquip == 0 && $CapEquipped == 0 && $CapCanEquip == 1 && $CapHas >= 1) {
		call clear_Hat_buyAuto
		$name = GetNamebyNameID(2228)
		log Setting equipauto $name
		do iconf 2220 0 0 1
		do iconf 2226 1 0 0
		do conf -f equipAuto_0_topHead GetNamebyNameID(2226)
		
	} elsif ($HelmCanEquip == 0 && $CapEquipped == 0 && $CapCanEquip == 1 && $CapHas == 0 && $CapCanBuy == 1) {
		call clear_Hat_buyAuto
		$name = GetNamebyNameID(2226)
		log Setting buyAuto $name
		$nextFreeSlot = get_free_slot_index_for_key("buyAuto","$name")
		do conf -f buyAuto_$nextFreeSlot $name
		do conf -f buyAuto_$nextFreeSlot_npc prt_in 172 132
		do conf -f buyAuto_$nextFreeSlot_minAmount 0
		do conf -f buyAuto_$nextFreeSlot_maxAmount 1
		do conf -f buyAuto_$nextFreeSlot_minDistance 1
		do conf -f buyAuto_$nextFreeSlot_maxDistance 10
		do conf -f buyAuto_$nextFreeSlot_zeny > 15000
		$currentZeny = $currentZeny - 15000
		
	} elsif ($HelmCanEquip == 0 && $CapCanEquip == 0 && $HatEquipped == 0 && $HatCanEquip == 1 && $HatHas >= 1) {
		$name = GetNamebyNameID(2220)
		log Setting equipauto $name
		do iconf 2220 1 0 0
		do conf -f equipAuto_0_topHead GetNamebyNameID(2220)
		
	} elsif ($HelmCanEquip == 0 && $CapCanEquip == 0 && $HatEquipped == 0 && $HatCanEquip == 1 && $HatHas == 0 && $HatCanBuy == 1) {
		$name = GetNamebyNameID(2220)
		log Setting buyAuto $name
		$nextFreeSlot = get_free_slot_index_for_key("buyAuto","$name")
		do conf -f buyAuto_$nextFreeSlot $name
		do conf -f buyAuto_$nextFreeSlot_npc prt_in 172 132
		do conf -f buyAuto_$nextFreeSlot_minAmount 0
		do conf -f buyAuto_$nextFreeSlot_maxAmount 1
		do conf -f buyAuto_$nextFreeSlot_minDistance 1
		do conf -f buyAuto_$nextFreeSlot_maxDistance 10
		do conf -f buyAuto_$nextFreeSlot_zeny > 1500
		$currentZeny = $currentZeny - 1500
	}
	]
}

macro knight_set_Hat {
	[
	$HatHas = &invamount(2220)
	$HatEquipped = isEquippedInSlotNameID('topHead', '2220')
	if ($.lvl >= 4) {
		$HatCanEquip = 1
	} else {
		$HatCanEquip = 0
	}
	if ($currentZeny >= 1500) {
		$HatCanBuy = 1
	} else {
		$HatCanBuy = 0
	}
	]
}

macro clear_Hat_buyAuto {
	[
	$name = GetNamebyNameID(2220)
	log Clearing buyAuto $name
	$foundSlot = get_free_slot_index_for_key("buyAuto","$name")
	do conf -f buyAuto_$foundSlot none
	]
}

macro knight_set_Cap {
	[
	$CapHas = &invamount(2226)
	$CapEquipped = isEquippedInSlotNameID('topHead', '2226')
	if ($.lvl >= 14) {
		$CapCanEquip = 1
	} else {
		$CapCanEquip = 0
	}
	if ($currentZeny >= 15000) {
		$CapCanBuy = 1
	} else {
		$CapCanBuy = 0
	}
	]
}

macro clear_Cap_buyAuto {
	[
	$name = GetNamebyNameID(2226)
	log Clearing buyAuto $name
	$foundSlot = get_free_slot_index_for_key("buyAuto","$name")
	do conf -f buyAuto_$foundSlot none
	]
}

macro knight_set_Helm {
	[
	$HelmHas = &invamount(2228)
	$HelmEquipped = isEquippedInSlotNameID('topHead', '2228')
	if ($.lvl >= 33) {
		$HelmCanEquip = 1
	} else {
		$HelmCanEquip = 0
	}
	if ($currentZeny >= 45000) {
		$HelmCanBuy = 1
	} else {
		$HelmCanBuy = 0
	}
	]
}

automacro Go_Job_Change {
	ConfigKey eventMacro_1_99_stage leveling
	ConfigKeyNotExist doing_knight_job_change
	IsEquippedID rightHand 1157
    InInventoryID 1157 > 0
	JobLevel = 50
    exclusive 1
	priority 0
    call {
		do conf -f eventMacro_1_99_stage turning_knight_true_start
		do conf -f doing_knight_job_change start
		
		do conf -f Turn_Knight_lockMap_before &config(lockMap)
		do conf -f lockMap none
		
		include on Turn_Knight.pm
		
		do reload eventMacros
    }
}

automacro Set_use_Two_Handed_Quicken {
	ConfigKey eventMacro_1_99_stage leveling
    ConfigKeyNot useSelf_skill_0 KN_TWOHANDQUICKEN
	SkillLevel KN_TWOHANDQUICKEN > 7
    exclusive 1
    call {
		[
		do conf -f useSelf_skill_0 KN_TWOHANDQUICKEN
		do conf -f useSelf_skill_0_disabled 0
		do conf -f useSelf_skill_0_sp > 50
		do conf -f useSelf_skill_0_whenStatusInactive EFST_TWOHANDQUICKEN
		do conf -f useSelf_skill_0_lvl 10
		do conf -f useSelf_skill_0_inLockOnly 1
		do conf -f useSelf_skill_0_notWhileSitting 1
		do conf -f useSelf_skill_0_notInTown 1
		]
    }
}

# Peco Peco

automacro Go_Get_Peco {
	ConfigKey eventMacro_1_99_stage leveling
	SkillLevel KN_CAVALIERMASTERY = 5
	StatusInactiveHandle EFST_RIDING
	Zeny > 10000
    exclusive 1
	priority 0
    call {
		do conf -f eventMacro_1_99_stage knight_getting_peco
    }
}

macro Move_to_peco_breeder {
	do move prontera 55 350 &rand(3,4,5,6,7,8)
}

automacro move_to_breeder_outside {
	ConfigKey eventMacro_1_99_stage knight_getting_peco
	StatusInactiveHandle EFST_RIDING
	NotInMap prontera
	exclusive 1
	call Move_to_peco_breeder
}

automacro move_to_breeder_inside {
	ConfigKey eventMacro_1_99_stage knight_getting_peco
	StatusInactiveHandle EFST_RIDING
	InMap prontera
	NpcNotNear /peco peco/i
	exclusive 1
	call Move_to_peco_breeder
}

automacro Talk_to_Breeder {
	ConfigKey eventMacro_1_99_stage knight_getting_peco
	StatusInactiveHandle EFST_RIDING
	InMap prontera
	NpcNear /peco peco/i
	exclusive 1
	call {
		do talknpc &arg("$.NpcNearLastPos", 1) &arg("$.NpcNearLastPos", 2) r0
	}
}

automacro Got_my_peco_peco {
	ConfigKey eventMacro_1_99_stage knight_getting_peco
	StatusActiveHandle EFST_RIDING
	exclusive 1
	priority 0
	call {
		do conf -f eventMacro_1_99_stage leveling
	}
}

automacro Peco_shit_happened_zeny {
	ConfigKey eventMacro_1_99_stage knight_getting_peco
	StatusInactiveHandle EFST_RIDING
	Zeny < 2500
	exclusive 1
	priority 0
	call {
		do conf -f eventMacro_1_99_stage leveling
	}
}

automacro Peco_shit_happened_skill {
	ConfigKey eventMacro_1_99_stage knight_getting_peco
	StatusActiveHandle EFST_RIDING
	SkillLevel KN_CAVALIERMASTERY < 5
	exclusive 1
	priority 0
	call {
		do conf -f eventMacro_1_99_stage leveling
	}
}
