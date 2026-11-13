extends Control

signal joystick_moved(vec: Vector2, active: bool)

const JS_SIZE: float = 280.0
const MAX_RADIUS: float = 100.0
const DEADZONE: float = 8.0

@onready var base: Panel = $Base
@onready var knob: Control = $Knob

var _dragging: bool = false
var _touch_index: int = -1
var _center: Vector2 = Vector2.ZERO
var _current_vector: Vector2 = Vector2.ZERO
var _tween_fade: Tween
var _tween_knob: Tween

var is_dragging_active: bool:
	get:
		return _dragging

var touch_index: int:
	get:
		return _touch_index

var current_vector: Vector2:
	get:
		return _current_vector

func _ready() -> void:
	custom_minimum_size = Vector2(JS_SIZE, JS_SIZE)
	size = Vector2(JS_SIZE, JS_SIZE)
	pivot_offset = size * 0.5
	visible = false
	modulate.a = 0.0
	_center = global_position + size * 0.5
	_reset_knob_position()

func activate_at(touch_pos: Vector2, touch_idx: int, clamp_bounds: Rect2 = Rect2()) -> void:
	var half := JS_SIZE * 0.5
	var target_center := touch_pos
	
	if clamp_bounds.size != Vector2.ZERO:
		var min_c := clamp_bounds.position + Vector2(half, half)
		var max_c := clamp_bounds.end - Vector2(half, half)
		target_center.x = clampf(touch_pos.x, min_c.x, max(min_c.x, max_c.x))
		target_center.y = clampf(touch_pos.y, min_c.y, max(min_c.y, max_c.y))
	
	global_position = target_center - Vector2(half, half)
	_center = global_position + Vector2(half, half)
	
	_dragging = true
	_touch_index = touch_idx
	_current_vector = Vector2.ZERO
	_reset_knob_position()
	
	if _tween_fade and _tween_fade.is_valid():
		_tween_fade.kill()
	visible = true
	scale = Vector2(0.85, 0.85)
	modulate.a = 0.0
	_tween_fade = create_tween().set_parallel(true)
	_tween_fade.tween_property(self, "modulate:a", 1.0, 0.10).set_trans(Tween.TRANS_SINE)
	_tween_fade.tween_property(self, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	_update_knob(touch_pos)

func update_touch(touch_pos: Vector2) -> void:
	if not _dragging:
		return
	_update_knob(touch_pos)

func release_touch() -> void:
	if not _dragging and _touch_index == -1:
		return
	_dragging = false
	_touch_index = -1
	_current_vector = Vector2.ZERO
	joystick_moved.emit(Vector2.ZERO, false)
	
	if _tween_knob and _tween_knob.is_valid():
		_tween_knob.kill()
	_tween_knob = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tween_knob.tween_property(knob, "position", (size - knob.size) * 0.5, 0.12)
	
	if _tween_fade and _tween_fade.is_valid():
		_tween_fade.kill()
	_tween_fade = create_tween().set_parallel(true)
	_tween_fade.tween_property(self, "modulate:a", 0.0, 0.16).set_trans(Tween.TRANS_SINE)
	_tween_fade.tween_property(self, "scale", Vector2(0.9, 0.9), 0.16).set_trans(Tween.TRANS_SINE)
	_tween_fade.finished.connect(func():
		if not _dragging:
			visible = false
	)

func cancel() -> void:
	_dragging = false
	_touch_index = -1
	_current_vector = Vector2.ZERO
	joystick_moved.emit(Vector2.ZERO, false)
	if _tween_knob and _tween_knob.is_valid():
		_tween_knob.kill()
	if _tween_fade and _tween_fade.is_valid():
		_tween_fade.kill()
	modulate.a = 0.0
	visible = false
	_reset_knob_position()

func _update_knob(touch_pos: Vector2) -> void:
	var diff := touch_pos - _center
	var dist := diff.length()
	if dist > MAX_RADIUS:
		diff = (diff / dist) * MAX_RADIUS
	
	var knob_center := (size * 0.5) + diff
	knob.position = knob_center - (knob.size * 0.5)
	
	if dist > DEADZONE:
		_current_vector = diff.normalized()
		joystick_moved.emit(_current_vector, true)
	else:
		_current_vector = Vector2.ZERO
		joystick_moved.emit(Vector2.ZERO, false)

func _reset_knob_position() -> void:
	if knob:
		knob.position = (size - knob.size) * 0.5

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and not _dragging:
			activate_at(event.position, event.index)
		elif not event.pressed and event.index == _touch_index:
			release_touch()
	elif event is InputEventScreenDrag and _dragging and event.index == _touch_index:
		update_touch(event.position)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			activate_at(event.position, 9999)
		else:
			release_touch()
	elif event is InputEventMouseMotion and _dragging:
		update_touch(event.position)
