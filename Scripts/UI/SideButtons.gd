extends VBoxContainer

signal sound_clicked
signal music_clicked
signal help_clicked
signal wheel_clicked

@onready var sound_btn: Button = $SoundButton
@onready var sound_icon: TextureRect = $SoundButton/Icon
@onready var help_btn: Button = $HelpButton
@onready var wheel_btn: Button = $WheelButton
@onready var wheel_icon: TextureRect = $WheelButton/Icon

var icon_vol_2: Texture2D = preload("res://Assets/Icons/volume_2.svg")
var icon_vol_x: Texture2D = preload("res://Assets/Icons/volume_x.svg")

func _ready() -> void:
	update_sound_icon()
	SoundManager.music_toggled.connect(func(_enabled): update_sound_icon())
	sound_btn.pressed.connect(func():
		SoundManager.set_music_enabled(not SoundManager.music_enabled)
		update_sound_icon()
		music_clicked.emit()
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

func _process(delta: float) -> void:
	if wheel_icon:
		wheel_icon.rotation += delta * 0.75

func update_sound_icon() -> void:
	if sound_icon:
		if SoundManager.music_enabled:
			sound_icon.texture = icon_vol_2
		else:
			sound_icon.texture = icon_vol_x
