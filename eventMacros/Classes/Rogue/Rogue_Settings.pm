
macro baseMacroUp {
	[
	call SetVar
	call set_buyauto_equipment
	call rogue_set_skills_stats
	
	$TFSTEALLevel = getSkillLevelByHandle("TF_STEAL")
	
	if ($TFSTEALLevel >= 5) {
		$nextFreeSlot = get_free_slot_index_for_key("attackSkillSlot","TF_STEAL")
		do conf -f attackSkillSlot_$nextFreeSlot TF_STEAL
		do conf -f attackSkillSlot_$nextFreeSlot_lvl $TFSTEALLevel
		do conf -f attackSkillSlot_$nextFreeSlot_sp > 10
		do conf -f attackSkillSlot_$nextFreeSlot_maxUses 1
		do conf -f attackSkillSlot_$nextFreeSlot_dist 1
		do conf -f attackSkillSlot_$nextFreeSlot_timeout 1
		do conf -f attackSkillSlot_$nextFreeSlot_maxAttempts 1
		do conf -f attackSkillSlot_$nextFreeSlot_disabled 0
	}
	
	$changed = 0
	
	call rogue_set_Dirk
	call rogue_set_Stiletto
	call rogue_set_Damascus
	if ($Dirk{Equipped} == 1 || $Stiletto{Equipped} == 1 || $Damascus{Equipped} == 1) {
		$hasWeapon = 1
	} else {
		$hasWeapon = 0
	}
	
	#Leveling
	if ($.lvl <= 21) {
		if ($configlockMap != prt_fild07) {
			# kafra prt_fild05 290 224
			# sell prt_fild05 290 221
			call set_lockmap_prt_fild07
			$changed = 1
		}
	
	} elsif ($.lvl <= 38 || $hasWeapon == 0) {
		if ($configlockMap != pay_fild01) {
			# kafra oldnewpayon 98 118
			# sell oldnewpayon 69 117
			call set_lockmap_pay_fild01
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

macro rogue_set_buyauto_equipment {
	[
	$currentZeny = $.zeny
	$extraBuyCost = 4000
	call rogue_set_buyauto_rightHand
	
	if ($Dirk{Equipped} == 1 || $Stiletto{Equipped} == 1 || $Damascus{Equipped} == 1) {
		$hasWeapon = 1
	} else {
		$hasWeapon = 0
	}
	if ($hasWeapon == 1) {
		call rogue_set_buyauto_armor 
		call rogue_set_buyauto_shoes 
		call rogue_set_buyauto_robe 
		call rogue_set_buyauto_topHead 
	}
	]
}

macro rogue_set_buyauto_rightHand {
	call rogue_set_Dirk
	call rogue_set_Stiletto
	call rogue_set_Damascus
	[
	if ($Damascus{Equipped} == 1) {
		log Damascus is {Equipped} DAMNN
		
	} elsif ($Stiletto{Equipped} == 1 && $Damascus{CanEquip} == 0) {
		log Stiletto is {Equipped} and cannot equip Damascus DAMNN
		
	} elsif ($Stiletto{Equipped} == 1 && $Damascus{CanEquip} == 1 && $Damascus{CanBuy} == 0 && $Damascus{Has} == 0) {
		log Stiletto is equipped, can equip Damascus but cannot buy it DAMNN
		
	} elsif ($Dirk{Equipped} == 1 && $Damascus{CanEquip} == 0 && $Stiletto{CanEquip} == 0) {
		log Dirk is {Equipped} and cannot equip Damascus or Stiletto DAMNN
		
	} elsif ($Dirk{Equipped} == 1 && ($Damascus{CanEquip} == 1 || $Stiletto{CanEquip} == 1) && $Damascus{CanBuy} == 0 && $Stiletto{CanBuy} == 0 && $Damascus{Has} == 0 && $Stiletto{Has} == 0) {
		log Dirk is equipped, can equip better stuff but not buy it DAMNN
		
	} elsif ($Dirk{Equipped} == 0 && $Dirk{CanBuy} == 0 && $Dirk{Has} == 0) {
		log Dirk is not equipped, cannot buy it
		
	} elsif ($Damascus{Equipped} == 0 && $Damascus{CanEquip} == 1 && $Damascus{Has} >= 1) {
		call buyAuto_clear $Dirk{id}
		call buyAuto_clear $Stiletto{id}
		call buyAuto_clear $Damascus{id}
		call set_equip $Damascus{id} $Damascus{slot}
		
	} elsif ($Damascus{Equipped} == 0 && $Damascus{CanEquip} == 1 && $Damascus{Has} == 0 && $Damascus{CanBuy} == 1) {
		call buyAuto_clear $Dirk{id}
		call buyAuto_clear $Stiletto{id}
		call set_buyAuto $Damascus{id} $Damascus{price} $Damascus{npcMap} $Damascus{npcX} $Damascus{npcY}
		
	} elsif (($Damascus{CanEquip} == 0 || $Damascus{Has} == 0) && $Stiletto{Equipped} == 0 && $Stiletto{CanEquip} == 1 && $Stiletto{Has} >= 1) {
		call buyAuto_clear $Dirk{id}
		call buyAuto_clear $Stiletto{id}
		call set_equip $Stiletto{id} $Stiletto{slot}
		
	} elsif (($Damascus{CanEquip} == 0 || $Damascus{CanBuy} == 0) && $Stiletto{Equipped} == 0 && $Stiletto{CanEquip} == 1 && $Stiletto{Has} == 0 && $Stiletto{CanBuy} == 1) {
		call buyAuto_clear $Dirk{id}
		call set_buyAuto $Stiletto{id} $Stiletto{price} $Stiletto{npcMap} $Stiletto{npcX} $Stiletto{npcY}
		
	} elsif (($Damascus{CanEquip} == 0 || $Damascus{CanBuy} == 0) && ($Stiletto{CanEquip} == 0 || $Stiletto{Has} == 0) && $Dirk{Equipped} == 0 && $Dirk{CanEquip} == 1 && $Dirk{Has} >= 1) {
		call buyAuto_clear $Dirk{id}
		call set_equip $Dirk{id} $Dirk{slot}
		
	} elsif (($Damascus{CanEquip} == 0 || $Damascus{CanBuy} == 0) && ($Stiletto{CanEquip} == 0 || $Stiletto{CanBuy} == 0) && $Dirk{Equipped} == 0 && $Dirk{CanEquip} == 1 && $Dirk{Has} == 0 && $Dirk{CanBuy} == 1) {
		call set_buyAuto $Dirk{id} $Dirk{price} $Dirk{npcMap} $Dirk{npcX} $Dirk{npcY}
	}
	]
}

macro rogue_set_Dirk {
	[
	$item{id} = 1210
	$item{slot} = rightHand
	$item{price} = 8500
	$item{minLevel} = 12
	$item{npcMap} = payon_in01
	$item{npcX} = 76
	$item{npcY} = 58
	call set_item
	
	$Dirk{id} = $item{id}
	$Dirk{slot} = $item{slot}
	$Dirk{price} = $item{price}
	$Dirk{minLevel} = $item{minLevel}
	$Dirk{npcMap} = $item{npcMap}
	$Dirk{npcX} = $item{npcX}
	$Dirk{npcY} = $item{npcY}
	$Dirk{Has} = $item{Has}
	$Dirk{Equipped} = $item{Equipped}
	$Dirk{CanEquip} = $item{CanEquip}
	$Dirk{CanBuy} = $item{CanBuy}
	]
}

macro rogue_set_Stiletto {
	[
	$item{id} = 1216
	$item{slot} = rightHand
	$item{price} = 19500
	$item{minLevel} = 12
	$item{npcMap} = payon_in01
	$item{npcX} = 76
	$item{npcY} = 58
	call set_item
	
	$Stiletto{id} = $item{id}
	$Stiletto{slot} = $item{slot}
	$Stiletto{price} = $item{price}
	$Stiletto{minLevel} = $item{minLevel}
	$Stiletto{npcMap} = $item{npcMap}
	$Stiletto{npcX} = $item{npcX}
	$Stiletto{npcY} = $item{npcY}
	$Stiletto{Has} = $item{Has}
	$Stiletto{Equipped} = $item{Equipped}
	$Stiletto{CanEquip} = $item{CanEquip}
	$Stiletto{CanBuy} = $item{CanBuy}
	]
}

macro rogue_set_Damascus {
	[
	$item{id} = 1222
	$item{slot} = rightHand
	$item{price} = 49000
	$item{minLevel} = 24
	$item{npcMap} = payon_in01
	$item{npcX} = 76
	$item{npcY} = 58
	call set_item
	
	$Damascus{id} = $item{id}
	$Damascus{slot} = $item{slot}
	$Damascus{price} = $item{price}
	$Damascus{minLevel} = $item{minLevel}
	$Damascus{npcMap} = $item{npcMap}
	$Damascus{npcX} = $item{npcX}
	$Damascus{npcY} = $item{npcY}
	$Damascus{Has} = $item{Has}
	$Damascus{Equipped} = $item{Equipped}
	$Damascus{CanEquip} = $item{CanEquip}
	$Damascus{CanBuy} = $item{CanBuy}
	]
}

macro rogue_set_buyauto_armor {
	call rogue_set_AdventureSuit
	call rogue_set_Coat
	call rogue_set_ChainMail
	[
	if ($ChainMail{Equipped} == 1) {
		log ChainMail is {Equipped} DAMNN
		
	} elsif ($Coat{Equipped} == 1 && $ChainMail{CanEquip} == 0) {
		log Coat is {Equipped} and cannot equip ChainMail DAMNN
		
	} elsif ($Coat{Equipped} == 1 && $ChainMail{CanEquip} == 1 && $ChainMail{CanBuy} == 0 && $ChainMail{Has} == 0) {
		log Coat is equipped, can equip ChainMail but cannot buy it DAMNN
		
	} elsif ($AdventureSuit{Equipped} == 1 && $ChainMail{CanEquip} == 0 && $Coat{CanEquip} == 0) {
		log AdventureSuit is {Equipped} and cannot equip ChainMail or Coat DAMNN
		
	} elsif ($AdventureSuit{Equipped} == 1 && ($ChainMail{CanEquip} == 1 || $Coat{CanEquip} == 1) && $ChainMail{CanBuy} == 0 && $Coat{CanBuy} == 0 && $ChainMail{Has} == 0 && $Coat{Has} == 0) {
		log AdventureSuit is equipped, can equip better stuff but not buy it DAMNN
		
	} elsif ($AdventureSuit{Equipped} == 0 && $AdventureSuit{CanBuy} == 0 && $AdventureSuit{Has} == 0) {
		log AdventureSuit is not equipped, cannot buy it
		
	} elsif ($ChainMail{Equipped} == 0 && $ChainMail{CanEquip} == 1 && $ChainMail{Has} >= 1) {
		call buyAuto_clear $AdventureSuit{id}
		call buyAuto_clear $Coat{id}
		call buyAuto_clear $ChainMail{id}
		call set_equip $ChainMail{id} $ChainMail{slot}
		
	} elsif ($ChainMail{Equipped} == 0 && $ChainMail{CanEquip} == 1 && $ChainMail{Has} == 0 && $ChainMail{CanBuy} == 1) {
		call buyAuto_clear $AdventureSuit{id}
		call buyAuto_clear $Coat{id}
		call set_buyAuto $ChainMail{id} $ChainMail{price} $ChainMail{npcMap} $ChainMail{npcX} $ChainMail{npcY}
		
	} elsif (($ChainMail{CanEquip} == 0 || $ChainMail{Has} == 0) && $Coat{Equipped} == 0 && $Coat{CanEquip} == 1 && $Coat{Has} >= 1) {
		call buyAuto_clear $AdventureSuit{id}
		call buyAuto_clear $Coat{id}
		call set_equip $Coat{id} $Coat{slot}
		
	} elsif (($ChainMail{CanEquip} == 0 || $ChainMail{CanBuy} == 0) && $Coat{Equipped} == 0 && $Coat{CanEquip} == 1 && $Coat{Has} == 0 && $Coat{CanBuy} == 1) {
		call buyAuto_clear $AdventureSuit{id}
		call set_buyAuto $Coat{id} $Coat{price} $Coat{npcMap} $Coat{npcX} $Coat{npcY}
		
	} elsif (($ChainMail{CanEquip} == 0 || $ChainMail{CanBuy} == 0) && ($Coat{CanEquip} == 0 || $Coat{Has} == 0) && $AdventureSuit{Equipped} == 0 && $AdventureSuit{CanEquip} == 1 && $AdventureSuit{Has} >= 1) {
		call buyAuto_clear $AdventureSuit{id}
		call set_equip $AdventureSuit{id} $AdventureSuit{slot}
		
	} elsif (($ChainMail{CanEquip} == 0 || $ChainMail{CanBuy} == 0) && ($Coat{CanEquip} == 0 || $Coat{CanBuy} == 0) && $AdventureSuit{Equipped} == 0 && $AdventureSuit{CanEquip} == 1 && $AdventureSuit{Has} == 0 && $AdventureSuit{CanBuy} == 1) {
		call set_buyAuto $AdventureSuit{id} $AdventureSuit{price} $AdventureSuit{npcMap} $AdventureSuit{npcX} $AdventureSuit{npcY}
	}
	]
}

macro rogue_set_AdventureSuit {
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

macro rogue_set_Coat {
	[
	$item{id} = 2312
	$item{slot} = armor
	$item{price} = 48000
	$item{minLevel} = 25
	$item{npcMap} = payon_in01
	$item{npcX} = 76
	$item{npcY} = 70 
	call set_item
	
	$Coat{id} = $item{id}
	$Coat{slot} = $item{slot}
	$Coat{price} = $item{price}
	$Coat{minLevel} = $item{minLevel}
	$Coat{npcMap} = $item{npcMap}
	$Coat{npcX} = $item{npcX}
	$Coat{npcY} = $item{npcY}
	$Coat{Has} = $item{Has}
	$Coat{Equipped} = $item{Equipped}
	$Coat{CanEquip} = $item{CanEquip}
	$Coat{CanBuy} = $item{CanBuy}
	]
}

macro rogue_set_ChainMail {
	[
	$item{id} = 2316
	$item{slot} = armor
	$item{price} = 80000
	$item{minLevel} = 40
	$item{npcMap} = payon_in01
	$item{npcX} = 76
	$item{npcY} = 70 
	call set_item
	
	$ChainMail{id} = $item{id}
	$ChainMail{slot} = $item{slot}
	$ChainMail{price} = $item{price}
	$ChainMail{minLevel} = $item{minLevel}
	$ChainMail{npcMap} = $item{npcMap}
	$ChainMail{npcX} = $item{npcX}
	$ChainMail{npcY} = $item{npcY}
	$ChainMail{Has} = $item{Has}
	$ChainMail{Equipped} = $item{Equipped}
	$ChainMail{CanEquip} = $item{CanEquip}
	$ChainMail{CanBuy} = $item{CanBuy}
	]
}

macro rogue_set_buyauto_shoes {
	call rogue_set_Sandals
	call rogue_set_Shoes
	call rogue_set_Boots
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

macro rogue_set_Sandals {
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

macro rogue_set_Shoes {
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

macro rogue_set_Boots {
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

macro rogue_set_buyauto_topHead {
	call rogue_set_Hat
	call rogue_set_Cap
	call rogue_set_Cap
	[
	if ($Cap{Equipped} == 1) {
		log Cap is {Equipped} DAMNN
		
	} elsif ($Hat{Equipped} == 1 && $Cap{CanEquip} == 0) {
		log Hat is {Equipped} and cannot equip Cap DAMNN
		
	} elsif ($Hat{Equipped} == 1 && $Cap{CanEquip} == 1 && $Cap{CanBuy} == 0 && $Cap{Has} == 0) {
		log Hat is equipped, can equip better stuff but not buy it DAMNN
		
	} elsif ($Hat{Equipped} == 0 && $Hat{CanBuy} == 0 && $Hat{Has} == 0) {
		log Hat is not equipped, cannot buy it
		
	} elsif ($Cap{Equipped} == 0 && $Cap{CanEquip} == 1 && $Cap{Has} >= 1) {
		call buyAuto_clear $Hat{id}
		call buyAuto_clear $Cap{id}
		call set_equip $Cap{id} $Cap{slot}
		
	} elsif ($Cap{Equipped} == 0 && $Cap{CanEquip} == 1 && $Cap{Has} == 0 && $Cap{CanBuy} == 1) {
		call buyAuto_clear $Hat{id}
		call set_buyAuto $Cap{id} $Cap{price} $Cap{npcMap} $Cap{npcX} $Cap{npcY}
		
	} elsif (($Cap{CanEquip} == 0 || $Cap{CanBuy} == 0) && $Hat{Equipped} == 0 && $Hat{CanEquip} == 1 && $Hat{Has} >= 1) {
		call buyAuto_clear $Hat{id}
		call set_equip $Hat{id} $Hat{slot}
		
	} elsif (($Cap{CanEquip} == 0 || $Cap{CanBuy} == 0) && $Hat{Equipped} == 0 && $Hat{CanEquip} == 1 && $Hat{Has} == 0 && $Hat{CanBuy} == 1) {
		call set_buyAuto $Hat{id} $Hat{price} $Hat{npcMap} $Hat{npcX} $Hat{npcY}
	}
	]
}

macro rogue_set_Hat {
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

macro rogue_set_Cap {
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

macro rogue_set_buyauto_robe {
	call rogue_set_Hood
	call rogue_set_Muffler
	call rogue_set_Manteau
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

macro rogue_set_Hood {
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

macro rogue_set_Muffler {
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

macro rogue_set_Manteau {
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
	JobLevel = 50
	JobID 6
    exclusive 1
	priority 0
    call {
		do conf -f eventMacro_1_99_stage turning_rogue_true_start
		do conf -f doing_rogue_job_change start
		
		do conf -f Turn_rogue_lockMap_before &config(lockMap)
		do conf -f lockMap none
		
		include on Turn_Rogue_.pm
		
		do reload eventMacros
    }
}