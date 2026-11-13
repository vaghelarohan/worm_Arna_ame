extends Control

@onready var bg_texture: TextureRect = $Background
@onready var beams_container: Control = $Beams
@onready var particles_container: Control = $Particles

const PARTICLE_COUNT = 28
var _particles: Array[Dictionary] = []
var _beams: Array[ColorRect] = []
var _time: float = 0.0

func _ready() -> void:
	_init_beams()
	_init_particles()

func _init_beams() -> void:
	var left_pcts = [0.18, 0.38, 0.62, 0.82]
	for i in range(left_pcts.size()):
		var beam := ColorRect.new()
		beam.custom_minimum_size = Vector2(160, 630)
		beam.size = Vector2(160, 630)
		beam.position = Vector2(1600.0 * left_pcts[i] - 80.0, 0.0)
		beam.color = Color(0.133, 0.827, 0.933, 0.22)
		beam.pivot_offset = Vector2(80, 0)
		beams_container.add_child(beam)
		_beams.append(beam)

func _init_particles() -> void:
	for i in range(PARTICLE_COUNT):
		var p := ColorRect.new()
		var is_cyan := (i % 3 != 0)
		var p_color := Color(0.133, 0.827, 0.933, 0.85) if is_cyan else Color(0.659, 0.333, 0.969, 0.85)
		var sz: float = float(4 + ((i * 7) % 6))
		p.custom_minimum_size = Vector2(sz, sz)
		p.size = Vector2(sz, sz)
		p.color = p_color
		particles_container.add_child(p)
		
		var x_pos: float = float((i * 37) % 100) * 16.0
		var dur: float = float(7 + ((i * 13) % 9))
		var delay: float = float((i * 11) % 14)
		var start_y: float = 900.0 - float((i * 17) % 40) * 9.0
		
		_particles.append({
			"rect": p,
			"x": x_pos,
			"startY": start_y,
			"dur": dur,
			"delay": delay,
			"sz": sz
		})

func _process(delta: float) -> void:
	_time += delta
	
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
		var cur_y: float = p_data["startY"] - progress * 500.0
		var cur_x: float = p_data["x"] + sin(_time * 1.5 + p_data["delay"]) * 12.0
		p_rect.position = Vector2(cur_x, cur_y)
		
		# Fade in and fade out
		var a: float = 1.0
		if progress < 0.15:
			a = progress / 0.15
		elif progress > 0.8:
			a = (1.0 - progress) / 0.2
		p_rect.color.a = a * 0.85

