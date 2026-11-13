class_name Arena3D
extends Node3D

const SCALE_3D: float = 0.05 # 3600 2D units = 180 3D units

var engine: GameEngine
var font_lilita: FontFile = preload("res://Assets/Fonts/LilitaOne-Regular.ttf")

@onready var camera: Camera3D = $Camera3D
@onready var sun: DirectionalLight3D = $DirectionalLight3D
@onready var ground: MeshInstance3D = $Ground
@onready var decor_container: Node3D = $DecorContainer
@onready var food_container: Node3D = $FoodContainer
@onready var worms_container: Node3D = $WormsContainer
@onready var popups_container: Node3D = $PopupsContainer
@onready var particles_container: Node3D = $ParticlesContainer

# Caches and pools
var _food_nodes: Dictionary = {} # food id -> Node3D
var _worm_nodes: Dictionary = {} # worm id -> Dictionary of nodes
var _popup_nodes: Array[Label3D] = []
var _time: float = 0.0

var hex_shader: Shader = preload("res://Assets/Shaders/hex_arena.gdshader")

func _ready() -> void:
	_setup_environment()
	_setup_boundary()

func _setup_environment() -> void:
	# Build dark futuristic hexagonal arena ground
	var gm := BoxMesh.new()
	var arena_sz := GameEngine.WORLD * SCALE_3D
	gm.size = Vector3(arena_sz, 0.2, arena_sz)
	ground.mesh = gm
	ground.position = Vector3(arena_sz * 0.5, -0.1, arena_sz * 0.5)
	
	var hex_mat := ShaderMaterial.new()
	hex_mat.shader = hex_shader
	ground.material_override = hex_mat

func _setup_boundary() -> void:
	var arena_sz := GameEngine.WORLD * SCALE_3D
	var step := 7.0
	
	var edges := [
		{"start": Vector3(0, 0, 0), "dir": Vector3(1, 0, 0), "count": int(arena_sz / step)},
		{"start": Vector3(arena_sz, 0, 0), "dir": Vector3(0, 0, 1), "count": int(arena_sz / step)},
		{"start": Vector3(arena_sz, 0, arena_sz), "dir": Vector3(-1, 0, 0), "count": int(arena_sz / step)},
		{"start": Vector3(0, 0, arena_sz), "dir": Vector3(0, 0, -1), "count": int(arena_sz / step)}
	]
	
	for edge in edges:
		var start: Vector3 = edge["start"]
		var dir: Vector3 = edge["dir"]
		var count: int = edge["count"]
		for i in range(count):
			var pos: Vector3 = start + dir * (float(i) * step)
			# Perimeter tree
			var tree := Model3DFactory.create_tree(Color(0.14, 0.55, 0.2) if i % 2 == 0 else Color(0.18, 0.68, 0.24))
			tree.position = pos + Vector3(randf_range(-1.2, 1.2), 0.0, randf_range(-1.2, 1.2))
			tree.scale = Vector3.ONE * randf_range(0.85, 1.25)
			tree.rotation.y = randf_range(0.0, TAU)
			decor_container.add_child(tree)
			
			# Add fence
			var fence := Model3DFactory.create_fence()
			decor_container.add_child(fence)
			fence.position = pos
			fence.look_at(pos + dir, Vector3.UP)

func setup_decor(decor_list: Array[Dictionary]) -> void:
	for d in decor_list:
		var p: Vector2 = d["pos"]
		var pos := Vector3(p.x * SCALE_3D, 0.0, p.y * SCALE_3D)
		var kind: String = d["kind"]
		var item: Node3D = null
		
		match kind:
			"plant", "bush":
				item = Model3DFactory.create_bush()
			"rock":
				item = Model3DFactory.create_rock()
			"flower":
				var cols := [Color(1.0, 0.25, 0.45), Color(1.0, 0.85, 0.15), Color(0.25, 0.65, 1.0), Color(0.95, 0.95, 1.0)]
				item = Model3DFactory.create_flower(cols[randi() % cols.size()])
			"mushroom":
				item = Model3DFactory.create_mushroom()
			_:
				item = Model3DFactory.create_flower()
		
		if item:
			item.position = pos
			item.scale = Vector3.ONE * float(d.get("scale", 1.0))
			item.rotation.y = float(d.get("rot", 0.0))
			decor_container.add_child(item)

