extends Node

signal player_data_changed

# Player Profile Data
var username: String = "Finalboss"
var selected_avatar: String = "hero"
var rank: String = "Novice"
var player_id: String = "#W-2707"
var level: int = 1
var xp: int = 108
var xp_max: int = 500
var coins: int = 5078
var kills: int = 0
var trophies: int = 117
var best_score: int = 1250
var diamonds: int = 20

# 8 High-Res Profile Avatars (Square 256x256 Head Portraits)
const AVATAR_DEFS: Dictionary = {
	"hero": {"id": "hero", "name": "Worm Hero", "path": "res://Assets/Characters/Avatars/avatar_hero.png"},
	"king": {"id": "king", "name": "Royal Crown", "path": "res://Assets/Characters/Avatars/avatar_king.png"},
	"dragon": {"id": "dragon", "name": "Inferno Dragon", "path": "res://Assets/Characters/Avatars/avatar_dragon.png"},
	"ice": {"id": "ice", "name": "Frost Legend", "path": "res://Assets/Characters/Avatars/avatar_ice.png"},
	"tiger": {"id": "tiger", "name": "Tiger Strike", "path": "res://Assets/Characters/Avatars/avatar_tiger.png"},
	"heart": {"id": "heart", "name": "Heart Queen", "path": "res://Assets/Characters/Avatars/avatar_heart.png"},
	"ninja": {"id": "ninja", "name": "Shadow Ninja", "path": "res://Assets/Characters/Avatars/avatar_ninja.png"},
	"cyber": {"id": "cyber", "name": "Cyber Samurai", "path": "res://Assets/Characters/Avatars/avatar_cyber.png"}
}

# Selected Game Parameters
var selected_mode: String = "quick" # "quick", "infinity", "tournament"
var match_duration_minutes: int = 5
var selected_background: String = "neon_blue"

# 8 Distinct 2D Arena Background Environments
var backgrounds: Array[Dictionary] = [
	{
		"id": "neon_blue",
		"name": "Neon Blue Arena",
		"desc": "Deep cyber sapphire arena with cyan hex grid and glowing motes",
		"bg_color": Color("#0b1736"),
		"accent": Color("#00f5ff"),
		"owned": true,
		"price": 0
	},
	{
		"id": "candy_world",
		"name": "Candy World",
		"desc": "Sweet pastel lilac arena with sugar-cane hex grid and candy motes",
		"bg_color": Color("#240e34"),
		"accent": Color("#f472b6"),
		"owned": true,
		"price": 0
	},
	{
		"id": "jungle",
		"name": "Jungle World",
		"desc": "Emerald tropical rainforest with mossy green hexes and fireflies",
		"bg_color": Color("#0a2214"),
		"accent": Color("#22c55e"),
		"owned": true,
		"price": 0
	},
	{
		"id": "space_galaxy",
		"name": "Space Galaxy",
		"desc": "Cosmic deep space nebula with stellar purple hexes and stardust",
		"bg_color": Color("#0e0725"),
		"accent": Color("#a855f7"),
		"owned": true,
		"price": 0
	},
	{
		"id": "lava_world",
		"name": "Lava Kingdom",
		"desc": "Blazing volcanic magma cavern with fiery magma hexes and embers",
		"bg_color": Color("#1a0909"),
		"accent": Color("#f97316"),
		"owned": true,
		"price": 0
	},
	{
		"id": "ice_kingdom",
		"name": "Ice Kingdom",
		"desc": "Frozen arctic crystal tundra with frosty turquoise hexes and snowflurries",
		"bg_color": Color("#082032"),
		"accent": Color("#38bdf8"),
		"owned": true,
		"price": 0
	},
	{
		"id": "sunset_beach",
		"name": "Sunset Beach",
		"desc": "Warm dusk horizon with sun-baked coral hexes and radiant golden sunlight",
		"bg_color": Color("#2b0e1e"),
		"accent": Color("#fb923c"),
		"owned": true,
		"price": 0
	},
	{
		"id": "magical_forest",
		"name": "Magical Forest",
		"desc": "Enchanted twilight woodland with bioluminescent jade hexes and fairy dust",
		"bg_color": Color("#051c19"),
		"accent": Color("#2dd4bf"),
		"owned": true,
		"price": 0
	}
]

