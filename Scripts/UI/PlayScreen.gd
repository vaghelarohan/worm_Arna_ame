extends Control

@onready var arena = $ContentStage/Arena
@onready var hud: Control = $ContentStage/Hud
@onready var minimap: Control = $ContentStage/MiniMap
@onready var left_joystick: Control = $ContentStage/VirtualJoystick
@onready var right_joystick: Control = $ContentStage/RightJoystick
@onready var joystick: Control = $ContentStage/VirtualJoystick
@onready var power_bar: Control = $ContentStage/PowerUpBar
@onready var boost_btn: Control = $ContentStage/BoostButton
@onready var overlay_layer: Control = $OverlayLayer

var pause_scene: PackedScene = preload("res://Scenes/Gameplay/PauseMenu.tscn")
var over_scene: PackedScene = preload("res://Scenes/Gameplay/GameOverScreen.tscn")
var settings_scene: PackedScene = preload("res://Scenes/Menus/SettingsModal.tscn")
var modal_scene: PackedScene = preload("res://Scenes/Components/GameModal.tscn")

var engine: GameEngine
var is_paused: bool = false
var has_recorded_over: bool = false

const MOUSE_TOUCH_INDEX: int = 9999
enum PrioritySide { NONE, LEFT, RIGHT }
var _last_priority: PrioritySide = PrioritySide.NONE

func _ready() -> void:
	engine = GameEngine.new()
	engine.init_game(GameManager.selected_mode, GameManager.match_duration_minutes)
	
	arena.engine = engine
	arena.setup_decor(engine.decor)
	minimap.engine = engine
	
	hud.pause_pressed.connect(_on_pause)
	left_joystick.joystick_moved.connect(func(_vec, _active): _update_combined_steering())
	right_joystick.joystick_moved.connect(func(_vec, _active): _update_combined_steering())
	power_bar.power_used.connect(_on_power_used)
	boost_btn.boost_toggled.connect(_on_boost_toggled)
	
	engine.kill_occurred.connect(func(v_name, v_col, reward):
		hud.show_kill_notification(v_name, v_col, reward)
	)
	engine.worm_died.connect(func(victim_name, killer_name, is_pv, is_pk, v_col):
		hud.add_death_notification(victim_name, killer_name, is_pv, is_pk, v_col)
	)
	SoundManager.play_bgm("gameplay")

func _input(event: InputEvent) -> void:
	if is_paused or (engine and engine.over) or overlay_layer.get_child_count() > 0:
		return
	
	# Touch input
	if event is InputEventScreenTouch:
		if event.pressed:
			_handle_touch_down(event.position, event.index)
		else:
			_handle_touch_up(event.index)
	elif event is InputEventScreenDrag:
		_handle_touch_drag(event.position, event.index)
	# Mouse input fallback for PC
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_handle_touch_down(event.position, MOUSE_TOUCH_INDEX)
		else:
			_handle_touch_up(MOUSE_TOUCH_INDEX)
	elif event is InputEventMouseMotion:
		_handle_touch_drag(event.position, MOUSE_TOUCH_INDEX)

func _is_touch_on_interactive_ui(pos: Vector2) -> bool:
	if is_paused or overlay_layer.get_child_count() > 0:
		return true
	
	# Top HUD area (Player Badge, Kills, Timer, Coins, PauseBtn)
	if pos.y < 110.0:
		return true
	
	# Pause button check
	if hud and is_instance_valid(hud.pause_btn) and hud.pause_btn.is_visible_in_tree():
		if hud.pause_btn.get_global_rect().grow(16.0).has_point(pos):
			return true
	
	# Boost button check
	if boost_btn and is_instance_valid(boost_btn) and boost_btn.is_visible_in_tree():
		if boost_btn.get_global_rect().grow(16.0).has_point(pos):
			return true
	
	# Power-up bar check
	if power_bar and is_instance_valid(power_bar) and power_bar.is_visible_in_tree():
		if power_bar.get_global_rect().grow(12.0).has_point(pos):
			return true
	
	# Mini-map check
	if minimap and is_instance_valid(minimap) and minimap.is_visible_in_tree():
		if minimap.get_global_rect().grow(10.0).has_point(pos):
			return true
	
	return false

func _handle_touch_down(pos: Vector2, idx: int) -> void:
	if _is_touch_on_interactive_ui(pos):
		return
	
	var vp_size := get_viewport_rect().size
	var split_x := vp_size.x * 0.5
	
	if pos.x < split_x:
		# LEFT SIDE TOUCH
		if not left_joystick.is_dragging_active:
			var left_bounds := Rect2(0.0, 110.0, split_x, vp_size.y - 110.0)
			left_joystick.activate_at(pos, idx, left_bounds)
			_last_priority = PrioritySide.LEFT
			_update_combined_steering()
	else:
		# RIGHT SIDE TOUCH
		if not right_joystick.is_dragging_active:
			var right_bounds := Rect2(split_x, 110.0, vp_size.x - split_x, vp_size.y - 110.0)
			right_joystick.activate_at(pos, idx, right_bounds)
			_last_priority = PrioritySide.RIGHT
			_update_combined_steering()

func _handle_touch_drag(pos: Vector2, idx: int) -> void:
	var updated := false
	if left_joystick.is_dragging_active and left_joystick.touch_index == idx:
		left_joystick.update_touch(pos)
		updated = true
	if right_joystick.is_dragging_active and right_joystick.touch_index == idx:
		right_joystick.update_touch(pos)
		updated = true
	if updated:
		_update_combined_steering()

