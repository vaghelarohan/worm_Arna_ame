class_name GameArenaRenderer
extends Control

var engine: GameEngine
var font_lilita: FontFile = preload("res://Assets/Fonts/LilitaOne-Regular.ttf")

# 2D Vector Textures for Food and Power-ups
var food_textures: Dictionary = {
	"apple": preload("res://Assets/Food/apple.svg"),
	"strawberry": preload("res://Assets/Food/strawberry.svg"),
	"blueberry": preload("res://Assets/Food/blueberry.svg"),
	"banana": preload("res://Assets/Food/banana.svg"),
	"grapes": preload("res://Assets/Food/grapes.svg"),
	"orange": preload("res://Assets/Food/orange.svg"),
	"cherry": preload("res://Assets/Food/cherry.svg"),
	"watermelon": preload("res://Assets/Food/watermelon.svg"),
	"mushroom": preload("res://Assets/Food/mushroom.svg"),
	"candy": preload("res://Assets/Food/candy.svg"),
	"donut": preload("res://Assets/Food/donut.svg"),
	"cookie": preload("res://Assets/Food/cookie.svg"),
	"cheese": preload("res://Assets/Food/cheese.svg"),
	"burger": preload("res://Assets/Food/burger.svg"),
	"cake": preload("res://Assets/Food/cake.svg"),
	"cupcake": preload("res://Assets/Food/candy.svg"),
	"sandwich": preload("res://Assets/Food/sandwich.svg"),
	"pizza": preload("res://Assets/Food/pizza.svg"),
	"chocolate": preload("res://Assets/Food/candy.svg"),
	"broccoli": preload("res://Assets/Food/plant.svg"),
	"diamond": preload("res://Assets/Food/diamond.svg"),
	"crown": preload("res://Assets/Food/crown.svg"),
	"coin": preload("res://Assets/Icons/coin.svg"),
	"special": preload("res://Assets/Icons/star.svg"),
	"golden_apple": preload("res://Assets/Food/apple.svg"),
	"rainbow_food": preload("res://Assets/Icons/star.svg"),
	"mystery_box": preload("res://Assets/Food/special.svg"),
	"magnet": preload("res://Assets/Icons/magnet.svg"),
	"speed": preload("res://Assets/Icons/zap.svg"),
	"speed_ring": preload("res://Assets/Icons/zap.svg"),
	"lightning_orb": preload("res://Assets/Icons/zap.svg"),
	"shield": preload("res://Assets/Icons/shield.svg"),
	"double": preload("res://Assets/Icons/double.svg"),
	"attract": preload("res://Assets/Icons/attract.svg"),
	"ghost": preload("res://Assets/Icons/ghost.svg"),
	"xp": preload("res://Assets/Icons/potion.svg"),
	"plant": preload("res://Assets/Food/plant.svg"),
	"rock": preload("res://Assets/Food/rock.svg"),
	"flower": preload("res://Assets/Food/flower.svg")
}

var _time: float = 0.0
var _blink_timer: float = 0.0
var _cam_pos: Vector2 = Vector2.ZERO

# Subtle floating ambient energy motes
var _ambient_motes: Array[Dictionary] = []

func _ready() -> void:
	# Initialize 45 ambient background motes
	for i in range(45):
		_ambient_motes.append({
			"pos": Vector2(randf_range(0, 1600), randf_range(0, 900)),
			"speed": Vector2(randf_range(-12.0, 12.0), randf_range(-18.0, -6.0)),
			"size": randf_range(2.0, 4.5),
			"alpha": randf_range(0.15, 0.40),
			"color": Color("#38bdf8") if i % 2 == 0 else Color("#facc15")
		})

func setup_decor(_decor_list: Array[Dictionary]) -> void:
	# Compatibility hook for PlayScreen.gd
	pass

