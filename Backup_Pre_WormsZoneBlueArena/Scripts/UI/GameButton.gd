class_name GameButton
extends Button

@export var click_pitch: float = 660.0
@export var animate_scale: bool = true

var _original_scale: Vector2 = Vector2.ONE
var _tween: Tween

func _ready() -> void:
	pivot_offset = size / 2.0
	resized.connect(func(): pivot_offset = size / 2.0)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)
	pressed.connect(_on_pressed)

func _on_mouse_entered() -> void:
	if not animate_scale or disabled:
		return
	if _tween and _tween.is_valid():
		_tween.kill()
	_tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "scale", _original_scale * 1.03, 0.16)

func _on_mouse_exited() -> void:
	if not animate_scale:
		return
	if _tween and _tween.is_valid():
		_tween.kill()
	_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "scale", _original_scale, 0.16)

func _on_button_down() -> void:
	if not animate_scale:
		return
	if _tween and _tween.is_valid():
		_tween.kill()
	_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "scale", _original_scale * 0.96, 0.08)

func _on_button_up() -> void:
	if not animate_scale:
		return
	if _tween and _tween.is_valid():
		_tween.kill()
	_tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "scale", _original_scale, 0.12)

func _on_pressed() -> void:
	SoundManager.play_click(click_pitch)