func _process(delta: float) -> void:
	if not engine:
		return
	_time += delta
	
	_update_camera(delta)
	_update_foods(delta)
	_update_worms(delta)
	_update_popups(delta)

func _update_camera(delta: float) -> void:
	if not engine.player["alive"] and engine.player["segs"].is_empty():
		return
	
	var ph: Vector2 = engine.player["segs"][0]
	var target_x: float = ph.x * SCALE_3D
	var target_z: float = ph.y * SCALE_3D
	
	var ang: float = float(engine.player["angle"])
	var lead := 2.5
	target_x += cos(ang) * lead
	target_z += sin(ang) * lead
	
	var shake_off := Vector3.ZERO
	if engine.shake > 0.0:
		shake_off = Vector3(randf_range(-1.0, 1.0), 0.0, randf_range(-1.0, 1.0)) * engine.shake * 1.4
	
	var desired_cam_pos := Vector3(target_x, 34.0, target_z + 16.0) + shake_off
	if _time <= delta * 1.5:
		camera.position = desired_cam_pos
	else:
		camera.position = camera.position.lerp(desired_cam_pos, clamp(delta * 9.0, 0.0, 1.0))
	camera.look_at(Vector3(target_x, 0.0, target_z), Vector3.UP)

func _update_foods(delta: float) -> void:
	var cam_pos := camera.position
	var max_dist := 48.0
	var current_visible: Dictionary = {}
	
	for i in range(engine.food.size()):
		var f: Dictionary = engine.food[i]
		var f_pos: Vector2 = f["pos"]
		var fx := f_pos.x * SCALE_3D
		var fz := f_pos.y * SCALE_3D
		
		var dx := fx - cam_pos.x
		var dz := fz - cam_pos.z
		if abs(dx) > max_dist or abs(dz) > max_dist:
			continue
		
		var key = f.get("id", i)
		current_visible[key] = true
		
		var node: Node3D = _food_nodes.get(key, null)
		if not node:
			node = _create_food_model(f["kind"], f.get("color", Color(0.2, 0.85, 1.0)))
			var is_special: bool = f["kind"] in ["magnet", "speed", "speed_ring", "lightning_orb", "crown", "diamond", "cake", "cheese"]
			node.scale = Vector3.ONE * (2.2 if is_special else 1.75)
			food_container.add_child(node)
			_food_nodes[key] = node
		
		var phase: float = float(f.get("phase", 0.0))
		var bob: float = sin(_time * 2.8 + phase) * 0.10
		node.position = Vector3(fx, 0.40 + bob, fz)
		node.rotation.y += delta * 1.5
	
	var to_remove: Array = []
	for k in _food_nodes.keys():
		if not current_visible.has(k):
			to_remove.append(k)
	for k in to_remove:
		var n: Node3D = _food_nodes[k]
		n.queue_free()
		_food_nodes.erase(k)

func _create_food_model(kind: String, col: Color = Color(0.2, 0.85, 1.0)) -> Node3D:
	match kind:
		"apple": return Model3DFactory.create_apple()
		"strawberry": return Model3DFactory.create_strawberry()
		"orange": return Model3DFactory.create_orange()
		"banana": return Model3DFactory.create_banana()
		"grapes": return Model3DFactory.create_grapes()
		"watermelon": return Model3DFactory.create_watermelon()
		"blueberry": return Model3DFactory.create_blueberry()
		"cherry": return Model3DFactory.create_cherry()
		"broccoli": return Model3DFactory.create_broccoli()
		"cheese": return Model3DFactory.create_cheese()
		"cake": return Model3DFactory.create_cake()
		"burger": return Model3DFactory.create_burger()
		"pizza": return Model3DFactory.create_pizza()
		"donut": return Model3DFactory.create_donut()
		"cupcake": return Model3DFactory.create_cupcake()
		"candy": return Model3DFactory.create_candy()
		"chocolate": return Model3DFactory.create_chocolate()
		"cookie": return Model3DFactory.create_cookie()
		"sandwich": return Model3DFactory.create_sandwich()
		"diamond", "diamond_fruit": return Model3DFactory.create_diamond()
		"crown": return Model3DFactory.create_crown()
		"golden_apple": return Model3DFactory.create_golden_apple()
		"rainbow_food": return Model3DFactory.create_rainbow_food()
		"mystery_box": return Model3DFactory.create_mystery_box()
		"coin": return Model3DFactory.create_coin_multiplier()
		"magnet": return Model3DFactory.create_magnet()
		"speed": return Model3DFactory.create_speed_bolt()
		"shield": return Model3DFactory.create_shield_orb()
		"rocket": return Model3DFactory.create_rocket()
		"potion": return Model3DFactory.create_potion()
		"speed_ring": return Model3DFactory.create_speed_ring()
		"lightning_orb": return Model3DFactory.create_lightning_orb()
		"ghost": return Model3DFactory.create_ghost()
		"special": return Model3DFactory.create_special_boost()
		_:
			# Colorful energy pearl matching concept
			var root := Node3D.new()
			var sm := SphereMesh.new()
			sm.radius = 0.32
			sm.height = 0.64
			sm.radial_segments = 14
			sm.rings = 8
			var m := MeshInstance3D.new()
			m.mesh = sm
			m.material_override = Model3DFactory.get_mat("orb_energy_" + col.to_html(false), col, 0.06, 0.08, col * 0.85)
			m.position.y = 0.32
			root.add_child(m)
			return root

