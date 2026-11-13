class_name Model3DFactory
extends RefCounted

# Shared Material Cache to optimize draw calls and memory on mobile
static var _materials: Dictionary = {}

static func get_mat(key: String, albedo: Color, roughness: float = 0.3, metallic: float = 0.0, emission: Color = Color.BLACK, transparent: bool = false, alpha: float = 1.0) -> StandardMaterial3D:
	if _materials.has(key):
		return _materials[key]
	
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(albedo.r, albedo.g, albedo.b, alpha if transparent else 1.0)
	mat.roughness = roughness
	mat.metallic = metallic
	if emission != Color.BLACK:
		mat.emission_enabled = true
		mat.emission = emission
		mat.emission_energy_multiplier = 1.8
	if transparent:
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
	mat.specular_mode = BaseMaterial3D.SPECULAR_SCHLICK_GGX
	_materials[key] = mat
	return mat

# --- SHADOW HELPER ---
static func _add_shadow(parent: Node3D, radius: float = 0.5) -> void:
	var shadow := MeshInstance3D.new()
	var sm := CylinderMesh.new()
	sm.top_radius = radius
	sm.bottom_radius = radius
	sm.height = 0.02
	sm.radial_segments = 14
	shadow.mesh = sm
	shadow.material_override = get_mat("shadow_ground", Color(0.01, 0.02, 0.06), 0.95, 0.0, Color.BLACK, true, 0.6)
	shadow.position.y = 0.02
	parent.add_child(shadow)

# ==============================================================================
# 1. 3D FRUITS (8 ITEMS)
# ==============================================================================

# Apple: Glossy red spherical body with indented top, curved stem & green leaf
static func create_apple() -> Node3D:
	var root := Node3D.new()
	_add_shadow(root, 0.44)
	
	var body := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = 0.44
	sm.height = 0.82
	sm.radial_segments = 16
	sm.rings = 10
	body.mesh = sm
	body.material_override = get_mat("apple_red", Color(0.96, 0.12, 0.16), 0.12, 0.05, Color(0.3, 0.02, 0.04))
	body.position.y = 0.44
	root.add_child(body)
	
	# Stem
	var stem := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 0.03
	cm.bottom_radius = 0.04
	cm.height = 0.24
	cm.radial_segments = 6
	stem.mesh = cm
	stem.material_override = get_mat("stem_brown", Color(0.42, 0.24, 0.12), 0.6)
	stem.position = Vector3(0.0, 0.86, 0.0)
	stem.rotation.z = 0.2
	root.add_child(stem)
	
	# Leaf
	var leaf := MeshInstance3D.new()
	var lm := SphereMesh.new()
	lm.radius = 0.14
	lm.height = 0.26
	leaf.mesh = lm
	leaf.scale = Vector3(1.0, 0.2, 0.6)
	leaf.rotation = Vector3(0.3, 0.0, 0.8)
	leaf.position = Vector3(0.10, 0.88, 0.0)
	leaf.material_override = get_mat("leaf_green", Color(0.18, 0.82, 0.22), 0.25)
	root.add_child(leaf)
	
	return root

# Strawberry: Tapered red berry with green calyx
static func create_strawberry() -> Node3D:
	var root := Node3D.new()
	_add_shadow(root, 0.40)
	
	var body := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 0.44
	cm.bottom_radius = 0.12
	cm.height = 0.76
	cm.radial_segments = 14
	body.mesh = cm
	body.material_override = get_mat("berry_red", Color(0.98, 0.10, 0.26), 0.14, 0.04)
	body.position.y = 0.44
	root.add_child(body)
	
	# Green Calyx on top
	for i in range(5):
		var leaf := MeshInstance3D.new()
		var lm := PrismMesh.new()
		lm.size = Vector3(0.18, 0.30, 0.04)
		leaf.mesh = lm
		leaf.material_override = get_mat("leaf_green", Color(0.18, 0.82, 0.22), 0.25)
		leaf.position = Vector3(0.0, 0.82, 0.0)
		leaf.rotation = Vector3(0.8, float(i) * TAU / 5.0, 0.0)
		root.add_child(leaf)
	
	return root

# Orange: Vibrant orange sphere with dimple and leaf
static func create_orange() -> Node3D:
	var root := Node3D.new()
	_add_shadow(root, 0.45)
	
	var body := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = 0.46
	sm.height = 0.88
	sm.radial_segments = 16
	sm.rings = 10
	body.mesh = sm
	body.material_override = get_mat("orange_fruit", Color(1.0, 0.55, 0.02), 0.2, 0.02)
	body.position.y = 0.46
	root.add_child(body)
	
	var stem := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 0.04
	cm.bottom_radius = 0.04
	cm.height = 0.14
	stem.mesh = cm
	stem.material_override = get_mat("stem_brown", Color(0.42, 0.24, 0.12), 0.6)
	stem.position = Vector3(0.0, 0.90, 0.0)
	root.add_child(stem)
	
	var leaf := MeshInstance3D.new()
	var lm := SphereMesh.new()
	lm.radius = 0.13
	lm.height = 0.24
	leaf.mesh = lm
	leaf.scale = Vector3(1.0, 0.2, 0.6)
	leaf.rotation = Vector3(0.2, 0.4, 0.7)
	leaf.position = Vector3(0.09, 0.92, 0.0)
	leaf.material_override = get_mat("leaf_green", Color(0.18, 0.82, 0.22), 0.25)
	root.add_child(leaf)
	
	return root

