extends Control

@onready var grid: GridContainer = $Grid

var tile_style: StyleBox = preload("res://Resources/tile_style.tres")
var btn_gold_style: StyleBox = preload("res://Resources/btn_gold.tres")
var btn_blue_style: StyleBox = preload("res://Resources/btn_blue.tres")
var icon_coin: Texture2D = preload("res://Assets/Icons/coin.svg")
var font_lilita: FontFile = preload("res://Assets/Fonts/LilitaOne-Regular.ttf")
var font_fredoka: FontFile = preload("res://Assets/Fonts/Fredoka.ttf")

var booster_icons: Dictionary = {
	"zap": preload("res://Assets/Icons/zap.svg"),
	"magnet": preload("res://Assets/Icons/magnet.svg"),
	"shield": preload("res://Assets/Icons/shield.svg"),
	"star": preload("res://Assets/Icons/star.svg")
}

func _ready() -> void:
	update_ui()
	GameManager.player_data_changed.connect(update_ui)

func update_ui() -> void:
	for c in grid.get_children():
		c.queue_free()
	
	for b in GameManager.boosters:
		var panel := Panel.new()
		panel.custom_minimum_size = Vector2(400, 110)
		panel.add_theme_stylebox_override("panel", tile_style)
		
		var hbox := HBoxContainer.new()
		hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		hbox.offset_left = 16
		hbox.offset_right = -16
		hbox.add_theme_constant_override("separation", 16)
		hbox.alignment = BoxContainer.ALIGNMENT_CENTER
		panel.add_child(hbox)
		
		var icon_badge := Panel.new()
		icon_badge.custom_minimum_size = Vector2(74, 74)
		icon_badge.add_theme_stylebox_override("panel", btn_blue_style)
		hbox.add_child(icon_badge)
		
		var icon_tex := TextureRect.new()
		icon_tex.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		icon_tex.offset_left = 16
		icon_tex.offset_top = 16
		icon_tex.offset_right = -16
		icon_tex.offset_bottom = -16
		icon_tex.texture = booster_icons.get(b["icon"], icon_coin)
		icon_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon_badge.add_child(icon_tex)
		
		var text_col := VBoxContainer.new()
		text_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		text_col.alignment = BoxContainer.ALIGNMENT_CENTER
		hbox.add_child(text_col)
		
		var name_row := HBoxContainer.new()
		name_row.add_theme_constant_override("separation", 8)
		text_col.add_child(name_row)
		
		var name_lbl := Label.new()
		name_lbl.add_theme_font_override("font", font_lilita)
		name_lbl.add_theme_font_size_override("font_size", 22)
		name_lbl.text = b["name"]
		name_row.add_child(name_lbl)
		
		var count: int = GameManager.owned_boosters.get(b["name"], 0)
		if count > 0:
			var count_lbl := Label.new()
			count_lbl.add_theme_font_override("font", font_lilita)
			count_lbl.add_theme_font_size_override("font_size", 20)
			count_lbl.add_theme_color_override("font_color", Color("#84cc16"))
			count_lbl.text = "×" + str(count)
			name_row.add_child(count_lbl)
		
		var desc_lbl := Label.new()
		desc_lbl.add_theme_font_override("font", font_fredoka)
		desc_lbl.add_theme_font_size_override("font_size", 16)
		desc_lbl.add_theme_color_override("font_color", Color("#94a3b8"))
		desc_lbl.text = b["desc"]
		text_col.add_child(desc_lbl)
		
		var buy_btn := Button.new()
		buy_btn.custom_minimum_size = Vector2(96, 48)
		buy_btn.add_theme_stylebox_override("normal", btn_gold_style)
		buy_btn.add_theme_stylebox_override("hover", btn_gold_style)
		buy_btn.add_theme_stylebox_override("pressed", btn_gold_style)
		
		var btn_hbox := HBoxContainer.new()
		btn_hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		btn_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
		btn_hbox.add_theme_constant_override("separation", 6)
		buy_btn.add_child(btn_hbox)
		
		var b_coin := TextureRect.new()
		b_coin.custom_minimum_size = Vector2(24, 24)
		b_coin.texture = icon_coin
		b_coin.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		b_coin.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		btn_hbox.add_child(b_coin)
		
		var price_lbl := Label.new()
		price_lbl.add_theme_font_override("font", font_lilita)
		price_lbl.add_theme_font_size_override("font_size", 20)
		price_lbl.add_theme_color_override("font_color", Color("#0b0c1e"))
		price_lbl.text = str(b["price"])
		btn_hbox.add_child(price_lbl)
		
		var b_name: String = b["name"]
		var b_price: int = int(b["price"])
		buy_btn.pressed.connect(func():
			if GameManager.buy_booster(b_name, b_price):
				SoundManager.play_click(990.0)
			else:
				SoundManager.play_click(330.0)
		)
		
		hbox.add_child(buy_btn)
		grid.add_child(panel)

