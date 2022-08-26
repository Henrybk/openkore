

# Equipping items

automacro EquipItems {
	priority 2
	exclusive 1
	ConfigKey eventMacro_1_99_stage equipping_items
	call {
		$return = get_next_to_be_equipped_item()
		if ($return != -1) {
			$slot = &arg("$return", 1)
			$id = &arg("$return", 2)
			do eq $slot $id
			pause 1
			
		} else {
			[
			$return = undef
			$slot = undef
			$id = undef
			do conf -f eventMacro_1_99_stage &config(equipItems_stage_before)
			do conf -f equipItems_stage_before none
			
			include off Equip_Items.pm
			include on &config(before_event_include)
			
			do conf -f current_event_include &config(before_event_include)
			do conf -f before_event_include none
			
			do reload eventMacros
			
			]
		}
	}
}