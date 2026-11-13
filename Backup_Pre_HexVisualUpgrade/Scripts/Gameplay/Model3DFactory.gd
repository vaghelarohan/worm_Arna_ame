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
		mat.emission_energy_multiplier = 1.6
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
	shadow.material_override = get_mat("shadow_ground", Color(0.04, 0.12, 0.05), 0.9, 0.0, Color.BLACK, true, 0.42)
	shadow.position.y = 0.02
	parent.add_child(shadow)

# ==============================================================================
# 1. 3D FRUITS (8 ITEMS)
# ==============================================================================

# Apple: Glossy red spherical body with indented top, curved stem & green leaf
static func create_apple() -> Node3D:
	var root := Node3D.new()
	_add_shadow(root, 0.42)
	
	var body := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = 0.42
	sm.height = 0.78
	sm.radial_segments = 16
	sm.rings = 10
	body.mesh = sm
	body.material_override = get_mat("apple_red", Color(0.92, 0.12, 0.16), 0.15, 0.05)
	body.position.y = 0.42
	root.add_child(body)
	
	# Stem
	var stem := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 0.03
	cm.bottom_radius = 0.04
	cm.height = 0.22
	cm.radial_segments = 6
	stem.mesh = cm
	stem.material_override = get_mat("stem_brown", Color(0.42, 0.24, 0.12), 0.6)
	stem.position = Vector3(0.0, 0.82, 0.0)
	stem.rotation.z = 0.2
	root.add_child(stem)
	
	# Leaf
	var leaf := MeshInstance3D.new()
	var lm := SphereMesh.new()
	lm.radius = 0.12
	lm.height = 0.24
	leaf.mesh = lm
	leaf.scale = Vector3(1.0, 0.2, 0.6)
	leaf.rotation = Vector3(0.3, 0.0, 0.8)
	leaf.position = Vector3(0.08, 0.84, 0.0)
	leaf.material_override = get_mat("leaf_green", Color(0.18, 0.72, 0.2), 0.3)
	root.add_child(leaf)
	
	return root

# Strawberry: Tapered red berry with green crown
static func create_strawberry() -> Node3D:
	var root := Node3D.new()
	_add_shadow(root, 0.38)
	
	var body := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 0.42
	cm.bottom_radius = 0.12
	cm.height = 0.72
	cm.radial_segments = 14
	body.mesh = cm
	body.material_override = get_mat("berry_red", Color(0.95, 0.08, 0.24), 0.18, 0.02)
	body.position.y = 0.42
	root.add_child(body)
	
	# Green Calyx on top
	for i in range(5):
		var leaf := MeshInstance3D.new()
		var lm := PrismMesh.new()
		lm.size = Vector3(0.16, 0.28, 0.04)
		leaf.mesh = lm
		leaf.material_override = get_mat("leaf_green", Color(0.18, 0.72, 0.2), 0.3)
		leaf.position = Vector3(0.0, 0.78, 0.0)
		leaf.rotation = Vector3(0.8, float(i) * TAU / 5.0, 0.0)
		root.add_child(leaf)
	
	return root

# Orange: Vibrant orange sphere with dimple and leaf
static func create_orange() -> Node3D:
	var root := Node3D.new()
	_add_shadow(root, 0.44)
	
	var body := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = 0.45
	sm.height = 0.85
	sm.radial_segments = 16
	sm.rings = 10
	body.mesh = sm
	body.material_override = get_mat("orange_fruit", Color(1.0, 0.52, 0.02), 0.25, 0.0)
	body.position.y = 0.44
	root.add_child(body)
	
	# Stem nub
	var stem := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 0.04
	cm.bottom_radius = 0.04
	cm.height = 0.12
	stem.mesh = cm
	stem.material_override = get_mat("stem_brown", Color(0.42, 0.24, 0.12), 0.6)
	stem.position = Vector3(0.0, 0.86, 0.0)
	root.add_child(stem)
	
	# Leaf
	var leaf := MeshInstance3D.new()
	var lm := SphereMesh.new()
	lm.radius = 0.12
	lm.height = 0.22
	leaf.mesh = lm
	leaf.scale = Vector3(1.0, 0.2, 0.6)
	leaf.rotation = Vector3(0.2, 0.4, 0.7)
	leaf.position = Vector3(0.08, 0.88, 0.0)
	leaf.material_override = get_mat("leaf_green", Color(0.18, 0.72, 0.2), 0.3)
	root.add_child(leaf)
	
	return root

