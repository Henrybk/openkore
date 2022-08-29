
macro baseMacroUp {
	[
	
	call SetVar
	call set_buyauto_equipment
	
	$changed = 0
	$HPRecoveryWhileMovingLevel = getSkillLevelByHandle("SM_MOVINGRECOVERY")
	
	if ($configlockMap == yuno_fild01 && $HPRecoveryWhileMovingLevel == 1) {
		do conf lockMap none
		call SetVar
	}
	
	call knight_set_Katana
	call knight_set_Slayer
	call knight_set_TwoHandedSword
	if ($Katana{Equipped} == 1 || $Slayer{Equipped} == 1 || $TwoHandedSword{Equipped} == 1) {
		$hasWeapon = 1
	} else {
		$hasWeapon = 0
	}
	
	#Leveling
	if ($.lvl <= 22) {
		if ($configlockMap != prt_sewb2) {
			# kafra prt_fild05 290 224
			# sell prt_fild05 290 221
			call set_lockmap_prt_sewb2
			$changed = 1
		}
	
	} elsif ($.lvl <= 32 || $hasWeapon == 0) {
		if ($configlockMap != pay_fild01) {
			# kafra oldnewpayon 98 118
			# sell oldnewpayon 69 117
			call set_lockmap_pay_fild01
			$changed = 1
		}
		
	} elsif ($.joblvl >= 25 && $.lvl >= 40 && $HPRecoveryWhileMovingLevel == 0 && $hasWeapon == 1) {
		if ($configlockMap != yuno_fild01) {
			# kafra aldebaran 143 119
			# sell aldeba_in 94 56
			call set_lockmap_yuno_fild01
			$changed = 1
		}
		
	#} elsif ($.lvl <= 50 && $hasWeapon == 1) {
	} elsif ($hasWeapon == 1) {
		if ($configlockMap != lasa_dun01) {
			# kafra aldebaran 143 119
			# sell aldeba_in 94 56
			call set_lockmap_lasa_dun01
			$changed = 1
		}
		
	}
	
	if ($changed == 1) {
		call after_lock_change
	}
	]
}

macro knight_set_buyauto_equipment {
	[
	$currentZeny = $.zeny
	$extraBuyCost = 4000
	call knight_set_buyauto_rightHand
	
	if ($Katana{Equipped} == 1 || $Slayer{Equipped} == 1 || $TwoHandedSword{Equipped} == 1) {
		$hasWeapon = 1
	} else {
		$hasWeapon = 0
	}
	if ($hasWeapon == 1) {
		call knight_set_buyauto_armor 
		call knight_set_buyauto_shoes 
		call knight_set_buyauto_robe 
		call knight_set_buyauto_topHead 
	}
	]
}

