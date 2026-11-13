
class_name GameEngine
extends RefCounted

const WORLD: float = 3600.0
const GAP: float = 9.0
const FOOD_TARGET: int = 560
const BASE_SPEED: float = 175.0
const TURN: float = 4.2

const ORB_COLORS: Array[Color] = [
	Color("#ff4fd8"), Color("#4fc3ff"), Color("#ffd23f"), Color("#7dff5a"),
	Color("#b06bff"), Color("#ff6a4f"), Color("#5effe9")
]

const KINDS: Array[Dictionary] = [
	# Ambient energy orbs (dropped by boosting worms / deaths)
	{ "kind": "orb", "w": 40, "value": 2.0, "r": 7.0 },
	
	# 8 3D Fruits
	{ "kind": "apple", "w": 6, "value": 10.0, "r": 16.0 },
	{ "kind": "strawberry", "w": 6, "value": 12.0, "r": 15.0 },
	{ "kind": "orange", "w": 5, "value": 12.0, "r": 16.0 },
	{ "kind": "banana", "w": 5, "value": 14.0, "r": 16.0 },
	{ "kind": "grapes", "w": 5, "value": 15.0, "r": 15.0 },
	{ "kind": "watermelon", "w": 5, "value": 18.0, "r": 18.0 },
	{ "kind": "blueberry", "w": 6, "value": 8.0, "r": 12.0 },
	{ "kind": "cherry", "w": 6, "value": 10.0, "r": 14.0 },
	{ "kind": "broccoli", "w": 5, "value": 15.0, "r": 16.0 },
	
	# 3D Snacks & Delicacies (matching reference image)
	{ "kind": "cheese", "w": 5, "value": 24.0, "r": 17.0 },
	{ "kind": "cake", "w": 5, "value": 28.0, "r": 17.0 },
	{ "kind": "burger", "w": 4, "value": 22.0, "r": 18.0 },
	{ "kind": "pizza", "w": 4, "value": 20.0, "r": 18.0 },
	{ "kind": "donut", "w": 5, "value": 16.0, "r": 16.0 },
	{ "kind": "cupcake", "w": 4, "value": 18.0, "r": 16.0 },
	{ "kind": "candy", "w": 6, "value": 12.0, "r": 14.0 },
	{ "kind": "chocolate", "w": 4, "value": 18.0, "r": 16.0 },
	{ "kind": "cookie", "w": 5, "value": 15.0, "r": 16.0 },
	{ "kind": "sandwich", "w": 4, "value": 20.0, "r": 18.0 },
	
	# Treasures & In-field Power-ups (matching reference image)
	{ "kind": "diamond", "w": 3, "value": 65.0, "r": 18.0 },
	{ "kind": "crown", "w": 2, "value": 80.0, "r": 18.0 },
	{ "kind": "magnet", "w": 2, "value": 30.0, "r": 20.0 },
	{ "kind": "speed", "w": 2, "value": 30.0, "r": 20.0 },
	{ "kind": "speed_ring", "w": 2, "value": 35.0, "r": 20.0 },
	{ "kind": "lightning_orb", "w": 2, "value": 40.0, "r": 20.0 },
	{ "kind": "golden_apple", "w": 2, "value": 50.0, "r": 18.0 },
	{ "kind": "rainbow_food", "w": 2, "value": 45.0, "r": 18.0 },
	{ "kind": "mystery_box", "w": 2, "value": 40.0, "r": 18.0 },
	
	# Currency
	{ "kind": "coin", "w": 8, "value": 5.0, "r": 15.0 }
]

var total_w: int = 111

var worms: Array = []
var player: Dictionary
var food: Array[Dictionary] = []
var decor: Array[Dictionary] = []
var particles: Array[Dictionary] = []
var popups: Array[Dictionary] = []

var time: float = 6.0
var coins: int = 5078
var coins_earned: int = 0
var kills: int = 0
var xp: int = 108
var level: int = 1
var over: bool = false
var shake: float = 0.0
var _next_food_id: int = 1

