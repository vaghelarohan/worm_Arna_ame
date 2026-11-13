extends Control

@onready var join_btn: Button = $VBox/JoinBtn

func _ready() -> void:
	join_btn.pressed.connect(func():
		GameManager.start_game("tournament", 5)
	)

