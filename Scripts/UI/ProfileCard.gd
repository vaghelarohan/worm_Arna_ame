extends Control

signal card_clicked

@onready var username_lbl: Label = $CardButton/Panel/TopRow/Username
@onready var rank_lbl: Label = $CardButton/Panel/InfoRow/Rank
@onready var id_lbl: Label = $CardButton/Panel/InfoRow/Id
@onready var xp_bar: ProgressBar = $CardButton/Panel/XpBar
@onready var xp_lbl: Label = $CardButton/Panel/XpBar/XpText
@onready var coins_lbl: Label = $CardButton/Panel/CoinsRow/CoinsValue
@onready var level_lbl: Label = $CardButton/Avatar/LevelBadge/LevelNumber
@onready var avatar_img: TextureRect = $CardButton/Avatar/CircleFrame/AvatarImg if has_node("CardButton/Avatar/CircleFrame/AvatarImg") else $CardButton/Avatar/AvatarImg
@onready var pencil_btn: Button = $CardButton/Panel/TopRow/PencilBtn

var _glow_tween: Tween

func _ready() -> void:
	update_ui()
	GameManager.player_data_changed.connect(update_ui)
	$CardButton.pressed.connect(func(): card_clicked.emit())
	if pencil_btn:
		pencil_btn.pressed.connect(func(): card_clicked.emit())
	_start_breathing_glow()

func _start_breathing_glow() -> void:
	var glow_panel = get_node_or_null("CardButton/Avatar/GlowShadow")
	if not glow_panel:
		return
	if _glow_tween and _glow_tween.is_valid():
		_glow_tween.kill()
	glow_panel.modulate.a = 0.8
	_glow_tween = create_tween().set_loops()
	_glow_tween.tween_property(glow_panel, "modulate:a", 1.25, 2.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_glow_tween.tween_property(glow_panel, "modulate:a", 0.75, 2.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func update_ui() -> void:
	username_lbl.text = GameManager.username
	rank_lbl.text = "Rank: " + GameManager.rank
	id_lbl.text = GameManager.player_id
	level_lbl.text = str(GameManager.level)
	coins_lbl.text = str(GameManager.coins)
	if avatar_img:
		avatar_img.texture = GameManager.get_avatar_texture()
	
	xp_bar.max_value = GameManager.xp_max
	xp_bar.value = GameManager.xp
	xp_lbl.text = str(GameManager.xp) + " / " + str(GameManager.xp_max) + " XP"


