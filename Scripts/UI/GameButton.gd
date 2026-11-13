class_name GameButton
extends Button

signal selection_toggled(selected: bool)

@export var click_pitch: float = 660.0
@export var animate_scale: bool = true
@export var animate_glow: bool = true
@export var hover_scale: float = 1.04
@export var pressed_scale: float = 0.95
@export var hover_duration: float = 0.16

@export var style_normal: StyleBox
@export var style_hover: StyleBox
@export var style_pressed: StyleBox
@export var style_selected: StyleBox
@export var style_selected_hover: StyleBox

var is_selected: bool = false:
	set(v):
		is_selected = v
		_update_styles()
		selection_toggled.emit(is_selected)

var _is_hovered: bool = false
var _is_pressed: bool = false
var _original_scale: Vector2 = Vector2.ONE
var _tween: Tween

func _ready() -> void:
	_update_pivot()
	if not resized.is_connected(_update_pivot):
		resized.connect(_update_pivot)
	
	if not mouse_entered.is_connected(_on_mouse_entered):
		mouse_entered.connect(_on_mouse_entered)
	if not mouse_exited.is_connected(_on_mouse_exited):
		mouse_exited.connect(_on_mouse_exited)
	if not button_down.is_connected(_on_button_down):
		button_down.connect(_on_button_down)
	if not button_up.is_connected(_on_button_up):
		button_up.connect(_on_button_up)
	if not pressed.is_connected(_on_pressed):
		pressed.connect(_on_pressed)
	
	_update_styles()

func _update_pivot() -> void:
	if size.x > 0.0 and size.y > 0.0:
		pivot_offset = size * 0.5

func _update_styles() -> void:
	if is_selected and style_selected:
		var target_style = style_selected_hover if (_is_hovered and style_selected_hover) else style_selected
		add_theme_stylebox_override("normal", target_style)
		add_theme_stylebox_override("hover", target_style)
		add_theme_stylebox_override("focus", target_style)
		if style_pressed:
			add_theme_stylebox_override("pressed", style_pressed)
	else:
		if style_normal:
			add_theme_stylebox_override("normal", style_normal)
			add_theme_stylebox_override("focus", style_normal)
		if style_hover:
			add_theme_stylebox_override("hover", style_hover)
		if style_pressed:
			add_theme_stylebox_override("pressed", style_pressed)

func _on_mouse_entered() -> void:
	if disabled:
		return
	_is_hovered = true
	_update_pivot()
	_update_styles()
	
	if not animate_scale:
		return
	if _tween and _tween.is_valid():
		_tween.kill()
	_tween = create_tween().set_parallel(true)
	_tween.tween_property(self, "scale", _original_scale * hover_scale, hover_duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if animate_glow:
		_tween.tween_property(self, "self_modulate", Color(1.12, 1.12, 1.16), hover_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _on_mouse_exited() -> void:
	_is_hovered = false
	_update_styles()
	
	if not animate_scale:
		return
	if _tween and _tween.is_valid():
		_tween.kill()
	_tween = create_tween().set_parallel(true)
	var target_scale: Vector2 = _original_scale
	_tween.tween_property(self, "scale", target_scale, hover_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if animate_glow:
		_tween.tween_property(self, "self_modulate", Color(1.0, 1.0, 1.0), hover_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _on_button_down() -> void:
	if disabled:
		return
	_is_pressed = true
	_update_pivot()
	
	if not animate_scale:
		return
	if _tween and _tween.is_valid():
		_tween.kill()
	_tween = create_tween().set_parallel(true)
	_tween.tween_property(self, "scale", _original_scale * pressed_scale, 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if animate_glow:
		_tween.tween_property(self, "self_modulate", Color(0.92, 0.92, 0.95), 0.08)

func _on_button_up() -> void:
	if disabled:
		return
	_is_pressed = false
	_update_pivot()
	
	if not animate_scale:
		return
	if _tween and _tween.is_valid():
		_tween.kill()
	_tween = create_tween().set_parallel(true)
	var target_scale: Vector2 = _original_scale * hover_scale if _is_hovered else _original_scale
	var target_glow: Color = Color(1.12, 1.12, 1.16) if _is_hovered else Color(1.0, 1.0, 1.0)
	_tween.tween_property(self, "scale", target_scale, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if animate_glow:
		_tween.tween_property(self, "self_modulate", target_glow, 0.12)

func _on_pressed() -> void:
	SoundManager.play_click(click_pitch)