# Banana: Curved golden fruit with green stem & brown tip
static func create_banana() -> Node3D:
	var root := Node3D.new()
	_add_shadow(root, 0.46)
	
	var b_root := Node3D.new()
	b_root.position.y = 0.36
	root.add_child(b_root)
	
	var angles := [-0.35, 0.0, 0.35]
	var positions := [Vector3(-0.32, -0.06, 0.0), Vector3(0.0, 0.04, 0.0), Vector3(0.32, -0.06, 0.0)]
	for i in range(3):
		var seg := MeshInstance3D.new()
		var cm := CylinderMesh.new()
		cm.top_radius = 0.15
		cm.bottom_radius = 0.16
		cm.height = 0.38
		cm.radial_segments = 8
		seg.mesh = cm
		seg.material_override = get_mat("banana_yellow", Color(0.98, 0.86, 0.12), 0.22, 0.02)
		seg.position = positions[i]
		seg.rotation.z = angles[i] + PI / 2.0
		b_root.add_child(seg)
	
	# Green stem
	var stem := MeshInstance3D.new()
	var sm := CylinderMesh.new()
	sm.top_radius = 0.06
	sm.bottom_radius = 0.1
	sm.height = 0.18
	stem.mesh = sm
	stem.material_override = get_mat("stem_green", Color(0.42, 0.75, 0.18), 0.4)
	stem.position = Vector3(-0.52, -0.15, 0.0)
	stem.rotation.z = PI / 2.2
	b_root.add_child(stem)
	
	return root

# Grapes: Shiny purple grape cluster with stem
static func create_grapes() -> Node3D:
	var root := Node3D.new()
	_add_shadow(root, 0.42)
	
	var grape_mat := get_mat("grape_purple", Color(0.56, 0.14, 0.88), 0.12, 0.05)
	var coords := [
		Vector3(0.0, 0.72, 0.0),
		Vector3(-0.16, 0.62, 0.12), Vector3(0.16, 0.62, 0.12), Vector3(0.0, 0.62, -0.18),
		Vector3(-0.18, 0.44, -0.08), Vector3(0.18, 0.44, -0.08), Vector3(0.0, 0.44, 0.18),
		Vector3(-0.1, 0.28, 0.08), Vector3(0.1, 0.28, 0.08),
		Vector3(0.0, 0.15, 0.0)
	]
	
	for c in coords:
		var grape := MeshInstance3D.new()
		var sm := SphereMesh.new()
		sm.radius = 0.15
		sm.height = 0.3
		sm.radial_segments = 10
		sm.rings = 6
		grape.mesh = sm
		grape.material_override = grape_mat
		grape.position = c
		root.add_child(grape)
	
	# Stem
	var stem := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 0.03
	cm.bottom_radius = 0.04
	cm.height = 0.25
	stem.mesh = cm
	stem.material_override = get_mat("stem_brown", Color(0.42, 0.24, 0.12), 0.6)
	stem.position = Vector3(0.0, 0.88, 0.0)
	root.add_child(stem)
	
	return root

# Watermelon: Thick juicy red triangular slice with green rind and seeds
static func create_watermelon() -> Node3D:
	var root := Node3D.new()
	_add_shadow(root, 0.48)
	
	var slice := MeshInstance3D.new()
	var pm := PrismMesh.new()
	pm.size = Vector3(0.85, 0.72, 0.28)
	slice.mesh = pm
	slice.material_override = get_mat("watermelon_flesh", Color(0.96, 0.16, 0.28), 0.2)
	slice.position.y = 0.38
	slice.rotation.z = PI
	root.add_child(slice)
	
	# Green rind at base
	var rind := MeshInstance3D.new()
	var rm := BoxMesh.new()
	rm.size = Vector3(0.88, 0.1, 0.3)
	rind.mesh = rm
	rind.material_override = get_mat("watermelon_rind", Color(0.12, 0.58, 0.22), 0.3)
	rind.position.y = 0.72
	root.add_child(rind)
	
	return root