func _process(delta: float) -> void:
	_time += delta
	_blink_timer += delta
	if _blink_timer > 3.8:
		if _blink_timer > 4.0:
			_blink_timer = 0.0
	
	# Update ambient motes
	for m in _ambient_motes:
		m["pos"] += m["speed"] * delta
		if m["pos"].y < -20.0:
			m["pos"].y = 920.0
			m["pos"].x = randf_range(0, 1600)
		elif m["pos"].x < -20.0:
			m["pos"].x = 1620.0
		elif m["pos"].x > 1620.0:
			m["pos"].x = -20.0
	
	queue_redraw()

func _get_theme_palette() -> Dictionary:
	var bg_id: String = GameManager.selected_background
	match bg_id:
		"candy_world":
			return {
				"bg": Color("#240e34"),
				"hex_fill": Color(0.24, 0.11, 0.34, 0.75),
				"hex_bevel": Color(0.48, 0.22, 0.58, 0.45),
				"hex_seam": Color(0.14, 0.06, 0.22, 0.85),
				"laser": Color(0.98, 0.45, 0.75, 0.95),
				"laser_glow": Color(0.95, 0.30, 0.70, 0.30),
				"motes": [Color("#f472b6"), Color("#38bdf8")]
			}
		"jungle":
			return {
				"bg": Color("#0a2214"),
				"hex_fill": Color(0.08, 0.24, 0.14, 0.75),
				"hex_bevel": Color(0.16, 0.42, 0.24, 0.45),
				"hex_seam": Color(0.04, 0.12, 0.07, 0.85),
				"laser": Color(0.15, 0.88, 0.45, 0.95),
				"laser_glow": Color(0.10, 0.80, 0.35, 0.25),
				"motes": [Color("#4ade80"), Color("#facc15")]
			}
		"space_galaxy":
			return {
				"bg": Color("#0e0725"),
				"hex_fill": Color(0.15, 0.09, 0.32, 0.75),
				"hex_bevel": Color(0.32, 0.20, 0.58, 0.45),
				"hex_seam": Color(0.08, 0.04, 0.18, 0.85),
				"laser": Color(0.72, 0.35, 0.98, 0.95),
				"laser_glow": Color(0.65, 0.25, 0.95, 0.28),
				"motes": [Color("#c084fc"), Color("#60a5fa")]
			}
		"lava_world":
			return {
				"bg": Color("#1a0909"),
				"hex_fill": Color(0.25, 0.09, 0.08, 0.75),
				"hex_bevel": Color(0.50, 0.20, 0.12, 0.45),
				"hex_seam": Color(0.12, 0.04, 0.03, 0.85),
				"laser": Color(1.0, 0.45, 0.10, 0.95),
				"laser_glow": Color(1.0, 0.35, 0.05, 0.30),
				"motes": [Color("#fb923c"), Color("#facc15")]
			}
		"ice_kingdom":
			return {
				"bg": Color("#082032"),
				"hex_fill": Color(0.09, 0.23, 0.36, 0.75),
				"hex_bevel": Color(0.20, 0.42, 0.60, 0.45),
				"hex_seam": Color(0.04, 0.12, 0.20, 0.85),
				"laser": Color(0.30, 0.85, 1.0, 0.95),
				"laser_glow": Color(0.25, 0.80, 1.0, 0.30),
				"motes": [Color("#7dd3fc"), Color("#ffffff")]
			}
		"sunset_beach":
			return {
				"bg": Color("#2b0e1e"),
				"hex_fill": Color(0.34, 0.15, 0.18, 0.75),
				"hex_bevel": Color(0.65, 0.28, 0.22, 0.48),
				"hex_seam": Color(0.16, 0.05, 0.09, 0.85),
				"laser": Color(1.0, 0.60, 0.20, 0.95),
				"laser_glow": Color(1.0, 0.40, 0.15, 0.30),
				"motes": [Color("#fb923c"), Color("#f43f5e")]
			}
		"magical_forest":
			return {
				"bg": Color("#051c19"),
				"hex_fill": Color(0.06, 0.22, 0.20, 0.75),
				"hex_bevel": Color(0.16, 0.46, 0.40, 0.48),
				"hex_seam": Color(0.02, 0.09, 0.08, 0.85),
				"laser": Color(0.20, 0.95, 0.70, 0.95),
				"laser_glow": Color(0.15, 0.85, 0.60, 0.30),
				"motes": [Color("#2dd4bf"), Color("#c084fc")]
			}
		_: # "neon_blue" default
			return {
				"bg": Color("#0b1736"),
				"hex_fill": Color(0.08, 0.17, 0.36, 0.72),
				"hex_bevel": Color(0.14, 0.28, 0.54, 0.42),
				"hex_seam": Color(0.04, 0.08, 0.18, 0.85),
				"laser": Color(0.0, 0.95, 1.0, 0.90),
				"laser_glow": Color(0.0, 0.90, 1.0, 0.25),
				"motes": [Color("#38bdf8"), Color("#facc15")]
			}

