extends Control

signal skins_requested

@onready var preview_card: Panel = $VBox/TopSection/PreviewCard
@onready var preview_canvas: Control = $VBox/TopSection/PreviewCard/PreviewCanvas
@onready var name_lbl: Label = $VBox/TopSection/PreviewCard/InfoHBox/NameLbl
@onready var action_btn: Button = $VBox/TopSection/PreviewCard/InfoHBox/ActionBtn
@onready var skins_btn: Button = $VBox/ThemesBar/SkinsBtn
@onready var grid: GridContainer = $VBox/Scroll/Grid

var font_lilita: FontFile = preload("res://Assets/Fonts/LilitaOne-Regular.ttf")
var font_fredoka: FontFile = preload("res://Assets/Fonts/Fredoka.ttf")
var icon_check: Texture2D = preload("res://Assets/Icons/check.svg")

var _selected_bg_id: String = "neon_blue"
var _anim_time: float = 0.0

func _ready() -> void:
	_selected_bg_id = GameManager.selected_background
	
	# Style Preview Card
	var p_style := StyleBoxFlat.new()
	p_style.bg_color = Color("#0f172a", 0.95)
	p_style.set_corner_radius_all(16)
	p_style.border_width_left = 2
	p_style.border_width_top = 2
	p_style.border_width_right = 2
	p_style.border_width_bottom = 2
	p_style.border_color = Color("#38bdf8")
	preview_card.add_theme_stylebox_override("panel", p_style)
	
	name_lbl.add_theme_font_override("font", font_lilita)
	name_lbl.add_theme_font_size_override("font_size", 24)
	name_lbl.add_theme_color_override("font_color", Color.WHITE)
	name_lbl.add_theme_constant_override("outline_size", 4)
	name_lbl.add_theme_color_override("font_outline_color", Color("#0b0c1e"))
	
	action_btn.add_theme_font_override("font", font_lilita)
	action_btn.add_theme_font_size_override("font_size", 16)
	
	skins_btn.add_theme_font_override("font", font_lilita)
	skins_btn.add_theme_font_size_override("font_size", 14)
	
	action_btn.pressed.connect(_on_action_pressed)
	skins_btn.pressed.connect(func():
		SoundManager.play_click()
		skins_requested.emit()
	)
	
	preview_canvas.draw.connect(_draw_preview)
	
	update_preview()
	update_grid()
	GameManager.player_data_changed.connect(func():
		update_preview()
		update_grid()
	)

func _process(delta: float) -> void:
	_anim_time += delta
	preview_canvas.queue_redraw()

func _get_bg_data(id: String) -> Dictionary:
	for bg in GameManager.backgrounds:
		if bg["id"] == id:
			return bg
	return GameManager.backgrounds[0]

func update_preview() -> void:
	var bg: Dictionary = _get_bg_data(_selected_bg_id)
	name_lbl.text = bg["name"]
	
	var is_equipped: bool = (_selected_bg_id == GameManager.selected_background)
	var sb := StyleBoxFlat.new()
	sb.set_corner_radius_all(10)
	if is_equipped:
		sb.bg_color = Color("#15803d")
		action_btn.text = "EQUIPPED"
		action_btn.disabled = true
	else:
		sb.bg_color = bg.get("accent", Color("#0284c7"))
		action_btn.text = "SELECT ARENA"
		action_btn.disabled = false
	
	action_btn.add_theme_stylebox_override("normal", sb)
	action_btn.add_theme_stylebox_override("hover", sb)
	action_btn.add_theme_stylebox_override("pressed", sb)
	preview_canvas.queue_redraw()

func _on_action_pressed() -> void:
	GameManager.equip_background(_selected_bg_id)
	SoundManager.play_click(880.0)
	update_preview()
	update_grid()

