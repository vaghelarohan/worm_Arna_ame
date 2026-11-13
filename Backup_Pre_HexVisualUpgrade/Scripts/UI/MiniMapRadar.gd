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
	
	# Arena perimeter boundary
	draw_rect(Rect2(0, 0, size.x, size.y), Color(0.2, 0.8, 0.4, 0.35), false, 2.0)
	
	# Draw food samples
	var food_list: Array = g.food
	for i in range(0, food_list.size(), 4):
		var f: Dictionary = food_list[i]
		var col: Color = Color("#ffd23f") if f["kind"] == "coin" else f["color"]
		col.a = 0.65
		draw_circle(f["pos"] * k, 1.8, col)
	
	# Draw bot heads
	for w in g.worms:
		if not w["alive"] or w.get("isPlayer", false):
			continue
		var h: Vector2 = w["segs"][0]
		draw_circle(h * k, 4.0, w["color"])
		draw_circle(h * k, 2.0, Color.WHITE)
	
	# Draw player beacon and arrow
	if g.player["alive"]:
		var ph: Vector2 = g.player["segs"][0]
		var p_radar: Vector2 = ph * k
		var ang: float = float(g.player["angle"])
		
		# Pulsing radar beacon ring
		var pulse: float = 5.0 + sin(_time * 8.0) * 2.0
		draw_arc(p_radar, pulse, 0, TAU, 16, Color(0.37, 1.0, 0.91, 0.6), 1.5)
		
		draw_set_transform(p_radar, ang, Vector2.ONE)
		var pts: PackedVector2Array = [
			Vector2(10, 0),
			Vector2(-7, -7),
			Vector2(-3, 0),
			Vector2(-7, 7)
		]
		draw_colored_polygon(pts, Color("#5effe9"))
		draw_polyline(pts, Color.WHITE, 1.5)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
