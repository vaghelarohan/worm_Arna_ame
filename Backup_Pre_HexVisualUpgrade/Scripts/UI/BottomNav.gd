extends Panel

signal item_selected(screen_name: String)

@onready var play_btn: Button = $Grid/PlayBtn
@onready var modes_btn: Button = $Grid/ModesBtn
@onready var skins_btn: Button = $Grid/SkinsBtn
@onready var boosters_btn: Button = $Grid/BoostersBtn
@onready var ranks_btn: Button = $Grid/RanksBtn
@onready var settings_btn: Button = $Grid/SettingsBtn

func _ready() -> void:
	play_btn.pressed.connect(func(): item_selected.emit("modes"))
	modes_btn.pressed.connect(func(): item_selected.emit("modes"))
	skins_btn.pressed.connect(func(): item_selected.emit("skins"))
	boosters_btn.pressed.connect(func(): item_selected.emit("boosters"))
	ranks_btn.pressed.connect(func(): item_selected.emit("ranks"))
	settings_btn.pressed.connect(func(): item_selected.emit("settings"))