macro knight_set_buyauto_rightHand {
	call knight_set_Katana
	call knight_set_Slayer
	call knight_set_TwoHandedSword
	[
	if ($TwoHandedSword{Equipped} == 1) {
		log TwoHandedSword is {Equipped} DAMNN
		
	} elsif ($Slayer{Equipped} == 1 && $TwoHandedSword{CanEquip} == 0) {
		log Slayer is {Equipped} and cannot equip TwoHandedSword DAMNN
		
	} elsif ($Slayer{Equipped} == 1 && $TwoHandedSword{CanEquip} == 1 && $TwoHandedSword{CanBuy} == 0 && $TwoHandedSword{Has} == 0) {
		log Slayer is equipped, can equip TwoHandedSword but cannot buy it DAMNN
		
	} elsif ($Katana{Equipped} == 1 && $TwoHandedSword{CanEquip} == 0 && $Slayer{CanEquip} == 0) {
		log Katana is {Equipped} and cannot equip TwoHandedSword or Slayer DAMNN
		
	} elsif ($Katana{Equipped} == 1 && ($TwoHandedSword{CanEquip} == 1 || $Slayer{CanEquip} == 1) && $TwoHandedSword{CanBuy} == 0 && $Slayer{CanBuy} == 0 && $TwoHandedSword{Has} == 0 && $Slayer{Has} == 0) {
		log Katana is equipped, can equip better stuff but not buy it DAMNN
		
	} elsif ($Katana{Equipped} == 0 && $Katana{CanBuy} == 0 && $Katana{Has} == 0) {
		log Katana is not equipped, cannot buy it
		
	} elsif ($TwoHandedSword{Equipped} == 0 && $TwoHandedSword{CanEquip} == 1 && $TwoHandedSword{Has} >= 1) {
		call buyAuto_clear $Katana{id}
		call buyAuto_clear $Slayer{id}
		call buyAuto_clear $TwoHandedSword{id}
		call set_equip $TwoHandedSword{id} $TwoHandedSword{slot}
		
	} elsif ($TwoHandedSword{Equipped} == 0 && $TwoHandedSword{CanEquip} == 1 && $TwoHandedSword{Has} == 0 && $TwoHandedSword{CanBuy} == 1) {
		call buyAuto_clear $Katana{id}
		call buyAuto_clear $Slayer{id}
		call set_buyAuto $TwoHandedSword{id} $TwoHandedSword{price} $TwoHandedSword{npcMap} $TwoHandedSword{npcX} $TwoHandedSword{npcY}
		
	} elsif (($TwoHandedSword{CanEquip} == 0 || $TwoHandedSword{Has} == 0) && $Slayer{Equipped} == 0 && $Slayer{CanEquip} == 1 && $Slayer{Has} >= 1) {
		call buyAuto_clear $Katana{id}
		call buyAuto_clear $Slayer{id}
		call set_equip $Slayer{id} $Slayer{slot}
		
	} elsif (($TwoHandedSword{CanEquip} == 0 || $TwoHandedSword{CanBuy} == 0) && $Slayer{Equipped} == 0 && $Slayer{CanEquip} == 1 && $Slayer{Has} == 0 && $Slayer{CanBuy} == 1) {
		call buyAuto_clear $Katana{id}
		call set_buyAuto $Slayer{id} $Slayer{price} $Slayer{npcMap} $Slayer{npcX} $Slayer{npcY}
		
	} elsif (($TwoHandedSword{CanEquip} == 0 || $TwoHandedSword{CanBuy} == 0) && ($Slayer{CanEquip} == 0 || $Slayer{Has} == 0) && $Katana{Equipped} == 0 && $Katana{CanEquip} == 1 && $Katana{Has} >= 1) {
		call buyAuto_clear $Katana{id}
		call set_equip $Katana{id} $Katana{slot}
		
	} elsif (($TwoHandedSword{CanEquip} == 0 || $TwoHandedSword{CanBuy} == 0) && ($Slayer{CanEquip} == 0 || $Slayer{CanBuy} == 0) && $Katana{Equipped} == 0 && $Katana{CanEquip} == 1 && $Katana{Has} == 0 && $Katana{CanBuy} == 1) {
		call set_buyAuto $Katana{id} $Katana{price} $Katana{npcMap} $Katana{npcX} $Katana{npcY}
	}
	]
}

macro knight_set_Katana {
	[
	$item{id} = 1116
	$item{slot} = rightHand
	$item{price} = 2000
	$item{minLevel} = 4
	$item{npcMap} = prt_in
	$item{npcX} = 172
	$item{npcY} = 130
	call set_item
	
	$Katana{id} = $item{id}
	$Katana{slot} = $item{slot}
	$Katana{price} = $item{price}
	$Katana{minLevel} = $item{minLevel}
	$Katana{npcMap} = $item{npcMap}
	$Katana{npcX} = $item{npcX}
	$Katana{npcY} = $item{npcY}
	$Katana{Has} = $item{Has}
	$Katana{Equipped} = $item{Equipped}
	$Katana{CanEquip} = $item{CanEquip}
	$Katana{CanBuy} = $item{CanBuy}
	]
}

macro knight_set_Slayer {
	[
	$item{id} = 1151
	$item{slot} = rightHand
	$item{price} = 15000
	$item{minLevel} = 18
	$item{npcMap} = izlude_in
	$item{npcX} = 60
	$item{npcY} = 127
	call set_item
	
	$Slayer{id} = $item{id}
	$Slayer{slot} = $item{slot}
	$Slayer{price} = $item{price}
	$Slayer{minLevel} = $item{minLevel}
	$Slayer{npcMap} = $item{npcMap}
	$Slayer{npcX} = $item{npcX}
	$Slayer{npcY} = $item{npcY}
	$Slayer{Has} = $item{Has}
	$Slayer{Equipped} = $item{Equipped}
	$Slayer{CanEquip} = $item{CanEquip}
	$Slayer{CanBuy} = $item{CanBuy}
	]
}

macro knight_set_TwoHandedSword {
	[
	$item{id} = 1157
	$item{slot} = rightHand
	$item{price} = 60000
	$item{minLevel} = 33
	$item{npcMap} = izlude_in
	$item{npcX} = 60
	$item{npcY} = 127
	call set_item
	
	$TwoHandedSword{id} = $item{id}
	$TwoHandedSword{slot} = $item{slot}
	$TwoHandedSword{price} = $item{price}
	$TwoHandedSword{minLevel} = $item{minLevel}
	$TwoHandedSword{npcMap} = $item{npcMap}
	$TwoHandedSword{npcX} = $item{npcX}
	$TwoHandedSword{npcY} = $item{npcY}
	$TwoHandedSword{Has} = $item{Has}
	$TwoHandedSword{Equipped} = $item{Equipped}
	$TwoHandedSword{CanEquip} = $item{CanEquip}
	$TwoHandedSword{CanBuy} = $item{CanBuy}
	]
}