func _draw() -> void:
	if not engine or not engine.player:
		return
	
	var vw: float = size.x
	var vh: float = size.y
	if vw <= 0 or vh <= 0:
		vw = 1600.0
		vh = 900.0
	
	if engine.player["segs"].is_empty():
		return
	
	var ph: Vector2 = engine.player["segs"][0]
	var p_ang: float = float(engine.player["angle"])
	var p_dir := Vector2(cos(p_ang), sin(p_ang))
	
	# Smooth forward camera lead & screen shake
	var lead: Vector2 = p_dir * 55.0
	var shake_off: Vector2 = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * 16.0 * engine.shake if engine.shake > 0.0 else Vector2.ZERO
	var target_cam: Vector2 = ph + lead - Vector2(vw / 2.0, vh / 2.0) + shake_off
	
	if _time <= 0.05:
		_cam_pos = target_cam
	else:
		_cam_pos = _cam_pos.lerp(target_cam, clamp(get_process_delta_time() * 9.0, 0.0, 1.0))
	
	var cam := _cam_pos
	var palette: Dictionary = _get_theme_palette()
	
	# 1. Base Arena Background Fill (Theme Dependent)
	draw_rect(Rect2(0, 0, vw, vh), palette["bg"])
	
	# 2. Illustrated Hexagonal Honeycomb Arena Floor
	_draw_hex_grid(cam, vw, vh, palette)
	
	# 3. World Boundary Electric Energy Barrier
	_draw_world_boundary(cam, vw, vh, palette)
	
	# 4. Ambient Energy Motes / Floating Dust
	var mote_colors: Array = palette["motes"]
	for i in range(_ambient_motes.size()):
		var m: Dictionary = _ambient_motes[i]
		var col: Color = mote_colors[i % mote_colors.size()]
		col.a = float(m["alpha"]) * (0.8 + sin(_time * 2.0 + float(m["size"])) * 0.2)
		draw_circle(m["pos"], float(m["size"]), col)
	
	# 5. Environmental Decorative Foliage / Rocks
	for d in engine.decor:
		var d_pos: Vector2 = d["pos"] - cam
		if d_pos.x > -80.0 and d_pos.y > -80.0 and d_pos.x < vw + 80.0 and d_pos.y < vh + 80.0:
			var tex: Texture2D = food_textures.get(d["kind"], null)
			if tex:
				var s: float = 68.0 * float(d.get("scale", 1.0))
				# Soft ground shadow
				draw_circle(d_pos + Vector2(3.0, 8.0), s * 0.42, Color(0.01, 0.02, 0.06, 0.35))
				draw_set_transform(d_pos, float(d.get("rot", 0.0)), Vector2.ONE)
				draw_texture_rect(tex, Rect2(-s / 2.0, -s / 2.0, s, s), false)
				draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	
	# 6. Food, Collectibles & In-field Power-ups (Enlarged +35% to 40% for Mobile)
	for f in engine.food:
		var f_pos: Vector2 = f["pos"] - cam
		if f_pos.x < -60.0 or f_pos.y < -60.0 or f_pos.x > vw + 60.0 or f_pos.y > vh + 60.0:
			continue
		
		var r: float = float(f["r"])
		var phase: float = float(f.get("phase", 0.0))
		var bob: float = sin(_time * 3.0 + phase) * 4.5
		var pulse: float = 1.0 + sin(_time * 4.0 + phase) * 0.08
		var kind: String = f["kind"]
		
		if kind == "orb":
			# Ambient glowing energy pearls (enlarged +35%)
			var col: Color = f.get("color", Color("#38bdf8"))
			var orb_r: float = r * 2.1 * pulse
			# Soft outer halo
			draw_circle(f_pos + Vector2(0, bob), orb_r * 1.9, Color(col.r, col.g, col.b, 0.25))
			# Saturated body
			draw_circle(f_pos + Vector2(0, bob), orb_r, col)
			# Crisp white specular core
			draw_circle(f_pos + Vector2(-orb_r * 0.3, bob - orb_r * 0.3), orb_r * 0.42, Color.WHITE)
		else:
			var tex: Texture2D = food_textures.get(kind, null)
			if tex:
				var is_powerup: bool = kind in ["magnet", "speed", "speed_ring", "lightning_orb", "shield", "special", "double", "xp"]
				# Enlarged +35% to 40% for mobile arcade clarity
				var sz: float = r * (4.8 if is_powerup else 4.4) * pulse
				
				# If power-up on ground, draw glowing floor aura ring
				if is_powerup:
					var aura_col := Color("#facc15") # Golden Magnet/Coin
					match kind:
						"speed", "speed_ring": aura_col = Color("#00f5ff")
						"shield": aura_col = Color("#38bdf8")
						"special", "lightning_orb": aura_col = Color("#a855f7")
						"double": aura_col = Color("#fb923c")
						"xp": aura_col = Color("#4ade80")
					
					var aura_r: float = r * 2.8 * (1.0 + sin(_time * 4.5 + phase) * 0.08)
					draw_circle(f_pos, aura_r, Color(aura_col.r, aura_col.g, aura_col.b, 0.18))
					draw_arc(f_pos, aura_r, 0, TAU, 32, aura_col, 4.5)
				
				# Soft ground drop shadow
				draw_circle(f_pos + Vector2(4.0, r * 1.0), r * 0.95, Color(0.01, 0.02, 0.06, 0.40))
				
				# Draw centered 2D food/power-up sprite with gentle bob
				var rot: float = sin(_time * 1.8 + phase) * 0.10
				draw_set_transform(Vector2(f_pos.x, f_pos.y + bob), rot, Vector2.ONE)
				draw_texture_rect(tex, Rect2(-sz / 2.0, -sz / 2.0, sz, sz), false)
				draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	
	# 7. AI Worms
	for w in engine.worms:
		if w["alive"] and not w.get("isPlayer", false):
			_draw_worm(w, cam, vw, vh, false)
	
	# 8. Player Worm (Drawn on top)
	if engine.player["alive"]:
		var has_shield: bool = engine.effects["shield"] > 0.0 or engine.effects["special"] > 0.0
		_draw_worm(engine.player, cam, vw, vh, has_shield)
	
	# 9. In-World Floating Score Popups
	for p in engine.popups:
		var pos: Vector2 = p["pos"] - cam
		var alpha: float = clamp(float(p["life"]) * 1.8, 0.0, 1.0)
		var col: Color = p["color"]
		col.a = alpha
		var text: String = p["text"]
		draw_string_outline(font_lilita, pos, text, HORIZONTAL_ALIGNMENT_CENTER, -1, 32, 6, Color(0.02, 0.02, 0.10, alpha))
		draw_string(font_lilita, pos, text, HORIZONTAL_ALIGNMENT_CENTER, -1, 32, col)
	
	# 10. Subtle Vignette Overlay for Depth
	draw_rect(Rect2(0, 0, vw, vh), Color(0.02, 0.04, 0.12, 0.18), false, 36.0)

