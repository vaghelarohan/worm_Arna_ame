extends Control

signal pause_pressed

@onready var kills_lbl: Label = $TopKills/HBox/Val
@onready var timer_lbl: Label = $TopTimer/HBox/Val
@onready var coins_lbl: Label = $TopCoins/HBox/Val
@onready var pause_btn: Button = $PauseBtn
@onready var xp_bar: ProgressBar = $PlayerBadge/Panel/Row/Bar
@onready var xp_lbl: Label = $PlayerBadge/Panel/Row/Bar/XpText
@onready var level_lbl: Label = $PlayerBadge/Panel/Row/LvBadge/Num
@onready var board_list: VBoxContainer = $Leaderboard/List

var icon_crown: Texture2D = preload("res://Assets/Icons/crown.svg")
var font_lilita: FontFile = preload("res://Assets/Fonts/LilitaOne-Regular.ttf")

var _last_kills: int = -1
var _last_coins: int = -1
var _last_level: int = -1
var _last_board_hash: String = ""

func _ready() -> void:
	pause_btn.pressed.connect(func():
		SoundManager.play_click()
		pause_pressed.emit()
	)
	# Center pivot for scale punch animations
	kills_lbl.pivot_offset = kills_lbl.size / 2.0
	coins_lbl.pivot_offset = coins_lbl.size / 2.0

func update_hud(data: Dictionary) -> void:
	var kills: int = data.get("kills", 0)
	if kills != _last_kills:
		kills_lbl.text = "Kills: %d" % kills
		if _last_kills >= 0 and kills > _last_kills:
			_punch_scale(kills_lbl, 1.35)
		_last_kills = kills
	
	var sec: int = int(data.get("time", 0.0))
	timer_lbl.text = "%02d:%02d" % [int(sec / 60), sec % 60]
	
	var coins: int = data.get("coins", 0)
	if coins != _last_coins:
		coins_lbl.text = "%d" % coins
		if _last_coins >= 0 and coins > _last_coins:
			_punch_scale(coins_lbl, 1.25)
		_last_coins = coins
	
	var xp_val: int = data.get("xp", 0)
	xp_bar.value = xp_val
	xp_lbl.text = "%d/500 XP" % xp_val
	
	var lv: int = data.get("level", 1)
	if lv != _last_level:
		level_lbl.text = "Lv.%d" % lv
		if _last_level > 0 and lv > _last_level:
			_punch_scale(level_lbl, 1.4)
		_last_level = lv
	
	# Update leaderboard only when ranks/scores change to preserve performance
	var board_rows: Array = data.get("board", [])
	var b_hash := ""
	for r in board_rows:
		b_hash += "%s:%d;" % [r.get("name", ""), r.get("score", 0)]
	
	if b_hash != _last_board_hash:
		_last_board_hash = b_hash
		for c in board_list.get_children():
			c.queue_free()
		
		for r in board_rows:
			var row := HBoxContainer.new()
			row.add_theme_constant_override("separation", 8)
			
			var rank_num: int = int(r.get("rank", 1))
			var rank_lbl := Label.new()
			rank_lbl.custom_minimum_size = Vector2(24, 0)
			rank_lbl.add_theme_font_override("font", font_lilita)
			rank_lbl.add_theme_font_size_override("font_size", 18)
			
			match rank_num:
				1: rank_lbl.add_theme_color_override("font_color", Color("#fbbf24")) # Gold
				2: rank_lbl.add_theme_color_override("font_color", Color("#cbd5e1")) # Silver
				3: rank_lbl.add_theme_color_override("font_color", Color("#f97316")) # Bronze
				_: rank_lbl.add_theme_color_override("font_color", Color("#22d3ee")) # Cyan
			rank_lbl.text = str(rank_num)
			row.add_child(rank_lbl)
			
			if rank_num == 1:
				var crn := TextureRect.new()
				crn.custom_minimum_size = Vector2(18, 18)
				crn.texture = icon_crown
				crn.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				crn.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				row.add_child(crn)
			else:
				var sp := Control.new()
				sp.custom_minimum_size = Vector2(18, 0)
				row.add_child(sp)
			
			var name_lbl := Label.new()
			name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			name_lbl.add_theme_font_override("font", font_lilita)
			name_lbl.add_theme_font_size_override("font_size", 18)
			name_lbl.text = r.get("name", "")
			if r.get("me", false):
				name_lbl.add_theme_color_override("font_color", Color("#38bdf8"))
			row.add_child(name_lbl)
			
			var score_lbl := Label.new()
			score_lbl.add_theme_font_override("font", font_lilita)
			score_lbl.add_theme_font_size_override("font_size", 18)
			score_lbl.add_theme_color_override("font_color", Color("#fbbf24"))
			score_lbl.text = "%d" % r.get("score", 0)
			row.add_child(score_lbl)
			
			board_list.add_child(row)

func _punch_scale(ctrl: Control, factor: float) -> void:
	ctrl.pivot_offset = ctrl.size / 2.0
	var tw := create_tween()
	tw.tween_property(ctrl, "scale", Vector2.ONE * factor, 0.08).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(ctrl, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