# 14 Premium Modern 2D Worm Skins
var skins: Array[Dictionary] = [
	{
		"id": "royal_blue",
		"name": "Royal Blue",
		"rarity": "Common",
		"color": Color("#1e40af"),
		"color2": Color("#f8fafc"),
		"head_color": Color("#f8fafc"),
		"iris_color": Color("#0284c7"),
		"owned": true,
		"price": 0
	},
	{
		"id": "golden_king",
		"name": "Golden King",
		"rarity": "Legendary",
		"color": Color("#eab308"),
		"color2": Color("#fef08a"),
		"head_color": Color("#fef08a"),
		"iris_color": Color("#ca8a04"),
		"owned": true,
		"price": 0
	},
	{
		"id": "cyber_neon",
		"name": "Cyber Neon",
		"rarity": "Epic",
		"color": Color("#00f5ff"),
		"color2": Color("#ec4899"),
		"head_color": Color("#00f5ff"),
		"iris_color": Color("#a855f7"),
		"owned": true,
		"price": 0
	},
	{
		"id": "rainbow_candy",
		"name": "Rainbow Candy",
		"rarity": "Rare",
		"color": Color("#f43f5e"),
		"color2": Color("#06b6d4"),
		"head_color": Color("#fef08a"),
		"iris_color": Color("#ec4899"),
		"owned": false,
		"price": 300
	},
	{
		"id": "fire_dragon",
		"name": "Fire Dragon",
		"rarity": "Epic",
		"color": Color("#dc2626"),
		"color2": Color("#f97316"),
		"head_color": Color("#f97316"),
		"iris_color": Color("#fbbf24"),
		"owned": false,
		"price": 350
	},
	{
		"id": "ice_crystal",
		"name": "Ice Crystal",
		"rarity": "Rare",
		"color": Color("#38bdf8"),
		"color2": Color("#e0f2fe"),
		"head_color": Color("#e0f2fe"),
		"iris_color": Color("#0284c7"),
		"owned": false,
		"price": 400
	},
	{
		"id": "galaxy_cosmic",
		"name": "Galaxy Cosmic",
		"rarity": "Legendary",
		"color": Color("#7c3aed"),
		"color2": Color("#38bdf8"),
		"head_color": Color("#c084fc"),
		"iris_color": Color("#60a5fa"),
		"owned": false,
		"price": 450
	},
	{
		"id": "toxic_green",
		"name": "Toxic Green",
		"rarity": "Common",
		"color": Color("#84cc16"),
		"color2": Color("#15803d"),
		"head_color": Color("#a3e635"),
		"iris_color": Color("#16a34a"),
		"owned": false,
		"price": 500
	},
	{
		"id": "royal_purple",
		"name": "Royal Purple",
		"rarity": "Rare",
		"color": Color("#6b21a8"),
		"color2": Color("#e9d5ff"),
		"head_color": Color("#d8b4fe"),
		"iris_color": Color("#9333ea"),
		"owned": false,
		"price": 550
	},
	{
		"id": "shadow_ninja",
		"name": "Shadow Ninja",
		"rarity": "Epic",
		"color": Color("#0f172a"),
		"color2": Color("#dc2626"),
		"head_color": Color("#1e293b"),
		"iris_color": Color("#ef4444"),
		"owned": false,
		"price": 600
	},
	{
		"id": "electric_blue",
		"name": "Electric Blue",
		"rarity": "Common",
		"color": Color("#0284c7"),
		"color2": Color("#38bdf8"),
		"head_color": Color("#7dd3fc"),
		"iris_color": Color("#00f5ff"),
		"owned": false,
		"price": 650
	},
	{
		"id": "lava_monster",
		"name": "Lava Monster",
		"rarity": "Legendary",
		"color": Color("#b91c1c"),
		"color2": Color("#fbbf24"),
		"head_color": Color("#f97316"),
		"iris_color": Color("#facc15"),
		"owned": false,
		"price": 700
	},
	{
		"id": "cute_strawberry",
		"name": "Cute Strawberry",
		"rarity": "Rare",
		"color": Color("#f43f5e"),
		"color2": Color("#86efac"),
		"head_color": Color("#fda4af"),
		"iris_color": Color("#10b981"),
		"owned": false,
		"price": 750
	},
	{
		"id": "cute_pink",
		"name": "Cute Pink",
		"rarity": "Rare",
		"color": Color("#ec4899"),
		"color2": Color("#fbcfe8"),
		"head_color": Color("#fdf2f8"),
		"iris_color": Color("#db2777"),
		"owned": false,
		"price": 800
	}
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

# Wheel of Fortune Daily Spin System
var wheel_spins_available: int = 1
var wheel_next_reset_time: int = 0
var wheel_daily_allowance: int = 2
var wheel_initialized: bool = false

const SAVE_PATH = "user://worm_save.json"

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if OS.has_feature("mobile") or OS.has_feature("android"):
		DisplayServer.screen_set_orientation(DisplayServer.SCREEN_LANDSCAPE)
	load_game()

func check_wheel_daily_refresh() -> void:
	var now: int = int(Time.get_unix_time_from_system())
	if not wheel_initialized or wheel_next_reset_time == 0:
		wheel_spins_available = 1
		wheel_daily_allowance = 2
		wheel_next_reset_time = now + 86400
		wheel_initialized = true
		save_game()
		return
	
	if now >= wheel_next_reset_time:
		wheel_spins_available = wheel_daily_allowance
		wheel_next_reset_time = now + 86400
		save_game()
		player_data_changed.emit()

func get_wheel_cooldown_remaining() -> int:
	var now: int = int(Time.get_unix_time_from_system())
	return max(0, wheel_next_reset_time - now)

func consume_wheel_spin() -> bool:
	check_wheel_daily_refresh()
	if wheel_spins_available <= 0:
		return false
	wheel_spins_available -= 1
	save_game()
	player_data_changed.emit()
	return true

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

func get_selected_background() -> Dictionary:
	for bg in backgrounds:
		if bg["id"] == selected_background:
			return bg
	return backgrounds[0]

func equip_background(bg_id: String) -> bool:
	for bg in backgrounds:
		if bg["id"] == bg_id:
			if bg["owned"]:
				selected_background = bg_id
				save_game()
				player_data_changed.emit()
				return true
	return false

func buy_background(bg_id: String) -> bool:
	for bg in backgrounds:
		if bg["id"] == bg_id:
			if not bg["owned"] and coins >= int(bg["price"]):
				coins -= int(bg["price"])
				bg["owned"] = true
				selected_background = bg_id
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

func get_avatar_texture(avatar_id: String = "") -> Texture2D:
	var aid = avatar_id if not avatar_id.is_empty() else selected_avatar
	if AVATAR_DEFS.has(aid):
		var path: String = AVATAR_DEFS[aid]["path"]
		if ResourceLoader.exists(path):
			return load(path)
	return load("res://Assets/Characters/Avatars/avatar_hero.png")

func set_avatar(avatar_id: String) -> bool:
	if not AVATAR_DEFS.has(avatar_id):
		return false
	selected_avatar = avatar_id
	save_game()
	player_data_changed.emit()
	return true

func set_profile(new_username: String, new_avatar: String = "") -> bool:
	var trimmed = new_username.strip_edges()
	if trimmed.is_empty() or trimmed.length() < 2 or trimmed.length() > 16:
		return false
	username = trimmed
	if not new_avatar.is_empty() and AVATAR_DEFS.has(new_avatar):
		selected_avatar = new_avatar
	for item in leaderboard:
		if item["me"]:
			item["name"] = username
	save_game()
	player_data_changed.emit()
	return true

func set_username(new_name: String) -> bool:
	return set_profile(new_name, "")

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
		"selected_avatar": selected_avatar,
		"coins": coins,
		"diamonds": diamonds,
		"level": level,
		"xp": xp,
		"xp_max": xp_max,
		"kills": kills,
		"trophies": trophies,
		"best_score": best_score,
		"equipped_skin_idx": equipped_skin_idx,
		"selected_background": selected_background,
		"owned_boosters": owned_boosters,
		"sound_enabled": SoundManager.sound_enabled,
		"music_enabled": SoundManager.music_enabled,
		"music_volume": SoundManager.music_volume,
		"sfx_volume": SoundManager.sfx_volume,
		"wheel_spins_available": wheel_spins_available,
		"wheel_next_reset_time": wheel_next_reset_time,
		"wheel_daily_allowance": wheel_daily_allowance,
		"wheel_initialized": wheel_initialized
	}
	var owned_skin_names: Array[String] = []
	for s in skins:
		if s["owned"]:
			owned_skin_names.append(s["name"])
	data["owned_skins"] = owned_skin_names
	
	var owned_bg_ids: Array[String] = []
	for bg in backgrounds:
		if bg["owned"]:
			owned_bg_ids.append(bg["id"])
	data["owned_backgrounds"] = owned_bg_ids
	
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
	if data.has("username"):
		username = str(data["username"])
		for item in leaderboard:
			if item["me"]:
				item["name"] = username
	if data.has("selected_avatar"):
		var a_str = str(data["selected_avatar"])
		if AVATAR_DEFS.has(a_str):
			selected_avatar = a_str
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
	if data.has("selected_background"):
		var bg_str = str(data["selected_background"])
		var valid_bg := false
		for b in backgrounds:
			if b["id"] == bg_str:
				valid_bg = true
				break
		if valid_bg:
			selected_background = bg_str
	if data.has("owned_boosters"): owned_boosters = data["owned_boosters"]
	if data.has("owned_skins"):
		var owned_names: Array = data["owned_skins"]
		for s in skins:
			if s["name"] in owned_names or (s["name"] == "Cyber Neon" and "Neon Cyber" in owned_names):
				s["owned"] = true
	if data.has("owned_backgrounds"):
		var owned_bgs: Array = data["owned_backgrounds"]
		for bg in backgrounds:
			if bg["id"] in owned_bgs:
				bg["owned"] = true
	if data.has("sound_enabled"): SoundManager.sound_enabled = bool(data["sound_enabled"])
	if data.has("music_enabled"): SoundManager.music_enabled = bool(data["music_enabled"])
	if data.has("music_volume"): SoundManager.music_volume = float(data["music_volume"])
	if data.has("sfx_volume"): SoundManager.sfx_volume = float(data["sfx_volume"])
	if data.has("wheel_spins_available"): wheel_spins_available = int(data["wheel_spins_available"])
	if data.has("wheel_next_reset_time"): wheel_next_reset_time = int(data["wheel_next_reset_time"])
	if data.has("wheel_daily_allowance"): wheel_daily_allowance = int(data["wheel_daily_allowance"])
	if data.has("wheel_initialized"): wheel_initialized = bool(data["wheel_initialized"])
	check_wheel_daily_refresh()
