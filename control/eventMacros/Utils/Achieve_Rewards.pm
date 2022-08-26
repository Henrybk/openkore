
sub get_next_Gift_Box_achievements {
	my %ids = (
		129001 => 1,
		129002 => 1,
		129003 => 1,
		129004 => 1,
		129005 => 1,
		129006 => 1,
		129007 => 1,
		129008 => 1,
		129009 => 1,
		129010 => 1,
		129011 => 1,
		129012 => 1,
		129014 => 1,
		129015 => 1,
		129017 => 1,
		129018 => 1,
		240001 => 1,
		240002 => 1,
		240003 => 1,
		240004 => 1,
		240005 => 1,
		240006 => 1,
		240007 => 1,
		240008 => 1,
		240009 => 1,
		240010 => 1,
		240011 => 1,
		240012 => 1,
		240013 => 1,
		240014 => 1,
		240015 => 1,
		240016 => 1,
		240017 => 1,
		240018 => 1,
		240019 => 1,
		240020 => 1
	);
	foreach my $achieve_id (keys %{$achievementList}) {
		my $achieve = $achievementList->{$achieve_id};
		if (exists $ids{$achieve_id} && $achieve->{completed} && $achieve->{reward} != 1) {
			Commands::run("achieve reward $achieve_id");
			return 1;
		}
	}
	return 0;
}

sub get_next_Old_Violet_Box_achievements {
	my %ids = (
		129008 => 1,
		129013 => 1,
		129016 => 1,
		129019 => 1,
		129020 => 1,
		200003 => 1
	);
	foreach my $achieve_id (keys %{$achievementList}) {
		my $achieve = $achievementList->{$achieve_id};
		if (exists $ids{$achieve_id} && $achieve->{completed} && $achieve->{reward} != 1) {
			Commands::run("achieve reward $achieve_id");
			return 1;
		}
	}
	return 0;
}

sub next_rodex_action {
	if (!defined $rodexList) {
		Commands::run('rodex open');
		return 1;
		
	} else {
	
		if (exists $rodexList->{current_read}) {
			if ($rodexList->{mails}{$rodexList->{current_read}}{zeny1} != 0) {
				Commands::run('rodex getzeny');
				return 1;
			} elsif (scalar @{$rodexList->{mails}{$rodexList->{current_read}}{items}} != 0) {
				Commands::run('rodex getitems');
				return 1;
			}
		}
		
		foreach my $mail_id (keys %{$rodexList->{mails}}) {
			my $mail = $rodexList->{mails}{$mail_id};
			
			next if ($mail->{isRead});
			
			Commands::run("rodex read $mail_id");
			return 1;
		}
		
		Commands::run("rodex close");
		return 0;
	}
}

sub get_box_index {
	my $gift = $char->inventory->getByNameID(644);
	if (defined $gift) {
		return $gift->{binID};
	}
	
	my $purple = $char->inventory->getByNameID(617);
	if (defined $purple) {
		return $purple->{binID};
	}
	
	return -1;
}

automacro Check_achieve_timer {
	timeout 1800
	exclusive 1
	InCity 1
	priority 3
	StorageOpened 0
	ConfigKey eventMacro_1_99_stage leveling
	CharCurrentWeight < 48%
	call start_achieve_check
}

macro start_achieve_check {
	[
	do conf -f achieve_stage_before &config(eventMacro_1_99_stage)
	do conf -f eventMacro_1_99_stage achieve_system
	]
}

automacro achieve_timer {
	ConfigKey eventMacro_1_99_stage achieve_system
	exclusive 1
	priority 1
	call achieve_system
}

macro achieve_system {
	
	$stage = 0
	$lastIndex = -1
	$lastAmount = 0
	$fails = 0
	
	while ($stage < 4) {
	
		pause 1
	
		if ($stage = 0) {
			$giftBoxAchieve = get_next_Gift_Box_achievements()
			if ($giftBoxAchieve = 0) {
				$stage++
			}
			
		} elsif ($stage = 1) {
			$violetBoxAchieve = get_next_Old_Violet_Box_achievements()
			if ($violetBoxAchieve = 0) {
				$stage++
			}
			
		} elsif ($stage = 2) {
			$rodexRead = next_rodex_action()
			if ($rodexRead = 0) {
				$stage++
			}
			
		} elsif ($stage = 3) {
			$boxIndex = get_box_index()
			if ($boxIndex != -1) {
				if ($lastIndex = $boxIndex && &invamount($boxIndex) = $lastAmount) {
					$fails++
					log An error happenned while tring to open gift of purple boxes, fail: $fails
				} else {
					$lastIndex = $boxIndex
					$lastAmount = $boxIndex
				}
				
				if ($fails >= 3) {
					log An error happenned while tring to open at least $fails times, resuming normal activity
					$stage++
				} else {
					do is $boxIndex
				}
			} else {
				$stage++
			}
		}
	
	}
	
	do conf -f eventMacro_1_99_stage &config(achieve_stage_before)
	do conf -f achieve_stage_before none
}
