
automacro LastBradeBug {
    NpcMsg /(Você ainda está fazendo o curso do instrutor Brade|You are still in the process of training with sir Brad)/
    exclusive 1
    priority 0
    call Brade_Bugged
}

macro Brade_Bugged {
	if ($.map = new_1-3 || $.map = new_2-3 || $.map = new_3-3 || $.map = new_4-3 || $.map = new_5-3) {
		do move 99 31
	} elsif ($.map = new_1-4 || $.map = new_2-4 || $.map = new_3-4 || $.map = new_4-4 || $.map = new_5-4) {
		$previousMap = previousMap("$.map")
		do move $previousMap 99 31
	}
	do talk &npc(/Brade/)
}