# Blueberry: Indigo sphere with 5-point calyx star
static func create_blueberry() -> Node3D:
	var root := Node3D.new()
	_add_shadow(root, 0.35)
	
	var body := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = 0.36
	sm.height = 0.68
	sm.radial_segments = 14
	sm.rings = 8
	body.mesh = sm
	body.material_override = get_mat("blueberry_indigo", Color(0.18, 0.32, 0.82), 0.18, 0.05)
	body.position.y = 0.36
	root.add_child(body)
	
	# Crown star
	var crown := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 0.12
	cm.bottom_radius = 0.06
	cm.height = 0.08
	crown.mesh = cm
	crown.material_override = get_mat("blueberry_dark", Color(0.1, 0.16, 0.48), 0.4)
	crown.position = Vector3(0.0, 0.7, 0.0)
	root.add_child(crown)
	
	return root

# Cherry: Two glossy crimson spheres joined with green stems
static func create_cherry() -> Node3D:
	var root := Node3D.new()
	_add_shadow(root, 0.45)
	
	var cherry_mat := get_mat("cherry_crimson", Color(0.88, 0.05, 0.18), 0.08, 0.1)
	for x in [-0.22, 0.22]:
		var ball := MeshInstance3D.new()
		var sm := SphereMesh.new()
		sm.radius = 0.26
		sm.height = 0.5
		sm.radial_segments = 12
		sm.rings = 8
		ball.mesh = sm
		ball.material_override = cherry_mat
		ball.position = Vector3(x, 0.32, 0.0)
		root.add_child(ball)
		
		# Stem
		var stem := MeshInstance3D.new()
		var cm := CylinderMesh.new()
		cm.top_radius = 0.02
		cm.bottom_radius = 0.02
		cm.height = 0.52
		stem.mesh = cm
		stem.material_override = get_mat("stem_green", Color(0.42, 0.75, 0.18), 0.4)
		stem.position = Vector3(x * 0.5, 0.64, 0.0)
		stem.rotation.z = -x * 0.8
		root.add_child(stem)
	
	# Join leaf
	var leaf := MeshInstance3D.new()
	var lm := SphereMesh.new()
	lm.radius = 0.1
	lm.height = 0.22
	leaf.mesh = lm
	leaf.scale = Vector3(1.0, 0.2, 0.5)
	leaf.position = Vector3(0.08, 0.9, 0.0)
	leaf.material_override = get_mat("leaf_green", Color(0.18, 0.72, 0.2), 0.3)
	root.add_child(leaf)
	
	return root

# ==============================================================================
# 2. 3D SNACKS (8 ITEMS)
# ==============================================================================

