extends Control

signal again_pressed
signal menu_pressed

@onready var new_best_lbl: Label = $CenterContainer/Panel/VBox/NewBest
@onready var val_score: Label = $CenterContainer/Panel/VBox/Grid/StatScore/Col/Val
@onready var val_kills: Label = $CenterContainer/Panel/VBox/Grid/StatKills/Col/Val
@onready var val_coins: Label = $CenterContainer/Panel/VBox/Grid/StatCoins/Col/HBox/Val
@onready var val_best: Label = $CenterContainer/Panel/VBox/Grid/StatBest/Col/Val

@onready var again_btn: Button = $CenterContainer/Panel/VBox/AgainBtn
@onready var menu_btn: Button = $CenterContainer/Panel/VBox/MenuBtn

func _ready() -> void:
	again_btn.pressed.connect(func(): again_pressed.emit())
	menu_btn.pressed.connect(func(): menu_pressed.emit())

func set_stats(score: int, match_kills: int, coins: int, best: int) -> void:
	val_score.text = "%d" % score
	val_kills.text = str(match_kills)
	val_coins.text = str(coins)
	val_best.text = "%d" % max(best, score)
	
	new_best_lbl.visible = (score >= best and score > 0)
