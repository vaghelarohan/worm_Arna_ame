extends Control

signal resume_pressed
signal restart_pressed
signal settings_pressed
signal menu_pressed

@onready var resume_btn: Button = $CenterContainer/Panel/VBox/ResumeBtn
@onready var restart_btn: Button = $CenterContainer/Panel/VBox/RestartBtn
@onready var settings_btn: Button = $CenterContainer/Panel/VBox/SettingsBtn
@onready var menu_btn: Button = $CenterContainer/Panel/VBox/MenuBtn

func _ready() -> void:
	resume_btn.pressed.connect(func(): resume_pressed.emit())
	restart_btn.pressed.connect(func(): restart_pressed.emit())
	settings_btn.pressed.connect(func(): settings_pressed.emit())
	menu_btn.pressed.connect(func(): menu_pressed.emit())
	
	var panel: Panel = $CenterContainer/Panel
	panel.pivot_offset = panel.custom_minimum_size / 2.0
	panel.scale = Vector2(0.88, 0.88)
	panel.modulate.a = 0.0
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(panel, "scale", Vector2.ONE, 0.24).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(panel, "modulate:a", 1.0, 0.18)