# Banana: Curved golden fruit with green stem & brown tip
static func create_banana() -> Node3D:
	var root := Node3D.new()
	_add_shadow(root, 0.48)
	
	var b_root := Node3D.new()
	b_root.position.y = 0.38
	root.add_child(b_root)
	
	var angles := [-0.35, 0.0, 0.35]
	var positions := [Vector3(-0.34, -0.06, 0.0), Vector3(0.0, 0.04, 0.0), Vector3(0.34, -0.06, 0.0)]
	for i in range(3):
		var seg := MeshInstance3D.new()
		var cm := CylinderMesh.new()
		cm.top_radius = 0.16
		cm.bottom_radius = 0.17
		cm.height = 0.40
		cm.radial_segments = 8
		seg.mesh = cm
		seg.material_override = get_mat("banana_yellow", Color(1.0, 0.88, 0.10), 0.18, 0.02)
		seg.position = positions[i]
		seg.rotation.z = angles[i] + PI / 2.0
		b_root.add_child(seg)
	
	var stem := MeshInstance3D.new()
	var sm := CylinderMesh.new()
	sm.top_radius = 0.06
	sm.bottom_radius = 0.1
	sm.height = 0.18
	stem.mesh = sm
	stem.material_override = get_mat("stem_green", Color(0.42, 0.78, 0.18), 0.35)
	stem.position = Vector3(-0.55, -0.15, 0.0)
	stem.rotation.z = PI / 2.2
	b_root.add_child(stem)
	
	return root

# Grapes: Shiny purple grape cluster with stem
static func create_grapes() -> Node3D:
	var root := Node3D.new()
	_add_shadow(root, 0.44)
	
	var grape_mat := get_mat("grape_purple", Color(0.58, 0.15, 0.92), 0.10, 0.08)
	var coords := [
		Vector3(0.0, 0.75, 0.0),
		Vector3(-0.16, 0.64, 0.12), Vector3(0.16, 0.64, 0.12), Vector3(0.0, 0.64, -0.18),
		Vector3(-0.18, 0.46, -0.08), Vector3(0.18, 0.46, -0.08), Vector3(0.0, 0.46, 0.18),
		Vector3(-0.1, 0.30, 0.08), Vector3(0.1, 0.30, 0.08),
		Vector3(0.0, 0.16, 0.0)
	]
	
	for c in coords:
		var grape := MeshInstance3D.new()
		var sm := SphereMesh.new()
		sm.radius = 0.16
		sm.height = 0.32
		sm.radial_segments = 10
		sm.rings = 6
		grape.mesh = sm
		grape.material_override = grape_mat
		grape.position = c
		root.add_child(grape)
	
	var stem := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 0.03
	cm.bottom_radius = 0.04
	cm.height = 0.26
	stem.mesh = cm
	stem.material_override = get_mat("stem_brown", Color(0.42, 0.24, 0.12), 0.6)
	stem.position = Vector3(0.0, 0.90, 0.0)
	root.add_child(stem)
	
	return root

# Watermelon: Thick juicy red triangular slice with green rind and seeds
static func create_watermelon() -> Node3D:
	var root := Node3D.new()
	_add_shadow(root, 0.50)
	
	var slice := MeshInstance3D.new()
	var pm := PrismMesh.new()
	pm.size = Vector3(0.88, 0.75, 0.30)
	slice.mesh = pm
	slice.material_override = get_mat("watermelon_flesh", Color(0.98, 0.14, 0.26), 0.16)
	slice.position.y = 0.40
	slice.rotation.z = PI
	root.add_child(slice)
	
	var rind := MeshInstance3D.new()
	var rm := BoxMesh.new()
	rm.size = Vector3(0.92, 0.12, 0.32)
	rind.mesh = rm
	rind.material_override = get_mat("watermelon_rind", Color(0.10, 0.62, 0.22), 0.25)
	rind.position.y = 0.76
	root.add_child(rind)
	
	return root

# Blueberry: Indigo sphere with 5-point calyx star
static func create_blueberry() -> Node3D:
	var root := Node3D.new()
	_add_shadow(root, 0.38)
	
	var body := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = 0.38
	sm.height = 0.72
	sm.radial_segments = 14
	sm.rings = 8
	body.mesh = sm
	body.material_override = get_mat("blueberry_indigo", Color(0.20, 0.35, 0.88), 0.14, 0.06)
	body.position.y = 0.38
	root.add_child(body)
	
	var crown := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 0.14
	cm.bottom_radius = 0.07
	cm.height = 0.08
	crown.mesh = cm
	crown.material_override = get_mat("blueberry_dark", Color(0.10, 0.18, 0.52), 0.35)
	crown.position = Vector3(0.0, 0.74, 0.0)
	root.add_child(crown)
	
	return root

# Cherry: Two glossy crimson spheres joined with green stems
static func create_cherry() -> Node3D:
	var root := Node3D.new()
	_add_shadow(root, 0.46)
	
	var cherry_mat := get_mat("cherry_crimson", Color(0.92, 0.04, 0.18), 0.06, 0.12)
	for x in [-0.24, 0.24]:
		var ball := MeshInstance3D.new()
		var sm := SphereMesh.new()
		sm.radius = 0.28
		sm.height = 0.54
		sm.radial_segments = 12
		sm.rings = 8
		ball.mesh = sm
		ball.material_override = cherry_mat
		ball.position = Vector3(x, 0.34, 0.0)
		root.add_child(ball)
		
		var stem := MeshInstance3D.new()
		var cm := CylinderMesh.new()
		cm.top_radius = 0.02
		cm.bottom_radius = 0.02
		cm.height = 0.55
		stem.mesh = cm
		stem.material_override = get_mat("stem_green", Color(0.42, 0.78, 0.18), 0.35)
		stem.position = Vector3(x * 0.5, 0.68, 0.0)
		stem.rotation.z = -x * 0.8
		root.add_child(stem)
	
	var leaf := MeshInstance3D.new()
	var lm := SphereMesh.new()
	lm.radius = 0.11
	lm.height = 0.24
	leaf.mesh = lm
	leaf.scale = Vector3(1.0, 0.2, 0.5)
	leaf.position = Vector3(0.08, 0.94, 0.0)
	leaf.material_override = get_mat("leaf_green", Color(0.18, 0.82, 0.22), 0.25)
	root.add_child(leaf)
	
	return root

