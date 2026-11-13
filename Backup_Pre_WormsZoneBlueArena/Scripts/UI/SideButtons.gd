extends VBoxContainer

signal sound_clicked
signal help_clicked
signal wheel_clicked

@onready var sound_btn: Button = $SoundButton
@onready var sound_icon: TextureRect = $SoundButton/Icon
@onready var help_btn: Button = $HelpButton
@onready var wheel_btn: Button = $WheelButton
@onready var wheel_disc: Control = $WheelButton/WheelCircle

var icon_vol_2: Texture2D = preload("res://Assets/Icons/volume_2.svg")
var icon_vol_x: Texture2D = preload("res://Assets/Icons/volume_x.svg")

func _ready() -> void:
	update_sound_icon()
	sound_btn.pressed.connect(func():
		SoundManager.set_sound_enabled(not SoundManager.sound_enabled)
		update_sound_icon()
		sound_clicked.emit()
	)
	help_btn.pressed.connect(func():
		SoundManager.play_click()
		help_clicked.emit()
	)
	wheel_btn.pressed.connect(func():
		SoundManager.play_click()
		wheel_clicked.emit()
	)

func update_sound_icon() -> void:
	if SoundManager.sound_enabled:
		sound_icon.texture = icon_vol_2
	else:
		sound_icon.texture = icon_vol_x

