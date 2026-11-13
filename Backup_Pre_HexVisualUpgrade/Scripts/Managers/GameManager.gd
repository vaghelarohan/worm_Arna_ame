extends Node

signal player_data_changed
signal sound_toggled(enabled: bool)

# Player Profile Data
var username: String = "Finalboss"
var rank: String = "Beginner"
var player_id: String = "#W-2707"
var level: int = 3
var xp: int = 844
var xp_max: int = 1100
var coins: int = 105
var kills: int = 24
var trophies: int = 117
var best_score: int = 1250
var diamonds: int = 20

# Selected Game Parameters
var selected_mode: String = "quick" # "quick", "infinity", "tournament"
var match_duration_minutes: int = 5

# Skins Catalog
var skins: Array[Dictionary] = [
	{ "name": "Electric Blue", "hue": 240, "color": Color("#4fc3ff"), "color2": Color("#1f7bff"), "owned": true, "price": 0 },
	{ "name": "Toxic Lime", "hue": 140, "color": Color("#8dff5a"), "color2": Color("#2fbf3a"), "owned": true, "price": 0 },
	{ "name": "Lava", "hue": 30, "color": Color("#ffb340"), "color2": Color("#ff6a1f"), "owned": false, "price": 250 },
	{ "name": "Galaxy", "hue": 300, "color": Color("#ff7ad9"), "color2": Color("#b03bff"), "owned": false, "price": 500 },
	{ "name": "Frost", "hue": 200, "color": Color("#9ab4ff"), "color2": Color("#3c4fd6"), "owned": false, "price": 400 },
	{ "name": "Gold King", "hue": 85, "color": Color("#ffe14f"), "color2": Color("#e0a600"), "owned": false, "price": 1000 }
]
var equipped_skin_idx: int = 0

# Boosters Catalog
var boosters: Array[Dictionary] = [
	{ "name": "Speed Rush", "desc": "+40% speed for 10s", "price": 30, "icon": "zap" },
	{ "name": "Magnet", "desc": "Pull food from afar", "price": 40, "icon": "magnet" },
	{ "name": "Shield", "desc": "Survive one crash", "price": 60, "icon": "shield" },
	{ "name": "Double XP", "desc": "2x XP next match", "price": 80, "icon": "star" }
]
var owned_boosters: Dictionary = {}

# Global Leaderboard
var leaderboard: Array[Dictionary] = [
	{ "name": "SnakeLord", "score": 98420, "me": false },
	{ "name": "NeonViper", "score": 87210, "me": false },
	{ "name": "WormZilla", "score": 76004, "me": false },
	{ "name": "Slinky", "score": 54320, "me": false },
	{ "name": "Noodle99", "score": 41200, "me": false },
	{ "name": "Finalboss", "score": 1250, "me": true }
]

# Wheel of Fortune Prizes
var wheel_prizes: Array[String] = [
	"50 Coins", "5 Gems", "Speed", "100 Coins", "Shield", "10 Gems", "Magnet", "250 Coins"
]

const SAVE_PATH = "user://worm_save.json"

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	load_game()

func get_equipped_skin() -> Dictionary:
	if equipped_skin_idx >= 0 and equipped_skin_idx < skins.size():
		return skins[equipped_skin_idx]
	return skins[0]

func equip_skin(idx: int) -> bool:
	if idx >= 0 and idx < skins.size():
		if skins[idx]["owned"]:
			equipped_skin_idx = idx
			save_game()
			player_data_changed.emit()
			return true
	return false

func buy_skin(idx: int) -> bool:
	if idx >= 0 and idx < skins.size():
		var s: Dictionary = skins[idx]
		if not s["owned"] and coins >= int(s["price"]):
			coins -= int(s["price"])
			s["owned"] = true
			equipped_skin_idx = idx
			save_game()
			player_data_changed.emit()
			return true
	return false

func buy_booster(booster_name: String, price: int) -> bool:
	if coins >= price:
		coins -= price
		owned_boosters[booster_name] = owned_boosters.get(booster_name, 0) + 1
		save_game()
		player_data_changed.emit()
		return true
	return false

func add_coins(amount: int) -> void:
	coins += amount
	save_game()
	player_data_changed.emit()

func add_diamonds(amount: int) -> void:
	diamonds += amount
	save_game()
	player_data_changed.emit()

func record_game_result(score: int, match_kills: int, earned_coins: int) -> void:
	coins += earned_coins
	kills += match_kills
	if score > best_score:
		best_score = score
		for item in leaderboard:
			if item["me"]:
				item["score"] = best_score
	
	xp += int(score * 0.1)
	while xp >= xp_max:
		xp -= xp_max
		level += 1
		xp_max = int(xp_max * 1.25)
	
	save_game()
	player_data_changed.emit()

func start_game(mode: String = "quick", duration: int = 5) -> void:
	selected_mode = mode
	match_duration_minutes = duration
	get_tree().change_scene_to_file("res://Scenes/Gameplay/PlayScreen.tscn")

func return_to_main_menu() -> void:
	get_tree().change_scene_to_file("res://Scenes/Main/MainMenu.tscn")

func save_game() -> void:
	var data := {
		"username": username,
		"coins": coins,
		"diamonds": diamonds,
		"level": level,
		"xp": xp,
		"xp_max": xp_max,
		"kills": kills,
		"trophies": trophies,
		"best_score": best_score,
		"equipped_skin_idx": equipped_skin_idx,
		"owned_boosters": owned_boosters
	}
	var owned_skin_names: Array[String] = []
	for s in skins:
		if s["owned"]:
			owned_skin_names.append(s["name"])
	data["owned_skins"] = owned_skin_names
	
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "\t"))
		file.close()

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return
	var content := file.get_as_text()
	file.close()
	var json := JSON.new()
	if json.parse(content) != OK:
		return
	var data: Dictionary = json.data
	if data.has("coins"): coins = int(data["coins"])
	if data.has("diamonds"): diamonds = int(data["diamonds"])
	if data.has("level"): level = int(data["level"])
	if data.has("xp"): xp = int(data["xp"])
	if data.has("xp_max"): xp_max = int(data["xp_max"])
	if data.has("kills"): kills = int(data["kills"])
	if data.has("trophies"): trophies = int(data["trophies"])
	if data.has("best_score"):
		best_score = int(data["best_score"])
		for item in leaderboard:
			if item["me"]:
				item["score"] = best_score
	if data.has("equipped_skin_idx"): equipped_skin_idx = int(data["equipped_skin_idx"])
	if data.has("owned_boosters"): owned_boosters = data["owned_boosters"]
	if data.has("owned_skins"):
		var owned_names: Array = data["owned_skins"]
		for s in skins:
			if s["name"] in owned_names:
				s["owned"] = true

