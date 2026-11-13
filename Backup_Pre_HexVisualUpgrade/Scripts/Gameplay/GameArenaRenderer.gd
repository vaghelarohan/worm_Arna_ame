extends Control

var engine
var font_lilita: FontFile = preload("res://Assets/Fonts/LilitaOne-Regular.ttf")

var food_textures: Dictionary = {
	"apple": preload("res://Assets/Food/apple.svg"),
	"strawberry": preload("res://Assets/Food/strawberry.svg"),
	"blueberry": preload("res://Assets/Food/blueberry.svg"),
	"banana": preload("res://Assets/Food/banana.svg"),
	"mushroom": preload("res://Assets/Food/mushroom.svg"),
	"orange": preload("res://Assets/Food/orange.svg"),
	"candy": preload("res://Assets/Food/candy.svg"),
	"special": preload("res://Assets/Food/special.svg"),
	"coin": preload("res://Assets/Icons/coin.svg"),
	"plant": preload("res://Assets/Food/plant.svg"),
	"rock": preload("res://Assets/Food/rock.svg"),
	"flower": preload("res://Assets/Food/flower.svg")
}

var _time: float = 0.0

func _process(delta: float) -> void:
	_time += delta
	queue_redraw()

func _draw() -> void:
	if not engine:
		return
	
	var vw: float = size.x
	var vh: float = size.y
	
	var ph: Vector2 = engine.player["segs"][0]
	var shake_off: Vector2 = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * 18.0 * engine.shake if engine.shake > 0.0 else Vector2.ZERO
	var cam: Vector2 = ph - Vector2(vw / 2.0, vh / 2.0) + shake_off
	
	# 1. Background Fill
	draw_rect(Rect2(0, 0, vw, vh), Color("#151a48"))
	
	# 2. Hexagonal Grid / Subtle grid lines
	var grid_sz: float = 64.0
	var start_x: float = fmod(-cam.x, grid_sz)
	var start_y: float = fmod(-cam.y, grid_sz)
	if start_x > 0: start_x -= grid_sz
	if start_y > 0: start_y -= grid_sz
	
	var x: float = start_x
	while x < vw + grid_sz:
		draw_line(Vector2(x, 0), Vector2(x, vh), Color(0.18, 0.22, 0.55, 0.25), 1.5)
		x += grid_sz
	
	var y: float = start_y
	while y < vh + grid_sz:
		draw_line(Vector2(0, y), Vector2(vw, y), Color(0.18, 0.22, 0.55, 0.25), 1.5)
		y += grid_sz
	
	# 3. World Border & Outside Darkness
	var w_rect := Rect2(-cam.x, -cam.y, GameEngine.WORLD, GameEngine.WORLD)
	draw_rect(w_rect, Color(1, 0.24, 0.94, 1.0), false, 6.0)
	
	# 4. Decor items
	for d in engine.decor:
		var d_pos: Vector2 = d["pos"] - cam
		if d_pos.x > -60.0 and d_pos.y > -60.0 and d_pos.x < vw + 60.0 and d_pos.y < vh + 60.0:
			var tex: Texture2D = food_textures.get(d["kind"], null)
			if tex:
				var s: float = 70.0 * float(d["scale"])
				draw_set_transform(d_pos, float(d["rot"]), Vector2.ONE)
				draw_texture_rect(tex, Rect2(-s / 2.0, -s / 2.0, s, s), false)
				draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	
	# 5. Food & Collectibles
	for f in engine.food:
		var f_pos: Vector2 = f["pos"] - cam
		if f_pos.x > -40.0 and f_pos.y > -40.0 and f_pos.x < vw + 40.0 and f_pos.y < vh + 40.0:
			var r: float = float(f["r"])
			var pulse: float = 1.0 + sin(_time * 3.0 + float(f["phase"])) * 0.12
			var kind: String = f["kind"]
			
			if kind == "orb":
				var orb_r: float = r * 2.2 * pulse
				draw_circle(f_pos, orb_r * 1.4, Color(f["color"].r, f["color"].g, f["color"].b, 0.25))
				draw_circle(f_pos, orb_r, f["color"])
				draw_circle(f_pos, orb_r * 0.45, Color.WHITE)
			else:
				var tex: Texture2D = food_textures.get(kind, null)
				if tex:
					var bob: float = sin(_time * 2.4 + float(f["phase"])) * 4.0
					var sz: float = r * 3.1
					# shadow
					draw_circle(Vector2(f_pos.x, f_pos.y + r * 0.8), r * 0.7, Color(0, 0, 0, 0.3))
					draw_texture_rect(tex, Rect2(f_pos.x - sz / 2.0, f_pos.y - sz / 2.0 + bob, sz, sz), false)
	
	# 6. Particles
	for p in engine.particles:
		var p_pos: Vector2 = p["pos"] - cam
		var alpha: float = clamp(float(p["life"]) / float(p["max"]), 0.0, 1.0)
		var col: Color = p["color"]
		col.a = alpha
		draw_circle(p_pos, float(p["size"]), col)
	
	# 7. AI Worms
	for w in engine.worms:
		if w["alive"] and not w.get("isPlayer", false):
			_draw_worm(w, cam, vw, vh, false)
	
	# 8. Player Worm
	if engine.player["alive"]:
		var has_shield: bool = engine.effects["shield"] > 0.0
		_draw_worm(engine.player, cam, vw, vh, has_shield)
	
	# 9. Popups
	for p in engine.popups:
		var pos: Vector2 = p["pos"] - cam
		var alpha: float = clamp(float(p["life"]) * 2.0, 0.0, 1.0)
		var col: Color = p["color"]
		col.a = alpha
		var text: String = p["text"]
		draw_string_outline(font_lilita, pos, text, HORIZONTAL_ALIGNMENT_CENTER, -1, 32, 6, Color(0.04, 0.02, 0.15, alpha))
		draw_string(font_lilita, pos, text, HORIZONTAL_ALIGNMENT_CENTER, -1, 32, col)
	
	# 10. Vignette overlay around screen
	draw_rect(Rect2(0, 0, vw, vh), Color(0.04, 0.02, 0.12, 0.25), false, 40.0)

