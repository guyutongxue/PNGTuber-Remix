extends Node2D

enum Mouth {
	Closed,
	Open,
	Screaming
}

signal key_pressed

signal blink

signal reinfo
signal animation_state
signal slider_values
signal light_info

signal speaking
signal not_speaking

signal reinfoanim
signal remake_layers
signal update_layers
signal update_layer_visib
signal reparent_objects
signal reparent_layers

signal new_file
signal load_model

signal mode_changed
signal deselect
signal theme_update

signal update_pos_spins
signal update_offset_spins

signal delete_states
signal remake_states
signal remake_for_plus
signal reset_states

signal update_mouse_vel_pos

signal editing_for_changed

signal add_window
signal edit_windows

signal update_ui_pieces

# Remix version
@onready var version: String = ProjectSettings.get_setting("application/config/version")

var blink_timer : Timer = Timer.new()
var held_sprite = null
var held_sprites : Array[SpriteObject] = []
var tick = 0
var current_state : int = 0
var mouth := Mouth.Closed
var editing_for := Mouth.Closed:
	set(x):
		if x == editing_for: return
		editing_for = x
		editing_for_changed.emit()

var settings_dict : Dictionary = {
	sensitivity_limit = 1,
	volume_limit = 0.1,
	volume_delay = 0.5,
	blink_speed = 1,
	blink_chance = 10,
	checkinput = true,
	bg_color = Color.SLATE_GRAY,
	is_transparent = false,
	states = [{}],
	light_states = [{}],
	darken = false,
	anti_alias = true,

	dim_color = Color.DIM_GRAY,
	auto_save = false,
	auto_save_timer = 1.0,
	
	saved_inputs = [],
	zoom = Vector2(1,1),
	pan = Vector2(640, 360),
	
	should_delta = true,
	max_fps = 241,
	monitor = Monitor.ALL_SCREENS,
	cycles = [],
}

var mode: int = 1: set = set_mode


#var undo_redo : UndoRedo = UndoRedo.new()
var new_rot = 0
var static_view : bool = false
var spinbox_held : bool = false

var main = null
var sprite_container = null
var viewer = null
var viewport = null
var top_ui = null
var file_dialog : FileDialog = null
var light = null
var camera : Camera2D = null

var frame_counter := 0
const FRAME_INTERVAL := 3  # Run every 5 frames
var swtich_session_popup : Node = null

var save_path := ""
var is_editor := false:
	set(x):
		if x == is_editor: 
			is_editor = x
			return
		is_editor = x
		Settings.change_cursor()


var transparent_mode_active: = false
var previous_always_on_top: = false
var previous_transparent: = false
var previous_window_size: = Vector2(1280, 720)
var previous_ui_visible: = true
var previous_borderless: = false


var dragging_window: = false
var drag_offset: = Vector2.ZERO
var drag_smoothing_factor: = 0.8



func _ready():
	get_window().min_size = Vector2(50, 50)
	add_child(blink_timer)
	blinking()
	get_window().title = "PNGTuber-Remix V" + version
	current_state = 0
	key_pressed.connect(update_cycles)

func set_mode(new_mode) -> void:
	if new_mode == mode: return
	mode = new_mode
	
	match mode:
		0:
			get_viewport().transparent_bg = false
			RenderingServer.set_default_clear_color(Color.SLATE_GRAY)
			if main.has_node("%Control"):
				main.get_node("%Control").show()
			is_editor = true
		1:
			RenderingServer.set_default_clear_color(settings_dict.bg_color)
			get_viewport().transparent_bg = settings_dict.is_transparent
			if main.has_node("%Control"):
				main.get_node("%Control").hide()
			is_editor = false
			if light != null && is_instance_valid(light):
				light.get_node("Grab").hide()
			deselect.emit()
			static_view = false
	
	Settings.theme_settings.mode = mode
	Settings.save()
	mode_changed.emit(mode)


func blinking():
	blink_timer.wait_time = settings_dict.blink_speed
	blink_timer.start()
	await blink_timer.timeout
	var rand = randi() % int(settings_dict.blink_chance)
	if rand == 0:
		blink.emit()
	blinking()

func load_sprite_states(state):
	current_state = state
	for i in get_tree().get_nodes_in_group("Sprites"):
		i.get_state(current_state)
	if held_sprite != null && is_instance_valid(held_sprite):
		emit_signal("reinfo")
		
	animation_state.emit(current_state)
	light_info.emit(current_state)
	reinfoanim.emit()

func get_sprite_states(state):
	if state != current_state:
		for i in get_tree().get_nodes_in_group("Sprites"):
			i.save_state(current_state)
	
	current_state = state
	for i in get_tree().get_nodes_in_group("Sprites"):
		i.get_state(current_state)
	if held_sprite != null && is_instance_valid(held_sprite):
		emit_signal("reinfo")
		
	animation_state.emit(current_state)
	light_info.emit(current_state)
	update_layer_visib.emit()
	reinfoanim.emit()