# Burger: Dome bun with sesame seeds, lettuce, cheese, beef patty & bottom bun
static func create_burger() -> Node3D:
	var root := Node3D.new()
	_add_shadow(root, 0.48)
	
	var bun_mat := get_mat("burger_bun", Color(0.88, 0.62, 0.28), 0.35)
	
	# Bottom bun
	var b_bun := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 0.42
	cm.bottom_radius = 0.40
	cm.height = 0.12
	b_bun.mesh = cm
	b_bun.material_override = bun_mat
	b_bun.position.y = 0.1
	root.add_child(b_bun)
	
	# Patty
	var patty := MeshInstance3D.new()
	var pm := CylinderMesh.new()
	pm.top_radius = 0.44
	pm.bottom_radius = 0.44
	pm.height = 0.12
	patty.mesh = pm
	patty.material_override = get_mat("burger_patty", Color(0.36, 0.18, 0.12), 0.6)
	patty.position.y = 0.22
	root.add_child(patty)
	
	# Cheese
	var cheese := MeshInstance3D.new()
	var chm := BoxMesh.new()
	chm.size = Vector3(0.82, 0.04, 0.82)
	cheese.mesh = chm
	cheese.material_override = get_mat("burger_cheese", Color(1.0, 0.75, 0.08), 0.25)
	cheese.position.y = 0.30
	cheese.rotation.y = 0.4
	root.add_child(cheese)
	
	# Lettuce
	var lettuce := MeshInstance3D.new()
	var lm := CylinderMesh.new()
	lm.top_radius = 0.48
	lm.bottom_radius = 0.48
	lm.height = 0.06
	lettuce.mesh = lm
	lettuce.material_override = get_mat("burger_lettuce", Color(0.24, 0.78, 0.18), 0.4)
	lettuce.position.y = 0.35
	root.add_child(lettuce)
	
	# Top bun dome
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
	
	# Slice body
	var slice := MeshInstance3D.new()
	var pm := PrismMesh.new()
	pm.size = Vector3(0.82, 0.12, 0.78)
	slice.mesh = pm
	slice.material_override = get_mat("pizza_cheese", Color(1.0, 0.82, 0.16), 0.28)
	slice.position.y = 0.2
	root.add_child(slice)
	
	# Crust
	var crust := MeshInstance3D.new()
	var cm := BoxMesh.new()
	cm.size = Vector3(0.85, 0.16, 0.18)
	crust.mesh = cm
	crust.material_override = get_mat("pizza_crust", Color(0.85, 0.58, 0.26), 0.5)
	crust.position = Vector3(0.0, 0.22, 0.35)
	root.add_child(crust)
	
	# Pepperoni discs
	var pep_mat := get_mat("pizza_pepperoni", Color(0.78, 0.15, 0.12), 0.2)
	var p_pos := [Vector3(0.0, 0.27, 0.18), Vector3(-0.16, 0.27, 0.02), Vector3(0.16, 0.27, 0.02)]
	for p in p_pos:
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
	dough.material_override = get_mat("donut_dough", Color(0.88, 0.68, 0.38), 0.35)
	dough.position.y = 0.2
	root.add_child(dough)
	
	# Pink frosting
	var icing := MeshInstance3D.new()
	var im := TorusMesh.new()
	im.inner_radius = 0.15
	im.outer_radius = 0.43
	im.rings = 16
	im.ring_segments = 10
	icing.mesh = im
	icing.material_override = get_mat("donut_icing", Color(0.98, 0.42, 0.68), 0.12, 0.05)
	icing.position.y = 0.25
	icing.scale = Vector3(1.0, 0.7, 1.0)
	root.add_child(icing)
	
	return root

