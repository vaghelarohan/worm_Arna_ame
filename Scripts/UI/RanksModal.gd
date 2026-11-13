extends Control

@onready var list_container: VBoxContainer = $ScrollContainer/List

var tile_style: StyleBox = preload("res://Resources/tile_style.tres")
var btn_gold: StyleBox = preload("res://Resources/btn_gold.tres")
var btn_navy: StyleBox = preload("res://Resources/btn_navy.tres")
var font_lilita: FontFile = preload("res://Assets/Fonts/LilitaOne-Regular.ttf")

func _ready() -> void:
	update_ui()
	GameManager.player_data_changed.connect(update_ui)

func update_ui() -> void:
	for c in list_container.get_children():
		c.queue_free()
	
	for i in range(GameManager.leaderboard.size()):
		var p: Dictionary = GameManager.leaderboard[i]
		var is_me: bool = p.get("me", false)
		
		var panel := Panel.new()
		panel.custom_minimum_size = Vector2(800, 68)
		panel.add_theme_stylebox_override("panel", tile_style)
		
		var hbox := HBoxContainer.new()
		hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		hbox.offset_left = 20
		hbox.offset_right = -20
		hbox.add_theme_constant_override("separation", 20)
		hbox.alignment = BoxContainer.ALIGNMENT_CENTER
		panel.add_child(hbox)
		
		var medal := Panel.new()
		medal.custom_minimum_size = Vector2(48, 48)
		medal.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		medal.add_theme_stylebox_override("panel", btn_gold if i < 3 else btn_navy)
		hbox.add_child(medal)
		
		var num_lbl := Label.new()
		num_lbl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		num_lbl.add_theme_font_override("font", font_lilita)
		num_lbl.add_theme_font_size_override("font_size", 22)
		num_lbl.add_theme_color_override("font_color", Color("#0b0c1e") if i < 3 else Color("#ffffff"))
		num_lbl.text = "—" if is_me else str(i + 1)
		num_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		num_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		medal.add_child(num_lbl)
		
		var name_lbl := Label.new()
		name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_lbl.add_theme_font_override("font", font_lilita)
		name_lbl.add_theme_font_size_override("font_size", 24)
		name_lbl.text = p["name"] + (" (You)" if is_me else "")
		hbox.add_child(name_lbl)
		
		var score_lbl := Label.new()
		score_lbl.add_theme_font_override("font", font_lilita)
		score_lbl.add_theme_font_size_override("font_size", 24)
		score_lbl.add_theme_color_override("font_color", Color("#fbbf24"))
		score_lbl.text = "%d" % p["score"]
		hbox.add_child(score_lbl)
		
		list_container.add_child(panel)