macro knight_set_buyauto_armor {
	call knight_set_AdventureSuit
	call knight_set_PaddedArmor
	call knight_set_PlateArmor
	[
	if ($PlateArmor{Equipped} == 1) {
		log PlateArmor is {Equipped} DAMNN
		
	} elsif ($PaddedArmor{Equipped} == 1 && $PlateArmor{CanEquip} == 0) {
		log PaddedArmor is {Equipped} and cannot equip PlateArmor DAMNN
		
	} elsif ($PaddedArmor{Equipped} == 1 && $PlateArmor{CanEquip} == 1 && $PlateArmor{CanBuy} == 0 && $PlateArmor{Has} == 0) {
		log PaddedArmor is equipped, can equip PlateArmor but cannot buy it DAMNN
		
	} elsif ($AdventureSuit{Equipped} == 1 && $PlateArmor{CanEquip} == 0 && $PaddedArmor{CanEquip} == 0) {
		log AdventureSuit is {Equipped} and cannot equip PlateArmor or PaddedArmor DAMNN
		
	} elsif ($AdventureSuit{Equipped} == 1 && ($PlateArmor{CanEquip} == 1 || $PaddedArmor{CanEquip} == 1) && $PlateArmor{CanBuy} == 0 && $PaddedArmor{CanBuy} == 0 && $PlateArmor{Has} == 0 && $PaddedArmor{Has} == 0) {
		log AdventureSuit is equipped, can equip better stuff but not buy it DAMNN
		
	} elsif ($AdventureSuit{Equipped} == 0 && $AdventureSuit{CanBuy} == 0 && $AdventureSuit{Has} == 0) {
		log AdventureSuit is not equipped, cannot buy it
		
	} elsif ($PlateArmor{Equipped} == 0 && $PlateArmor{CanEquip} == 1 && $PlateArmor{Has} >= 1) {
		call buyAuto_clear $AdventureSuit{id}
		call buyAuto_clear $PaddedArmor{id}
		call buyAuto_clear $PlateArmor{id}
		call set_equip $PlateArmor{id} $PlateArmor{slot}
		
	} elsif ($PlateArmor{Equipped} == 0 && $PlateArmor{CanEquip} == 1 && $PlateArmor{Has} == 0 && $PlateArmor{CanBuy} == 1) {
		call buyAuto_clear $AdventureSuit{id}
		call buyAuto_clear $PaddedArmor{id}
		call set_buyAuto $PlateArmor{id} $PlateArmor{price} $PlateArmor{npcMap} $PlateArmor{npcX} $PlateArmor{npcY}
		
	} elsif (($PlateArmor{CanEquip} == 0 || $PlateArmor{Has} == 0) && $PaddedArmor{Equipped} == 0 && $PaddedArmor{CanEquip} == 1 && $PaddedArmor{Has} >= 1) {
		call buyAuto_clear $AdventureSuit{id}
		call buyAuto_clear $PaddedArmor{id}
		call set_equip $PaddedArmor{id} $PaddedArmor{slot}
		
	} elsif (($PlateArmor{CanEquip} == 0 || $PlateArmor{CanBuy} == 0) && $PaddedArmor{Equipped} == 0 && $PaddedArmor{CanEquip} == 1 && $PaddedArmor{Has} == 0 && $PaddedArmor{CanBuy} == 1) {
		call buyAuto_clear $AdventureSuit{id}
		call set_buyAuto $PaddedArmor{id} $PaddedArmor{price} $PaddedArmor{npcMap} $PaddedArmor{npcX} $PaddedArmor{npcY}
		
	} elsif (($PlateArmor{CanEquip} == 0 || $PlateArmor{CanBuy} == 0) && ($PaddedArmor{CanEquip} == 0 || $PaddedArmor{Has} == 0) && $AdventureSuit{Equipped} == 0 && $AdventureSuit{CanEquip} == 1 && $AdventureSuit{Has} >= 1) {
		call buyAuto_clear $AdventureSuit{id}
		call set_equip $AdventureSuit{id} $AdventureSuit{slot}
		
	} elsif (($PlateArmor{CanEquip} == 0 || $PlateArmor{CanBuy} == 0) && ($PaddedArmor{CanEquip} == 0 || $PaddedArmor{CanBuy} == 0) && $AdventureSuit{Equipped} == 0 && $AdventureSuit{CanEquip} == 1 && $AdventureSuit{Has} == 0 && $AdventureSuit{CanBuy} == 1) {
		call set_buyAuto $AdventureSuit{id} $AdventureSuit{price} $AdventureSuit{npcMap} $AdventureSuit{npcX} $AdventureSuit{npcY}
	}
	]
}

