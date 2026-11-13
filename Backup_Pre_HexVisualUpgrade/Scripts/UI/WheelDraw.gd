extends Control

var colors = [
	Color("#ef4444"), Color("#fbbf24"), Color("#84cc16"), Color("#22d3ee"),
	Color("#1e293b"), Color("#a855f7"), Color("#d97706"), Color("#f43f5e")
]

var font_lilita: FontFile = preload("res://Assets/Fonts/LilitaOne-Regular.ttf")

func _draw() -> void:
	var r: float = size.x / 2.0
	var center := Vector2(r, r)
	var prizes: Array[String] = GameManager.wheel_prizes
	var n: int = prizes.size()
	var seg_rad: float = TAU / float(n)
	
	for i in range(n):
		var a1: float = float(i) * seg_rad
		var a2: float = float(i + 1) * seg_rad
		
		# Draw pie wedge
		var points: PackedVector2Array = [center]
		var steps: int = 16
		for s in range(steps + 1):
			var a: float = a1 + (a2 - a1) * (float(s) / float(steps))
			points.append(center + Vector2(cos(a), sin(a)) * r)
		
		draw_colored_polygon(points, colors[i % colors.size()])
		draw_line(center, points[1], Color("#0b0c1e"), 2.0)
		
		# Draw label along radius
		var mid_a: float = (a1 + a2) / 2.0
		var text_pos: Vector2 = center + Vector2(cos(mid_a), sin(mid_a)) * (r * 0.62)
		draw_set_transform(text_pos, mid_a, Vector2.ONE)
		draw_string(font_lilita, Vector2(-40, 6), prizes[i], HORIZONTAL_ALIGNMENT_CENTER, 80, 16, Color.WHITE)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	
	# Draw outer gold ring
	draw_arc(center, r - 3.0, 0, TAU, 64, Color("#fbbf24"), 8.0)
	# Center knob
	draw_circle(center, 34.0, Color("#fbbf24"))
	draw_circle(center, 28.0, Color("#d97706"))
	draw_circle(center, 12.0, Color("#ffffff"))