# Cupcake: Fluted cup base with swirl frosting and cherry
static func create_cupcake() -> Node3D:
	var root := Node3D.new()
	_add_shadow(root, 0.42)
	
	# Cup
	var cup := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 0.40
	cm.bottom_radius = 0.28
	cm.height = 0.36
	cup.mesh = cm
	cup.material_override = get_mat("cupcake_liner", Color(0.92, 0.88, 0.82), 0.6)
	cup.position.y = 0.22
	root.add_child(cup)
	
	# Swirl frosting
	var swirl := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = 0.38
	sm.height = 0.52
	swirl.mesh = sm
	swirl.material_override = get_mat("cupcake_frosting", Color(0.42, 0.78, 0.95), 0.15)
	swirl.position.y = 0.52
	root.add_child(swirl)
	
	# Cherry
	var cherry := MeshInstance3D.new()
	var chm := SphereMesh.new()
	chm.radius = 0.12
	chm.height = 0.24
	cherry.mesh = chm
	cherry.material_override = get_mat("cherry_crimson", Color(0.88, 0.05, 0.18), 0.08, 0.1)
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
	center.material_override = get_mat("candy_red", Color(0.96, 0.22, 0.48), 0.12, 0.1)
	center.position.y = 0.32
	center.rotation.z = PI / 2.0
	root.add_child(center)
	
	for side in [-0.38, 0.38]:
		var twist := MeshInstance3D.new()
		var pm := PrismMesh.new()
		pm.size = Vector3(0.24, 0.28, 0.06)
		twist.mesh = pm
		twist.material_override = get_mat("candy_wrapper", Color(1.0, 0.88, 0.92), 0.2)
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
	bar.material_override = get_mat("choc_brown", Color(0.32, 0.18, 0.12), 0.25)
	bar.position.y = 0.18
	root.add_child(bar)
	
	# Silver foil wrapper
	var foil := MeshInstance3D.new()
	var fm := BoxMesh.new()
	fm.size = Vector3(0.54, 0.15, 0.42)
	foil.mesh = fm
	foil.material_override = get_mat("foil_silver", Color(0.85, 0.88, 0.92), 0.1, 0.85)
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
	disc.material_override = get_mat("cookie_dough", Color(0.85, 0.65, 0.35), 0.45)
	disc.position.y = 0.16
	root.add_child(disc)
	
	# Chips
	var chip_mat := get_mat("choc_brown", Color(0.32, 0.18, 0.12), 0.25)
	var c_coords := [
		Vector3(-0.18, 0.24, -0.15), Vector3(0.18, 0.24, -0.12),
		Vector3(0.0, 0.24, 0.18), Vector3(-0.2, 0.24, 0.12), Vector3(0.2, 0.24, 0.14)
	]
	for c in c_coords:
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
	
	var bread_mat := get_mat("bread_toast", Color(0.88, 0.72, 0.45), 0.4)
	
	# Bottom slice
	var b_bread := MeshInstance3D.new()
	var pm1 := PrismMesh.new()
	pm1.size = Vector3(0.72, 0.12, 0.72)
	b_bread.mesh = pm1
	b_bread.material_override = bread_mat
	b_bread.position.y = 0.12
	root.add_child(b_bread)
	
	# Ham & cheese filling
	var fill := MeshInstance3D.new()
	var fm := PrismMesh.new()
	fm.size = Vector3(0.74, 0.08, 0.74)
	fill.mesh = fm
	fill.material_override = get_mat("ham_pink", Color(0.95, 0.52, 0.55), 0.3)
	fill.position.y = 0.22
	root.add_child(fill)
	
	# Top slice
	var t_bread := MeshInstance3D.new()
	var pm2 := PrismMesh.new()
	pm2.size = Vector3(0.72, 0.12, 0.72)
	t_bread.mesh = pm2
	t_bread.material_override = bread_mat
	t_bread.position.y = 0.32
	root.add_child(t_bread)
	
	return root

# ==============================================================================
# 3. 3D SPECIAL FOODS (4 ITEMS)
# ==============================================================================

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
	body.material_override = get_mat("gold_metallic", Color(1.0, 0.85, 0.15), 0.12, 0.95, Color(0.6, 0.45, 0.05))
	body.position.y = 0.45
	root.add_child(body)
	
	var stem := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 0.04
	cm.bottom_radius = 0.04
	cm.height = 0.25
	stem.mesh = cm
	stem.material_override = get_mat("stem_gold", Color(0.92, 0.75, 0.1), 0.2, 0.8)
	stem.position = Vector3(0.0, 0.88, 0.0)
	root.add_child(stem)
	
	return root

# Diamond Fruit: Multifaceted luminous cyan crystal fruit
static func create_diamond_fruit() -> Node3D:
	var root := Node3D.new()
	_add_shadow(root, 0.42)
	
	var crystal := MeshInstance3D.new()
	var pm := PrismMesh.new()
	pm.size = Vector3(0.7, 0.85, 0.7)
	crystal.mesh = pm
	crystal.material_override = get_mat("diamond_cyan", Color(0.2, 0.9, 1.0), 0.05, 0.2, Color(0.15, 0.65, 0.95), true, 0.88)
	crystal.position.y = 0.45
	root.add_child(crystal)
	
	return root

# Rainbow Food: Vivid rainbow pulsing celestial orb
static func create_rainbow_food() -> Node3D:
	var root := Node3D.new()
	_add_shadow(root, 0.42)
	
	var orb := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = 0.42
	sm.height = 0.84
	sm.radial_segments = 16
	orb.mesh = sm
	orb.material_override = get_mat("rainbow_orb", Color(1.0, 0.4, 0.9), 0.08, 0.1, Color(0.8, 0.2, 0.7))
	orb.position.y = 0.44
	root.add_child(orb)
	
	# Orbiting halo ring
	var ring := MeshInstance3D.new()
	var tm := TorusMesh.new()
	tm.inner_radius = 0.52
	tm.outer_radius = 0.62
	ring.mesh = tm
	ring.material_override = get_mat("halo_gold", Color(1.0, 0.88, 0.2), 0.1, 0.8, Color(0.9, 0.7, 0.1))
	ring.position.y = 0.44
	ring.rotation.x = 0.4
	root.add_child(ring)
	
	return root