func _input(event):
	if event.is_action_pressed("save"):
		if save_path:
			SaveAndLoad.save_file(save_path)
		else:
			main.save_as_file()
	if event.is_action_pressed("desel"):

		if held_sprite != null && is_instance_valid(held_sprite):
			if held_sprite.has_node("%Origin"):
				held_sprite.get_node("%Origin").hide()
		held_sprite = null
		deselect.emit()


	if Input.is_action_just_pressed("toggle_transparent_mode"):
		toggle_transparent_mode()


	if transparent_mode_active:
		handle_transparent_mode_scaling(event)
	for i in held_sprites:
		if i != null && is_instance_valid(i):
			if Input.is_action_pressed("ctrl"):
				if Input.is_action_pressed("scrollup"):
					i.sprite_data.rotation -= 0.05
					rot(i)

				elif Input.is_action_pressed("scrolldown"):
					i.sprite_data.rotation += 0.05
					rot(i)

func offset(i):
	i.get_node("%Sprite2D/Grab").anchors_preset = Control.LayoutPreset.PRESET_FULL_RECT
	i.sprite_data.position = i.position
	i.sprite_data.offset = i.get_node("%Sprite2D").position
	i.save_state(current_state)

	update_offset_spins.emit()

func _process(delta):
	if settings_dict.should_delta:
		tick = wrap(tick + delta, 0, 922337203685477630)
	else:
		tick = wrap(tick + 1, 0, 922337203685477630)
	#	print(tick)
	if !spinbox_held:
		moving_origin(delta)
		moving_sprite(delta)
		

func moving_origin(delta):
	for i in held_sprites:
		if i != null && is_instance_valid(i):
			if Input.is_action_pressed("up"):
				i.get_node("%Sprite2D").global_position.y += 10 * delta
				i.global_position.y -= 10 * delta
				offset(i)
			elif Input.is_action_pressed("down"):
				i.get_node("%Sprite2D").global_position.y -= 10 * delta
				i.global_position.y += 10 * delta
				offset(i)
			if Input.is_action_pressed("left"):
				i.get_node("%Sprite2D").global_position.x += 10 * delta
				i.global_position.x -= 10 * delta
				offset(i)
			elif Input.is_action_pressed("right"):
				i.get_node("%Sprite2D").global_position.x -= 10 * delta
				i.global_position.x += 10 * delta

				offset(i)
			
			
		if main.can_scroll:
			if Input.is_action_pressed("ctrl"):
				if Input.is_action_just_pressed("lmb"):
					var of = i.get_parent().to_local(i.get_parent().get_global_mouse_position()) - i.position
					i.position += of
					i.get_node("%Sprite2D").global_position -= of

					offset(i)

func rot(i):
	i.rotation = i.get_value("rotation")
	i.save_state(current_state)
	update_pos_spins.emit()

func moving_sprite(delta):
	for i in held_sprites:
		if i != null && is_instance_valid(i):
			if Input.is_action_pressed("w"):
				i.position.y -= 10 * delta
				i.sprite_data.position.y -= 10 * delta
				update_spins()
			elif Input.is_action_pressed("s_move"):
				i.position.y += 10 * delta
				i.sprite_data.position.y += 10 * delta
				update_spins()
				
			if Input.is_action_pressed("a"):
				i.position.x -= 10 * delta
				i.sprite_data.position.x -= 10 * delta
				update_spins()
				
			elif Input.is_action_pressed("d"):
				i.position.x += 10 * delta
				i.sprite_data.position.x += 10 * delta
				update_spins()

func update_spins():
	for i in held_sprites:
		if i != null && is_instance_valid(i):
			i.save_state(current_state)
			update_pos_spins.emit()

func toggle_transparent_mode():
	if !transparent_mode_active:

		previous_always_on_top = get_window().always_on_top
		previous_transparent = settings_dict.is_transparent
		previous_window_size = get_window().size
		previous_borderless = get_window().borderless


		if top_ui != null && is_instance_valid(top_ui):
			previous_ui_visible = top_ui.visible
		else:
			previous_ui_visible = true


		get_window().always_on_top = true
		settings_dict.is_transparent = true
		get_viewport().transparent_bg = true
		get_window().borderless = true


		var tween = create_tween()
		var current_size = get_window().size
		var target_size = Vector2(150, 150)


		tween.tween_method(
			func(size): get_window().size = size, 
			current_size, 
			current_size * 1.1, 
			0.1
		)
		tween.tween_method(
			func(size): get_window().size = size, 
			current_size * 1.1, 
			target_size, 
			0.2
		)


		initial_window_size = target_size


		if top_ui != null && is_instance_valid(top_ui):
			top_ui.hide()


		if main != null && is_instance_valid(main):
			if main.has_node("%Control"):
				main.get_node("%Control").hide()

		transparent_mode_active = true
		print("透明模式已激活 - 置顶: true, 透明: true, 窗口大小: 150x150, UI隐藏, 标题栏隐藏")
	else:

		get_window().always_on_top = previous_always_on_top
		settings_dict.is_transparent = previous_transparent
		get_viewport().transparent_bg = previous_transparent
		get_window().borderless = previous_borderless


		var tween = create_tween()
		var current_size = get_window().size
		var target_size = previous_window_size


		tween.tween_method(
			func(size): get_window().size = size, 
			current_size, 
			current_size * 0.9, 
			0.1
		)
		tween.tween_method(
			func(size): get_window().size = size, 
			current_size, 
			target_size, 
			0.2
		)


		if top_ui != null && is_instance_valid(top_ui):
			top_ui.visible = previous_ui_visible



		if main != null && is_instance_valid(main):
			if main.has_node("%Control"):
				main.get_node("%Control").hide()

		transparent_mode_active = false
		print("透明模式已恢复 - 置顶: ", previous_always_on_top, " 透明: ", previous_transparent, " 窗口大小: ", previous_window_size, " 标题栏恢复")


	Settings.theme_settings.always_on_top = get_window().always_on_top
	Settings.save()


