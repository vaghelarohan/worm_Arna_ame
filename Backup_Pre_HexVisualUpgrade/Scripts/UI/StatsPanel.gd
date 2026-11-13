extends Panel

@onready var coins_val: Label = $Grid/CoinsStat/TextCol/Val
@onready var kills_val: Label = $Grid/KillsStat/TextCol/Val
@onready var trophies_val: Label = $Grid/TrophiesStat/TextCol/Val
@onready var best_val: Label = $Grid/BestStat/TextCol/Val
@onready var diamonds_val: Label = $Grid/DiamondsStat/TextCol/Val
@onready var level_val: Label = $Grid/LevelStat/TextCol/Val

func _ready() -> void:
	update_ui()
	GameManager.player_data_changed.connect(update_ui)

func update_ui() -> void:
	coins_val.text = str(GameManager.coins)
	kills_val.text = str(GameManager.kills)
	trophies_val.text = str(GameManager.trophies)
	best_val.text = "%d" % GameManager.best_score
	diamonds_val.text = str(GameManager.diamonds)
	level_val.text = "Lv. " + str(GameManager.level)
