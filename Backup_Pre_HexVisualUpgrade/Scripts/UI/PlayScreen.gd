extends Control

@onready var arena = $ContentStage/ViewportContainer/SubViewport/Arena3D
@onready var hud: Control = $ContentStage/Hud
@onready var minimap: Control = $ContentStage/MiniMap
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

var _keys_pressed: Dictionary = {}

func _ready() -> void:
	engine = GameEngine.new()
	engine.init_game(GameManager.selected_mode, GameManager.match_duration_minutes)
	
	arena.engine = engine
	arena.setup_decor(engine.decor)
	minimap.engine = engine
	
	hud.pause_pressed.connect(_on_pause)
	joystick.joystick_moved.connect(_on_joystick_moved)
	power_bar.power_used.connect(_on_power_used)
	boost_btn.boost_toggled.connect(_on_boost_toggled)

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
	# Keyboard direction input
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
	if active:
		engine.input_dir = vec
	else:
		engine.input_dir = Vector2.ZERO

func _on_boost_toggled(active: bool) -> void:
	engine.input_boost = active

func _on_power_used(id: String) -> void:
	if engine.use_power(id):
		SoundManager.play_click(990.0)

func _on_pause() -> void:
	if engine.over:
		return
	is_paused = true
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
	for c in overlay_layer.get_children():
		c.queue_free()
	engine.init_game(GameManager.selected_mode, GameManager.match_duration_minutes)
	arena.setup_decor(engine.decor)
	SoundManager.play_click()

func _on_game_over() -> void:
	SoundManager.play_click(200.0)
	
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