func _draw_hex_grid(cam: Vector2, vw: float, vh: float, palette: Dictionary) -> void:
	var R: float = 62.0
	var dx: float = R * 1.5
	var dy: float = R * 1.7320508
	
	var min_c: int = int((cam.x - R) / dx) - 1
	var max_c: int = int((cam.x + vw + R) / dx) + 1
	var min_r: int = int((cam.y - R) / dy) - 1
	var max_r: int = int((cam.y + vh + R) / dy) + 1
	
	var tile_fill: Color = palette["hex_fill"]
	var tile_bevel: Color = palette["hex_bevel"]
	var tile_seam: Color = palette["hex_seam"]
	
	for col in range(min_c, max_c):
		for row in range(min_r, max_r):
			var cx: float = float(col) * dx - cam.x
			var cy: float = float(row) * dy + (dy * 0.5 if abs(col) % 2 == 1 else 0.0) - cam.y
			
			if cx < -R or cy < -R or cx > vw + R or cy > vh + R:
				continue
			
			var pts: PackedVector2Array = PackedVector2Array()
			var bevel_pts: PackedVector2Array = PackedVector2Array()
			for i in range(6):
				var a: float = float(i) * TAU / 6.0
				pts.append(Vector2(cx + cos(a) * (R - 2.5), cy + sin(a) * (R - 2.5)))
				bevel_pts.append(Vector2(cx + cos(a) * (R - 6.0), cy + sin(a) * (R - 6.0)))
			
			# Draw Hex Tile Background
			draw_colored_polygon(pts, tile_fill)
			# Draw Subtle 3D Bevel Edge
			draw_polyline(pts, tile_bevel, 2.0)
			# Deep Seam Outline
			draw_polyline(pts, tile_seam, 1.2)