var effects: Dictionary = {
	"speed": 0.0, "magnet": 0.0, "shield": 0.0, "double": 0.0,
	"potion": 0.0, "ghost": 0.0, "rocket": 0.0, "special": 0.0,
	"xp": 0.0, "attract": 0.0, "energy": 0.0
}
var cooldowns: Dictionary = {
	"speed": 0.0, "magnet": 0.0, "shield": 0.0, "double": 0.0,
	"potion": 0.0, "ghost": 0.0, "rocket": 0.0, "special": 0.0,
	"xp": 0.0, "attract": 0.0, "energy": 0.0
}
var counts: Dictionary = {
	"speed": 3, "magnet": 3, "shield": 3, "double": 2,
	"potion": 2, "ghost": 2, "rocket": 2, "special": 1,
	"xp": 2, "attract": 2, "energy": 2
}

var input_dir: Vector2 = Vector2.ZERO
var input_boost: bool = false

var mode: String = "quick"
var duration_limit: float = 300.0 # 5 min default

static func worm_len(score: float) -> int:
	return int(clamp(14.0 + floor(score / 25.0), 14.0, 240.0))

static func worm_radius(score: float) -> float:
	return 13.0 + min(13.0, score / 220.0)

func init_game(p_mode: String = "quick", p_duration_minutes: int = 5) -> void:
	mode = p_mode
	duration_limit = float(p_duration_minutes * 60)
	
	total_w = 0
	for k in KINDS:
		total_w += int(k["w"])
	
	var c: float = WORLD / 2.0
	var eq_skin = GameManager.get_equipped_skin()
	player = _make_worm(0, GameManager.username, eq_skin["color"], eq_skin["color2"], Vector2(c, c + 35.0), PI / 2.0, 187.0, true)
	
	var ai = [
		_make_worm(1, "Shadow", Color("#1e293b"), Color("#0ea5e9"), Vector2(c + 850, c + 320), -1.2, 1296.0),
		_make_worm(2, "Speedy", Color("#8dff5a"), Color("#2fbf3a"), Vector2(c - 780, c - 450), 2.6, 1100.0),
		_make_worm(3, "Blaze", Color("#ffb340"), Color("#ff6a1f"), Vector2(c - 950, c + 700), 0.4, 882.0),
		_make_worm(4, "Nova", Color("#ff7ad9"), Color("#b03bff"), Vector2(c + 920, c - 850), 3.6, 339.0),
		_make_worm(5, "Ziggy", Color("#ffe14f"), Color("#e0a600"), Vector2(c - 750, c - 800), 1.0, 140.0),
		_make_worm(6, "Rex", Color("#ff5f6d"), Color("#c4183a"), Vector2(c + 1100, c + 900), 4.0, 120.0)
	]
	
	worms.clear()
	worms.append(player)
	for b in ai:
		worms.append(b)
	
	food.clear()
	decor.clear()
	particles.clear()
	popups.clear()
	
	for i in range(FOOD_TARGET):
		_spawn_food()
	
	var decor_kinds = ["plant", "plant", "rock", "flower"]
	for i in range(260):
		# Spawn perimeter foliage and rocks along the outer boundary borders
		var dpos := Vector2.ZERO
		var side := randi() % 4
		match side:
			0: dpos = Vector2(randf_range(20.0, WORLD - 20.0), randf_range(20.0, 240.0))
			1: dpos = Vector2(randf_range(20.0, WORLD - 20.0), randf_range(WORLD - 240.0, WORLD - 20.0))
			2: dpos = Vector2(randf_range(20.0, 240.0), randf_range(20.0, WORLD - 20.0))
			3: dpos = Vector2(randf_range(WORLD - 240.0, WORLD - 20.0), randf_range(20.0, WORLD - 20.0))
		decor.append({
			"pos": dpos,
			"kind": decor_kinds[randi() % decor_kinds.size()],
			"scale": randf_range(0.8, 1.4),
			"rot": randf_range(0.0, TAU)
		})
	
	# Initial showcase layout matching concept design around the starting center
	var showcase_items = [
		{"kind": "apple", "off": Vector2(-180, -180)},
		{"kind": "apple", "off": Vector2(-170, 40)},
		{"kind": "magnet", "off": Vector2(300, -140)},
		{"kind": "crown", "off": Vector2(70, -80)},
		{"kind": "crown", "off": Vector2(300, -220)},
		{"kind": "speed", "off": Vector2(-250, -70)},
		{"kind": "lightning_orb", "off": Vector2(-290, 60)},
		{"kind": "diamond", "off": Vector2(-70, 150)},
		{"kind": "banana", "off": Vector2(-140, 180)},
		{"kind": "cheese", "off": Vector2(280, -240)},
		{"kind": "cheese", "off": Vector2(-260, 260)},
		{"kind": "cake", "off": Vector2(240, 40)},
		{"kind": "speed_ring", "off": Vector2(330, 90)},
		{"kind": "strawberry", "off": Vector2(270, 180)},
		{"kind": "coin", "off": Vector2(210, 210)},
		{"kind": "broccoli", "off": Vector2(240, -140)},
		{"kind": "broccoli", "off": Vector2(310, 280)},
		{"kind": "broccoli", "off": Vector2(-30, 140)}
	]
	for item in showcase_items:
		_spawn_food(Vector2(c, c) + item["off"], item["kind"])
	
	# Scattered energy pearls around the spawn area
	var pearl_offsets = [
		Vector2(-200, -260), Vector2(-120, -110), Vector2(120, -200), Vector2(220, -180),
		Vector2(-280, 0), Vector2(-150, 20), Vector2(160, -40), Vector2(200, 110),
		Vector2(-200, 120), Vector2(-60, -40), Vector2(40, 90), Vector2(170, 230),
		Vector2(-10, 250), Vector2(-140, 280), Vector2(280, 240), Vector2(340, 190)
	]
	for p_off in pearl_offsets:
		_spawn_food(Vector2(c, c) + p_off, "pearl")

