extends Control

signal pause_pressed

@onready var kills_lbl: Label = $TopKills/HBox/Val
@onready var top_timer: Panel = $TopTimer
@onready var timer_lbl: Label = $TopTimer/HBox/Val
@onready var coins_lbl: Label = $TopCoins/HBox/Val
@onready var pause_btn: Button = $PauseBtn
@onready var xp_bar: ProgressBar = $PlayerBadge/Panel/Row/Bar
@onready var xp_lbl: Label = $PlayerBadge/Panel/Row/Bar/XpText
@onready var level_lbl: Label = $PlayerBadge/Panel/Row/LvBadge/Num
@onready var board_list: VBoxContainer = $Leaderboard/List
@onready var kill_feed: VBoxContainer = $KillFeed
@onready var kill_bar: Panel = $KillNotificationBar
@onready var kill_bar_text: Label = $KillNotificationBar/HBox/Text
@onready var kill_bar_reward: Label = $KillNotificationBar/HBox/RewardBadge
@onready var kill_bar_icon: TextureRect = $KillNotificationBar/HBox/Icon

var icon_crown: Texture2D = preload("res://Assets/Icons/crown.svg")
var icon_skull: Texture2D = preload("res://Assets/Icons/skull.svg")
var font_lilita: FontFile = preload("res://Assets/Fonts/LilitaOne-Regular.ttf")

var _last_kills: int = -1
var _last_coins: int = -1
var _last_level: int = -1
var _last_board_hash: String = ""

var _kill_queue: Array[Dictionary] = []
var _kill_active: bool = false
var _combo_count: int = 0
var _combo_timer: float = 0.0

func _process(delta: float) -> void:
	if _combo_timer > 0.0:
		_combo_timer -= delta
		if _combo_timer <= 0.0:
			_combo_count = 0

func show_kill_notification(victim_name: String, victim_color: Color = Color.WHITE, reward: int = 25) -> void:
	if _combo_timer > 0.0:
		_combo_count += 1
	else:
		_combo_count = 1
	_combo_timer = 5.0
	
	var title_text := ""
	var reward_amt: int = reward
	match _combo_count:
		1:
			title_text = "YOU DEFEATED %s!" % victim_name.to_upper()
			reward_amt = reward
		2:
			title_text = "⚡ DOUBLE KILL! (%s)" % victim_name.to_upper()
			reward_amt = reward * 2
		3:
			title_text = "🔥 TRIPLE KILL! (%s)" % victim_name.to_upper()
			reward_amt = reward * 3
		_:
			title_text = "👑 UNSTOPPABLE! (%s)" % victim_name.to_upper()
			reward_amt = reward * 4
	
	_kill_queue.append({
		"title": title_text,
		"reward": "+%d 🪙" % reward_amt,
		"color": victim_color
	})
	
	if not _kill_active:
		_process_kill_queue()

func _process_kill_queue() -> void:
	if _kill_queue.is_empty():
		_kill_active = false
		kill_bar.visible = false
		return
	
	_kill_active = true
	var item: Dictionary = _kill_queue.pop_front()
	
	kill_bar_text.text = item["title"]
	kill_bar_reward.text = item["reward"]
	kill_bar_icon.modulate = item["color"]
	
	kill_bar.visible = true
	kill_bar.modulate.a = 0.0
	kill_bar.scale = Vector2(0.7, 0.7)
	kill_bar.pivot_offset = kill_bar.size / 2.0
	kill_bar.position.y = 80.0
	
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(kill_bar, "position:y", 105.0, 0.24).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(kill_bar, "scale", Vector2.ONE, 0.24).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(kill_bar, "modulate:a", 1.0, 0.20)
	
	await get_tree().create_timer(2.2).timeout
	if not is_inside_tree():
		return
	
	var out_tw := create_tween()
	out_tw.set_parallel(true)
	out_tw.tween_property(kill_bar, "position:y", 75.0, 0.22).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	out_tw.tween_property(kill_bar, "scale", Vector2(0.85, 0.85), 0.22)
	out_tw.tween_property(kill_bar, "modulate:a", 0.0, 0.22)
	
	await out_tw.finished
	_process_kill_queue()

