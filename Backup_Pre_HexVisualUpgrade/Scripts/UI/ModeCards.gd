extends VBoxContainer

signal mode_selected(mode_name: String)

@onready var quick_btn: Button = $QuickPlayCard
@onready var infinity_btn: Button = $InfinityCard
@onready var tournament_btn: Button = $TournamentCard

func _ready() -> void:
	quick_btn.pressed.connect(func(): mode_selected.emit("quick"))
	infinity_btn.pressed.connect(func(): mode_selected.emit("infinity"))
	tournament_btn.pressed.connect(func(): mode_selected.emit("tournament"))