# Broccoli / Vegetable: Cute green floret bunch (as seen in concept image)
static func create_broccoli() -> Node3D:
	var root := Node3D.new()
	_add_shadow(root, 0.44)
	
	# Stem
	var stem := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 0.16
	cm.bottom_radius = 0.20
	cm.height = 0.35
	stem.mesh = cm
	stem.material_override = get_mat("broccoli_stem", Color(0.78, 0.90, 0.58), 0.35)
	stem.position.y = 0.18
	root.add_child(stem)
	
	# Florets bunch
	var floret_mat := get_mat("broccoli_floret", Color(0.24, 0.78, 0.22), 0.30)
	var floret_mat_dark := get_mat("broccoli_floret_dark", Color(0.18, 0.65, 0.18), 0.32)
	
	var floret_positions := [
		Vector3(0.0, 0.48, 0.0),
		Vector3(-0.20, 0.38, 0.12),
		Vector3(0.20, 0.38, 0.12),
		Vector3(0.0, 0.40, -0.20),
		Vector3(0.0, 0.36, 0.22)
	]
	
	for i in range(floret_positions.size()):
		var f := MeshInstance3D.new()
		var sm := SphereMesh.new()
		sm.radius = 0.24 if i == 0 else 0.20
		sm.height = sm.radius * 1.8
		f.mesh = sm
		f.material_override = floret_mat if i % 2 == 0 else floret_mat_dark
		f.position = floret_positions[i]
		root.add_child(f)
	
	return root

# ==============================================================================
# 2. 3D SNACKS & DELICACIES
# ==============================================================================

# Swiss Cheese Wedge with Holes (as in reference image)
static func create_cheese() -> Node3D:
	var root := Node3D.new()
	_add_shadow(root, 0.46)
	
	var wedge := MeshInstance3D.new()
	var pm := PrismMesh.new()
	pm.size = Vector3(0.82, 0.36, 0.75)
	wedge.mesh = pm
	wedge.material_override = get_mat("cheese_yellow", Color(1.0, 0.78, 0.12), 0.20, 0.04)
	wedge.position.y = 0.24
	root.add_child(wedge)
	
	var hole_mat := get_mat("cheese_hole", Color(0.88, 0.60, 0.06), 0.35)
	var hole_coords := [
		Vector3(-0.18, 0.34, 0.14), Vector3(0.16, 0.34, 0.06),
		Vector3(0.0, 0.34, -0.16), Vector3(-0.12, 0.34, -0.06)
	]
	for h in hole_coords:
		var hole := MeshInstance3D.new()
		var hm := CylinderMesh.new()
		hm.top_radius = 0.07
		hm.bottom_radius = 0.07
		hm.height = 0.05
		hole.mesh = hm
		hole.material_override = hole_mat
		hole.position = h
		root.add_child(hole)
	
	return root

# Layer Cake / Pastry Slice with pink frosting & cherry (as in reference image)
static func create_cake() -> Node3D:
	var root := Node3D.new()
	_add_shadow(root, 0.48)
	
	var cake_mat := get_mat("cake_sponge", Color(0.96, 0.88, 0.72), 0.35)
	var cream_mat := get_mat("cake_cream", Color(1.0, 1.0, 0.95), 0.25)
	var icing_mat := get_mat("cake_icing", Color(0.98, 0.42, 0.68), 0.12, 0.05)
	
	# Sponge bottom
	var b_sponge := MeshInstance3D.new()
	var pm1 := PrismMesh.new()
	pm1.size = Vector3(0.74, 0.15, 0.74)
	b_sponge.mesh = pm1
	b_sponge.material_override = cake_mat
	b_sponge.position.y = 0.12
	root.add_child(b_sponge)
	
	# Cream middle
	var cream := MeshInstance3D.new()
	var pm2 := PrismMesh.new()
	pm2.size = Vector3(0.75, 0.08, 0.75)
	cream.mesh = pm2
	cream.material_override = cream_mat
	cream.position.y = 0.23
	root.add_child(cream)
	
	# Sponge top
	var t_sponge := MeshInstance3D.new()
	var pm3 := PrismMesh.new()
	pm3.size = Vector3(0.74, 0.15, 0.74)
	t_sponge.mesh = pm3
	t_sponge.material_override = cake_mat
	t_sponge.position.y = 0.34
	root.add_child(t_sponge)
	
	# Pink frosting
	var icing := MeshInstance3D.new()
	var pm4 := PrismMesh.new()
	pm4.size = Vector3(0.76, 0.06, 0.76)
	icing.mesh = pm4
	icing.material_override = icing_mat
	icing.position.y = 0.44
	root.add_child(icing)
	
	# Cherry on top
	var cherry := MeshInstance3D.new()
	var cm := SphereMesh.new()
	cm.radius = 0.13
	cm.height = 0.26
	cherry.mesh = cm
	cherry.material_override = get_mat("cherry_crimson", Color(0.92, 0.04, 0.18), 0.06, 0.12)
	cherry.position.y = 0.56
	root.add_child(cherry)
	
	return root

# Burger: Dome bun with sesame seeds, lettuce, cheese, beef patty & bottom bun
static func create_burger() -> Node3D:
	var root := Node3D.new()
	_add_shadow(root, 0.48)
	var bun_mat := get_mat("burger_bun", Color(0.88, 0.62, 0.28), 0.30)
	
	var b_bun := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 0.42
	cm.bottom_radius = 0.40
	cm.height = 0.12
	b_bun.mesh = cm
	b_bun.material_override = bun_mat
	b_bun.position.y = 0.1
	root.add_child(b_bun)
	
	var patty := MeshInstance3D.new()
	var pm := CylinderMesh.new()
	pm.top_radius = 0.44
	pm.bottom_radius = 0.44
	pm.height = 0.12
	patty.mesh = pm
	patty.material_override = get_mat("burger_patty", Color(0.36, 0.18, 0.12), 0.55)
	patty.position.y = 0.22
	root.add_child(patty)
	
	var cheese := MeshInstance3D.new()
	var chm := BoxMesh.new()
	chm.size = Vector3(0.82, 0.04, 0.82)
	cheese.mesh = chm
	cheese.material_override = get_mat("burger_cheese", Color(1.0, 0.75, 0.08), 0.20)
	cheese.position.y = 0.30
	cheese.rotation.y = 0.4
	root.add_child(cheese)
	
	var lettuce := MeshInstance3D.new()
	var lm := CylinderMesh.new()
	lm.top_radius = 0.48
	lm.bottom_radius = 0.48
	lm.height = 0.06
	lettuce.mesh = lm
	lettuce.material_override = get_mat("burger_lettuce", Color(0.24, 0.82, 0.18), 0.35)
	lettuce.position.y = 0.35
	root.add_child(lettuce)
	
	var t_bun := MeshInstance3D.new()
	var tm := SphereMesh.new()
	tm.radius = 0.44
	tm.height = 0.45
	t_bun.mesh = tm
	t_bun.material_override = bun_mat
	t_bun.position.y = 0.48
	root.add_child(t_bun)
	
	return root

