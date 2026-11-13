extends Control

signal boost_toggled(active: bool)

@onready var btn: Button = $Btn

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

func set_boosting(v: bool) -> void:
	if v:
		scale = Vector2(0.92, 0.92)
	else:
		scale = Vector2.ONE