func _make_worm(id: int, name: String, col: Color, col2: Color, pos: Vector2, angle: float, score: float, is_p: bool = false) -> Dictionary:
	var segs: Array[Vector2] = []
	var count := worm_len(score)
	for i in range(count):
		var wave: float = sin(float(i) * 0.28) * 8.0 if is_p else 0.0
		segs.append(Vector2(pos.x - cos(angle) * GAP * float(i) + wave, pos.y - sin(angle) * GAP * float(i)))
	return {
		"id": id,
		"name": name,
		"color": col,
		"color2": col2,
		"segs": segs,
		"angle": angle,
		"target": angle,
		"score": score,
		"alive": true,
		"isPlayer": is_p,
		"boosting": false,
		"kills": 0,
		"respawn": 0.0,
		"aiTimer": 0.0,
		"dropTimer": 0.0
	}

func _spawn_food(pos: Vector2 = Vector2(-1, -1), forced_kind: String = "") -> void:
	var f_pos: Vector2 = pos
	if f_pos.x < 0:
		var c := WORLD * 0.5
		for attempt in range(10):
			f_pos = Vector2(randf_range(60.0, WORLD - 60.0), randf_range(60.0, WORLD - 60.0))
			if abs(f_pos.x - c) > 440.0 or abs(f_pos.y - c) > 340.0:
				break
	
	var k_data: Dictionary = KINDS[0]
	if forced_kind != "":
		for q in KINDS:
			if q["kind"] == forced_kind:
				k_data = q
				break
	else:
		var roll := randf() * float(total_w)
		for q in KINDS:
			roll -= float(q["w"])
			if roll <= 0:
				k_data = q
				break
	
	_next_food_id += 1
	food.append({
		"id": _next_food_id,
		"pos": f_pos,
		"kind": k_data["kind"],
		"r": float(k_data["r"]),
		"value": float(k_data["value"]),
		"color": ORB_COLORS[randi() % ORB_COLORS.size()],
		"phase": randf_range(0.0, TAU)
	})