# Mystery Box: Glowing purple cube with yellow ribbon & golden question mark
static func create_mystery_box() -> Node3D:
	var root := Node3D.new()
	_add_shadow(root, 0.46)
	
	var box := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(0.68, 0.68, 0.68)
	box.mesh = bm
	box.material_override = get_mat("mystery_purple", Color(0.58, 0.18, 0.92), 0.25, 0.1, Color(0.3, 0.08, 0.5))
	box.position.y = 0.42
	root.add_child(box)
	
	# Ribbon
	var rib := MeshInstance3D.new()
	var rm := BoxMesh.new()
	rm.size = Vector3(0.72, 0.70, 0.18)
	rib.mesh = rm
	rib.material_override = get_mat("gold_metallic", Color(1.0, 0.85, 0.15), 0.12, 0.95, Color(0.6, 0.45, 0.05))
	rib.position.y = 0.42
	root.add_child(rib)
	
	return root

# ==============================================================================
# 4. 3D POWER-UPS (8 ITEMS)
# ==============================================================================

# 1. Magnet: Red metallic horseshoe with silver tips
static func create_magnet() -> Node3D:
	var root := Node3D.new()
	_add_shadow(root, 0.48)
	
	var red_mat := get_mat("magnet_red", Color(0.92, 0.12, 0.14), 0.15, 0.3)
	var silver_mat := get_mat("foil_silver", Color(0.85, 0.88, 0.92), 0.1, 0.85)
	
	# Top bar
	var top := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(0.72, 0.18, 0.18)
	top.mesh = bm
	top.material_override = red_mat
	top.position.y = 0.68
	root.add_child(top)
	
	# Two arms
	for x in [-0.27, 0.27]:
		var arm := MeshInstance3D.new()
		var am := BoxMesh.new()
		am.size = Vector3(0.18, 0.42, 0.18)
		arm.mesh = am
		arm.material_override = red_mat
		arm.position = Vector3(x, 0.48, 0.0)
		root.add_child(arm)
		
		# Silver tips
		var tip := MeshInstance3D.new()
		var tm := BoxMesh.new()
		tm.size = Vector3(0.19, 0.16, 0.19)
		tip.mesh = tm
		tip.material_override = silver_mat
		tip.position = Vector3(x, 0.22, 0.0)
		root.add_child(tip)
	
	return root

# 2. Speed Boost: Glowing electric 3D lightning bolt
static func create_speed_bolt() -> Node3D:
	var root := Node3D.new()
	_add_shadow(root, 0.44)
	
	var bolt_mat := get_mat("speed_yellow", Color(1.0, 0.9, 0.15), 0.08, 0.1, Color(1.0, 0.8, 0.1))
	
	var top := MeshInstance3D.new()
	var pm1 := PrismMesh.new()
	pm1.size = Vector3(0.48, 0.52, 0.14)
	top.mesh = pm1
	top.material_override = bolt_mat
	top.position = Vector3(0.1, 0.62, 0.0)
	top.rotation.z = -0.3
	root.add_child(top)
	
	var bot := MeshInstance3D.new()
	var pm2 := PrismMesh.new()
	pm2.size = Vector3(0.42, 0.58, 0.14)
	bot.mesh = pm2
	bot.material_override = bolt_mat
	bot.position = Vector3(-0.08, 0.35, 0.0)
	bot.rotation.z = 0.3
	root.add_child(bot)
	
	return root

# 3. Shield: Transparent protective energy sphere
static func create_shield_orb() -> Node3D:
	var root := Node3D.new()
	_add_shadow(root, 0.50)
	
	var sphere := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = 0.52
	sm.height = 1.04
	sm.radial_segments = 18
	sphere.mesh = sm
	sphere.material_override = get_mat("shield_cyan", Color(0.15, 0.85, 0.95), 0.05, 0.1, Color(0.1, 0.6, 0.8), true, 0.65)
	sphere.position.y = 0.52
	root.add_child(sphere)
	
	return root

