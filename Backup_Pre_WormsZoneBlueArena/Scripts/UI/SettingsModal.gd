extends Control

@onready var btn_sound: Button = $Grid/BtnSound
@onready var btn_music: Button = $Grid/BtnMusic
@onready var btn_vib: Button = $Grid/BtnVibration
@onready var btn_hq: Button = $Grid/BtnGraphics

@onready var sw_sound: Panel = $Grid/BtnSound/Switch
@onready var sw_sound_knob: Panel = $Grid/BtnSound/Switch/Knob
@onready var sw_music: Panel = $Grid/BtnMusic/Switch
@onready var sw_music_knob: Panel = $Grid/BtnMusic/Switch/Knob
@onready var sw_vib: Panel = $Grid/BtnVibration/Switch
@onready var sw_vib_knob: Panel = $Grid/BtnVibration/Switch/Knob
@onready var sw_hq: Panel = $Grid/BtnGraphics/Switch
@onready var sw_hq_knob: Panel = $Grid/BtnGraphics/Switch/Knob

func _ready() -> void:
	_update_switches()
	
	btn_sound.pressed.connect(func():
		SoundManager.set_sound_enabled(not SoundManager.sound_enabled)
		_update_switches()
	)
	btn_music.pressed.connect(func():
		SoundManager.music_enabled = not SoundManager.music_enabled
		SoundManager.play_click()
		_update_switches()
	)
	btn_vib.pressed.connect(func():
		SoundManager.vibration_enabled = not SoundManager.vibration_enabled
		SoundManager.play_click()
		_update_switches()
	)
	btn_hq.pressed.connect(func():
		SoundManager.high_graphics_enabled = not SoundManager.high_graphics_enabled
		SoundManager.play_click()
		_update_switches()
	)

func _update_switches() -> void:
	_apply_toggle(sw_sound, sw_sound_knob, SoundManager.sound_enabled)
	_apply_toggle(sw_music, sw_music_knob, SoundManager.music_enabled)
	_apply_toggle(sw_vib, sw_vib_knob, SoundManager.vibration_enabled)
	_apply_toggle(sw_hq, sw_hq_knob, SoundManager.high_graphics_enabled)

func _apply_toggle(sw: Panel, knob: Panel, on: bool) -> void:
	var sb: StyleBoxFlat = sw.get_theme_stylebox("panel").duplicate()
	sb.bg_color = Color("#84cc16") if on else Color("#334155")
	sw.add_theme_stylebox_override("panel", sb)
	knob.position.x = 32.0 if on else 4.0