func use_power(id: String) -> bool:
	if over or counts.get(id, 0) <= 0 or cooldowns.get(id, 0.0) > 0.0 or effects.get(id, 0.0) > 0.0:
		return false
	
	counts[id] -= 1
	var dur: float = 6.0
	var cd: float = 12.0
	match id:
		"speed": dur = 6.0; cd = 12.0
		"magnet": dur = 8.0; cd = 12.0
		"shield": dur = 6.0; cd = 15.0
		"double": dur = 10.0; cd = 18.0
		"potion":
			dur = 8.0; cd = 16.0
			player["score"] += 80.0
			xp += 150
		"ghost": dur = 5.0; cd = 18.0
		"rocket": dur = 4.0; cd = 15.0
		"special":
			dur = 7.0; cd = 22.0
			effects["shield"] = 7.0
			effects["magnet"] = 7.0
			effects["double"] = 7.0
		"xp": dur = 15.0; cd = 20.0
		"attract": dur = 6.0; cd = 16.0
		"energy": dur = 5.0; cd = 14.0
	
	effects[id] = dur
	cooldowns[id] = cd
	
	var h: Vector2 = player["segs"][0]
	popups.append({
		"pos": Vector2(h.x, h.y - 40.0),
		"text": id.to_upper() + "!",
		"life": 1.2,
		"color": Color("#5effe9")
	})
	_burst(h, Color("#5effe9"), 24)
	return true

func _burst(pos: Vector2, col: Color, n: int) -> void:
	for i in range(n):
		if particles.size() >= 500:
			break
		var a: float = randf_range(0.0, TAU)
		var s: float = randf_range(60.0, 260.0)
		var life: float = randf_range(0.35, 0.8)
		particles.append({
			"pos": pos,
			"vel": Vector2(cos(a) * s, sin(a) * s),
			"life": life,
			"max": life,
			"color": col,
			"size": randf_range(2.0, 5.0)
		})

func _kill_worm(w: Dictionary, killer: Dictionary = {}) -> void:
	w["alive"] = false
	var segs: Array = w["segs"]
	for i in range(0, segs.size(), 2):
		var s: Vector2 = segs[i]
		_next_food_id += 1
		food.append({
			"id": _next_food_id,
			"pos": Vector2(s.x + randf_range(-8.0, 8.0), s.y + randf_range(-8.0, 8.0)),
			"kind": "orb",
			"r": 9.0,
			"value": 4.0,
			"color": w["color"],
			"phase": randf_range(0.0, TAU)
		})
	
	var h: Vector2 = segs[0]
	_burst(h, w["color"], 40)
	
	if not killer.is_empty():
		killer["kills"] += 1
		if killer.get("isPlayer", false):
			kills += 1
			coins += 10
			coins_earned += 10
			popups.append({
				"pos": Vector2(h.x, h.y - 30.0),
				"text": "KILL! +10",
				"life": 1.4,
				"color": Color("#ffd23f")
			})
	
	if w.get("isPlayer", false):
		over = true
		shake = 0.5
	else:
		w["respawn"] = 4.0

func _respawn_ai(w: Dictionary) -> void:
	var ph: Vector2 = player["segs"][0]
	var pos := Vector2.ZERO
	while true:
		pos = Vector2(randf_range(300.0, WORLD - 300.0), randf_range(300.0, WORLD - 300.0))
		if pos.distance_to(ph) >= 800.0:
			break
	var nw = _make_worm(w["id"], w["name"], w["color"], w["color2"], pos, randf_range(0.0, TAU), randf_range(120.0, 420.0))
	nw["kills"] = w["kills"]
	for k in nw.keys():
		w[k] = nw[k]