# 4. Rocket Boost: Miniature 3D rocket with fins and thruster flame
static func create_rocket() -> Node3D:
	var root := Node3D.new()
	_add_shadow(root, 0.44)
	
	# Body
	var body := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 0.18
	cm.bottom_radius = 0.22
	cm.height = 0.58
	cm.radial_segments = 12
	body.mesh = cm
	body.material_override = get_mat("rocket_white", Color(0.96, 0.96, 0.98), 0.2, 0.1)
	body.position.y = 0.46
	root.add_child(body)
	
	# Red nose cone
	var cone := MeshInstance3D.new()
	var pm := CylinderMesh.new()
	pm.top_radius = 0.01
	pm.bottom_radius = 0.19
	pm.height = 0.34
	cone.mesh = pm
	cone.material_override = get_mat("rocket_red", Color(0.92, 0.12, 0.15), 0.15)
	cone.position.y = 0.9
	root.add_child(cone)
	
	# 3 Fins
	var fin_mat := get_mat("rocket_red", Color(0.92, 0.12, 0.15), 0.15)
	for i in range(3):
		var fin := MeshInstance3D.new()
		var fm := PrismMesh.new()
		fm.size = Vector3(0.24, 0.32, 0.04)
		fin.mesh = fm
		fin.material_override = fin_mat
		fin.position = Vector3(0.0, 0.26, 0.0)
		fin.rotation.y = float(i) * TAU / 3.0
		fin.position += Vector3(cos(float(i) * TAU / 3.0) * 0.24, 0.0, sin(float(i) * TAU / 3.0) * 0.24)
		root.add_child(fin)
	
	return root

# 5. Potion Bottle: Glass laboratory flask with bubbling emerald elixir
static func create_potion() -> Node3D:
	var root := Node3D.new()
	_add_shadow(root, 0.44)
	
	# Bulb
	var bulb := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = 0.36
	sm.height = 0.68
	bulb.mesh = sm
	bulb.material_override = get_mat("potion_green", Color(0.12, 0.92, 0.42), 0.1, 0.05, Color(0.08, 0.75, 0.32), true, 0.78)
	bulb.position.y = 0.36
	root.add_child(bulb)
	
	# Neck
	var neck := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 0.12
	cm.bottom_radius = 0.14
	cm.height = 0.28
	neck.mesh = cm
	neck.material_override = get_mat("glass_clear", Color(0.9, 0.95, 1.0), 0.05, 0.2, Color.BLACK, true, 0.45)
	neck.position.y = 0.76
	root.add_child(neck)
	
	# Cork
	var cork := MeshInstance3D.new()
	var ckm := CylinderMesh.new()
	ckm.top_radius = 0.14
	ckm.bottom_radius = 0.12
	ckm.height = 0.12
	cork.mesh = ckm
	cork.material_override = get_mat("cork_brown", Color(0.72, 0.52, 0.32), 0.6)
	cork.position.y = 0.94
	root.add_child(cork)
	
	return root

# 6. Coin Multiplier (2X): Thick spinning golden coin
static func create_coin_multiplier() -> Node3D:
	var root := Node3D.new()
	_add_shadow(root, 0.46)
	
	var coin := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 0.44
	cm.bottom_radius = 0.44
	cm.height = 0.14
	cm.radial_segments = 20
	coin.mesh = cm
	coin.material_override = get_mat("gold_metallic", Color(1.0, 0.85, 0.15), 0.12, 0.95, Color(0.6, 0.45, 0.05))
	coin.position.y = 0.44
	coin.rotation.x = PI / 2.0
	root.add_child(coin)
	
	return root

# 7. Ghost Mode: Translucent energy specter
static func create_ghost() -> Node3D:
	var root := Node3D.new()
	_add_shadow(root, 0.42)
	
	var head := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = 0.38
	sm.height = 0.72
	head.mesh = sm
	head.material_override = get_mat("ghost_cyan", Color(0.55, 0.92, 1.0), 0.05, 0.0, Color(0.2, 0.7, 0.9), true, 0.65)
	head.position.y = 0.46
	root.add_child(head)
	
	# Ghost eyes
	var eye_mat := get_mat("ghost_eyes", Color(0.04, 0.08, 0.22), 0.2)
	for x in [-0.14, 0.14]:
		var eye := MeshInstance3D.new()
		var em := SphereMesh.new()
		em.radius = 0.08
		em.height = 0.14
		eye.mesh = em
		eye.material_override = eye_mat
		eye.position = Vector3(x, 0.52, 0.32)
		root.add_child(eye)
	
	return root

