extends Control

signal backgrounds_requested

@onready var prev_btn: Button = $VBox/TopSection/PrevBtn
@onready var next_btn: Button = $VBox/TopSection/NextBtn
@onready var preview_card: Panel = $VBox/TopSection/PreviewCard
@onready var preview_canvas: Control = $VBox/TopSection/PreviewCard/PreviewCanvas
@onready var name_lbl: Label = $VBox/TopSection/PreviewCard/InfoHBox/NameLbl
@onready var rarity_badge: Label = $VBox/TopSection/PreviewCard/InfoHBox/RarityBadge
@onready var action_btn: Button = $VBox/TopSection/PreviewCard/InfoHBox/ActionBtn
@onready var themes_btn: Button = $VBox/ThemesBar/ThemesBtn
@onready var grid: GridContainer = $VBox/Scroll/Grid

var font_lilita: FontFile = preload("res://Assets/Fonts/LilitaOne-Regular.ttf")
var font_fredoka: FontFile = preload("res://Assets/Fonts/Fredoka.ttf")
var icon_check: Texture2D = preload("res://Assets/Icons/check.svg")
var icon_lock: Texture2D = preload("res://Assets/Icons/lock.svg")
var icon_coin: Texture2D = preload("res://Assets/Icons/coin.svg")

var _selected_idx: int = 0
var _anim_time: float = 0.0
var _blink_timer: float = 0.0