func _think_ai(w: Dictionary, dt: float) -> void:
	w["aiTimer"] -= dt
	if w["aiTimer"] > 0:
		return
	w["aiTimer"] = randf_range(0.18, 0.45)
	
	var h: Vector2 = w["segs"][0]
	var m: float = 260.0
	var c := Vector2(WORLD / 2.0, WORLD / 2.0)
	if h.x < m or h.y < m or h.x > WORLD - m or h.y > WORLD - m:
		w["target"] = (c - h).angle()
		w["boosting"] = false
		return
	
	var lx: float = h.x + cos(w["angle"]) * 90.0
	var ly: float = h.y + sin(w["angle"]) * 90.0
	var l_pos := Vector2(lx, ly)
	
	for o in worms:
		if o == w or not o["alive"]:
			continue
		var o_segs: Array = o["segs"]
		var oh: Vector2 = o_segs[0]
		if abs(oh.x - h.x) > float(o_segs.size()) * GAP + 200.0 and abs(oh.y - h.y) > float(o_segs.size()) * GAP + 200.0:
			continue
		for i in range(0, o_segs.size(), 2):
			var s: Vector2 = o_segs[i]
			if s.distance_to(l_pos) < 48.0:
				w["target"] = w["angle"] + (1.7 if randf() < 0.5 else -1.7)
				w["boosting"] = false
				return
	
	var best_f: Dictionary = {}
	var bd: float = 480.0
	for f in food:
		var f_pos: Vector2 = f["pos"]
		var dx: float = f_pos.x - h.x
		var dy: float = f_pos.y - h.y
		if abs(dx) > bd or abs(dy) > bd:
			continue
		var dist: float = Vector2(dx, dy).length() / (2.0 if float(f["value"]) > 2.0 else 1.0)
		if dist < bd:
			bd = dist
			best_f = f
	
	if not best_f.is_empty():
		w["target"] = (best_f["pos"] - h).angle()
	else:
		w["target"] = w["angle"] + randf_range(-0.8, 0.8)
	
	w["boosting"] = (float(w["score"]) > 150.0 and randf() < 0.06)

func _move_worm(w: Dictionary, dist: float) -> void:
	var s: Array = w["segs"]
	var h: Vector2 = s[0]
	h.x += cos(w["angle"]) * dist
	h.y += sin(w["angle"]) * dist
	s[0] = h
	
	for i in range(1, s.size()):
		var p: Vector2 = s[i - 1]
		var q: Vector2 = s[i]
		var diff: Vector2 = q - p
		var d: float = diff.length()
		if d > GAP:
			s[i] = p + (diff / d) * GAP
	
	var req_len := worm_len(w["score"])
	while s.size() < req_len:
		s.append(s[s.size() - 1])
	while s.size() > req_len:
		s.pop_back()