# 8. Special Boost: Rainbow star energy orb
static func create_special_boost() -> Node3D:
	var root := Node3D.new()
	_add_shadow(root, 0.48)
	
	var core := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = 0.44
	sm.height = 0.88
	core.mesh = sm
	core.material_override = get_mat("rainbow_orb", Color(1.0, 0.4, 0.9), 0.08, 0.1, Color(0.8, 0.2, 0.7))
	core.position.y = 0.48
	root.add_child(core)
	
	# 2 Gyro rings
	var r1 := MeshInstance3D.new()
	var tm := TorusMesh.new()
	tm.inner_radius = 0.56
	tm.outer_radius = 0.64
	r1.mesh = tm
	r1.material_override = get_mat("halo_gold", Color(1.0, 0.88, 0.2), 0.1, 0.8, Color(0.9, 0.7, 0.1))
	r1.position.y = 0.48
	r1.rotation.x = 0.6
	root.add_child(r1)
	
	return root

# ==============================================================================
# 5. 3D GARDEN ENVIRONMENT OBJECTS
# ==============================================================================

# Stylized Tree: Brown trunk + 2 conical/spherical foliage canopies
static func create_tree(foliage_color: Color = Color(0.18, 0.68, 0.24)) -> Node3D:
	var root := Node3D.new()
	_add_shadow(root, 1.4)
	
	# Trunk
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
	
	# Leaves bottom tier
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
	
	# Leaves top tier
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

# Stylized Rock: Low poly beveled stone
static func create_rock() -> Node3D:
	var root := Node3D.new()
	_add_shadow(root, 0.75)
	
	var rock := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(1.1, 0.7, 0.9)
	rock.mesh = bm
	rock.material_override = get_mat("rock_gray", Color(0.52, 0.55, 0.6), 0.65)
	rock.position.y = 0.35
	rock.rotation = Vector3(0.15, 0.4, 0.1)
	root.add_child(rock)
	
	return root

# Flower: Stem + 5 colorful petals + yellow center
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
	
	# Center yellow disc
	var center := MeshInstance3D.new()
	var dm := CylinderMesh.new()
	dm.top_radius = 0.10
	dm.bottom_radius = 0.10
	dm.height = 0.06
	center.mesh = dm
	center.material_override = get_mat("flower_center", Color(1.0, 0.88, 0.12), 0.2)
	center.position.y = 0.46
	root.add_child(center)
	
	# 5 Petals
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

# Mushroom: White stem + red polka-dot cap
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
	
	# Cap
	var cap := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = 0.42
	sm.height = 0.45
	cap.mesh = sm
	cap.material_override = get_mat("shroom_cap", Color(0.92, 0.12, 0.15), 0.25)
	cap.position.y = 0.46
	root.add_child(cap)
	
	return root

# Bush: Fluffy sphere clusters
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

# Wooden Fence: Post + horizontal bars
static func create_fence() -> Node3D:
	var root := Node3D.new()
	var wood_mat := get_mat("fence_wood", Color(0.58, 0.40, 0.24), 0.7)
	
	# Post
	var post := MeshInstance3D.new()
	var cm := BoxMesh.new()
	cm.size = Vector3(0.2, 1.2, 0.2)
	post.mesh = cm
	post.material_override = wood_mat
	post.position.y = 0.6
	root.add_child(post)
	
	# 2 rails
	for y in [0.4, 0.85]:
		var rail := MeshInstance3D.new()
		var rm := BoxMesh.new()
		rm.size = Vector3(1.8, 0.12, 0.08)
		rail.mesh = rm
		rail.material_override = wood_mat
		rail.position = Vector3(0.9, y, 0.0)
		root.add_child(rail)
	
	return root