macro knight_set_AdventureSuit {
	[
	$item{id} = 2305
	$item{slot} = armor
	$item{price} = 1000
	$item{minLevel} = 4
	$item{npcMap} = payon_in01
	$item{npcX} = 134
	$item{npcY} = 51
	call set_item
	
	$AdventureSuit{id} = $item{id}
	$AdventureSuit{slot} = $item{slot}
	$AdventureSuit{price} = $item{price}
	$AdventureSuit{minLevel} = $item{minLevel}
	$AdventureSuit{npcMap} = $item{npcMap}
	$AdventureSuit{npcX} = $item{npcX}
	$AdventureSuit{npcY} = $item{npcY}
	$AdventureSuit{Has} = $item{Has}
	$AdventureSuit{Equipped} = $item{Equipped}
	$AdventureSuit{CanEquip} = $item{CanEquip}
	$AdventureSuit{CanBuy} = $item{CanBuy}
	]
}

macro knight_set_PaddedArmor {
	[
	$item{id} = 2312
	$item{slot} = armor
	$item{price} = 48000
	$item{minLevel} = 25
	$item{npcMap} = payon_in01
	$item{npcX} = 76
	$item{npcY} = 70 
	call set_item
	
	$PaddedArmor{id} = $item{id}
	$PaddedArmor{slot} = $item{slot}
	$PaddedArmor{price} = $item{price}
	$PaddedArmor{minLevel} = $item{minLevel}
	$PaddedArmor{npcMap} = $item{npcMap}
	$PaddedArmor{npcX} = $item{npcX}
	$PaddedArmor{npcY} = $item{npcY}
	$PaddedArmor{Has} = $item{Has}
	$PaddedArmor{Equipped} = $item{Equipped}
	$PaddedArmor{CanEquip} = $item{CanEquip}
	$PaddedArmor{CanBuy} = $item{CanBuy}
	]
}

macro knight_set_PlateArmor {
	[
	$item{id} = 2316
	$item{slot} = armor
	$item{price} = 80000
	$item{minLevel} = 40
	$item{npcMap} = payon_in01
	$item{npcX} = 76
	$item{npcY} = 70 
	call set_item
	
	$PlateArmor{id} = $item{id}
	$PlateArmor{slot} = $item{slot}
	$PlateArmor{price} = $item{price}
	$PlateArmor{minLevel} = $item{minLevel}
	$PlateArmor{npcMap} = $item{npcMap}
	$PlateArmor{npcX} = $item{npcX}
	$PlateArmor{npcY} = $item{npcY}
	$PlateArmor{Has} = $item{Has}
	$PlateArmor{Equipped} = $item{Equipped}
	$PlateArmor{CanEquip} = $item{CanEquip}
	$PlateArmor{CanBuy} = $item{CanBuy}
	]
}