func update_grid() -> void:
	for c in grid.get_children():
		c.queue_free()
	
	for bg in GameManager.backgrounds:
		var bg_id: String = bg["id"]
		var is_equipped: bool = (bg_id == GameManager.selected_background)
		var is_selected: bool = (bg_id == _selected_bg_id)
		
		var card := Button.new()
		card.custom_minimum_size = Vector2(236, 175)
		
		var csb := StyleBoxFlat.new()
		csb.bg_color = Color("#111827", 0.92)
		csb.set_corner_radius_all(14)
		csb.border_width_left = 3 if (is_equipped or is_selected) else 1
		csb.border_width_top = 3 if (is_equipped or is_selected) else 1
		csb.border_width_right = 3 if (is_equipped or is_selected) else 1
		csb.border_width_bottom = 3 if (is_equipped or is_selected) else 1
		csb.border_color = Color("#facc15") if is_equipped else (bg["accent"] if is_selected else Color("#1e293b"))
		card.add_theme_stylebox_override("normal", csb)
		card.add_theme_stylebox_override("hover", csb)
		card.add_theme_stylebox_override("pressed", csb)
		
		var vbox := VBoxContainer.new()
		vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		vbox.add_theme_constant_override("separation", 6)
		card.add_child(vbox)
		
		# Thumbnail Swatch
		var preview_box := Panel.new()
		preview_box.custom_minimum_size = Vector2(210, 68)
		preview_box.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		var pb_style := StyleBoxFlat.new()
		pb_style.bg_color = bg["bg_color"]
		pb_style.set_corner_radius_all(10)
		pb_style.border_width_left = 2
		pb_style.border_width_top = 2
		pb_style.border_width_right = 2
		pb_style.border_width_bottom = 2
		pb_style.border_color = bg["accent"]
		preview_box.add_theme_stylebox_override("panel", pb_style)
		
		# Glowing dots in swatch
		var dot_cont := HBoxContainer.new()
		dot_cont.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		dot_cont.alignment = BoxContainer.ALIGNMENT_CENTER
		dot_cont.add_theme_constant_override("separation", 16)
		for dot_i in range(5):
			var dot := ColorRect.new()
			dot.custom_minimum_size = Vector2(10, 10)
			dot.color = bg["accent"] if dot_i % 2 == 0 else Color.WHITE
			dot_cont.add_child(dot)
		preview_box.add_child(dot_cont)
		vbox.add_child(preview_box)
		
		# Title
		var title_lbl := Label.new()
		title_lbl.add_theme_font_override("font", font_lilita)
		title_lbl.add_theme_font_size_override("font_size", 18)
		title_lbl.add_theme_constant_override("outline_size", 4)
		title_lbl.add_theme_color_override("font_outline_color", Color("#0b0c1e"))
		title_lbl.text = bg["name"]
		title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(title_lbl)
		
		# Status indicator
		var st_lbl := Label.new()
		st_lbl.add_theme_font_override("font", font_fredoka)
		st_lbl.add_theme_font_size_override("font_size", 13)
		if is_equipped:
			st_lbl.text = "✓ EQUIPPED"
			st_lbl.add_theme_color_override("font_color", Color("#4ade80"))
		else:
			st_lbl.text = "TAP TO EQUIP"
			st_lbl.add_theme_color_override("font_color", bg["accent"])
		st_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(st_lbl)
		
		var target_id := bg_id
		card.pressed.connect(func():
			_selected_bg_id = target_id
			GameManager.equip_background(target_id)
			SoundManager.play_click(880.0)
			update_preview()
			update_grid()
		)
		
		grid.add_child(card)

func _draw_preview() -> void:
	var bg: Dictionary = _get_bg_data(_selected_bg_id)
	var bg_col: Color = bg["bg_color"]
	var accent: Color = bg["accent"]
	var sz := preview_canvas.size
	
	# Base backdrop
	preview_canvas.draw_rect(Rect2(Vector2.ZERO, sz), bg_col)
	
	# Animated hex tiles grid across preview
	var hex_size: float = 30.0
	var w: float = hex_size * 2.0
	var h: float = sqrt(3.0) * hex_size
	var cols: int = int(sz.x / (w * 0.75)) + 2
	var rows: int = int(sz.y / h) + 2
	
	var hex_line_col := Color(accent.r, accent.g, accent.b, 0.25)
	var hex_fill_col := Color(bg_col.r * 1.3, bg_col.g * 1.3, bg_col.b * 1.3, 0.40)
	
	for r_i in range(rows):
		var y: float = float(r_i) * h + (h * 0.5 if 0 % 2 == 1 else 0.0)
		for c_i in range(cols):
			var x: float = float(c_i) * (w * 0.75)
			var y_off: float = y + (h * 0.5 if c_i % 2 == 1 else 0.0)
			var center := Vector2(x, y_off)
			
			var pts: PackedVector2Array = []
			for a_i in range(6):
				var a: float = float(a_i) * (TAU / 6.0)
				pts.append(center + Vector2(cos(a) * hex_size * 0.88, sin(a) * hex_size * 0.88))
			if pts.size() == 6:
				preview_canvas.draw_colored_polygon(pts, hex_fill_col)
				for p_i in range(6):
					preview_canvas.draw_line(pts[p_i], pts[(p_i + 1) % 6], hex_line_col, 1.2)
	
	# Floating theme motes
	for m_i in range(12):
		var phase: float = float(m_i) * 1.7
		var mx: float = fmod(float(m_i * 61) + _anim_time * 25.0, sz.x)
		var my: float = 20.0 + sin(_anim_time * 2.0 + phase) * 35.0 + float(m_i * 9)
		my = fmod(my, sz.y)
		var mr: float = 2.5 + sin(_anim_time * 3.0 + phase) * 1.2
		var mote_alpha: float = 0.5 + sin(_anim_time * 4.0 + phase) * 0.35
		var m_col: Color = accent if (m_i % 2 == 0) else Color.WHITE
		m_col.a = mote_alpha
		preview_canvas.draw_circle(Vector2(mx, my), mr, m_col)