func step(dt: float) -> void:
	time += dt
	shake = max(0.0, shake - dt)
	
	if mode == "quick" and time >= duration_limit:
		over = true
	
	for k in effects.keys():
		effects[k] = max(0.0, effects[k] - dt)
		cooldowns[k] = max(0.0, cooldowns[k] - dt)
	
	if input_dir != Vector2.ZERO:
		player["target"] = input_dir.angle()
	
	player["boosting"] = input_boost and float(player["score"]) > 30.0
	
	for w in worms:
		if not w["alive"]:
			if not w.get("isPlayer", false):
				w["respawn"] -= dt
				if w["respawn"] <= 0.0:
					_respawn_ai(w)
			continue
		
		if not w.get("isPlayer", false):
			_think_ai(w, dt)
		
		var free_boost: bool = w.get("isPlayer", false) and effects["energy"] > 0.0
		if free_boost:
			w["boosting"] = true
		if w["boosting"] and float(w["score"]) <= 30.0 and not free_boost:
			w["boosting"] = false
		
		# Turn angle smoothly towards target
		var diff_ang: float = wrapf(w["target"] - w["angle"], -PI, PI)
		w["angle"] += clamp(diff_ang, -TURN * dt, TURN * dt)
		
		var speed: float = BASE_SPEED * (1.9 if w["boosting"] else 1.0)
		if w.get("isPlayer", false):
			if effects["speed"] > 0.0:
				speed *= 1.4
			if effects["rocket"] > 0.0:
				speed *= 2.0
			if effects["special"] > 0.0:
				speed *= 1.35
		
		_move_worm(w, speed * dt)
		
		if w["boosting"]:
			if not free_boost:
				w["score"] -= 22.0 * dt
			w["dropTimer"] -= dt
			var s: Array = w["segs"]
			var t_pos: Vector2 = s[s.size() - 1]
			if w["dropTimer"] <= 0.0:
				w["dropTimer"] = 0.18
				_next_food_id += 1
				food.append({
					"id": _next_food_id,
					"pos": t_pos,
					"kind": "orb",
					"r": 6.0,
					"value": 1.0,
					"color": w["color"],
					"phase": 0.0
				})
			if w.get("isPlayer", false) and particles.size() < 500:
				var life := randf_range(0.3, 0.6)
				particles.append({
					"pos": t_pos,
					"vel": Vector2(randf_range(-40.0, 40.0), randf_range(-40.0, 40.0)),
					"life": life,
					"max": life,
					"color": Color("#ffb340"),
					"size": randf_range(2.0, 4.0)
				})
	
	# Eating & Magnet
	var pull: float = 460.0 if effects["attract"] > 0.0 else (280.0 if effects["magnet"] > 0.0 else 0.0)
	var has_magnet: bool = pull > 0.0
	var mult: float = 2.0 if effects["double"] > 0.0 else 1.0
	var xp_mult: int = 2 if effects["xp"] > 0.0 else 1
	
	for w in worms:
		if not w["alive"]:
			continue
		var h: Vector2 = w["segs"][0]
		var wr: float = worm_radius(w["score"])
		var reach: float = pull if (w.get("isPlayer", false) and has_magnet) else 60.0
		
		for i in range(food.size() - 1, -1, -1):
			var f: Dictionary = food[i]
			var f_pos: Vector2 = f["pos"]
			var diff := f_pos - h
			if abs(diff.x) > reach or abs(diff.y) > reach:
				continue
			var d := diff.length()
			if w.get("isPlayer", false) and has_magnet and d < pull and d > 1.0:
				f_pos -= (diff / d) * 480.0 * dt
				f["pos"] = f_pos
				diff = f_pos - h
				d = diff.length()
			
			if d < wr + float(f["r"]):
				food.remove_at(i)
				if w.get("isPlayer", false):
					var v: float = float(f["value"]) * mult
					w["score"] += v
					if f["kind"] == "coin":
						coins += 5
						coins_earned += 5
					elif f["kind"] == "diamond":
						coins += 2
						coins_earned += 2
					elif f["kind"] == "crown":
						coins += 5
						coins_earned += 5
					elif f["kind"] == "magnet":
						effects["magnet"] = 8.0
					elif f["kind"] == "speed" or f["kind"] == "speed_ring":
						effects["speed"] = 8.0
					elif f["kind"] == "lightning_orb":
						effects["special"] = 7.0
					if float(f["value"]) >= 5.0:
						popups.append({
							"pos": Vector2(f_pos.x, f_pos.y - 20.0),
							"text": "+5 🪙" if f["kind"] == "coin" else "+%d" % int(v),
							"life": 1.0,
							"color": Color("#ffd23f") if f["kind"] == "coin" else Color.WHITE
						})
						_burst(f_pos, Color("#ffd23f") if f["kind"] == "coin" else (Color("#7dff5a") if f["kind"] == "special" else Color("#ff6ad5")), 14)
					else:
						_burst(f_pos, f["color"], 4)
					
					xp += xp_mult
					if xp >= 500:
						xp = 0
						level += 1
						popups.append({
							"pos": Vector2(h.x, h.y - 60.0),
							"text": "LEVEL UP!",
							"life": 1.6,
							"color": Color("#7dff5a")
						})
				else:
					w["score"] += float(f["value"])
	
	# Collisions
	var has_shield: bool = effects["shield"] > 0.0
	var has_ghost: bool = effects["ghost"] > 0.0
	
	for a in worms:
		if not a["alive"]:
			continue
		var h: Vector2 = a["segs"][0]
		var ar: float = worm_radius(a["score"])
		if h.x < 0 or h.y < 0 or h.x > WORLD or h.y > WORLD:
			if a.get("isPlayer", false) and has_shield:
				h.x = clamp(h.x, 1.0, WORLD - 1.0)
				h.y = clamp(h.y, 1.0, WORLD - 1.0)
				a["segs"][0] = h
				a["angle"] += PI
				a["target"] = a["angle"]
			else:
				_kill_worm(a)
				continue
		
		if a.get("isPlayer", false) and (has_shield or has_ghost):
			continue
		
		var died: bool = false
		for b in worms:
			if b == a or not b["alive"]:
				continue
			var b_segs: Array = b["segs"]
			var bh: Vector2 = b_segs[0]
			var span: float = float(b_segs.size()) * GAP + 60.0
			if abs(bh.x - h.x) > span or abs(bh.y - h.y) > span:
				continue
			var br: float = worm_radius(b["score"]) * 0.85
			for i in range(1, b_segs.size()):
				var s: Vector2 = b_segs[i]
				if abs(s.x - h.x) < ar + br and h.distance_to(s) < ar * 0.7 + br:
					if b.get("isPlayer", false) and (has_shield or has_ghost):
						continue
					_kill_worm(a, b)
					died = true
					break
			if died:
				break
	
	while food.size() < FOOD_TARGET:
		_spawn_food()
	
	for i in range(particles.size() - 1, -1, -1):
		var p: Dictionary = particles[i]
		p["life"] -= dt
		p["pos"] += p["vel"] * dt
		p["vel"] *= 0.92
		if p["life"] <= 0.0:
			particles.remove_at(i)
	
	for i in range(popups.size() - 1, -1, -1):
		var p: Dictionary = popups[i]
		p["life"] -= dt
		var pos: Vector2 = p["pos"]
		pos.y -= 45.0 * dt
		p["pos"] = pos
		if p["life"] <= 0.0:
			popups.remove_at(i)

