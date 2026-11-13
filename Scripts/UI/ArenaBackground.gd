extends Control

@onready var bg_texture: TextureRect = $Background
@onready var beams_container: Control = $Beams
@onready var particles_container: Control = $Particles

const PARTICLE_COUNT = 32
var _particles: Array[Dictionary] = []
var _beams: Array[ColorRect] = []
var _time: float = 0.0

func _ready() -> void:
	_init_beams()
	_init_particles()
	resized.connect(_on_resized)

func _get_viewport_size() -> Vector2:
	var s: Vector2 = size
	if s.x <= 10.0 or s.y <= 10.0:
		s = get_viewport_rect().size
	if s.x <= 10.0 or s.y <= 10.0:
		s = Vector2(1920, 1080)
	return s

func _init_beams() -> void:
	for c in beams_container.get_children():
		c.queue_free()
	_beams.clear()
	
	var left_pcts = [0.15, 0.35, 0.65, 0.85]
	var vp_size := _get_viewport_size()
	var beam_w: float = vp_size.x * 0.10
	var beam_h: float = vp_size.y * 0.70
	
	for i in range(left_pcts.size()):
		var beam := ColorRect.new()
		beam.custom_minimum_size = Vector2(beam_w, beam_h)
		beam.size = Vector2(beam_w, beam_h)
		beam.position = Vector2(vp_size.x * left_pcts[i] - beam_w * 0.5, 0.0)
		beam.color = Color(0.133, 0.827, 0.933, 0.22)
		beam.pivot_offset = Vector2(beam_w * 0.5, 0)
		beams_container.add_child(beam)
		_beams.append(beam)

func _init_particles() -> void:
	for c in particles_container.get_children():
		c.queue_free()
	_particles.clear()
	
	var vp_size := _get_viewport_size()
	for i in range(PARTICLE_COUNT):
		var p := ColorRect.new()
		var is_cyan := (i % 3 != 0)
		var p_color := Color(0.133, 0.827, 0.933, 0.85) if is_cyan else Color(0.659, 0.333, 0.969, 0.85)
		var sz: float = float(4 + ((i * 7) % 6))
		p.custom_minimum_size = Vector2(sz, sz)
		p.size = Vector2(sz, sz)
		p.color = p_color
		particles_container.add_child(p)
		
		var x_pct: float = float((i * 37) % 100) / 100.0
		var dur: float = float(7 + ((i * 13) % 9))
		var delay: float = float((i * 11) % 14)
		var start_y: float = vp_size.y - float((i * 17) % 40) * (vp_size.y * 0.01)
		
		_particles.append({
			"rect": p,
			"idx": i,
			"x_pct": x_pct,
			"startY": start_y,
			"dur": dur,
			"delay": delay,
			"sz": sz
		})

func _on_resized() -> void:
	var vp_size := _get_viewport_size()
	var left_pcts = [0.15, 0.35, 0.65, 0.85]
	var beam_w: float = vp_size.x * 0.10
	var beam_h: float = vp_size.y * 0.70
	for i in range(_beams.size()):
		var beam: ColorRect = _beams[i]
		beam.size = Vector2(beam_w, beam_h)
		beam.position = Vector2(vp_size.x * left_pcts[i] - beam_w * 0.5, 0.0)
		beam.pivot_offset = Vector2(beam_w * 0.5, 0)
	
	for p_data in _particles:
		p_data["startY"] = vp_size.y - float((p_data["idx"] * 17) % 40) * (vp_size.y * 0.01)

func _process(delta: float) -> void:
	_time += delta
	var vp_size := _get_viewport_size()
	
	# Animate beams swaying
	for i in range(_beams.size()):
		var beam: ColorRect = _beams[i]
		var angle: float = sin(_time * 1.05 + float(i) * 1.5) * deg_to_rad(8.0)
		beam.rotation = angle
		var alpha: float = 0.15 + (sin(_time * 1.05 + float(i) * 1.5) + 1.0) * 0.1
		beam.color.a = alpha
	
	# Animate particles drifting upward
	for p_data in _particles:
		var p_rect: ColorRect = p_data["rect"]
		var t_eff: float = fmod(_time + p_data["delay"], p_data["dur"])
		var progress: float = t_eff / p_data["dur"]
		var cur_y: float = p_data["startY"] - progress * (vp_size.y * 0.55)
		var cur_x: float = (p_data["x_pct"] * vp_size.x) + sin(_time * 1.5 + p_data["delay"]) * 14.0
		p_rect.position = Vector2(cur_x, cur_y)
		
		# Fade in and fade out
		var a: float = 1.0
		if progress < 0.15:
			a = progress / 0.15
		elif progress > 0.8:
			a = (1.0 - progress) / 0.2
		p_rect.color.a = a * 0.85