func add_death_notification(victim_name: String, killer_name: String, is_player_victim: bool, is_player_killer: bool, victim_color: Color = Color.WHITE) -> void:
	if not kill_feed:
		return
	
	# Cull oldest if at max capacity (max 3 visible simultaneously)
	while kill_feed.get_child_count() >= 3:
		var oldest = kill_feed.get_child(0)
		kill_feed.remove_child(oldest)
		oldest.queue_free()
	
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(320, 32)
	
	var sb := StyleBoxFlat.new()
	sb.content_margin_left = 10
	sb.content_margin_top = 4
	sb.content_margin_right = 10
	sb.content_margin_bottom = 4
	sb.bg_color = Color("#070e22", 0.92)
	sb.set_corner_radius_all(8)
	sb.border_width_left = 3
	sb.border_width_top = 1
	sb.border_width_right = 1
	sb.border_width_bottom = 1
	sb.shadow_color = Color(0, 0, 0, 0.45)
	sb.shadow_size = 6
	
	var accent_color := Color("#38bdf8")
	var msg := ""
	
	if is_player_killer:
		accent_color = Color("#4ade80") # Lime Green
		sb.border_color = Color("#4ade80")
		msg = "You eliminated %s!" % victim_name
	elif is_player_victim:
		accent_color = Color("#ef4444") # Crimson
		sb.border_color = Color("#ef4444")
		if killer_name != "" and killer_name != "You":
			msg = "Your worm was eliminated by %s!" % killer_name
		else:
			msg = "Your worm was eliminated!"
	else:
		accent_color = Color("#06b6d4") # Cyan
		sb.border_color = Color("#06b6d4")
		if killer_name != "" and killer_name != "Unknown":
			msg = "%s was eliminated by %s!" % [victim_name, killer_name]
		else:
			msg = "%s was eliminated!" % victim_name
	
	card.add_theme_stylebox_override("panel", sb)
	
	var hbox := HBoxContainer.new()
	hbox.name = "HBox"
	hbox.add_theme_constant_override("separation", 8)
	card.add_child(hbox)
	
	var icon := TextureRect.new()
	icon.name = "Icon"
	icon.custom_minimum_size = Vector2(16, 16)
	icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	icon.texture = icon_skull
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.modulate = accent_color
	hbox.add_child(icon)
	
	var lbl := Label.new()
	lbl.name = "Text"
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl.add_theme_font_override("font", font_lilita)
	lbl.add_theme_font_size_override("font_size", 14)
	lbl.add_theme_color_override("font_color", accent_color if (is_player_killer or is_player_victim) else Color("#f1f5f9"))
	lbl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	lbl.text = msg
	hbox.add_child(lbl)
	
	kill_feed.add_child(card)
	
	# Slide-in animation
	card.modulate.a = 0.0
	card.position.x = -40.0
	var tw_in := create_tween()
	tw_in.set_parallel(true)
	tw_in.tween_property(card, "modulate:a", 1.0, 0.20)
	tw_in.tween_property(card, "position:x", 0.0, 0.20).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	_schedule_kill_feed_removal(card)

func _schedule_kill_feed_removal(card: PanelContainer) -> void:
	await get_tree().create_timer(3.5).timeout
	if not is_instance_valid(card) or not card.is_inside_tree():
		return
	var tw_out := create_tween()
	tw_out.set_parallel(true)
	tw_out.tween_property(card, "modulate:a", 0.0, 0.25)
	tw_out.tween_property(card, "position:x", -30.0, 0.25)
	await tw_out.finished
	if is_instance_valid(card):
		card.queue_free()

func _ready() -> void:
	pause_btn.pressed.connect(func():
		SoundManager.play_click()
		pause_pressed.emit()
	)
	kills_lbl.pivot_offset = kills_lbl.size / 2.0
	coins_lbl.pivot_offset = coins_lbl.size / 2.0