func _draw_world_boundary(cam: Vector2, vw: float, vh: float, palette: Dictionary) -> void:
	var w: float = GameEngine.WORLD
	var left: float = -cam.x
	var top: float = -cam.y
	var right: float = w - cam.x
	var bottom: float = w - cam.y
	
	# Electric Neon Boundary Frame (Theme Dependent)
	var border_col: Color = palette["laser"]
	var glow_col: Color = palette["laser_glow"]
	
	var w_rect := Rect2(left, top, w, w)
	# Soft glow halo
	draw_rect(w_rect, glow_col, false, 16.0)
	# Core crisp laser barrier
	draw_rect(w_rect, border_col, false, 5.0)
	
	# Shaded darkness outside arena limits
	if left > 0:
		draw_rect(Rect2(0, 0, left, vh), Color(0.01, 0.02, 0.08, 0.88))
	if right < vw:
		draw_rect(Rect2(right, 0, vw - right, vh), Color(0.01, 0.02, 0.08, 0.88))
	if top > 0:
		draw_rect(Rect2(0, 0, vw, top), Color(0.01, 0.02, 0.08, 0.88))
	if bottom < vh:
		draw_rect(Rect2(0, bottom, vw, vh - bottom), Color(0.01, 0.02, 0.08, 0.88))

