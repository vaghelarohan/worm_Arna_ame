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

