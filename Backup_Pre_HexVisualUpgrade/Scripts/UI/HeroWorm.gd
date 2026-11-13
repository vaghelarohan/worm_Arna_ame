extends Control

@onready var worm_sprite: TextureRect = $WormSprite
@onready var shadow_rect: ColorRect = $Podium/Shadow
@onready var dashed_ring: Control = $Podium/DashedRing

var _time: float = 0.0
var _initial_worm_pos: Vector2

func _ready() -> void:
	_initial_worm_pos = worm_sprite.position
	worm_sprite.pivot_offset = Vector2(worm_sprite.size.x * 0.5, worm_sprite.size.y * 0.9)

func _process(delta: float) -> void:
	_time += delta
	
	# Worm idle float & sway (3.2s cycle)
	var t: float = _time * (TAU / 3.2)
	var bob_y: float = -sin(t) * 14.0
	var rot: float = sin(t) * deg_to_rad(1.5)
	var sc_y: float = 1.0 + (sin(t) * 0.015)
	
	worm_sprite.position.y = _initial_worm_pos.y + bob_y
	worm_sprite.rotation = rot
	worm_sprite.scale = Vector2(1.0, sc_y)
	
	# Shadow pulse
	var sh_scale: float = 1.0 - (sin(t) * 0.15)
	var sh_alpha: float = 0.45 - (sin(t) * 0.1)
	shadow_rect.scale = Vector2(sh_scale, sh_scale)
	shadow_rect.color.a = sh_alpha
	
	# Dashed ring spin
	dashed_ring.rotation += delta * 0.45

