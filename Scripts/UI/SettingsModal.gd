extends Control

signal backgrounds_requested

@onready var btn_sound: Button = $Grid/BtnSound
@onready var btn_music: Button = $Grid/BtnMusic
@onready var btn_vib: Button = $Grid/BtnVibration
@onready var btn_hq: Button = $Grid/BtnGraphics
@onready var btn_themes: Button = $Grid/BtnThemes

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
	_setup_volume_sliders()
	
	btn_sound.pressed.connect(func():
		SoundManager.set_sound_enabled(not SoundManager.sound_enabled)
		_update_switches()
		GameManager.save_game()
	)
	btn_music.pressed.connect(func():
		SoundManager.set_music_enabled(not SoundManager.music_enabled)
		SoundManager.play_click()
		_update_switches()
		GameManager.save_game()
	)
	btn_vib.pressed.connect(func():
		SoundManager.vibration_enabled = not SoundManager.vibration_enabled
		SoundManager.play_click()
		_update_switches()
		GameManager.save_game()
	)
	btn_hq.pressed.connect(func():
		SoundManager.high_graphics_enabled = not SoundManager.high_graphics_enabled
		SoundManager.play_click()
		_update_switches()
		GameManager.save_game()
	)
	btn_themes.pressed.connect(func():
		SoundManager.play_click()
		backgrounds_requested.emit()
	)

func _setup_volume_sliders() -> void:
	# Add responsive volume controls inside Sound and Music cards
	for item in [{"btn": btn_sound, "type": "sfx"}, {"btn": btn_music, "type": "music"}]:
		var parent_btn: Button = item["btn"]
		var type: String = item["type"]
		
		var slider_row := HBoxContainer.new()
		slider_row.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
		slider_row.offset_top = -32.0
		slider_row.offset_bottom = -8.0
		slider_row.offset_left = 24.0
		slider_row.offset_right = -24.0
		slider_row.add_theme_constant_override("separation", 10)
		
		var vol_lbl := Label.new()
		vol_lbl.add_theme_font_override("font", preload("res://Assets/Fonts/LilitaOne-Regular.ttf"))
		vol_lbl.add_theme_font_size_override("font_size", 14)
		vol_lbl.add_theme_color_override("font_color", Color("#94a3b8"))
		var cur_vol: float = SoundManager.sfx_volume if type == "sfx" else SoundManager.music_volume
		vol_lbl.text = "VOL: %d%%" % int(cur_vol * 100.0)
		slider_row.add_child(vol_lbl)
		
		var slider := HSlider.new()
		slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		slider.min_value = 0.0
		slider.max_value = 1.0
		slider.step = 0.05
		slider.value = cur_vol
		
		var t_type: String = type
		var t_lbl: Label = vol_lbl
		slider.value_changed.connect(func(v: float):
			if t_type == "sfx":
				SoundManager.sfx_volume = v
			else:
				SoundManager.music_volume = v
			t_lbl.text = "VOL: %d%%" % int(v * 100.0)
			GameManager.save_game()
		)
		slider_row.add_child(slider)
		parent_btn.add_child(slider_row)

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