func update_hud(data: Dictionary) -> void:
	var kills: int = data.get("kills", 0)
	if kills != _last_kills:
		kills_lbl.text = "Kills: %d" % kills
		if _last_kills >= 0 and kills > _last_kills:
			_punch_scale(kills_lbl, 1.35)
		_last_kills = kills
	
	var mode_name: String = str(data.get("mode", "quick"))
	if mode_name == "infinity":
		top_timer.visible = false
	else:
		top_timer.visible = true
		var rem_sec: int = int(data.get("time_remaining", 0.0))
		timer_lbl.text = "%02d:%02d" % [int(rem_sec / 60), rem_sec % 60]
	
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
			var is_me: bool = r.get("me", false)
			var rank_num: int = int(r.get("rank", 1))
			
			var row_container := PanelContainer.new()
			var row_sb := StyleBoxFlat.new()
			row_sb.content_margin_left = 6
			row_sb.content_margin_right = 6
			row_sb.content_margin_top = 2
			row_sb.content_margin_bottom = 2
			row_sb.set_corner_radius_all(6)
			
			if is_me:
				row_sb.bg_color = Color("#0c2340", 0.85)
				row_sb.border_width_left = 2
				row_sb.border_width_top = 1
				row_sb.border_width_right = 2
				row_sb.border_width_bottom = 1
				row_sb.border_color = Color("#38bdf8")
			else:
				row_sb.bg_color = Color(0, 0, 0, 0)
			row_container.add_theme_stylebox_override("panel", row_sb)
			
			var row := HBoxContainer.new()
			row.custom_minimum_size = Vector2(0, 24)
			row.add_theme_constant_override("separation", 8)
			row_container.add_child(row)
			
			# Rank icon / number
			var rank_box := HBoxContainer.new()
			rank_box.custom_minimum_size = Vector2(24, 22)
			rank_box.alignment = BoxContainer.ALIGNMENT_CENTER
			
			if rank_num == 1:
				var crn := TextureRect.new()
				crn.custom_minimum_size = Vector2(18, 18)
				crn.texture = icon_crown
				crn.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				crn.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				rank_box.add_child(crn)
			else:
				var rank_lbl := Label.new()
				rank_lbl.add_theme_font_override("font", font_lilita)
				rank_lbl.add_theme_font_size_override("font_size", 16)
				match rank_num:
					2: rank_lbl.add_theme_color_override("font_color", Color("#cbd5e1")) # Silver
					3: rank_lbl.add_theme_color_override("font_color", Color("#f97316")) # Bronze
					_: rank_lbl.add_theme_color_override("font_color", Color("#38bdf8")) # Cyan
				rank_lbl.text = str(rank_num)
				rank_box.add_child(rank_lbl)
			row.add_child(rank_box)
			
			# Name
			var name_lbl := Label.new()
			name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			name_lbl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
			name_lbl.add_theme_font_override("font", font_lilita)
			name_lbl.add_theme_font_size_override("font_size", 16)
			
			if is_me:
				name_lbl.text = "%s (YOU)" % GameManager.username
				name_lbl.add_theme_color_override("font_color", Color("#38bdf8"))
			else:
				name_lbl.text = r.get("name", "")
				name_lbl.add_theme_color_override("font_color", Color("#f1f5f9"))
			row.add_child(name_lbl)
			
			# Score
			var score_lbl := Label.new()
			score_lbl.custom_minimum_size = Vector2(56, 0)
			score_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			score_lbl.add_theme_font_override("font", font_lilita)
			score_lbl.add_theme_font_size_override("font_size", 16)
			score_lbl.add_theme_color_override("font_color", Color("#fbbf24"))
			score_lbl.text = "%d" % r.get("score", 0)
			row.add_child(score_lbl)
			
			board_list.add_child(row_container)

func _punch_scale(ctrl: Control, factor: float) -> void:
	ctrl.pivot_offset = ctrl.size / 2.0
	var tw := create_tween()
	tw.tween_property(ctrl, "scale", Vector2.ONE * factor, 0.08).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(ctrl, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
