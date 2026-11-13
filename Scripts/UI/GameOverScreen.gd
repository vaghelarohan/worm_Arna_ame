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
	
	var panel: Panel = $CenterContainer/Panel
	panel.pivot_offset = panel.custom_minimum_size / 2.0
	panel.scale = Vector2(0.85, 0.85)
	panel.modulate.a = 0.0
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(panel, "scale", Vector2.ONE, 0.28).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(panel, "modulate:a", 1.0, 0.22)

func set_stats(score: int, match_kills: int, coins: int, best: int) -> void:
	val_score.text = "%d" % score
	val_kills.text = str(match_kills)
	val_coins.text = str(coins)
	val_best.text = "%d" % max(best, score)
	
	new_best_lbl.visible = (score >= best and score > 0)
