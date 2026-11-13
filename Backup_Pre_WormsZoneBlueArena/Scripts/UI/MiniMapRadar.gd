extends Control

@onready var parent: Panel = get_parent()
var _time: float = 0.0

func _process(delta: float) -> void:
	_time += delta
	queue_redraw()

func _draw() -> void:
	if not parent.engine:
		return
	var g = parent.engine
	var k: float = size.x / GameEngine.WORLD
	
	# Background deep space navy
	draw_rect(Rect2(0, 0, size.x, size.y), Color(0.04, 0.06, 0.14, 0.95), true)
	# Glowing cyan border
	draw_rect(Rect2(0, 0, size.x, size.y), Color(0.0, 0.90, 1.0, 0.9), false, 2.0)
	
	# Draw starry food points
	var food_list: Array = g.food
	var star_colors := [
		Color(0.0, 0.94, 1.0),   # Cyan
		Color(1.0, 0.88, 0.12),  # Yellow
		Color(0.85, 0.25, 1.0),  # Purple
		Color(1.0, 0.28, 0.65),  # Magenta/Pink
		Color(0.25, 1.0, 0.45),  # Lime
		Color(1.0, 0.55, 0.15)   # Orange
	]
	
	for i in range(0, food_list.size(), 2):
		var f: Dictionary = food_list[i]
		var col: Color = star_colors[i % star_colors.size()]
		col.a = 0.85
		var pt_size: float = 1.6 if i % 3 != 0 else 2.2
		draw_circle(f["pos"] * k, pt_size, col)
	
	# Draw bot heads
	for w in g.worms:
		if not w["alive"] or w.get("isPlayer", false):
			continue
		var h: Vector2 = w["segs"][0]
		draw_circle(h * k, 3.5, w["color"])
		draw_circle(h * k, 1.8, Color.WHITE)
	
	# Draw player beacon and sleek white arrow (matching concept image)
	if g.player["alive"]:
		var ph: Vector2 = g.player["segs"][0]
		var p_radar: Vector2 = ph * k
		var ang: float = float(g.player["angle"])
		
		# Subtle radar ping ring
		var pulse: float = 4.0 + sin(_time * 6.0) * 1.5
		draw_arc(p_radar, pulse, 0, TAU, 16, Color(0.0, 0.94, 1.0, 0.5), 1.2)
		
		# Crisp white cursor/arrow
		draw_set_transform(p_radar, ang, Vector2.ONE)
		var pts: PackedVector2Array = [
			Vector2(11, 0),
			Vector2(-7, -6),
			Vector2(-3, 0),
			Vector2(-7, 6)
		]
		draw_colored_polygon(pts, Color.WHITE)
		draw_polyline(pts, Color(0.0, 0.8, 1.0), 1.2)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