# Pizza: Triangular slice with crust, cheese & pepperoni
static func create_pizza() -> Node3D:
	var root := Node3D.new()
	_add_shadow(root, 0.46)
	
	var slice := MeshInstance3D.new()
	var pm := PrismMesh.new()
	pm.size = Vector3(0.82, 0.12, 0.78)
	slice.mesh = pm
	slice.material_override = get_mat("pizza_cheese", Color(1.0, 0.82, 0.16), 0.22)
	slice.position.y = 0.2
	root.add_child(slice)
	
	var crust := MeshInstance3D.new()
	var cm := BoxMesh.new()
	cm.size = Vector3(0.85, 0.16, 0.18)
	crust.mesh = cm
	crust.material_override = get_mat("pizza_crust", Color(0.85, 0.58, 0.26), 0.45)
	crust.position = Vector3(0.0, 0.22, 0.35)
	root.add_child(crust)
	
	var pep_mat := get_mat("pizza_pepperoni", Color(0.78, 0.15, 0.12), 0.18)
	for p in [Vector3(0.0, 0.27, 0.18), Vector3(-0.16, 0.27, 0.02), Vector3(0.16, 0.27, 0.02)]:
		var pep := MeshInstance3D.new()
		var dm := CylinderMesh.new()
		dm.top_radius = 0.09
		dm.bottom_radius = 0.09
		dm.height = 0.03
		pep.mesh = dm
		pep.material_override = pep_mat
		pep.position = p
		root.add_child(pep)
	
	return root

# Donut: Golden torus with glossy pink icing & sprinkles
static func create_donut() -> Node3D:
	var root := Node3D.new()
	_add_shadow(root, 0.46)
	
	var dough := MeshInstance3D.new()
	var tm := TorusMesh.new()
	tm.inner_radius = 0.14
	tm.outer_radius = 0.44
	tm.rings = 16
	tm.ring_segments = 12
	dough.mesh = tm
	dough.material_override = get_mat("donut_dough", Color(0.88, 0.68, 0.38), 0.30)
	dough.position.y = 0.2
	root.add_child(dough)
	
	var icing := MeshInstance3D.new()
	var im := TorusMesh.new()
	im.inner_radius = 0.15
	im.outer_radius = 0.43
	im.rings = 16
	im.ring_segments = 10
	icing.mesh = im
	icing.material_override = get_mat("donut_icing", Color(0.98, 0.42, 0.68), 0.10, 0.05)
	icing.position.y = 0.25
	icing.scale = Vector3(1.0, 0.7, 1.0)
	root.add_child(icing)
	
	return root

# Cupcake: Fluted cup base with swirl frosting and cherry
static func create_cupcake() -> Node3D:
	var root := Node3D.new()
	_add_shadow(root, 0.42)
	
	var cup := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 0.40
	cm.bottom_radius = 0.28
	cm.height = 0.36
	cup.mesh = cm
	cup.material_override = get_mat("cupcake_liner", Color(0.92, 0.88, 0.82), 0.5)
	cup.position.y = 0.22
	root.add_child(cup)
	
	var swirl := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = 0.38
	sm.height = 0.52
	swirl.mesh = sm
	swirl.material_override = get_mat("cupcake_frosting", Color(0.42, 0.78, 0.95), 0.12)
	swirl.position.y = 0.52
	root.add_child(swirl)
	
	var cherry := MeshInstance3D.new()
	var chm := SphereMesh.new()
	chm.radius = 0.12
	chm.height = 0.24
	cherry.mesh = chm
	cherry.material_override = get_mat("cherry_crimson", Color(0.92, 0.04, 0.18), 0.06, 0.12)
	cherry.position.y = 0.82
	root.add_child(cherry)
	
	return root

# Candy: Sweet wrapped candy with twist ends
static func create_candy() -> Node3D:
	var root := Node3D.new()
	_add_shadow(root, 0.40)
	
	var center := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = 0.32
	sm.height = 0.58
	center.mesh = sm
	center.material_override = get_mat("candy_red", Color(0.98, 0.22, 0.52), 0.10, 0.08)
	center.position.y = 0.32
	center.rotation.z = PI / 2.0
	root.add_child(center)
	
	for side in [-0.38, 0.38]:
		var twist := MeshInstance3D.new()
		var pm := PrismMesh.new()
		pm.size = Vector3(0.24, 0.28, 0.06)
		twist.mesh = pm
		twist.material_override = get_mat("candy_wrapper", Color(1.0, 0.88, 0.94), 0.18)
		twist.position = Vector3(side, 0.32, 0.0)
		twist.rotation.z = PI / 2.0 if side > 0 else -PI / 2.0
		root.add_child(twist)
	
	return root

# Chocolate: Chocolate bar with foil wrapper
static func create_chocolate() -> Node3D:
	var root := Node3D.new()
	_add_shadow(root, 0.44)
	
	var bar := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(0.52, 0.14, 0.78)
	bar.mesh = bm
	bar.material_override = get_mat("choc_brown", Color(0.32, 0.18, 0.12), 0.22)
	bar.position.y = 0.18
	root.add_child(bar)
	
	var foil := MeshInstance3D.new()
	var fm := BoxMesh.new()
	fm.size = Vector3(0.54, 0.15, 0.42)
	foil.mesh = fm
	foil.material_override = get_mat("foil_silver", Color(0.88, 0.92, 0.96), 0.08, 0.9)
	foil.position = Vector3(0.0, 0.19, -0.2)
	root.add_child(foil)
	
	return root