func get_hud_data() -> Dictionary:
	var ranked: Array = worms.duplicate()
	ranked.sort_custom(func(a, b): return float(a["score"]) > float(b["score"]))
	
	var board: Array[Dictionary] = []
	for i in range(min(5, ranked.size())):
		var w: Dictionary = ranked[i]
		board.append({
			"name": "You" if w.get("isPlayer", false) else w["name"],
			"score": int(w["score"]),
			"me": w.get("isPlayer", false),
			"rank": i + 1
		})
	
	var player_in_top_5: bool = false
	for r in board:
		if r["me"]:
			player_in_top_5 = true
			break
	if not player_in_top_5 and board.size() >= 5:
		for i in range(ranked.size()):
			if ranked[i].get("isPlayer", false):
				board[4] = {
					"name": "You",
					"score": int(ranked[i]["score"]),
					"me": true,
					"rank": i + 1
				}
				break
	
	return {
		"time": time,
		"kills": kills,
		"coins": coins,
		"coins_earned": coins_earned,
		"score": int(player["score"]),
		"length": player["segs"].size(),
		"xp": xp,
		"level": level,
		"boosting": player["boosting"],
		"board": board,
		"effects": effects.duplicate(),
		"cooldowns": cooldowns.duplicate(),
		"counts": counts.duplicate(),
		"over": over
	}

