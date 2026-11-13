extends Control

signal boost_toggled(active: bool)

@onready var btn: Button = $Btn
@onready var aura: Panel = $Aura

var _time: float = 0.0
var _is_active: bool = false
var _boost_touch_index: int = -1

func _ready() -> void:
	btn.button_down.connect(func():
		_set_boost(true)
	)
	btn.button_up.connect(func():
		_set_boost(false)
	)

func _process(delta: float) -> void:
	_time += delta
	var pulse: float = 1.0 + sin(_time * 4.0) * 0.05
	aura.scale = Vector2(pulse, pulse)
	aura.pivot_offset = aura.size / 2.0

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			if get_global_rect().grow(16.0).has_point(event.position):
				_boost_touch_index = event.index
				_set_boost(true)
		else:
			if event.index == _boost_touch_index:
				_boost_touch_index = -1
				_set_boost(false)

func _set_boost(active: bool) -> void:
	if _is_active == active:
		return
	_is_active = active
	boost_toggled.emit(active)
	var t := create_tween()
	if active:
		t.tween_property(self, "scale", Vector2(0.92, 0.92), 0.08)
	else:
		t.tween_property(self, "scale", Vector2.ONE, 0.1)

func set_boosting(v: bool) -> void:
	if v:
		scale = Vector2(0.92, 0.92)
	else:
		scale = Vector2.ONE