macro knight_set_buyauto_shoes {
	call knight_set_Sandals
	call knight_set_Shoes
	call knight_set_Boots
	[
	if ($Boots{Equipped} == 1) {
		log Boots is {Equipped} DAMNN
		
	} elsif ($Shoes{Equipped} == 1 && $Boots{CanEquip} == 0) {
		log Shoes is {Equipped} and cannot equip Boots DAMNN
		
	} elsif ($Shoes{Equipped} == 1 && $Boots{CanEquip} == 1 && $Boots{CanBuy} == 0 && $Boots{Has} == 0) {
		log Shoes is equipped, can equip Boots but cannot buy it DAMNN
		
	} elsif ($Sandals{Equipped} == 1 && $Boots{CanEquip} == 0 && $Shoes{CanEquip} == 0) {
		log Sandals is {Equipped} and cannot equip Boots or Shoes DAMNN
		
	} elsif ($Sandals{Equipped} == 1 && ($Boots{CanEquip} == 1 || $Shoes{CanEquip} == 1) && $Boots{CanBuy} == 0 && $Shoes{CanBuy} == 0 && $Boots{Has} == 0 && $Shoes{Has} == 0) {
		log Sandals is equipped, can equip better stuff but not buy it DAMNN
		
	} elsif ($Sandals{Equipped} == 0 && $Sandals{CanBuy} == 0 && $Sandals{Has} == 0) {
		log Sandals is not equipped, cannot buy it
		
	} elsif ($Boots{Equipped} == 0 && $Boots{CanEquip} == 1 && $Boots{Has} >= 1) {
		call buyAuto_clear $Sandals{id}
		call buyAuto_clear $Shoes{id}
		call buyAuto_clear $Boots{id}
		call set_equip $Boots{id} $Boots{slot}
		
	} elsif ($Boots{Equipped} == 0 && $Boots{CanEquip} == 1 && $Boots{Has} == 0 && $Boots{CanBuy} == 1) {
		call buyAuto_clear $Sandals{id}
		call buyAuto_clear $Shoes{id}
		call set_buyAuto $Boots{id} $Boots{price} $Boots{npcMap} $Boots{npcX} $Boots{npcY}
		
	} elsif (($Boots{CanEquip} == 0 || $Boots{Has} == 0) && $Shoes{Equipped} == 0 && $Shoes{CanEquip} == 1 && $Shoes{Has} >= 1) {
		call buyAuto_clear $Sandals{id}
		call buyAuto_clear $Shoes{id}
		call set_equip $Shoes{id} $Shoes{slot}
		
	} elsif (($Boots{CanEquip} == 0 || $Boots{CanBuy} == 0) && $Shoes{Equipped} == 0 && $Shoes{CanEquip} == 1 && $Shoes{Has} == 0 && $Shoes{CanBuy} == 1) {
		call buyAuto_clear $Sandals{id}
		call set_buyAuto $Shoes{id} $Shoes{price} $Shoes{npcMap} $Shoes{npcX} $Shoes{npcY}
		
	} elsif (($Boots{CanEquip} == 0 || $Boots{CanBuy} == 0) && ($Shoes{CanEquip} == 0 || $Shoes{Has} == 0) && $Sandals{Equipped} == 0 && $Sandals{CanEquip} == 1 && $Sandals{Has} >= 1) {
		call buyAuto_clear $Sandals{id}
		call set_equip $Sandals{id} $Sandals{slot}
		
	} elsif (($Boots{CanEquip} == 0 || $Boots{CanBuy} == 0) && ($Shoes{CanEquip} == 0 || $Shoes{CanBuy} == 0) && $Sandals{Equipped} == 0 && $Sandals{CanEquip} == 1 && $Sandals{Has} == 0 && $Sandals{CanBuy} == 1) {
		call set_buyAuto $Sandals{id} $Sandals{price} $Sandals{npcMap} $Sandals{npcX} $Sandals{npcY}
	}
	]
}

macro knight_set_Sandals {
	[
	$item{id} = 2401
	$item{slot} = shoes
	$item{price} = 400
	$item{minLevel} = 4
	$item{npcMap} = payon_in01
	$item{npcX} = 134
	$item{npcY} = 51
	call set_item
	
	$Sandals{id} = $item{id}
	$Sandals{slot} = $item{slot}
	$Sandals{price} = $item{price}
	$Sandals{minLevel} = $item{minLevel}
	$Sandals{npcMap} = $item{npcMap}
	$Sandals{npcX} = $item{npcX}
	$Sandals{npcY} = $item{npcY}
	$Sandals{Has} = $item{Has}
	$Sandals{Equipped} = $item{Equipped}
	$Sandals{CanEquip} = $item{CanEquip}
	$Sandals{CanBuy} = $item{CanBuy}
	]
}

macro knight_set_Shoes {
	[
	$item{id} = 2403
	$item{slot} = shoes
	$item{price} = 3500
	$item{minLevel} = 14
	$item{npcMap} = payon_in01
	$item{npcX} = 134
	$item{npcY} = 51
	call set_item
	
	$Shoes{id} = $item{id}
	$Shoes{slot} = $item{slot}
	$Shoes{price} = $item{price}
	$Shoes{minLevel} = $item{minLevel}
	$Shoes{npcMap} = $item{npcMap}
	$Shoes{npcX} = $item{npcX}
	$Shoes{npcY} = $item{npcY}
	$Shoes{Has} = $item{Has}
	$Shoes{Equipped} = $item{Equipped}
	$Shoes{CanEquip} = $item{CanEquip}
	$Shoes{CanBuy} = $item{CanBuy}
	]
}

macro knight_set_Boots {
	[
	$item{id} = 2405
	$item{slot} = shoes
	$item{price} = 18000
	$item{minLevel} = 33
	$item{npcMap} = payon_in01
	$item{npcX} = 134
	$item{npcY} = 51
	call set_item
	
	$Boots{id} = $item{id}
	$Boots{slot} = $item{slot}
	$Boots{price} = $item{price}
	$Boots{minLevel} = $item{minLevel}
	$Boots{npcMap} = $item{npcMap}
	$Boots{npcX} = $item{npcX}
	$Boots{npcY} = $item{npcY}
	$Boots{Has} = $item{Has}
	$Boots{Equipped} = $item{Equipped}
	$Boots{CanEquip} = $item{CanEquip}
	$Boots{CanBuy} = $item{CanBuy}
	]
}

