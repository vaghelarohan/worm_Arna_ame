extends Control

@onready var grid: GridContainer = $HBox/RightCol/Grid
@onready var input_name: LineEdit = $HBox/RightCol/EditSection/Pad/VBox/Row/UsernameInput
@onready var btn_save: Button = $HBox/RightCol/EditSection/Pad/VBox/Row/SaveBtn
@onready var btn_cancel: Button = $HBox/RightCol/EditSection/Pad/VBox/Row/CancelBtn
@onready var lbl_feedback: Label = $HBox/RightCol/EditSection/Pad/VBox/FeedbackLbl
@onready var lbl_player_id: Label = $HBox/LeftCol/IdPill/PlayerIdLabel
@onready var lbl_rank: Label = $HBox/LeftCol/RankPill/RankLabel
@onready var lbl_level: Label = $HBox/LeftCol/LevelLabel
@onready var avatar_img: TextureRect = $HBox/LeftCol/AvatarContainer/Avatar/Img

var tile_style: StyleBox = preload("res://Resources/tile_style.tres")
var font_lilita: FontFile = preload("res://Assets/Fonts/LilitaOne-Regular.ttf")
var font_fredoka: FontFile = preload("res://Assets/Fonts/Fredoka.ttf")

var _selected_avatar: String = ""

func get_modal_size() -> Vector2:
	return Vector2(920, 550)

func _ready() -> void:
	_selected_avatar = GameManager.selected_avatar
	_refresh_profile()
	
	btn_save.pressed.connect(_on_save_pressed)
	btn_cancel.pressed.connect(_on_cancel_pressed)
	input_name.text_submitted.connect(func(_t): _on_save_pressed())
	
	update_stats()
	GameManager.player_data_changed.connect(func():
		_refresh_profile()
		update_stats()
	)

func _refresh_profile() -> void:
	input_name.text = GameManager.username
	lbl_player_id.text = GameManager.player_id
	lbl_rank.text = "👑 RANK: " + GameManager.rank.to_upper()
	lbl_level.text = "LEVEL %d" % GameManager.level
	avatar_img.texture = GameManager.get_avatar_texture()

func _on_save_pressed() -> void:
	var raw: String = input_name.text.strip_edges()
	if raw.is_empty():
		_show_feedback("Name cannot be empty!", Color("#f87171"))
		SoundManager.play_click(200.0)
		return
	
	if raw.length() < 2:
		_show_feedback("Name is too short (min 2 chars)", Color("#f87171"))
		SoundManager.play_click(200.0)
		return
	
	if raw.length() > 16:
		_show_feedback("Name is too long (max 16 chars)", Color("#f87171"))
		SoundManager.play_click(200.0)
		return
	
	var avatar_to_save: String = _selected_avatar if not _selected_avatar.is_empty() else GameManager.selected_avatar
	var success := GameManager.set_profile(raw, avatar_to_save)
	if success:
		_show_feedback("Profile updated successfully!", Color("#4ade80"))
		SoundManager.play_click(880.0)
		_refresh_profile()
	else:
		_show_feedback("Failed to save profile", Color("#f87171"))

func _on_cancel_pressed() -> void:
	input_name.text = GameManager.username
	lbl_feedback.visible = false
	SoundManager.play_click(440.0)

func _show_feedback(msg: String, col: Color) -> void:
	lbl_feedback.text = msg
	lbl_feedback.add_theme_color_override("font_color", col)
	lbl_feedback.visible = true
	lbl_feedback.modulate.a = 1.0

func update_stats() -> void:
	for c in grid.get_children():
		c.queue_free()
	
	var rows = [
		["Rank", GameManager.rank, Color("#38bdf8")],
		["Level", "Lv. %d" % GameManager.level, Color("#fbbf24")],
		["XP Progress", "%d / %d XP" % [GameManager.xp, GameManager.xp_max], Color("#f59e0b")],
		["Total Kills", str(GameManager.kills), Color("#f87171")],
		["Best Score", "%d" % GameManager.best_score, Color("#fbbf24")],
		["Trophies", "%d 🏆" % GameManager.trophies, Color("#a855f7")],
		["Coins", "%d 🪙" % GameManager.coins, Color("#fbbf24")],
		["Diamonds", "%d 💎" % GameManager.diamonds, Color("#38bdf8")]
	]
	
	for r in rows:
		var panel := Panel.new()
		panel.custom_minimum_size = Vector2(240, 52)
		panel.add_theme_stylebox_override("panel", tile_style)
		
		var col := VBoxContainer.new()
		col.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		col.offset_left = 14
		col.offset_top = 4
		col.offset_right = -14
		col.offset_bottom = -4
		col.alignment = BoxContainer.ALIGNMENT_CENTER
		col.add_theme_constant_override("separation", 2)
		panel.add_child(col)
		
		var lbl := Label.new()
		lbl.add_theme_font_override("font", font_fredoka)
		lbl.add_theme_font_size_override("font_size", 11)
		lbl.add_theme_color_override("font_color", Color("#94a3b8"))
		lbl.text = r[0].to_upper()
		col.add_child(lbl)
		
		var val := Label.new()
		val.add_theme_font_override("font", font_lilita)
		val.add_theme_font_size_override("font_size", 18)
		val.add_theme_color_override("font_color", r[2])
		val.text = r[1]
		col.add_child(val)
		
		if r[0] == "XP Progress":
			var pb := ProgressBar.new()
			pb.custom_minimum_size = Vector2(0, 6)
			pb.max_value = GameManager.xp_max
			pb.value = GameManager.xp
			pb.show_percentage = false
			
			var bg_sb := StyleBoxFlat.new()
			bg_sb.bg_color = Color("#0f172a")
			bg_sb.set_corner_radius_all(3)
			pb.add_theme_stylebox_override("background", bg_sb)
			
			var fill_sb := StyleBoxFlat.new()
			fill_sb.bg_color = Color("#f59e0b")
			fill_sb.set_corner_radius_all(3)
			pb.add_theme_stylebox_override("fill", fill_sb)
			col.add_child(pb)
		
		grid.add_child(panel)
