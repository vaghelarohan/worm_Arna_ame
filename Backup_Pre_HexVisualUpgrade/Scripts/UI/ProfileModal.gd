extends Control

@onready var grid: GridContainer = $HBox/Grid

var tile_style: StyleBox = preload("res://Resources/tile_style.tres")
var font_lilita: FontFile = preload("res://Assets/Fonts/LilitaOne-Regular.ttf")
var font_fredoka: FontFile = preload("res://Assets/Fonts/Fredoka.ttf")

func _ready() -> void:
	update_ui()
	GameManager.player_data_changed.connect(update_ui)

func update_ui() -> void:
	for c in grid.get_children():
		c.queue_free()
	
	var rows = [
		["Username", GameManager.username],
		["Player ID", GameManager.player_id],
		["Rank", GameManager.rank],
		["Level", str(GameManager.level)],
		["XP", str(GameManager.xp) + " / " + str(GameManager.xp_max)],
		["Total Kills", str(GameManager.kills)],
		["Best Score", "%d" % GameManager.best_score],
		["Trophies", str(GameManager.trophies)]
	]
	
	for r in rows:
		var panel := Panel.new()
		panel.custom_minimum_size = Vector2(240, 72)
		panel.add_theme_stylebox_override("panel", tile_style)
		
		var col := VBoxContainer.new()
		col.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		col.offset_left = 16
		col.offset_right = -16
		col.alignment = BoxContainer.ALIGNMENT_CENTER
		col.add_theme_constant_override("separation", 2)
		panel.add_child(col)
		
		var lbl := Label.new()
		lbl.add_theme_font_override("font", font_fredoka)
		lbl.add_theme_font_size_override("font_size", 13)
		lbl.add_theme_color_override("font_color", Color("#94a3b8"))
		lbl.text = r[0].to_upper()
		col.add_child(lbl)
		
		var val := Label.new()
		val.add_theme_font_override("font", font_lilita)
		val.add_theme_font_size_override("font_size", 22)
		val.text = r[1]
		col.add_child(val)
		
		grid.add_child(panel)

