extends Control

@onready var grid: GridContainer = $Grid

var tile_style: StyleBox = preload("res://Resources/tile_style.tres")
var worm_tex: Texture2D = preload("res://Assets/Characters/worm-hero.png")
var icon_check: Texture2D = preload("res://Assets/Icons/check.svg")
var icon_lock: Texture2D = preload("res://Assets/Icons/lock.svg")
var icon_coin: Texture2D = preload("res://Assets/Icons/coin.svg")
var font_lilita: FontFile = preload("res://Assets/Fonts/LilitaOne-Regular.ttf")
var font_fredoka: FontFile = preload("res://Assets/Fonts/Fredoka.ttf")

func _ready() -> void:
	update_ui()
	GameManager.player_data_changed.connect(update_ui)

func update_ui() -> void:
	for c in grid.get_children():
		c.queue_free()
	
	for i in range(GameManager.skins.size()):
		var s: Dictionary = GameManager.skins[i]
		var is_equipped: bool = (i == GameManager.equipped_skin_idx)
		var is_owned: bool = s["owned"]
		
		var card := Button.new()
		card.custom_minimum_size = Vector2(260, 240)
		card.add_theme_stylebox_override("normal", tile_style)
		card.add_theme_stylebox_override("hover", tile_style)
		card.add_theme_stylebox_override("pressed", tile_style)
		
		var vbox := VBoxContainer.new()
		vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		vbox.add_theme_constant_override("separation", 10)
		card.add_child(vbox)
		
		var img := TextureRect.new()
		img.custom_minimum_size = Vector2(110, 110)
		img.texture = worm_tex
		img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		img.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		img.modulate = s["color"] if is_owned else Color(0.5, 0.5, 0.5, 0.7)
		vbox.add_child(img)
		
		var name_lbl := Label.new()
		name_lbl.add_theme_font_override("font", font_lilita)
		name_lbl.add_theme_font_size_override("font_size", 22)
		name_lbl.add_theme_constant_override("outline_size", 4)
		name_lbl.add_theme_color_override("font_outline_color", Color("#0b0c1e"))
		name_lbl.text = s["name"]
		name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(name_lbl)
		
		var status_box := HBoxContainer.new()
		status_box.alignment = BoxContainer.ALIGNMENT_CENTER
		status_box.add_theme_constant_override("separation", 6)
		vbox.add_child(status_box)
		
		if is_equipped:
			var chk := TextureRect.new()
			chk.custom_minimum_size = Vector2(20, 20)
			chk.texture = icon_check
			chk.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			chk.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			status_box.add_child(chk)
			
			var st_lbl := Label.new()
			st_lbl.add_theme_font_override("font", font_fredoka)
			st_lbl.add_theme_font_size_override("font_size", 18)
			st_lbl.add_theme_color_override("font_color", Color("#84cc16"))
			st_lbl.text = "Equipped"
			status_box.add_child(st_lbl)
		elif is_owned:
			var st_lbl := Label.new()
			st_lbl.add_theme_font_override("font", font_fredoka)
			st_lbl.add_theme_font_size_override("font_size", 18)
			st_lbl.add_theme_color_override("font_color", Color("#93c5fd"))
			st_lbl.text = "Owned"
			status_box.add_child(st_lbl)
		else:
			var lck := TextureRect.new()
			lck.custom_minimum_size = Vector2(18, 18)
			lck.texture = icon_lock
			lck.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			lck.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			status_box.add_child(lck)
			
			var cn := TextureRect.new()
			cn.custom_minimum_size = Vector2(20, 20)
			cn.texture = icon_coin
			cn.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			cn.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			status_box.add_child(cn)
			
			var prc_lbl := Label.new()
			prc_lbl.add_theme_font_override("font", font_lilita)
			prc_lbl.add_theme_font_size_override("font_size", 18)
			prc_lbl.add_theme_color_override("font_color", Color("#fbbf24"))
			prc_lbl.text = str(s["price"])
			status_box.add_child(prc_lbl)
		
		var idx := i
		card.pressed.connect(func():
			if is_owned:
				GameManager.equip_skin(idx)
				SoundManager.play_click(880.0)
			else:
				if GameManager.buy_skin(idx):
					SoundManager.play_click(990.0)
				else:
					SoundManager.play_click(330.0)
		)
		
		grid.add_child(card)