# Cookie: Golden cookie with chocolate chips
static func create_cookie() -> Node3D:
	var root := Node3D.new()
	_add_shadow(root, 0.42)
	
	var disc := MeshInstance3D.new()
	var dm := CylinderMesh.new()
	dm.top_radius = 0.42
	dm.bottom_radius = 0.40
	dm.height = 0.14
	disc.mesh = dm
	disc.material_override = get_mat("cookie_dough", Color(0.85, 0.65, 0.35), 0.40)
	disc.position.y = 0.16
	root.add_child(disc)
	
	var chip_mat := get_mat("choc_brown", Color(0.32, 0.18, 0.12), 0.22)
	for c in [Vector3(-0.18, 0.24, -0.15), Vector3(0.18, 0.24, -0.12), Vector3(0.0, 0.24, 0.18), Vector3(-0.2, 0.24, 0.12)]:
		var chip := MeshInstance3D.new()
		var cm := SphereMesh.new()
		cm.radius = 0.07
		cm.height = 0.12
		chip.mesh = cm
		chip.material_override = chip_mat
		chip.position = c
		root.add_child(chip)
	
	return root

# Sandwich: Sliced triangular bread with layered filling
static func create_sandwich() -> Node3D:
	var root := Node3D.new()
	_add_shadow(root, 0.46)
	var bread_mat := get_mat("bread_toast", Color(0.88, 0.72, 0.45), 0.35)
	
	var b_bread := MeshInstance3D.new()
	var pm1 := PrismMesh.new()
	pm1.size = Vector3(0.72, 0.12, 0.72)
	b_bread.mesh = pm1
	b_bread.material_override = bread_mat
	b_bread.position.y = 0.12
	root.add_child(b_bread)
	
	var fill := MeshInstance3D.new()
	var fm := PrismMesh.new()
	fm.size = Vector3(0.74, 0.08, 0.74)
	fill.mesh = fm
	fill.material_override = get_mat("ham_pink", Color(0.95, 0.52, 0.55), 0.25)
	fill.position.y = 0.22
	root.add_child(fill)
	
	var t_bread := MeshInstance3D.new()
	var pm2 := PrismMesh.new()
	pm2.size = Vector3(0.72, 0.12, 0.72)
	t_bread.mesh = pm2
	t_bread.material_override = bread_mat
	t_bread.position.y = 0.32
	root.add_child(t_bread)
	
	return root

# ==============================================================================
# 3. 3D SPECIAL FOODS & TREASURES
# ==============================================================================

# Brilliant Faceted Cyan Diamond (as in reference image)
static func create_diamond() -> Node3D:
	var root := Node3D.new()
	_add_shadow(root, 0.44)
	
	var dia_mat := get_mat("diamond_jewel", Color(0.18, 0.92, 1.0), 0.04, 0.15, Color(0.15, 0.70, 0.95), true, 0.88)
	
	var top := MeshInstance3D.new()
	var pm1 := PrismMesh.new()
	pm1.size = Vector3(0.70, 0.42, 0.70)
	top.mesh = pm1
	top.material_override = dia_mat
	top.position.y = 0.44
	root.add_child(top)
	
	var bot := MeshInstance3D.new()
	var pm2 := PrismMesh.new()
	pm2.size = Vector3(0.70, 0.42, 0.70)
	bot.mesh = pm2
	bot.material_override = dia_mat
	bot.position.y = 0.22
	bot.rotation.z = PI
	root.add_child(bot)
	
	return root

# 3D Golden Crown (as in reference image)
static func create_crown() -> Node3D:
	var root := Node3D.new()
	_add_shadow(root, 0.46)
	
	var crown_mat := get_mat("gold_metallic", Color(1.0, 0.85, 0.15), 0.08, 0.95, Color(0.65, 0.48, 0.05))
	
	var base := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 0.38
	cm.bottom_radius = 0.36
	cm.height = 0.14
	base.mesh = cm
	base.material_override = crown_mat
	base.position.y = 0.16
	root.add_child(base)
	
	for i in range(5):
		var pt := MeshInstance3D.new()
		var pm := PrismMesh.new()
		pm.size = Vector3(0.16, 0.32, 0.06)
		pt.mesh = pm
		pt.material_override = crown_mat
		var a: float = float(i) * TAU / 5.0
		pt.position = Vector3(cos(a) * 0.36, 0.36, sin(a) * 0.36)
		pt.rotation.y = -a + PI / 2.0
		root.add_child(pt)
		
		var jewel := MeshInstance3D.new()
		var jm := SphereMesh.new()
		jm.radius = 0.045
		jm.height = 0.09
		jewel.mesh = jm
		jewel.material_override = get_mat("ruby_jewel", Color(0.96, 0.12, 0.24), 0.08, 0.2, Color(0.85, 0.1, 0.15))
		jewel.position = Vector3(cos(a) * 0.36, 0.52, sin(a) * 0.36)
		root.add_child(jewel)
	
	return root

# Golden Apple: Pure gleaming metallic gold apple
static func create_golden_apple() -> Node3D:
	var root := Node3D.new()
	_add_shadow(root, 0.45)
	
	var body := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = 0.45
	sm.height = 0.85
	sm.radial_segments = 18
	body.mesh = sm
	body.material_override = get_mat("gold_metallic", Color(1.0, 0.85, 0.15), 0.08, 0.95, Color(0.65, 0.48, 0.05))
	body.position.y = 0.45
	root.add_child(body)
	
	var stem := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 0.04
	cm.bottom_radius = 0.04
	cm.height = 0.25
	stem.mesh = cm
	stem.material_override = get_mat("stem_gold", Color(0.92, 0.75, 0.1), 0.15, 0.8)
	stem.position = Vector3(0.0, 0.88, 0.0)
	root.add_child(stem)
	
	return root

# Diamond Fruit
static func create_diamond_fruit() -> Node3D:
	return create_diamond()