func _ready() -> void:
	_selected_idx = GameManager.equipped_skin_idx
	
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
	
	rarity_badge.add_theme_font_override("font", font_lilita)
	rarity_badge.add_theme_font_size_override("font_size", 16)
	
	action_btn.add_theme_font_override("font", font_lilita)
	action_btn.add_theme_font_size_override("font_size", 16)
	
	themes_btn.add_theme_font_override("font", font_lilita)
	themes_btn.add_theme_font_size_override("font_size", 14)
	
	prev_btn.pressed.connect(func():
		_selected_idx = (_selected_idx - 1 + GameManager.skins.size()) % GameManager.skins.size()
		SoundManager.play_click()
		update_preview()
	)
	next_btn.pressed.connect(func():
		_selected_idx = (_selected_idx + 1) % GameManager.skins.size()
		SoundManager.play_click()
		update_preview()
	)
	action_btn.pressed.connect(_on_action_pressed)
	themes_btn.pressed.connect(func():
		SoundManager.play_click()
		backgrounds_requested.emit()
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
	_blink_timer += delta
	if _blink_timer > 3.6:
		if _blink_timer > 3.8:
			_blink_timer = 0.0
	preview_canvas.queue_redraw()

func update_preview() -> void:
	if _selected_idx < 0 or _selected_idx >= GameManager.skins.size():
		_selected_idx = 0
	
	var skin: Dictionary = GameManager.skins[_selected_idx]
	name_lbl.text = skin["name"]
	
	var rarity: String = skin.get("rarity", "Common").to_upper()
	rarity_badge.text = rarity
	match rarity:
		"LEGENDARY": rarity_badge.add_theme_color_override("font_color", Color("#fbbf24"))
		"EPIC": rarity_badge.add_theme_color_override("font_color", Color("#c084fc"))
		"RARE": rarity_badge.add_theme_color_override("font_color", Color("#60a5fa"))
		_: rarity_badge.add_theme_color_override("font_color", Color("#4ade80"))
	
	var is_equipped: bool = (_selected_idx == GameManager.equipped_skin_idx)
	var is_owned: bool = skin["owned"]
	
	var sb := StyleBoxFlat.new()
	sb.set_corner_radius_all(10)
	if is_equipped:
		sb.bg_color = Color("#15803d")
		action_btn.text = "EQUIPPED"
		action_btn.disabled = true
	elif is_owned:
		sb.bg_color = Color("#0284c7")
		action_btn.text = "EQUIP"
		action_btn.disabled = false
	else:
		sb.bg_color = Color("#b45309")
		action_btn.text = "UNLOCK: %d" % int(skin["price"])
		action_btn.disabled = (GameManager.coins < int(skin["price"]))
	
	action_btn.add_theme_stylebox_override("normal", sb)
	action_btn.add_theme_stylebox_override("hover", sb)
	action_btn.add_theme_stylebox_override("pressed", sb)
	preview_canvas.queue_redraw()

func _on_action_pressed() -> void:
	var skin: Dictionary = GameManager.skins[_selected_idx]
	if skin["owned"]:
		GameManager.equip_skin(_selected_idx)
		SoundManager.play_click(880.0)
	else:
		if GameManager.buy_skin(_selected_idx):
			SoundManager.play_click(990.0)
		else:
			SoundManager.play_click(330.0)
	update_preview()
	update_grid()

func update_grid() -> void:
	for c in grid.get_children():
		c.queue_free()
	
	for i in range(GameManager.skins.size()):
		var s: Dictionary = GameManager.skins[i]
		var is_equipped: bool = (i == GameManager.equipped_skin_idx)
		var is_selected: bool = (i == _selected_idx)
		var is_owned: bool = s["owned"]
		
		var card := Button.new()
		card.custom_minimum_size = Vector2(215, 110)
		
		var csb := StyleBoxFlat.new()
		csb.bg_color = Color("#1e293b", 0.90)
		csb.set_corner_radius_all(12)
		csb.border_width_left = 3 if (is_selected or is_equipped) else 1
		csb.border_width_top = 3 if (is_selected or is_equipped) else 1
		csb.border_width_right = 3 if (is_selected or is_equipped) else 1
		csb.border_width_bottom = 3 if (is_selected or is_equipped) else 1
		csb.border_color = Color("#facc15") if is_equipped else (Color("#38bdf8") if is_selected else Color("#334155"))
		card.add_theme_stylebox_override("normal", csb)
		card.add_theme_stylebox_override("hover", csb)
		card.add_theme_stylebox_override("pressed", csb)
		
		var vbox := VBoxContainer.new()
		vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		vbox.add_theme_constant_override("separation", 6)
		card.add_child(vbox)
		
		# Color swatch preview
		var swatch_box := HBoxContainer.new()
		swatch_box.alignment = BoxContainer.ALIGNMENT_CENTER
		swatch_box.add_theme_constant_override("separation", 6)
		for col in [s["color"], s["color2"]]:
			var dot := Panel.new()
			dot.custom_minimum_size = Vector2(22, 22)
			var dot_sb := StyleBoxFlat.new()
			dot_sb.bg_color = col
			dot_sb.set_corner_radius_all(11)
			dot_sb.border_width_left = 2
			dot_sb.border_width_top = 2
			dot_sb.border_width_right = 2
			dot_sb.border_width_bottom = 2
			dot_sb.border_color = Color(1, 1, 1, 0.4)
			dot.add_theme_stylebox_override("panel", dot_sb)
			swatch_box.add_child(dot)
		vbox.add_child(swatch_box)
		
		# Title
		var title_lbl := Label.new()
		title_lbl.add_theme_font_override("font", font_lilita)
		title_lbl.add_theme_font_size_override("font_size", 16)
		title_lbl.text = s["name"]
		title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(title_lbl)
		
		# Status indicator
		var st_lbl := Label.new()
		st_lbl.add_theme_font_override("font", font_fredoka)
		st_lbl.add_theme_font_size_override("font_size", 13)
		if is_equipped:
			st_lbl.text = "✓ EQUIPPED"
			st_lbl.add_theme_color_override("font_color", Color("#4ade80"))
		elif is_owned:
			st_lbl.text = "OWNED"
			st_lbl.add_theme_color_override("font_color", Color("#93c5fd"))
		else:
			st_lbl.text = "🔒 %d" % int(s["price"])
			st_lbl.add_theme_color_override("font_color", Color("#fbbf24"))
		st_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(st_lbl)
		
		var idx: int = i
		card.pressed.connect(func():
			_selected_idx = idx
			SoundManager.play_click()
			if is_owned:
				GameManager.equip_skin(idx)
			update_preview()
			update_grid()
		)
		grid.add_child(card)

func _draw_preview() -> void:
	if _selected_idx < 0 or _selected_idx >= GameManager.skins.size():
		return
	
	var skin: Dictionary = GameManager.skins[_selected_idx]
	var col_a: Color = skin["color"]
	var col_b: Color = skin["color2"]
	var head_col: Color = skin.get("head_color", col_b)
	var iris_col: Color = skin.get("iris_color", col_a)
	
	var canvas_width: float = preview_canvas.size.x
	var r: float = 28.0
	var hr: float = 38.0
	var num_segs: int = 7
	var seg_spacing: float = 30.0
	
	# Horizontal centering:
	# Tail left bound is at (head_center_x - num_segs * seg_spacing - r)
	# Head right bound is at (head_center_x + hr)
	# Center of bounds = (2*head_center_x - num_segs * seg_spacing - r + hr) / 2
	# Setting Center of bounds == canvas_width * 0.5:
	# head_center_x = canvas_width * 0.5 + (num_segs * seg_spacing + r - hr) * 0.5
	var head_center_x: float = canvas_width * 0.5 + (float(num_segs) * seg_spacing + r - hr) * 0.5
	var center_y: float = 70.0
	
	# Draw undulating segments trailing to the left
	for i in range(num_segs, 0, -1):
		var seg_wave: float = sin(_anim_time * 4.0 - float(i) * 0.55) * 14.0
		var pos := Vector2(head_center_x - float(i) * seg_spacing, center_y + seg_wave)
		var seg_col: Color = col_b if (int(i / 2) % 2 == 1) else col_a
		
		# Drop Shadow
		preview_canvas.draw_circle(pos + Vector2(3.0, 9.0), r * 0.95, Color(0.01, 0.02, 0.06, 0.40))
		# Dark Border Rim
		preview_canvas.draw_circle(pos, r + 2.0, Color(0.02, 0.04, 0.12, 0.95))
		# Outer Segment Body
		preview_canvas.draw_circle(pos, r, seg_col)
		# Inner Glow / Specular
		preview_canvas.draw_circle(pos + Vector2(-r * 0.28, -r * 0.28), r * 0.35, Color(1, 1, 1, 0.45))
	
	# Draw Head
	var head_wave: float = sin(_anim_time * 4.0) * 8.0
	var h_pos := Vector2(head_center_x, center_y + head_wave)
	
	# Head Drop Shadow
	preview_canvas.draw_circle(h_pos + Vector2(4.0, 10.0), hr * 0.95, Color(0.01, 0.02, 0.06, 0.40))
	# Head Rim
	preview_canvas.draw_circle(h_pos, hr + 2.5, Color(0.02, 0.04, 0.12, 0.95))
	# Head Base Fill
	preview_canvas.draw_circle(h_pos, hr, head_col)
	# Head Specular Highlight
	preview_canvas.draw_circle(h_pos + Vector2(-hr * 0.28, -hr * 0.28), hr * 0.38, Color(1, 1, 1, 0.50))
	
	# Expressive Eyes
	var is_blinking: bool = (_blink_timer > 3.6 and _blink_timer < 3.76)
	var er: float = hr * 0.38
	var eye_dist: float = hr * 0.45
	
	for eye_x in [-eye_dist, eye_dist]:
		var eye_center := h_pos + Vector2(eye_x, -hr * 0.12)
		if is_blinking:
			preview_canvas.draw_arc(eye_center, er * 0.65, -0.6, 0.6, 8, Color(0.02, 0.04, 0.12), 3.5)
		else:
			# Eye Sclera (White)
			preview_canvas.draw_circle(eye_center, er + 1.5, Color(0.02, 0.04, 0.12, 0.95))
			preview_canvas.draw_circle(eye_center, er, Color.WHITE)
			
			# Iris & Pupil
			var iris_center := eye_center + Vector2(er * 0.2, 0)
			preview_canvas.draw_circle(iris_center, er * 0.65, iris_col)
			preview_canvas.draw_circle(iris_center, er * 0.42, Color(0.02, 0.03, 0.08))
			# Specular reflections
			preview_canvas.draw_circle(iris_center + Vector2(-er * 0.22, -er * 0.22), er * 0.22, Color.WHITE)
			preview_canvas.draw_circle(iris_center + Vector2(er * 0.25, er * 0.22), er * 0.12, Color.WHITE)
			
			# Eyelash / Brow Arc
			preview_canvas.draw_arc(eye_center + Vector2(0, -er * 0.7), er * 0.65, -0.4, 0.4, 8, Color(0.02, 0.04, 0.12), 2.5)
	
	# Cheeks Blush
	preview_canvas.draw_circle(h_pos + Vector2(-hr * 0.75, hr * 0.25), hr * 0.22, Color(1.0, 0.42, 0.56, 0.55))
	preview_canvas.draw_circle(h_pos + Vector2(hr * 0.75, hr * 0.25), hr * 0.22, Color(1.0, 0.42, 0.56, 0.55))
	
	# Cheerful Smile
	preview_canvas.draw_arc(h_pos + Vector2(0, hr * 0.35), hr * 0.32, 0.2, PI - 0.2, 10, Color(0.08, 0.02, 0.10), 3.2)
	preview_canvas.draw_circle(h_pos + Vector2(0, hr * 0.48), hr * 0.15, Color(0.96, 0.32, 0.48))