var initial_window_size: = Vector2.ZERO

func handle_transparent_mode_scaling(event: InputEvent):
	if event is InputEventMouseButton and Input.is_action_pressed("ctrl"):
		if event.button_index == 4:
			if event.pressed:

				var current_size = get_window().size
				var scale_factor = 1.1
				var new_size = current_size * scale_factor

				if new_size.x <= 450 and new_size.y <= 450:
					get_window().size = new_size

		elif event.button_index == 5:
			if event.pressed:

				var current_size = get_window().size
				var scale_factor = 0.9
				var new_size = current_size * scale_factor

				if new_size.x >= 75 and new_size.y >= 75:
					get_window().size = new_size


	elif event is InputEventMouseButton:
		if event.button_index == 2:
			if event.pressed:

				dragging_window = true

				drag_offset = event.global_position - Vector2(get_window().position)

				if transparent_mode_active:
					get_window().borderless = false
			else:

				dragging_window = false

				if transparent_mode_active:
					get_window().borderless = true


func _physics_process(_delta: float) -> void :
	mouse_delay()


	if dragging_window:
		var target_position = Vector2(DisplayServer.mouse_get_position())
		get_window().position = Vector2i(target_position)


func mouse_delay():
	frame_counter += 1
	if frame_counter >= FRAME_INTERVAL:
		update_mouse_vel_pos.emit()
		frame_counter = 0


func update_cycles(key):
	for cycle in settings_dict.cycles:
		if cycle.sprites.size() > 0:
			if cycle.toggle.as_text() == key:
				cycle.active = !cycle.active
				
				if cycle.active:
					var array = cycle.sprites.duplicate()
					if array.has(cycle.last_sprite):
						array.remove_at(array.find(cycle.last_sprite))

					var rand = array.pick_random()
					cycle.last_sprite = rand
					cycle.pos = cycle.sprites.find(rand)
					for sprite in get_tree().get_nodes_in_group("Sprites"):
						if sprite.sprite_id in cycle.sprites && sprite.get_value("is_cycle"):
							sprite.get_node("%Drag").hide()
							sprite.was_active_before = sprite.get_node("%Drag").visible
						
						if sprite.sprite_id == rand && sprite.get_value("is_cycle"):
							sprite.get_node("%Drag").show()
							sprite.was_active_before = sprite.get_node("%Drag").visible
					
					
				elif !cycle.active:
					for sprite in get_tree().get_nodes_in_group("Sprites"):
						if sprite.sprite_id in cycle.sprites && sprite.get_value("is_cycle"):
							sprite.get_node("%Drag").hide()
							sprite.was_active_before = sprite.get_node("%Drag").visible
						
					#print(rand)
					
			elif cycle.forward.as_text() == key:
				cycle.pos = wrap(cycle.pos +1,0 ,  cycle.sprites.size() - 1)
				cycle.last_sprite = cycle.sprites[cycle.pos]
				for sprite in get_tree().get_nodes_in_group("Sprites"):
					if sprite.sprite_id in cycle.sprites && sprite.get_value("is_cycle"):
						sprite.get_node("%Drag").hide()
						sprite.was_active_before = sprite.get_node("%Drag").visible
					
					if sprite.sprite_id == cycle.last_sprite && sprite.get_value("is_cycle"):
						sprite.get_node("%Drag").show()
						sprite.was_active_before = sprite.get_node("%Drag").visible
				
			elif cycle.backward.as_text() == key:
				cycle.pos = wrap(cycle.pos -1,0 ,  cycle.sprites.size() - 1)
				cycle.last_sprite = cycle.sprites[cycle.pos]
				for sprite in get_tree().get_nodes_in_group("Sprites"):
					if sprite.sprite_id in cycle.sprites && sprite.get_value("is_cycle"):
						sprite.get_node("%Drag").hide()
						sprite.was_active_before = sprite.get_node("%Drag").visible
					
					if sprite.sprite_id == cycle.last_sprite && sprite.get_value("is_cycle"):
						sprite.get_node("%Drag").show()
						sprite.was_active_before = sprite.get_node("%Drag").visible

func update_camera_smoothing() -> void:
	if !is_instance_valid(camera): return
	camera.position_smoothing_enabled = Settings.theme_settings.floaty_panning