# Rainbow Food: Vivid rainbow pulsing celestial orb
static func create_rainbow_food() -> Node3D:
	var root := Node3D.new()
	_add_shadow(root, 0.44)
	
	var orb := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = 0.44
	sm.height = 0.88
	sm.radial_segments = 16
	orb.mesh = sm
	orb.material_override = get_mat("rainbow_orb", Color(1.0, 0.4, 0.9), 0.08, 0.1, Color(0.85, 0.2, 0.75))
	orb.position.y = 0.46
	root.add_child(orb)
	
	var ring := MeshInstance3D.new()
	var tm := TorusMesh.new()
	tm.inner_radius = 0.54
	tm.outer_radius = 0.65
	ring.mesh = tm
	ring.material_override = get_mat("halo_gold", Color(1.0, 0.88, 0.2), 0.08, 0.8, Color(0.95, 0.72, 0.1))
	ring.position.y = 0.46
	ring.rotation.x = 0.4
	root.add_child(ring)
	
	return root

# Mystery Box: Glowing purple cube with yellow ribbon
static func create_mystery_box() -> Node3D:
	var root := Node3D.new()
	_add_shadow(root, 0.46)
	
	var box := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(0.68, 0.68, 0.68)
	box.mesh = bm
	box.material_override = get_mat("mystery_purple", Color(0.62, 0.18, 0.96), 0.20, 0.1, Color(0.4, 0.08, 0.6))
	box.position.y = 0.42
	root.add_child(box)
	
	var rib := MeshInstance3D.new()
	var rm := BoxMesh.new()
	rm.size = Vector3(0.72, 0.70, 0.18)
	rib.mesh = rm
	rib.material_override = get_mat("gold_metallic", Color(1.0, 0.85, 0.15), 0.08, 0.95, Color(0.65, 0.48, 0.05))
	rib.position.y = 0.42
	root.add_child(rib)
	
	return root

# 3D Gold Coin (as in reference image)
static func create_coin_multiplier() -> Node3D:
	var root := Node3D.new()
	_add_shadow(root, 0.46)
	
	var coin := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 0.44
	cm.bottom_radius = 0.44
	cm.height = 0.14
	cm.radial_segments = 22
	coin.mesh = cm
	coin.material_override = get_mat("gold_metallic", Color(1.0, 0.85, 0.15), 0.08, 0.95, Color(0.65, 0.48, 0.05))
	coin.position.y = 0.44
	coin.rotation.x = PI / 2.0
	root.add_child(coin)
	
	return root

# ==============================================================================
# 4. 3D POWER-UPS (MATCHING REFERENCE CONCEPT)
# ==============================================================================

# 1. Magnet: Red & blue metallic 3D horseshoe with silver tips + golden aura ring
static func create_magnet() -> Node3D:
	var root := Node3D.new()
	
	# Golden glowing aura ring on floor (as seen in concept image!)
	var aura := MeshInstance3D.new()
	var tm := TorusMesh.new()
	tm.inner_radius = 0.85
	tm.outer_radius = 1.08
	aura.mesh = tm
	aura.material_override = get_mat("magnet_aura", Color(1.0, 0.78, 0.08), 0.05, 0.1, Color(1.0, 0.65, 0.0), true, 0.88)
	aura.position.y = 0.04
	root.add_child(aura)
	
	_add_shadow(root, 0.52)
	
	var red_mat := get_mat("magnet_red", Color(0.94, 0.12, 0.14), 0.12, 0.3)
	var blue_mat := get_mat("magnet_blue", Color(0.12, 0.48, 0.98), 0.12, 0.3)
	var silver_mat := get_mat("foil_silver", Color(0.88, 0.92, 0.98), 0.06, 0.92)
	
	# Top bridge
	var top := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(0.74, 0.18, 0.18)
	top.mesh = bm
	top.material_override = red_mat
	top.position.y = 0.70
	root.add_child(top)
	
	# Left arm (Red)
	var arm_l := MeshInstance3D.new()
	var am_l := BoxMesh.new()
	am_l.size = Vector3(0.18, 0.36, 0.18)
	arm_l.mesh = am_l
	arm_l.material_override = red_mat
	arm_l.position = Vector3(-0.28, 0.50, 0.0)
	root.add_child(arm_l)
	
	# Right arm (Blue)
	var arm_r := MeshInstance3D.new()
	var am_r := BoxMesh.new()
	am_r.size = Vector3(0.18, 0.36, 0.18)
	arm_r.mesh = am_r
	arm_r.material_override = blue_mat
	arm_r.position = Vector3(0.28, 0.50, 0.0)
	root.add_child(arm_r)
	
	# Silver tips
	for x in [-0.28, 0.28]:
		var tip := MeshInstance3D.new()
		var tm_box := BoxMesh.new()
		tm_box.size = Vector3(0.19, 0.16, 0.19)
		tip.mesh = tm_box
		tip.material_override = silver_mat
		tip.position = Vector3(x, 0.23, 0.0)
		root.add_child(tip)
	
	return root

# 2. Speed Boost: Golden 3D lightning bolt + cyan aura ring
static func create_speed_bolt() -> Node3D:
	var root := Node3D.new()
	
	# Cyan glowing aura ring on floor (as in concept image!)
	var aura := MeshInstance3D.new()
	var tm := TorusMesh.new()
	tm.inner_radius = 0.85
	tm.outer_radius = 1.08
	aura.mesh = tm
	aura.material_override = get_mat("speed_aura", Color(0.0, 0.94, 1.0), 0.05, 0.1, Color(0.0, 0.85, 1.0), true, 0.88)
	aura.position.y = 0.04
	root.add_child(aura)
	
	_add_shadow(root, 0.48)
	
	var bolt_mat := get_mat("speed_gold", Color(1.0, 0.85, 0.12), 0.06, 0.4, Color(1.0, 0.78, 0.05))
	
	var top := MeshInstance3D.new()
	var pm1 := PrismMesh.new()
	pm1.size = Vector3(0.50, 0.54, 0.14)
	top.mesh = pm1
	top.material_override = bolt_mat
	top.position = Vector3(0.1, 0.64, 0.0)
	top.rotation.z = -0.3
	root.add_child(top)
	
	var bot := MeshInstance3D.new()
	var pm2 := PrismMesh.new()
	pm2.size = Vector3(0.44, 0.60, 0.14)
	bot.mesh = pm2
	bot.material_override = bolt_mat
	bot.position = Vector3(-0.08, 0.36, 0.0)
	bot.rotation.z = 0.3
	root.add_child(bot)
	
	return root

