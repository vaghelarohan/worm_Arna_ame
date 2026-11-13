extends Control

signal joystick_moved(vec: Vector2, active: bool)

@onready var knob: Control = $Knob
const JS_SIZE: float = 260.0
const MAX_RADIUS: float = 80.0

var _dragging: bool = false
var _touch_index: int = -1

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and not _dragging:
			_dragging = true
			_touch_index = event.index
			_update_knob(event.position)
		elif not event.pressed and event.index == _touch_index:
			_release_knob()
	elif event is InputEventScreenDrag and _dragging and event.index == _touch_index:
		_update_knob(event.position)
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_dragging = true
				_update_knob(event.position)
			else:
				_release_knob()
	elif event is InputEventMouseMotion and _dragging:
		_update_knob(event.position)

func _update_knob(touch_pos: Vector2) -> void:
	var center := size / 2.0
	var diff := touch_pos - center
	var dist := diff.length()
	if dist > MAX_RADIUS:
		diff = (diff / dist) * MAX_RADIUS
	
	knob.position = center + diff - knob.size / 2.0
	if dist > 6.0:
		joystick_moved.emit(diff.normalized(), true)
	else:
		joystick_moved.emit(Vector2.ZERO, false)

func _release_knob() -> void:
	_dragging = false
	_touch_index = -1
	var center := size / 2.0
	var tween := create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(knob, "position", center - knob.size / 2.0, 0.12)
	joystick_moved.emit(Vector2.ZERO, false)

