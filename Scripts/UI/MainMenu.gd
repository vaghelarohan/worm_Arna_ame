extends Control

@onready var profile_card: Control = $ContentStage/ProfileCard
@onready var stats_panel: Control = $ContentStage/StatsPanel
@onready var settings_btn: Button = $ContentStage/SettingsBtn
@onready var side_buttons: Control = $ContentStage/SideButtons
@onready var mode_cards: Control = $ContentStage/ModeCards
@onready var bottom_nav: Control = $ContentStage/BottomNav
@onready var logo_rect: TextureRect = $ContentStage/Logo
@onready var modal_layer: Control = $ModalLayer

var modal_scene: PackedScene = preload("res://Scenes/Components/GameModal.tscn")

var modal_scenes: Dictionary = {
	"quick": preload("res://Scenes/Menus/QuickPlayModal.tscn"),
	"infinity": preload("res://Scenes/Menus/InfinityModal.tscn"),
	"tournament": preload("res://Scenes/Menus/TournamentModal.tscn"),
	"modes": preload("res://Scenes/Menus/ModesModal.tscn"),
	"skins": preload("res://Scenes/Menus/SkinsModal.tscn"),
	"backgrounds": preload("res://Scenes/Menus/BackgroundSelectModal.tscn"),
	"boosters": preload("res://Scenes/Menus/BoostersModal.tscn"),
	"ranks": preload("res://Scenes/Menus/RanksModal.tscn"),
	"settings": preload("res://Scenes/Menus/SettingsModal.tscn"),
	"help": preload("res://Scenes/Menus/HelpModal.tscn"),
	"wheel": preload("res://Scenes/Menus/WheelModal.tscn"),
	"profile": preload("res://Scenes/Menus/ProfileModal.tscn")
}

var modal_titles: Dictionary = {
	"modes": "GAME MODES",
	"skins": "SKINS CATALOG",
	"backgrounds": "ARENA ENVIRONMENTS",
	"boosters": "BOOSTERS",
	"ranks": "LEADERBOARD",
	"settings": "SETTINGS",
	"help": "HOW TO PLAY",
	"wheel": "WHEEL OF FORTUNE",
	"profile": "PLAYER PROFILE",
	"quick": "QUICK PLAY",
	"infinity": "INFINITY MODE",
	"tournament": "TOURNAMENT"
}

var modal_sizes: Dictionary = {
	"quick": Vector2(780, 500),
	"profile": Vector2(920, 550)
}

var _logo_initial_y: float = 8.0
var _time: float = 0.0

func _ready() -> void:
	_logo_initial_y = logo_rect.position.y
	SoundManager.play_bgm("menu")
	
	profile_card.card_clicked.connect(func(): open_modal("profile"))
	settings_btn.pressed.connect(func(): open_modal("settings"))
	side_buttons.help_clicked.connect(func(): open_modal("help"))
	side_buttons.wheel_clicked.connect(func(): open_modal("wheel"))
	mode_cards.mode_selected.connect(open_modal)
	bottom_nav.item_selected.connect(open_modal)

func _process(delta: float) -> void:
	_time += delta
	# Animate logo bob (4s period)
	var bob: float = sin(_time * (TAU / 4.0)) * 6.0
	logo_rect.position.y = _logo_initial_y + bob

func open_modal(screen_id: String) -> void:
	SoundManager.play_click()
	
	# Clear any active modal
	for c in modal_layer.get_children():
		c.queue_free()
	
	if not modal_scenes.has(screen_id):
		return
	
	var modal = modal_scene.instantiate()
	modal_layer.add_child(modal)
	modal.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	if modal_sizes.has(screen_id):
		modal.set_panel_size(modal_sizes[screen_id])
	modal.set_title(modal_titles.get(screen_id, "WORM ARENA"))
	
	var content = modal_scenes[screen_id].instantiate()
	if screen_id == "modes" and content.has_signal("mode_picked"):
		content.mode_picked.connect(func(m): open_modal(m))
	if content.has_signal("backgrounds_requested"):
		content.backgrounds_requested.connect(func(): open_modal("backgrounds"))
	if content.has_signal("skins_requested"):
		content.skins_requested.connect(func(): open_modal("skins"))
	
	modal.set_content(content)