macro knight_set_buyauto_topHead {
	call knight_set_Hat
	call knight_set_Cap
	call knight_set_Helm
	[
	if ($Helm{Equipped} == 1) {
		log Helm is {Equipped} DAMNN
		
	} elsif ($Cap{Equipped} == 1 && $Helm{CanEquip} == 0) {
		log Cap is {Equipped} and cannot equip Helm DAMNN
		
	} elsif ($Cap{Equipped} == 1 && $Helm{CanEquip} == 1 && $Helm{CanBuy} == 0 && $Helm{Has} == 0) {
		log Cap is equipped, can equip Helm but cannot buy it DAMNN
		
	} elsif ($Hat{Equipped} == 1 && $Helm{CanEquip} == 0 && $Cap{CanEquip} == 0) {
		log Hat is {Equipped} and cannot equip Helm or Cap DAMNN
		
	} elsif ($Hat{Equipped} == 1 && ($Helm{CanEquip} == 1 || $Cap{CanEquip} == 1) && $Helm{CanBuy} == 0 && $Cap{CanBuy} == 0 && $Helm{Has} == 0 && $Cap{Has} == 0) {
		log Hat is equipped, can equip better stuff but not buy it DAMNN
		
	} elsif ($Hat{Equipped} == 0 && $Hat{CanBuy} == 0 && $Hat{Has} == 0) {
		log Hat is not equipped, cannot buy it
		
	} elsif ($Helm{Equipped} == 0 && $Helm{CanEquip} == 1 && $Helm{Has} >= 1) {
		call buyAuto_clear $Hat{id}
		call buyAuto_clear $Cap{id}
		call buyAuto_clear $Helm{id}
		call set_equip $Helm{id} $Helm{slot}
		
	} elsif ($Helm{Equipped} == 0 && $Helm{CanEquip} == 1 && $Helm{Has} == 0 && $Helm{CanBuy} == 1) {
		call buyAuto_clear $Hat{id}
		call buyAuto_clear $Cap{id}
		call set_buyAuto $Helm{id} $Helm{price} $Helm{npcMap} $Helm{npcX} $Helm{npcY}
		
	} elsif (($Helm{CanEquip} == 0 || $Helm{Has} == 0) && $Cap{Equipped} == 0 && $Cap{CanEquip} == 1 && $Cap{Has} >= 1) {
		call buyAuto_clear $Hat{id}
		call buyAuto_clear $Cap{id}
		call set_equip $Cap{id} $Cap{slot}
		
	} elsif (($Helm{CanEquip} == 0 || $Helm{CanBuy} == 0) && $Cap{Equipped} == 0 && $Cap{CanEquip} == 1 && $Cap{Has} == 0 && $Cap{CanBuy} == 1) {
		call buyAuto_clear $Hat{id}
		call set_buyAuto $Cap{id} $Cap{price} $Cap{npcMap} $Cap{npcX} $Cap{npcY}
		
	} elsif (($Helm{CanEquip} == 0 || $Helm{CanBuy} == 0) && ($Cap{CanEquip} == 0 || $Cap{Has} == 0) && $Hat{Equipped} == 0 && $Hat{CanEquip} == 1 && $Hat{Has} >= 1) {
		call buyAuto_clear $Hat{id}
		call set_equip $Hat{id} $Hat{slot}
		
	} elsif (($Helm{CanEquip} == 0 || $Helm{CanBuy} == 0) && ($Cap{CanEquip} == 0 || $Cap{CanBuy} == 0) && $Hat{Equipped} == 0 && $Hat{CanEquip} == 1 && $Hat{Has} == 0 && $Hat{CanBuy} == 1) {
		call set_buyAuto $Hat{id} $Hat{price} $Hat{npcMap} $Hat{npcX} $Hat{npcY}
	}
	]
}

macro knight_set_Hat {
	[
	$item{id} = 2220
	$item{slot} = topHead
	$item{price} = 1000
	$item{minLevel} = 4
	$item{npcMap} = prt_in
	$item{npcX} = 172
	$item{npcY} = 132
	call set_item
	
	$Hat{id} = $item{id}
	$Hat{slot} = $item{slot}
	$Hat{price} = $item{price}
	$Hat{minLevel} = $item{minLevel}
	$Hat{npcMap} = $item{npcMap}
	$Hat{npcX} = $item{npcX}
	$Hat{npcY} = $item{npcY}
	$Hat{Has} = $item{Has}
	$Hat{Equipped} = $item{Equipped}
	$Hat{CanEquip} = $item{CanEquip}
	$Hat{CanBuy} = $item{CanBuy}
	]
}

