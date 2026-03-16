extends BackgroundInputCapture

var keys : Array = []
var already_input_keys : Array = []

func _ready() -> void:
	bg_key_pressed.connect(_on_background_input_capture_bg_key_pressed)

func _on_background_input_capture_bg_key_pressed(_node, keys_pressed : Dictionary):
	if Global.settings_dict.checkinput:
		
		var has_number_key = false
		for i in keys_pressed:
			if keys_pressed[i]:
				var key_string = OS.get_keycode_string(i)
				if key_string in ["4", "5", "6", "7", "8", "9", "0"]:
					has_number_key = true
					break

		var ctrl_pressed = keys_pressed.get(KEY_CTRL, false)

		if has_number_key and not ctrl_pressed:
			return

		var keyStrings = []
		var costumeKeys = []
		
		for l in get_tree().get_nodes_in_group("StateButtons"):
			if InputMap.action_get_events(l.input_key).size() > 0:
				costumeKeys.append(InputMap.action_get_events(l.input_key)[0].as_text())
				
		for l in Global.settings_dict.cycles:
			if l.toggle != null:
				costumeKeys.append(l.toggle.as_text())
			if l.forward != null:
				costumeKeys.append(l.forward.as_text())
				
			if l.backward != null:
				costumeKeys.append(l.backward.as_text())
				
				
		for l in get_tree().get_nodes_in_group("Sprites"):
			if InputMap.action_get_events(str(l.sprite_id)).size() > 0:
				costumeKeys.append(InputMap.action_get_events(str(l.sprite_id))[0].as_text())
			for j in l.saved_keys:
				costumeKeys.append(j)
		
		for i in keys_pressed:
			if keys_pressed[i]:
				if OS.get_keycode_string(i) not in already_input_keys:
					keyStrings.append(OS.get_keycode_string(i))
					
		
		already_input_keys = keyStrings
		
		if Global.file_dialog != null && is_instance_valid(Global.file_dialog):
			if Global.file_dialog.visible:
				return
			
		
		for key in keyStrings:
			var e = InputEventKey.new()
			e.keycode = OS.find_keycode_from_string(key)
			e.alt_pressed = keys_pressed.get(KEY_ALT, false)
			e.shift_pressed = keys_pressed.get(KEY_SHIFT, false)
			e.ctrl_pressed = keys_pressed.get(KEY_CTRL, false)
			e.meta_pressed = keys_pressed.get(KEY_META, false)
			
			var matched_hotkey = ""
			var i = costumeKeys.find(e.as_text())
			
			if i == -1 and ctrl_pressed and key in ["4", "5", "6", "7", "8", "9", "0"]:
				i = costumeKeys.find(key)
				if i != -1:
					matched_hotkey = key
			
			if i >= 0:
				if matched_hotkey.is_empty():
					matched_hotkey = costumeKeys[i]
				if matched_hotkey not in keys:
					Global.key_pressed.emit(matched_hotkey)
					keys.append(matched_hotkey)
	
	keys = []
