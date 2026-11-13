extends Control

@onready var best_lbl: Label = $VBox/BestScore
@onready var enter_btn: Button = $VBox/EnterBtn

func _ready() -> void:
	best_lbl.text = "Your best: " + str(GameManager.best_score)
	enter_btn.pressed.connect(func():
		GameManager.start_game("infinity", 0)
	)