macro knight_set_Cap {
	[
	$item{id} = 2226
	$item{slot} = topHead
	$item{price} = 12000
	$item{minLevel} = 14
	$item{npcMap} = prt_in
	$item{npcX} = 172
	$item{npcY} = 132
	call set_item
	
	$Cap{id} = $item{id}
	$Cap{slot} = $item{slot}
	$Cap{price} = $item{price}
	$Cap{minLevel} = $item{minLevel}
	$Cap{npcMap} = $item{npcMap}
	$Cap{npcX} = $item{npcX}
	$Cap{npcY} = $item{npcY}
	$Cap{Has} = $item{Has}
	$Cap{Equipped} = $item{Equipped}
	$Cap{CanEquip} = $item{CanEquip}
	$Cap{CanBuy} = $item{CanBuy}
	]
}

macro knight_set_Helm {
	[
	$item{id} = 2228
	$item{slot} = topHead
	$item{price} = 44000
	$item{minLevel} = 40
	$item{npcMap} = payon_in01
	$item{npcX} = 76
	$item{npcY} = 70 
	call set_item
	
	$Helm{id} = $item{id}
	$Helm{slot} = $item{slot}
	$Helm{price} = $item{price}
	$Helm{minLevel} = $item{minLevel}
	$Helm{npcMap} = $item{npcMap}
	$Helm{npcX} = $item{npcX}
	$Helm{npcY} = $item{npcY}
	$Helm{Has} = $item{Has}
	$Helm{Equipped} = $item{Equipped}
	$Helm{CanEquip} = $item{CanEquip}
	$Helm{CanBuy} = $item{CanBuy}
	]
}

macro knight_set_buyauto_robe {
	call knight_set_Hood
	call knight_set_Muffler
	call knight_set_Manteau
	[
	if ($Manteau{Equipped} == 1) {
		log Manteau is {Equipped} DAMNN
		
	} elsif ($Muffler{Equipped} == 1 && $Manteau{CanEquip} == 0) {
		log Muffler is {Equipped} and cannot equip Manteau DAMNN
		
	} elsif ($Muffler{Equipped} == 1 && $Manteau{CanEquip} == 1 && $Manteau{CanBuy} == 0 && $Manteau{Has} == 0) {
		log Muffler is equipped, can equip Manteau but cannot buy it DAMNN
		
	} elsif ($Hood{Equipped} == 1 && $Manteau{CanEquip} == 0 && $Muffler{CanEquip} == 0) {
		log Hood is {Equipped} and cannot equip Manteau or Muffler DAMNN
		
	} elsif ($Hood{Equipped} == 1 && ($Manteau{CanEquip} == 1 || $Muffler{CanEquip} == 1) && $Manteau{CanBuy} == 0 && $Muffler{CanBuy} == 0 && $Manteau{Has} == 0 && $Muffler{Has} == 0) {
		log Hood is equipped, can equip better stuff but not buy it DAMNN
		
	} elsif ($Hood{Equipped} == 0 && $Hood{CanBuy} == 0 && $Hood{Has} == 0) {
		log Hood is not equipped, cannot buy it
		
	} elsif ($Manteau{Equipped} == 0 && $Manteau{CanEquip} == 1 && $Manteau{Has} >= 1) {
		call buyAuto_clear $Hood{id}
		call buyAuto_clear $Muffler{id}
		call buyAuto_clear $Manteau{id}
		call set_equip $Manteau{id} $Manteau{slot}
		
	} elsif ($Manteau{Equipped} == 0 && $Manteau{CanEquip} == 1 && $Manteau{Has} == 0 && $Manteau{CanBuy} == 1) {
		call buyAuto_clear $Hood{id}
		call buyAuto_clear $Muffler{id}
		call set_buyAuto $Manteau{id} $Manteau{price} $Manteau{npcMap} $Manteau{npcX} $Manteau{npcY}
		
	} elsif (($Manteau{CanEquip} == 0 || $Manteau{Has} == 0) && $Muffler{Equipped} == 0 && $Muffler{CanEquip} == 1 && $Muffler{Has} >= 1) {
		call buyAuto_clear $Hood{id}
		call buyAuto_clear $Muffler{id}
		call set_equip $Muffler{id} $Muffler{slot}
		
	} elsif (($Manteau{CanEquip} == 0 || $Manteau{CanBuy} == 0) && $Muffler{Equipped} == 0 && $Muffler{CanEquip} == 1 && $Muffler{Has} == 0 && $Muffler{CanBuy} == 1) {
		call buyAuto_clear $Hood{id}
		call set_buyAuto $Muffler{id} $Muffler{price} $Muffler{npcMap} $Muffler{npcX} $Muffler{npcY}
		
	} elsif (($Manteau{CanEquip} == 0 || $Manteau{CanBuy} == 0) && ($Muffler{CanEquip} == 0 || $Muffler{Has} == 0) && $Hood{Equipped} == 0 && $Hood{CanEquip} == 1 && $Hood{Has} >= 1) {
		call buyAuto_clear $Hood{id}
		call set_equip $Hood{id} $Hood{slot}
		
	} elsif (($Manteau{CanEquip} == 0 || $Manteau{CanBuy} == 0) && ($Muffler{CanEquip} == 0 || $Muffler{CanBuy} == 0) && $Hood{Equipped} == 0 && $Hood{CanEquip} == 1 && $Hood{Has} == 0 && $Hood{CanBuy} == 1) {
		call set_buyAuto $Hood{id} $Hood{price} $Hood{npcMap} $Hood{npcX} $Hood{npcY}
	}
	]
}