func _update_worms(delta: float) -> void:
	var active_ids: Dictionary = {}
	
	for w in engine.worms:
		var wid: int = int(w["id"])
		active_ids[wid] = true
		
		var wdata: Dictionary = _worm_nodes.get(wid, {})
		if wdata.is_empty():
			wdata = _create_worm_node(w)
			_worm_nodes[wid] = wdata
		
		_update_single_worm(w, wdata, delta)
	
	var to_erase: Array = []
	for wid in _worm_nodes.keys():
		if not active_ids.has(wid):
			to_erase.append(wid)
	for wid in to_erase:
		var wd: Dictionary = _worm_nodes[wid]
		wd["root"].queue_free()
		_worm_nodes.erase(wid)

func _create_worm_node(w: Dictionary) -> Dictionary:
	var root := Node3D.new()
	worms_container.add_child(root)
	
	var is_player: bool = w.get("isPlayer", false)
	var col_a: Color = w["color"]
	var col_b: Color = w["color2"]
	
	var mat_a := StandardMaterial3D.new()
	mat_a.albedo_color = col_a
	mat_a.roughness = 0.12
	mat_a.metallic = 0.08
	mat_a.specular_mode = BaseMaterial3D.SPECULAR_SCHLICK_GGX
	mat_a.rim_enabled = true
	mat_a.rim = 0.45
	mat_a.rim_tint = 0.5
	mat_a.clearcoat_enabled = true
	mat_a.clearcoat = 0.7
	
	var mat_b := StandardMaterial3D.new()
	mat_b.albedo_color = col_b
	mat_b.roughness = 0.14
	mat_b.metallic = 0.06
	mat_b.rim_enabled = true
	mat_b.rim = 0.4
	mat_b.clearcoat_enabled = true
	mat_b.clearcoat = 0.6
	
	# Head node
	var head_node := Node3D.new()
	root.add_child(head_node)
	
	# Head Sphere
	var head_mesh := MeshInstance3D.new()
	var hm := SphereMesh.new()
	hm.radius = 1.45
	hm.height = 2.80
	hm.radial_segments = 20
	hm.rings = 14
	head_mesh.mesh = hm
	head_mesh.material_override = mat_a
	head_mesh.position.y = 1.40
	head_node.add_child(head_mesh)
	
	# Head Ground Shadow
	var h_shadow := MeshInstance3D.new()
	var hsm := CylinderMesh.new()
	hsm.top_radius = 1.60
	hsm.bottom_radius = 1.60
	hsm.height = 0.02
	h_shadow.mesh = hsm
	h_shadow.material_override = Model3DFactory.get_mat("shadow_ground", Color(0.01, 0.02, 0.06), 0.95, 0.0, Color.BLACK, true, 0.6)
	h_shadow.position.y = 0.02
	head_node.add_child(h_shadow)
	
	# 3D Anime Eyes (matching concept image!)
	var eye_white_mat := Model3DFactory.get_mat("eye_white", Color.WHITE, 0.08, 0.0)
	var iris_col: Color = col_b if is_player else col_a
	var eye_iris_mat := Model3DFactory.get_mat("eye_iris_" + iris_col.to_html(false), iris_col, 0.12, 0.1)
	var eye_pupil_mat := Model3DFactory.get_mat("eye_pupil", Color(0.04, 0.06, 0.14), 0.04, 0.0)
	var eye_shine_mat := Model3DFactory.get_mat("eye_shine", Color.WHITE, 0.02, 0.0, Color.WHITE)
	
	for side in [-1.0, 1.0]:
		var eye_root := Node3D.new()
		eye_root.position = Vector3(side * 0.48, 1.55, 1.25)
		head_node.add_child(eye_root)
		
		# White Sclera
		var sclera := MeshInstance3D.new()
		var em := SphereMesh.new()
		em.radius = 0.52
		em.height = 0.96
		em.radial_segments = 16
		sclera.mesh = em
		sclera.material_override = eye_white_mat
		eye_root.add_child(sclera)
		
		# Colored Iris Ring
		var iris := MeshInstance3D.new()
		var im := SphereMesh.new()
		im.radius = 0.40
		im.height = 0.76
		iris.mesh = im
		iris.material_override = eye_iris_mat
		iris.position = Vector3(0.0, 0.02, 0.28)
		eye_root.add_child(iris)
		
		# Dark Pupil
		var pupil := MeshInstance3D.new()
		var pm := SphereMesh.new()
		pm.radius = 0.28
		pm.height = 0.54
		pupil.mesh = pm
		pupil.material_override = eye_pupil_mat
		pupil.position = Vector3(0.0, 0.04, 0.40)
		eye_root.add_child(pupil)
		
		# Large Primary Specular Reflection Dot (top)
		var shine1 := MeshInstance3D.new()
		var shm1 := SphereMesh.new()
		shm1.radius = 0.14
		shm1.height = 0.26
		shine1.mesh = shm1
		shine1.material_override = eye_shine_mat
		shine1.position = Vector3(side * -0.09, 0.20, 0.56)
		eye_root.add_child(shine1)
		
		# Small Secondary Specular Reflection Dot (bottom)
		var shine2 := MeshInstance3D.new()
		var shm2 := SphereMesh.new()
		shm2.radius = 0.08
		shm2.height = 0.16
		shine2.mesh = shm2
		shine2.material_override = eye_shine_mat
		shine2.position = Vector3(side * 0.11, -0.09, 0.56)
		eye_root.add_child(shine2)
	
	# Cute smile mouth
	var smile := MeshInstance3D.new()
	var smm := BoxMesh.new()
	smm.size = Vector3(0.65, 0.12, 0.08)
	smile.mesh = smm
	smile.material_override = Model3DFactory.get_mat("mouth_red", Color(0.75, 0.10, 0.22), 0.25)
	smile.position = Vector3(0.0, 1.05, 1.38)
	head_node.add_child(smile)
	
	# Cute rosy cheek blush
	var blush_mat := Model3DFactory.get_mat("cheek_blush", Color(1.0, 0.4, 0.55), 0.4, 0.0, Color.BLACK, true, 0.65)
	for side in [-1.0, 1.0]:
		var cheek := MeshInstance3D.new()
		var chm := SphereMesh.new()
		chm.radius = 0.30
		chm.height = 0.16
		cheek.mesh = chm
		cheek.material_override = blush_mat
		cheek.position = Vector3(side * 0.90, 1.15, 1.18)
		head_node.add_child(cheek)
	
	# Shield Bubble
	var shield_bubble := MeshInstance3D.new()
	var shbm := SphereMesh.new()
	shbm.radius = 1.75
	shbm.height = 3.5
	shield_bubble.mesh = shbm
	shield_bubble.material_override = Model3DFactory.get_mat("shield_aura", Color(0.2, 0.85, 1.0), 0.05, 0.1, Color(0.15, 0.7, 0.95), true, 0.5)
	shield_bubble.position.y = 1.05
	shield_bubble.visible = false
	head_node.add_child(shield_bubble)
	
	# Name Label3D for bots
	var name_tag: Label3D = null
	if not is_player:
		name_tag = Label3D.new()
		name_tag.text = w["name"]
		name_tag.font = font_lilita
		name_tag.font_size = 28
		name_tag.outline_size = 6
		name_tag.outline_modulate = Color(0.04, 0.04, 0.15, 0.9)
		name_tag.modulate = Color.WHITE
		name_tag.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		name_tag.position = Vector3(0.0, 2.7, 0.0)
		head_node.add_child(name_tag)
	
	return {
		"root": root,
		"head": head_node,
		"shield": shield_bubble,
		"mat_a": mat_a,
		"mat_b": mat_b,
		"segments": [],
		"shadows": []
	}