# 3. Shield: Transparent protective energy sphere
static func create_shield_orb() -> Node3D:
	var root := Node3D.new()
	_add_shadow(root, 0.52)
	
	var sphere := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = 0.54
	sm.height = 1.08
	sm.radial_segments = 20
	sphere.mesh = sm
	sphere.material_override = get_mat("shield_cyan", Color(0.12, 0.88, 1.0), 0.04, 0.1, Color(0.1, 0.7, 0.95), true, 0.70)
	sphere.position.y = 0.54
	root.add_child(sphere)
	
	return root

# 4. Rocket Boost: Futuristic red rocket
static func create_rocket() -> Node3D:
	var root := Node3D.new()
	_add_shadow(root, 0.46)
	
	var rocket_red := get_mat("rocket_red", Color(0.94, 0.15, 0.20), 0.12, 0.2)
	var rocket_white := get_mat("rocket_white", Color(0.98, 0.98, 1.0), 0.15, 0.1)
	
	var body := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 0.20
	cm.bottom_radius = 0.24
	cm.height = 0.60
	cm.radial_segments = 14
	body.mesh = cm
	body.material_override = rocket_red
	body.position.y = 0.48
	root.add_child(body)
	
	# White nose cone
	var cone := MeshInstance3D.new()
	var pm := CylinderMesh.new()
	pm.top_radius = 0.01
	pm.bottom_radius = 0.21
	pm.height = 0.36
	cone.mesh = pm
	cone.material_override = rocket_white
	cone.position.y = 0.94
	root.add_child(cone)
	
	# 3 Fins
	for i in range(3):
		var fin := MeshInstance3D.new()
		var fm := PrismMesh.new()
		fm.size = Vector3(0.25, 0.34, 0.04)
		fin.mesh = fm
		fin.material_override = rocket_white
		fin.position = Vector3(0.0, 0.28, 0.0)
		fin.rotation.y = float(i) * TAU / 3.0
		fin.position += Vector3(cos(float(i) * TAU / 3.0) * 0.25, 0.0, sin(float(i) * TAU / 3.0) * 0.25)
		root.add_child(fin)
	
	return root

# 5. Potion Bottle: Glowing emerald laboratory flask
static func create_potion() -> Node3D:
	var root := Node3D.new()
	_add_shadow(root, 0.45)
	
	var bulb := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = 0.38
	sm.height = 0.72
	bulb.mesh = sm
	bulb.material_override = get_mat("potion_green", Color(0.15, 0.95, 0.45), 0.08, 0.05, Color(0.1, 0.85, 0.35), true, 0.82)
	bulb.position.y = 0.38
	root.add_child(bulb)
	
	var neck := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 0.12
	cm.bottom_radius = 0.14
	cm.height = 0.30
	neck.mesh = cm
	neck.material_override = get_mat("glass_clear", Color(0.9, 0.96, 1.0), 0.04, 0.2, Color.BLACK, true, 0.5)
	neck.position.y = 0.78
	root.add_child(neck)
	
	var cork := MeshInstance3D.new()
	var ckm := CylinderMesh.new()
	ckm.top_radius = 0.14
	ckm.bottom_radius = 0.12
	ckm.height = 0.12
	cork.mesh = ckm
	cork.material_override = get_mat("cork_brown", Color(0.72, 0.52, 0.32), 0.6)
	cork.position.y = 0.96
	root.add_child(cork)
	
	return root

# 6. Double Speed Ring (as in concept image)
static func create_speed_ring() -> Node3D:
	var root := Node3D.new()
	var aura := MeshInstance3D.new()
	var tm := TorusMesh.new()
	tm.inner_radius = 0.64
	tm.outer_radius = 0.82
	aura.mesh = tm
	aura.material_override = get_mat("speed_ring_green", Color(0.15, 0.95, 0.35), 0.1, 0.1, Color(0.1, 0.85, 0.25), true, 0.85)
	aura.position.y = 0.04
	root.add_child(aura)
	
	_add_shadow(root, 0.50)
	
	var arr_mat := get_mat("speed_chevron", Color(0.2, 1.0, 0.4), 0.08, 0.1, Color(0.15, 0.9, 0.3))
	for y_off in [0.35, 0.56]:
		var ch := MeshInstance3D.new()
		var pm := PrismMesh.new()
		pm.size = Vector3(0.38, 0.26, 0.08)
		ch.mesh = pm
		ch.material_override = arr_mat
		ch.position.y = y_off
		root.add_child(ch)
	
	return root

# 7. Purple Lightning Orb (as in concept image)
static func create_lightning_orb() -> Node3D:
	var root := Node3D.new()
	var aura := MeshInstance3D.new()
	var tm := TorusMesh.new()
	tm.inner_radius = 0.64
	tm.outer_radius = 0.82
	aura.mesh = tm
	aura.material_override = get_mat("purple_aura", Color(0.85, 0.25, 1.0), 0.1, 0.1, Color(0.75, 0.15, 0.95), true, 0.85)
	aura.position.y = 0.04
	root.add_child(aura)
	
	_add_shadow(root, 0.50)
	
	var orb := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = 0.44
	sm.height = 0.88
	orb.mesh = sm
	orb.material_override = get_mat("purple_lightning_core", Color(0.9, 0.3, 1.0), 0.08, 0.1, Color(0.8, 0.2, 0.95))
	orb.position.y = 0.48
	root.add_child(orb)
	
	return root

