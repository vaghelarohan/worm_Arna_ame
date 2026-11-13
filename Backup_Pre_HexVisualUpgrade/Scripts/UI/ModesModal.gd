extends Control

signal mode_picked(m: String)

@onready var btn_quick: Button = $Grid/BtnQuick
@onready var btn_infinity: Button = $Grid/BtnInfinity
@onready var btn_tournament: Button = $Grid/BtnTournament

func _ready() -> void:
	btn_quick.pressed.connect(func(): mode_picked.emit("quick"))
	btn_infinity.pressed.connect(func(): mode_picked.emit("infinity"))
	btn_tournament.pressed.connect(func(): mode_picked.emit("tournament"))