func _update_single_worm(w: Dictionary, wdata: Dictionary, delta: float) -> void:
	var root: Node3D = wdata["root"]
	if not w["alive"]:
		root.visible = false
		return
	root.visible = true
	
	var segs: Array = w["segs"]
	var n: int = segs.size()
	if n == 0:
		return
	
	var h: Vector2 = segs[0]
	var head_node: Node3D = wdata["head"]
	head_node.position = Vector3(h.x * SCALE_3D, 0.0, h.y * SCALE_3D)
	
	var ang: float = float(w["angle"])
	head_node.rotation.y = -ang + PI / 2.0
	head_node.rotation.x = -0.08
	
	var is_player: bool = w.get("isPlayer", false)
	var shield_mesh: MeshInstance3D = wdata["shield"]
	if is_player:
		var has_shield: bool = engine.effects["shield"] > 0.0 or engine.effects["special"] > 0.0
		shield_mesh.visible = has_shield
		if has_shield:
			shield_mesh.rotation.y += delta * 2.5
	
	var segment_nodes: Array = wdata["segments"]
	var shadow_nodes: Array = wdata["shadows"]
	var r: float = GameEngine.worm_radius(w["score"]) * SCALE_3D * 2.1
	
	var mat_a: StandardMaterial3D = wdata["mat_a"]
	var mat_b: StandardMaterial3D = wdata["mat_b"]
	
	while segment_nodes.size() < n - 1:
		var seg_mesh := MeshInstance3D.new()
		var sm := SphereMesh.new()
		sm.radius = 1.35
		sm.height = 2.70
		sm.radial_segments = 14
		sm.rings = 10
		seg_mesh.mesh = sm
		root.add_child(seg_mesh)
		segment_nodes.append(seg_mesh)
		
		var sh := MeshInstance3D.new()
		var shm := CylinderMesh.new()
		shm.top_radius = 1.50
		shm.bottom_radius = 1.50
		shm.height = 0.02
		sh.mesh = shm
		sh.material_override = Model3DFactory.get_mat("shadow_ground", Color(0.01, 0.02, 0.06), 0.95, 0.0, Color.BLACK, true, 0.55)
		root.add_child(sh)
		shadow_nodes.append(sh)
	
	for i in range(1, n):
		var p: Vector2 = segs[i]
		var idx: int = i - 1
		var seg_mesh: MeshInstance3D = segment_nodes[idx]
		var sh_mesh: MeshInstance3D = shadow_nodes[idx]
		
		var taper: float = 1.0
		if i > n * 0.65:
			taper = 1.0 - ((float(i) - float(n) * 0.65) / (float(n) * 0.35)) * 0.55
		var seg_r: float = r * taper
		
		var pos_3d := Vector3(p.x * SCALE_3D, seg_r, p.y * SCALE_3D)
		seg_mesh.position = pos_3d
		seg_mesh.scale = Vector3.ONE * (seg_r / 1.35)
		seg_mesh.material_override = mat_b if (int(i / 3) % 2 == 1) else mat_a
		seg_mesh.visible = true
		
		sh_mesh.position = Vector3(p.x * SCALE_3D, 0.02, p.y * SCALE_3D)
		sh_mesh.scale = Vector3.ONE * (seg_r / 1.35)
		sh_mesh.visible = true
	
	for i in range(n - 1, segment_nodes.size()):
		segment_nodes[i].visible = false
		shadow_nodes[i].visible = false

func _update_popups(delta: float) -> void:
	while _popup_nodes.size() < engine.popups.size():
		var lbl := Label3D.new()
		lbl.font = font_lilita
		lbl.font_size = 38
		lbl.outline_size = 8
		lbl.outline_modulate = Color(0.04, 0.02, 0.15, 0.9)
		lbl.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		popups_container.add_child(lbl)
		_popup_nodes.append(lbl)
	
	for i in range(engine.popups.size()):
		var p: Dictionary = engine.popups[i]
		var lbl: Label3D = _popup_nodes[i]
		var pos: Vector2 = p["pos"]
		lbl.position = Vector3(pos.x * SCALE_3D, 2.5 + (1.2 - float(p["life"])) * 3.0, pos.y * SCALE_3D)
		lbl.text = p["text"]
		var col: Color = p["color"]
		col.a = clamp(float(p["life"]) * 1.8, 0.0, 1.0)
		lbl.modulate = col
		lbl.visible = true
	
	for i in range(engine.popups.size(), _popup_nodes.size()):
		_popup_nodes[i].visible = false