func _draw_worm(w: Dictionary, cam: Vector2, vw: float, vh: float, shield: bool) -> void:
	var segs: Array = w["segs"]
	var n: int = segs.size()
	if n == 0:
		return
	
	var h: Vector2 = segs[0]
	var hx: float = h.x - cam.x
	var hy: float = h.y - cam.y
	if hx < -n * 12 - 120 or hy < -n * 12 - 120 or hx > vw + n * 12 + 120 or hy > vh + n * 12 + 120:
		return
	
	var r: float = GameEngine.worm_radius(w["score"]) * 2.1
	var is_player: bool = w.get("isPlayer", false)
	var is_boosting: bool = bool(w.get("boosting", false))
	
	var col_a: Color = w["color"]
	var col_b: Color = w["color2"]
	var head_col: Color = w.get("head_color", col_b)
	var iris_col: Color = w.get("iris_color", col_a)
	
	# 1. Ground Drop Shadow under entire body
	for i in range(n - 1, -1, -2):
		var p: Vector2 = segs[i] - cam
		var taper: float = 1.0
		if i > n * 0.85:
			taper = 1.0 - ((float(i) - float(n) * 0.85) / (float(n) * 0.15)) * 0.50
		var sh_r: float = r * taper * 0.92
		draw_circle(p + Vector2(7.0, 12.0), sh_r, Color(0.01, 0.02, 0.06, 0.32))
	
	# 2. Boosting Speed Glow
	if is_boosting:
		var glow_col := Color("#ffaa00", 0.32)
		for i in range(1, n, 2):
			var pos: Vector2 = segs[i] - cam
			draw_circle(pos, r * 1.85, glow_col)
	
	# 3. Smooth Connected Body Segments (drawn tail to neck)
	for i in range(n - 1, 0, -1):
		var p: Vector2 = segs[i] - cam
		if p.x < -70 or p.y < -70 or p.x > vw + 70 or p.y > vh + 70:
			continue
		
		var taper: float = 1.0
		if i > n * 0.85:
			taper = 1.0 - ((float(i) - float(n) * 0.85) / (float(n) * 0.15)) * 0.50
		var seg_r: float = r * taper
		
		# Alternating wide clean cartoon stripes (every 4 segments for bold stripes)
		var seg_col: Color = col_b if (int(i / 4) % 2 == 1) else col_a
		
		# Outer Dark Outline
		draw_circle(p, seg_r, Color(0.02, 0.04, 0.12, 0.95))
		# Base Colored Segment Fill
		draw_circle(p, seg_r - 2.8, seg_col)
		# Soft Lower Crescent Shading for 2D Depth
		draw_circle(p + Vector2(0.0, seg_r * 0.28), seg_r * 0.65, Color(seg_col.r * 0.65, seg_col.g * 0.65, seg_col.b * 0.65, 0.45))
		# Glossy Specular Highlight on top-left
		draw_circle(p + Vector2(-seg_r * 0.30, -seg_r * 0.30), seg_r * 0.34, Color(1, 1, 1, 0.45))
		draw_circle(p + Vector2(-seg_r * 0.35, -seg_r * 0.35), seg_r * 0.18, Color(1, 1, 1, 0.80))
	
	# 4. Expressive 2D Cartoon Head
	var head_pos := Vector2(hx, hy)
	var hr: float = r * 1.25
	
	# Head Outline & Fill
	draw_circle(head_pos, hr, Color(0.02, 0.04, 0.12, 0.95))
	draw_circle(head_pos, hr - 2.8, head_col)
	# Soft Lower Shading
	draw_circle(head_pos + Vector2(0.0, hr * 0.28), hr * 0.65, Color(head_col.r * 0.80, head_col.g * 0.80, head_col.b * 0.85, 0.40))
	# Glossy Highlight
	draw_circle(head_pos + Vector2(-hr * 0.30, -hr * 0.30), hr * 0.38, Color(1, 1, 1, 0.55))
	
	# Direction Vectors for Facial Features
	var ang: float = float(w["angle"])
	var fwd := Vector2(cos(ang), sin(ang))
	var side_vec := Vector2(-sin(ang), cos(ang))
	
	# 5. Adorable Expressive Cartoon Eyes (with Blinking!)
	var is_blinking: bool = (_blink_timer > 3.8 and _blink_timer < 3.96)
	var er: float = hr * 0.40
	var eye_dist: float = hr * 0.44
	var fwd_eye_dist: float = hr * 0.32
	
	var left_eye_pos: Vector2 = head_pos + fwd * fwd_eye_dist - side_vec * eye_dist
	var right_eye_pos: Vector2 = head_pos + fwd * fwd_eye_dist + side_vec * eye_dist
	
	for eye_pos in [left_eye_pos, right_eye_pos]:
		if is_blinking:
			# Cute curved closed-eye eyelid line
			draw_arc(eye_pos, er * 0.70, ang - 0.75, ang + 0.75, 8, Color(0.02, 0.04, 0.12), 3.5)
		else:
			# White Sclera with Dark Outline
			draw_circle(eye_pos, er, Color(0.02, 0.04, 0.12, 0.95))
			draw_circle(eye_pos, er - 2.0, Color.WHITE)
			
			# Colored Iris (looking forward in movement direction)
			var iris_r: float = er * 0.65
			var pupil_offset: Vector2 = fwd * (er * 0.18)
			var iris_center: Vector2 = eye_pos + pupil_offset
			draw_circle(iris_center, iris_r, iris_col)
			
			# Big Jet-Black Pupil
			var pupil_r: float = iris_r * 0.68
			draw_circle(iris_center, pupil_r, Color(0.02, 0.03, 0.08))
			
			# Dual Anime Specular Highlights
			draw_circle(iris_center + Vector2(-pupil_r * 0.38, -pupil_r * 0.38), pupil_r * 0.38, Color.WHITE)
			draw_circle(iris_center + Vector2(pupil_r * 0.44, pupil_r * 0.38), pupil_r * 0.20, Color.WHITE)
			
			# Cute Eyebrow above eye
			draw_arc(eye_pos + fwd * (er * 0.45), er * 0.75, ang - 0.45, ang + 0.45, 8, Color(0.02, 0.04, 0.12), 2.8)
	
	# 6. Cute Rosy Cheek Blush
	var cheek_dist: float = hr * 0.78
	var cheek_fwd: float = hr * 0.20
	var cheek_l: Vector2 = head_pos + fwd * cheek_fwd - side_vec * cheek_dist
	var cheek_r: Vector2 = head_pos + fwd * cheek_fwd + side_vec * cheek_dist
	draw_circle(cheek_l, hr * 0.22, Color(1.0, 0.42, 0.56, 0.55))
	draw_circle(cheek_r, hr * 0.22, Color(1.0, 0.42, 0.56, 0.55))
	
	# 7. Cheerful Smiling Mouth / Excited Boosting Expression
	var mouth_center: Vector2 = head_pos + fwd * (hr * 0.68)
	var mw: float = hr * 0.32
	if is_boosting:
		# Excited wide open joyful mouth with teeth and tongue when boosting!
		var open_r: float = mw * 0.85
		draw_circle(mouth_center + fwd * 2.0, open_r, Color(0.12, 0.04, 0.16, 0.95))
		draw_circle(mouth_center + fwd * (open_r * 0.35), open_r * 0.70, Color("#f43f5e"))
		# Cute cartoon front teeth
		draw_circle(mouth_center - fwd * (open_r * 0.25), open_r * 0.35, Color.WHITE)
		draw_arc(mouth_center + fwd * 2.0, open_r, ang - PI / 2.2, ang + PI / 2.2, 12, Color(0.08, 0.02, 0.10), 2.5)
	else:
		# Relaxed charming smile with pink tongue
		draw_arc(mouth_center, mw, ang - PI / 3.2, ang + PI / 3.2, 12, Color(0.08, 0.02, 0.10), 3.2)
		draw_circle(mouth_center + fwd * 3.5, mw * 0.45, Color(0.96, 0.32, 0.48))
	
	# 8. Protective Shield Bubble
	if shield:
		var shield_a: float = 0.55 + sin(_time * 7.0) * 0.25
		draw_circle(head_pos, hr * 1.70, Color(0.2, 0.85, 1.0, 0.18))
		draw_arc(head_pos, hr * 1.70, 0, TAU, 32, Color(0.2, 0.90, 1.0, shield_a), 4.5)
	
	# 9. AI Worm Name Label
	if not is_player:
		var name_pos := Vector2(hx, hy - hr - 14.0)
		var bot_name: String = w["name"]
		draw_string_outline(font_lilita, name_pos, bot_name, HORIZONTAL_ALIGNMENT_CENTER, -1, 18, 4, Color(0.02, 0.02, 0.12, 0.85))
		draw_string(font_lilita, name_pos, bot_name, HORIZONTAL_ALIGNMENT_CENTER, -1, 18, Color.WHITE)