macro knight_set_Hood {
	[
	$item{id} = 2501
	$item{slot} = robe
	$item{price} = 1000
	$item{minLevel} = 4
	$item{npcMap} = payon_in01
	$item{npcX} = 134
	$item{npcY} = 51
	call set_item
	
	$Hood{id} = $item{id}
	$Hood{slot} = $item{slot}
	$Hood{price} = $item{price}
	$Hood{minLevel} = $item{minLevel}
	$Hood{npcMap} = $item{npcMap}
	$Hood{npcX} = $item{npcX}
	$Hood{npcY} = $item{npcY}
	$Hood{Has} = $item{Has}
	$Hood{Equipped} = $item{Equipped}
	$Hood{CanEquip} = $item{CanEquip}
	$Hood{CanBuy} = $item{CanBuy}
	]
}

macro knight_set_Muffler {
	[
	$item{id} = 2503
	$item{slot} = robe
	$item{price} = 5000
	$item{minLevel} = 14
	$item{npcMap} = payon_in01
	$item{npcX} = 134
	$item{npcY} = 51
	call set_item
	
	$Muffler{id} = $item{id}
	$Muffler{slot} = $item{slot}
	$Muffler{price} = $item{price}
	$Muffler{minLevel} = $item{minLevel}
	$Muffler{npcMap} = $item{npcMap}
	$Muffler{npcX} = $item{npcX}
	$Muffler{npcY} = $item{npcY}
	$Muffler{Has} = $item{Has}
	$Muffler{Equipped} = $item{Equipped}
	$Muffler{CanEquip} = $item{CanEquip}
	$Muffler{CanBuy} = $item{CanBuy}
	]
}

macro knight_set_Manteau {
	[
	$item{id} = 2505
	$item{slot} = robe
	$item{price} = 32000
	$item{minLevel} = 33
	$item{npcMap} = payon_in01
	$item{npcX} = 134
	$item{npcY} = 51
	call set_item
	
	$Manteau{id} = $item{id}
	$Manteau{slot} = $item{slot}
	$Manteau{price} = $item{price}
	$Manteau{minLevel} = $item{minLevel}
	$Manteau{npcMap} = $item{npcMap}
	$Manteau{npcX} = $item{npcX}
	$Manteau{npcY} = $item{npcY}
	$Manteau{Has} = $item{Has}
	$Manteau{Equipped} = $item{Equipped}
	$Manteau{CanEquip} = $item{CanEquip}
	$Manteau{CanBuy} = $item{CanBuy}
	]
}

automacro Go_Job_Change {
	ConfigKey eventMacro_1_99_stage leveling
	ConfigKeyNotExist doing_knight_job_change
	SkillLevel SM_MOVINGRECOVERY = 1
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

automacro need_to_do_SM_MOVINGRECOVERY_Quest {
    exclusive 1
	priority 0
	ConfigKey eventMacro_1_99_stage leveling
	SkillLevel SM_MOVINGRECOVERY = 0
    InInventoryID 713 >= 50
    InInventoryID 1058 >= 1
	JobLevel >= 25
	JobID 1
    call {
		do conf -f SM_MOVINGRECOVERY_Quest_before &config(eventMacro_1_99_stage)
		do conf -f eventMacro_1_99_stage SM_MOVINGRECOVERY_Quest
		do conf -f before_event_include &config(current_event_include)
		do conf -f current_event_include SM_MOVINGRECOVERY_Quest.pm
		include off &config(before_event_include)
		include on SM_MOVINGRECOVERY_Quest.pm
		
		do reload eventMacros
    }
}