# 8. Ghost Mode
static func create_ghost() -> Node3D:
	var root := Node3D.new()
	_add_shadow(root, 0.44)
	
	var head := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = 0.40
	sm.height = 0.76
	head.mesh = sm
	head.material_override = get_mat("ghost_cyan", Color(0.55, 0.92, 1.0), 0.05, 0.0, Color(0.2, 0.7, 0.9), true, 0.68)
	head.position.y = 0.48
	root.add_child(head)
	
	return root

# 9. Special Boost
static func create_special_boost() -> Node3D:
	return create_lightning_orb()

# ==============================================================================
# 5. 3D GARDEN & ARENA BOUNDARY OBJECTS
# ==============================================================================

static func create_tree(foliage_color: Color = Color(0.18, 0.68, 0.24)) -> Node3D:
	var root := Node3D.new()
	_add_shadow(root, 1.4)
	
	var trunk := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 0.35
	cm.bottom_radius = 0.5
	cm.height = 2.4
	cm.radial_segments = 8
	trunk.mesh = cm
	trunk.material_override = get_mat("tree_bark", Color(0.42, 0.26, 0.15), 0.7)
	trunk.position.y = 1.2
	root.add_child(trunk)
	
	var fol_mat := get_mat("tree_leaves_" + foliage_color.to_html(false), foliage_color, 0.4)
	var leaf1 := MeshInstance3D.new()
	var sm1 := SphereMesh.new()
	sm1.radius = 1.4
	sm1.height = 1.8
	sm1.radial_segments = 10
	leaf1.mesh = sm1
	leaf1.material_override = fol_mat
	leaf1.position.y = 2.8
	root.add_child(leaf1)
	
	var leaf2 := MeshInstance3D.new()
	var sm2 := SphereMesh.new()
	sm2.radius = 1.0
	sm2.height = 1.4
	sm2.radial_segments = 10
	leaf2.mesh = sm2
	leaf2.material_override = fol_mat
	leaf2.position.y = 3.9
	root.add_child(leaf2)
	
	return root

static func create_rock() -> Node3D:
	var root := Node3D.new()
	_add_shadow(root, 0.75)
	
	var rock := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(1.1, 0.7, 0.9)
	rock.mesh = bm
	rock.material_override = get_mat("rock_gray", Color(0.45, 0.48, 0.55), 0.65)
	rock.position.y = 0.35
	rock.rotation = Vector3(0.15, 0.4, 0.1)
	root.add_child(rock)
	
	return root

static func create_flower(petal_col: Color = Color(1.0, 0.28, 0.45)) -> Node3D:
	var root := Node3D.new()
	_add_shadow(root, 0.25)
	
	var stem := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 0.03
	cm.bottom_radius = 0.04
	cm.height = 0.45
	stem.mesh = cm
	stem.material_override = get_mat("stem_green", Color(0.24, 0.72, 0.2), 0.4)
	stem.position.y = 0.22
	root.add_child(stem)
	
	var center := MeshInstance3D.new()
	var dm := CylinderMesh.new()
	dm.top_radius = 0.10
	dm.bottom_radius = 0.10
	dm.height = 0.06
	center.mesh = dm
	center.material_override = get_mat("flower_center", Color(1.0, 0.88, 0.12), 0.2)
	center.position.y = 0.46
	root.add_child(center)
	
	var pet_mat := get_mat("petal_" + petal_col.to_html(false), petal_col, 0.3)
	for i in range(5):
		var p := MeshInstance3D.new()
		var sm := SphereMesh.new()
		sm.radius = 0.12
		sm.height = 0.22
		p.mesh = sm
		p.scale = Vector3(1.0, 0.25, 1.0)
		p.material_override = pet_mat
		var a := float(i) * TAU / 5.0
		p.position = Vector3(cos(a) * 0.16, 0.45, sin(a) * 0.16)
		root.add_child(p)
	
	return root

static func create_mushroom() -> Node3D:
	var root := Node3D.new()
	_add_shadow(root, 0.38)
	
	var stem := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 0.16
	cm.bottom_radius = 0.22
	cm.height = 0.38
	stem.mesh = cm
	stem.material_override = get_mat("shroom_stem", Color(0.92, 0.90, 0.85), 0.5)
	stem.position.y = 0.2
	root.add_child(stem)
	
	var cap := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = 0.42
	sm.height = 0.45
	cap.mesh = sm
	cap.material_override = get_mat("shroom_cap", Color(0.94, 0.14, 0.18), 0.20)
	cap.position.y = 0.46
	root.add_child(cap)
	
	return root

static func create_bush() -> Node3D:
	var root := Node3D.new()
	_add_shadow(root, 0.9)
	
	var b_mat := get_mat("bush_green", Color(0.16, 0.62, 0.22), 0.45)
	var coords := [
		Vector3(0.0, 0.48, 0.0),
		Vector3(-0.35, 0.38, 0.15), Vector3(0.35, 0.38, 0.15),
		Vector3(0.0, 0.40, -0.32)
	]
	var radii := [0.55, 0.44, 0.44, 0.42]
	for i in range(coords.size()):
		var b := MeshInstance3D.new()
		var sm := SphereMesh.new()
		sm.radius = radii[i]
		sm.height = radii[i] * 1.6
		sm.radial_segments = 10
		b.mesh = sm
		b.material_override = b_mat
		b.position = coords[i]
		root.add_child(b)
	
	return root

static func create_fence() -> Node3D:
	var root := Node3D.new()
	var wood_mat := get_mat("fence_wood", Color(0.58, 0.40, 0.24), 0.7)
	
	var post := MeshInstance3D.new()
	var cm := BoxMesh.new()
	cm.size = Vector3(0.2, 1.2, 0.2)
	post.mesh = cm
	post.material_override = wood_mat
	post.position.y = 0.6
	root.add_child(post)
	
	for y in [0.4, 0.85]:
		var rail := MeshInstance3D.new()
		var rm := BoxMesh.new()
		rm.size = Vector3(1.8, 0.12, 0.08)
		rail.mesh = rm
		rail.material_override = wood_mat
		rail.position = Vector3(0.9, y, 0.0)
		root.add_child(rail)
	
	return root