func _handle_touch_up(idx: int) -> void:
	var released := false
	if left_joystick.is_dragging_active and left_joystick.touch_index == idx:
		left_joystick.release_touch()
		released = true
	if right_joystick.is_dragging_active and right_joystick.touch_index == idx:
		right_joystick.release_touch()
		released = true
	if released:
		_update_combined_steering()

func _update_combined_steering() -> void:
	var left_act: bool = left_joystick.is_dragging_active
	var right_act: bool = right_joystick.is_dragging_active
	
	if left_act and right_act:
		# Both joysticks active: predictable priority (most recently touched side)
		if _last_priority == PrioritySide.RIGHT:
			if right_joystick.current_vector != Vector2.ZERO:
				engine.input_dir = right_joystick.current_vector
			elif left_joystick.current_vector != Vector2.ZERO:
				engine.input_dir = left_joystick.current_vector
			else:
				engine.input_dir = Vector2.ZERO
		else:
			if left_joystick.current_vector != Vector2.ZERO:
				engine.input_dir = left_joystick.current_vector
			elif right_joystick.current_vector != Vector2.ZERO:
				engine.input_dir = right_joystick.current_vector
			else:
				engine.input_dir = Vector2.ZERO
	elif left_act:
		_last_priority = PrioritySide.LEFT
		engine.input_dir = left_joystick.current_vector
	elif right_act:
		_last_priority = PrioritySide.RIGHT
		engine.input_dir = right_joystick.current_vector
	else:
		_last_priority = PrioritySide.NONE
		engine.input_dir = Vector2.ZERO

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.pressed and event.keycode == KEY_P):
		_on_pause()
		get_viewport().set_input_as_handled()
		return
	
	if event is InputEventKey and event.pressed:
		if event.keycode >= KEY_1 and event.keycode <= KEY_5:
			var powers = ["magnet", "speed", "shield", "double", "xp"]
			var idx: int = event.keycode - KEY_1
			if idx < powers.size():
				_on_power_used(powers[idx])
				get_viewport().set_input_as_handled()
				return
		
		if event.keycode == KEY_SPACE:
			_on_boost_toggled(true)
			get_viewport().set_input_as_handled()
	elif event is InputEventKey and not event.pressed:
		if event.keycode == KEY_SPACE:
			_on_boost_toggled(false)
			get_viewport().set_input_as_handled()

func _process(_delta: float) -> void:
	# Keyboard direction input for PC
	var k_dir := Vector2.ZERO
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		k_dir.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		k_dir.x += 1.0
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		k_dir.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		k_dir.y += 1.0
	
	if k_dir != Vector2.ZERO:
		engine.input_dir = k_dir.normalized()

func _physics_process(delta: float) -> void:
	if is_paused:
		return
	
	if not engine.over:
		engine.step(delta)
	elif not has_recorded_over:
		has_recorded_over = true
		_on_game_over()
	
	var data := engine.get_hud_data()
	hud.update_hud(data)
	power_bar.update_hud(data)
	boost_btn.set_boosting(data["boosting"])

func _on_joystick_moved(vec: Vector2, active: bool) -> void:
	# Backwards compatibility
	if active:
		engine.input_dir = vec
	else:
		engine.input_dir = Vector2.ZERO

func _on_boost_toggled(active: bool) -> void:
	if active and not engine.input_boost:
		SoundManager.play_boost(true)
	engine.input_boost = active

func _on_power_used(id: String) -> void:
	if engine.use_power(id):
		SoundManager.play_click(990.0)

func _on_pause() -> void:
	if engine.over:
		return
	is_paused = true
	left_joystick.cancel()
	right_joystick.cancel()
	engine.input_dir = Vector2.ZERO
	SoundManager.play_click(440.0)
	
	var pm = pause_scene.instantiate()
	overlay_layer.add_child(pm)
	
	pm.resume_pressed.connect(func():
		is_paused = false
		pm.queue_free()
		SoundManager.play_click()
	)
	pm.restart_pressed.connect(func():
		pm.queue_free()
		_restart_game()
	)
	pm.settings_pressed.connect(func():
		var sm = modal_scene.instantiate()
		overlay_layer.add_child(sm)
		sm.set_title("SETTINGS")
		sm.set_content(settings_scene.instantiate())
	)
	pm.menu_pressed.connect(func():
		GameManager.return_to_main_menu()
	)

func _restart_game() -> void:
	is_paused = false
	has_recorded_over = false
	left_joystick.cancel()
	right_joystick.cancel()
	for c in overlay_layer.get_children():
		c.queue_free()
	engine.init_game(GameManager.selected_mode, GameManager.match_duration_minutes)
	arena.setup_decor(engine.decor)
	var data := engine.get_hud_data()
	hud.update_hud(data)
	power_bar.update_hud(data)
	boost_btn.set_boosting(false)
	SoundManager.play_click()
	SoundManager.play_bgm("gameplay")

func _on_game_over() -> void:
	left_joystick.cancel()
	right_joystick.cancel()
	engine.input_dir = Vector2.ZERO
	SoundManager.play_click(200.0)
	engine.shake = 0.0
	
	var final_score := int(engine.player["score"])
	var old_best: int = GameManager.best_score
	GameManager.record_game_result(final_score, engine.kills, engine.coins_earned)
	
	await get_tree().create_timer(0.7).timeout
	
	var go = over_scene.instantiate()
	overlay_layer.add_child(go)
	go.set_stats(final_score, engine.kills, engine.coins_earned, old_best)
	
	go.again_pressed.connect(func():
		_restart_game()
	)
	go.menu_pressed.connect(func():
		GameManager.return_to_main_menu()
	)
