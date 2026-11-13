extends Control

signal boost_toggled(active: bool)

@onready var btn: Button = $Btn
@onready var aura: Panel = $Aura

var _time: float = 0.0

func _ready() -> void:
	btn.button_down.connect(func():
		boost_toggled.emit(true)
		var t := create_tween()
		t.tween_property(self, "scale", Vector2(0.92, 0.92), 0.08)
	)
	btn.button_up.connect(func():
		boost_toggled.emit(false)
		var t := create_tween()
		t.tween_property(self, "scale", Vector2.ONE, 0.1)
	)

func _process(delta: float) -> void:
	_time += delta
	var pulse: float = 1.0 + sin(_time * 4.0) * 0.05
	aura.scale = Vector2(pulse, pulse)
	aura.pivot_offset = aura.size / 2.0

func set_boosting(v: bool) -> void:
	if v:
		scale = Vector2(0.92, 0.92)
	else:
		scale = Vector2.ONE