func _draw_worm(w: Dictionary, cam: Vector2, vw: float, vh: float, shield: bool) -> void:
	var segs: Array = w["segs"]
	var n: int = segs.size()
	if n == 0:
		return
	
	var h: Vector2 = segs[0]
	var hx: float = h.x - cam.x
	var hy: float = h.y - cam.y
	if hx < -n * 10 - 100 or hy < -n * 10 - 100 or hx > vw + n * 10 + 100 or hy > vh + n * 10 + 100:
		return
	
	var r: float = GameEngine.worm_radius(w["score"])
	var col_a: Color = w["color"]
	var col_b: Color = w["color2"]
	
	# Glowing aura under player/boosting worm
	if w.get("isPlayer", false) or w["boosting"]:
		var glow_col: Color = Color("#ffb340") if w["boosting"] else col_a
		glow_col.a = 0.28 if w["boosting"] else 0.14
		for i in range(2, n, 2):
			var pos: Vector2 = segs[i] - cam
			draw_circle(pos, r * 1.8, glow_col)
	
	# Shadow under body
	for i in range(n - 1, 0, -2):
		var p: Vector2 = segs[i] - cam
		draw_circle(Vector2(p.x + 6, p.y + 10), r * 0.9, Color(0, 0, 0.08, 0.25))
	
	# Body segments with alternating beads and tail tapering
	for i in range(n - 1, 0, -1):
		var p: Vector2 = segs[i] - cam
		if p.x < -40 or p.y < -40 or p.x > vw + 40 or p.y > vh + 40:
			continue
		var taper: float = 1.0
		if i > n * 0.65:
			taper = 1.0 - ((float(i) - float(n) * 0.65) / (float(n) * 0.35)) * 0.5
		var rr: float = r * taper * 1.08
		var seg_col: Color = col_b if (int(i / 3) % 2 == 1) else col_a
		
		# Draw glossy circle
		draw_circle(p, rr, seg_col)
		draw_circle(Vector2(p.x - rr * 0.28, p.y - rr * 0.28), rr * 0.38, Color(1, 1, 1, 0.38))
		draw_arc(p, rr, 0, TAU, 16, Color(0.04, 0.04, 0.15, 0.35), 2.0)
	
	# Head
	var hr: float = r * 1.22
	var head_pos := Vector2(hx, hy)
	draw_circle(head_pos, hr, col_a)
	draw_circle(Vector2(hx - hr * 0.28, hy - hr * 0.28), hr * 0.38, Color(1, 1, 1, 0.45))
	draw_arc(head_pos, hr, 0, TAU, 24, Color(0.04, 0.04, 0.15, 0.4), 2.5)
	
	# Eyes
	var ang: float = float(w["angle"])
	var ex := Vector2(cos(ang), sin(ang))
	var px := Vector2(-sin(ang), cos(ang))
	
	for side in [-1.0, 1.0]:
		var eye_center: Vector2 = head_pos + ex * (hr * 0.3) + px * (side * hr * 0.45)
		draw_circle(eye_center, hr * 0.36, Color.WHITE)
		draw_arc(eye_center, hr * 0.36, 0, TAU, 16, Color(0.04, 0.04, 0.15, 0.5), 1.5)
		# Pupil looking forward
		var pupil_pos: Vector2 = eye_center + ex * (hr * 0.13)
		draw_circle(pupil_pos, hr * 0.2, Color("#0b0b2a"))
		# Highlight reflection
		draw_circle(pupil_pos + ex * (hr * 0.06) + px * (-side * hr * 0.06), hr * 0.07, Color.WHITE)
	
	# Smile mouth
	var mouth_pos: Vector2 = head_pos + ex * (hr * 0.55)
	var mouth_left: Vector2 = mouth_pos + px * (hr * 0.25)
	var mouth_right: Vector2 = mouth_pos - px * (hr * 0.25)
	draw_line(mouth_left, mouth_right, Color("#7a1030"), 2.5)
	
	# Shield bubble
	if shield:
		var shield_a: float = 0.6 + sin(_time * 8.0) * 0.25
		draw_arc(head_pos, hr * 1.9, 0, TAU, 32, Color(0.37, 1.0, 0.91, shield_a), 4.0)
	
	# Name tag for AI worms
	if not w.get("isPlayer", false):
		var name_pos := Vector2(hx, hy - hr - 14.0)
		var bot_name: String = w["name"]
		draw_string_outline(font_lilita, name_pos, bot_name, HORIZONTAL_ALIGNMENT_CENTER, -1, 18, 4, Color(0.02, 0.02, 0.12, 0.85))
		draw_string(font_lilita, name_pos, bot_name, HORIZONTAL_ALIGNMENT_CENTER, -1, 18, Color.WHITE)
