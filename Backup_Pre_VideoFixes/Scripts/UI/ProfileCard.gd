extends Control

signal card_clicked

@onready var username_lbl: Label = $CardButton/Panel/TopRow/Username
@onready var rank_lbl: Label = $CardButton/Panel/InfoRow/Rank
@onready var id_lbl: Label = $CardButton/Panel/InfoRow/Id
@onready var xp_bar: ProgressBar = $CardButton/Panel/XpBar
@onready var xp_lbl: Label = $CardButton/Panel/XpBar/XpText
@onready var coins_lbl: Label = $CardButton/Panel/CoinsRow/CoinsValue
@onready var level_lbl: Label = $CardButton/Avatar/LevelBadge/LevelNumber

func _ready() -> void:
	update_ui()
	GameManager.player_data_changed.connect(update_ui)
	$CardButton.pressed.connect(func(): card_clicked.emit())

func update_ui() -> void:
	username_lbl.text = GameManager.username
	rank_lbl.text = "Rank: " + GameManager.rank
	id_lbl.text = GameManager.player_id
	level_lbl.text = str(GameManager.level)
	coins_lbl.text = str(GameManager.coins)
	
	xp_bar.max_value = GameManager.xp_max
	xp_bar.value = GameManager.xp
	xp_lbl.text = str(GameManager.xp) + " / " + str(GameManager.xp_max) + " XP"

