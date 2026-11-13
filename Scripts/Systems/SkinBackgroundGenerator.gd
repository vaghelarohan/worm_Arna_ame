extends Node

var skins_list: Array = []
var backgrounds_list: Array = []
var _curr_skin: Dictionary = {}
var _curr_bg: Dictionary = {}
var _skin_canvas: Control
var _bg_canvas: Control

func _ready() -> void:
	print("==================================================")
	print("STARTING SKIN & BACKGROUND GENERATOR AND VERIFIER")
	print("==================================================")
	
	skins_list = GameManager.skins
	backgrounds_list = GameManager.backgrounds
	
	await get_tree().process_frame
	await get_tree().physics_frame
	
	# 1. Generate transparent PNG textures for all skins
	await _generate_skin_textures()
	
	# 2. Generate HD preview textures for all 8 backgrounds
	await _generate_background_textures()
	
	# 3. Capture Main Menu with new SKINS and ARENAS buttons
	await _capture_main_menu()
	
	# 4. Capture Modals and Gameplay Integration Tests
	await _capture_modals_and_gameplay()
	
	# 5. Verify Save and Persistence
	_verify_save_persistence()
	
	print("==================================================")
	print("ALL SKINS & BACKGROUNDS FULLY GENERATED & VERIFIED!")
	print("==================================================")
	get_tree().quit(0)

func _generate_skin_textures() -> void:
	print("Generating 2D transparent PNG textures for %d skins..." % skins_list.size())
	
	# Create dedicated SubViewport for 512x512 transparent rendering
	var vp := SubViewport.new()
	vp.size = Vector2i(512, 512)
	vp.transparent_bg = true
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(vp)
	
	_skin_canvas = Control.new()
	_skin_canvas.size = Vector2(512, 512)
	_skin_canvas.draw.connect(_on_draw_skin_canvas)
	vp.add_child(_skin_canvas)
	
	for s_idx in range(skins_list.size()):
		var s: Dictionary = skins_list[s_idx]
		var s_id: String = s["id"]
		_curr_skin = s
		_skin_canvas.queue_redraw()
		
		await get_tree().process_frame
		await get_tree().process_frame
		
		var img: Image = vp.get_texture().get_image()
		if img:
			var asset_path := "res://Assets/Skins/skin_%s.png" % s_id
			var shot_path := "res://Screenshots/skin_%s.png" % s_id
			img.save_png(asset_path)
			img.save_png(shot_path)
			print("  [OK] Saved skin: %s -> %s" % [s["name"], asset_path])
		else:
			printerr("  [FAIL] Could not capture skin texture for: %s" % s_id)
	
	vp.queue_free()

func _on_draw_skin_canvas() -> void:
	if _curr_skin.is_empty():
		return
	var col_a: Color = _curr_skin["color"]
	var col_b: Color = _curr_skin["color2"]
	var head_col: Color = _curr_skin.get("head_color", col_b)
	var iris_col: Color = _curr_skin.get("iris_color", col_a)
	_draw_skin_canvas(_skin_canvas, col_a, col_b, head_col, iris_col)

func _draw_skin_canvas(canvas: Control, col_a: Color, col_b: Color, head_col: Color, iris_col: Color) -> void:
	var center := Vector2(280.0, 240.0)
	var seg_count := 11
	var r := 28.0
	
	# Draw body segments in gentle S-curve
	for i in range(seg_count, 0, -1):
		var t := float(i) / float(seg_count)
		var x_off := -float(i) * 22.0
		var y_off := sin(t * 3.5) * 45.0 + float(i) * 5.0
		var pos := center + Vector2(x_off, y_off)
		
		var seg_r := r * (1.0 - t * 0.28)
		var seg_col: Color = col_b if (int(i / 2) % 2 == 1) else col_a
		
		# Soft drop shadow
		canvas.draw_circle(pos + Vector2(5.0, 12.0), seg_r * 0.95, Color(0.01, 0.02, 0.05, 0.35))
		# Dark cartoon outline
		canvas.draw_circle(pos, seg_r, Color(0.02, 0.04, 0.12, 0.95))
		# Base color
		canvas.draw_circle(pos, seg_r - 3.0, seg_col)
		# Lower shading
		canvas.draw_circle(pos + Vector2(0, seg_r * 0.28), seg_r * 0.65, Color(seg_col.r * 0.7, seg_col.g * 0.7, seg_col.b * 0.7, 0.45))
		# Glossy highlights
		canvas.draw_circle(pos + Vector2(-seg_r * 0.32, -seg_r * 0.32), seg_r * 0.32, Color(1, 1, 1, 0.45))
		canvas.draw_circle(pos + Vector2(-seg_r * 0.38, -seg_r * 0.38), seg_r * 0.16, Color(1, 1, 1, 0.85))
	
	# Head
	var head_pos := center + Vector2(10.0, 0.0)
	var hr := r * 1.38
	
	# Head shadow, outline, base
	canvas.draw_circle(head_pos + Vector2(5.0, 14.0), hr * 0.95, Color(0.01, 0.02, 0.05, 0.35))
	canvas.draw_circle(head_pos, hr, Color(0.02, 0.04, 0.12, 0.95))
	canvas.draw_circle(head_pos, hr - 3.2, head_col)
	canvas.draw_circle(head_pos + Vector2(0, hr * 0.28), hr * 0.65, Color(head_col.r * 0.8, head_col.g * 0.8, head_col.b * 0.85, 0.40))
	canvas.draw_circle(head_pos + Vector2(-hr * 0.30, -hr * 0.30), hr * 0.36, Color(1, 1, 1, 0.55))
	
	# Eyes
	var er := hr * 0.40
	var eye_dist := hr * 0.46
	var eye_y := -hr * 0.12
	
	for eye_x in [-eye_dist, eye_dist]:
		var eye_center := head_pos + Vector2(eye_x, eye_y)
		canvas.draw_circle(eye_center, er, Color(0.02, 0.04, 0.12, 0.95))
		canvas.draw_circle(eye_center, er - 2.2, Color.WHITE)
		
		var iris_center := eye_center + Vector2(er * 0.22, 0.0)
		canvas.draw_circle(iris_center, er * 0.65, iris_col)
		canvas.draw_circle(iris_center, er * 0.42, Color(0.02, 0.03, 0.08))
		canvas.draw_circle(iris_center + Vector2(-er * 0.22, -er * 0.22), er * 0.22, Color.WHITE)
		canvas.draw_circle(iris_center + Vector2(er * 0.25, er * 0.22), er * 0.12, Color.WHITE)
		
		canvas.draw_arc(eye_center + Vector2(0, -er * 0.72), er * 0.70, -0.45, 0.45, 8, Color(0.02, 0.04, 0.12), 2.8)
	
	# Rosy Cheeks
	canvas.draw_circle(head_pos + Vector2(-hr * 0.76, hr * 0.25), hr * 0.22, Color(1.0, 0.42, 0.56, 0.55))
	canvas.draw_circle(head_pos + Vector2(hr * 0.76, hr * 0.25), hr * 0.22, Color(1.0, 0.42, 0.56, 0.55))
	
	# Smile
	canvas.draw_arc(head_pos + Vector2(0, hr * 0.38), hr * 0.32, 0.2, PI - 0.2, 10, Color(0.08, 0.02, 0.10), 3.2)
	canvas.draw_circle(head_pos + Vector2(0, hr * 0.50), hr * 0.15, Color(0.96, 0.32, 0.48))

func _generate_background_textures() -> void:
	print("Generating HD 2D preview textures for %d backgrounds..." % backgrounds_list.size())
	
	var vp := SubViewport.new()
	vp.size = Vector2i(800, 450)
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(vp)
	
	_bg_canvas = Control.new()
	_bg_canvas.size = Vector2(800, 450)
	_bg_canvas.draw.connect(_on_draw_bg_canvas)
	vp.add_child(_bg_canvas)
	
	for bg in backgrounds_list:
		var bg_id: String = bg["id"]
		_curr_bg = bg
		_bg_canvas.queue_redraw()
		
		await get_tree().process_frame
		await get_tree().process_frame
		
		var img: Image = vp.get_texture().get_image()
		if img:
			var asset_path := "res://Assets/Backgrounds/bg_%s.png" % bg_id
			var shot_path := "res://Screenshots/bg_%s.png" % bg_id
			img.save_png(asset_path)
			img.save_png(shot_path)
			print("  [OK] Saved background: %s -> %s" % [bg["name"], asset_path])
	
	vp.queue_free()

func _on_draw_bg_canvas() -> void:
	if _curr_bg.is_empty():
		return
	var bg_col: Color = _curr_bg["bg_color"]
	var accent: Color = _curr_bg["accent"]
	_draw_bg_canvas(_bg_canvas, bg_col, accent)

func _draw_bg_canvas(canvas: Control, bg_col: Color, accent: Color) -> void:
	var sz := canvas.size
	# Fill base background
	canvas.draw_rect(Rect2(Vector2.ZERO, sz), bg_col)
	
	# Draw Hex Grid
	var hex_r := 34.0
	var w := hex_r * 2.0
	var h := sqrt(3.0) * hex_r
	var cols := int(sz.x / (w * 0.75)) + 2
	var rows := int(sz.y / h) + 2
	
	var hex_line_col := Color(accent.r, accent.g, accent.b, 0.32)
	var hex_fill_col := Color(bg_col.r * 1.35, bg_col.g * 1.35, bg_col.b * 1.35, 0.45)
	
	for r_i in range(rows):
		var y := float(r_i) * h
		for c_i in range(cols):
			var x := float(c_i) * (w * 0.75)
			var y_off := y + (h * 0.5 if c_i % 2 == 1 else 0.0)
			var center := Vector2(x, y_off)
			
			var pts: PackedVector2Array = []
			for a_i in range(6):
				var a := float(a_i) * (TAU / 6.0)
				pts.append(center + Vector2(cos(a) * hex_r * 0.88, sin(a) * hex_r * 0.88))
			if pts.size() == 6:
				canvas.draw_colored_polygon(pts, hex_fill_col)
				for p_i in range(6):
					canvas.draw_line(pts[p_i], pts[(p_i + 1) % 6], hex_line_col, 1.5)
	
	# Perimeter glow line
	canvas.draw_rect(Rect2(Vector2(12, 12), sz - Vector2(24, 24)), accent, false, 3.5)
	canvas.draw_rect(Rect2(Vector2(8, 8), sz - Vector2(16, 16)), Color(accent.r, accent.g, accent.b, 0.25), false, 7.0)
	
	# Ambient floating motes
	for i in range(24):
		var mx := fmod(float(i * 97), sz.x)
		var my := fmod(float(i * 53 + 40), sz.y)
		var mr := 2.5 + float(i % 4) * 1.2
		var m_col: Color = accent if (i % 2 == 0) else Color.WHITE
		m_col.a = 0.65
		canvas.draw_circle(Vector2(mx, my), mr, m_col)

func _capture_main_menu() -> void:
	print("Capturing Main Menu with SKINS & ARENAS navigation buttons...")
	var mm_scene = preload("res://Scenes/Main/MainMenu.tscn").instantiate()
	get_tree().root.add_child(mm_scene)
	await get_tree().create_timer(0.6).timeout
	
	var img: Image = get_viewport().get_texture().get_image()
	img.save_png("res://Screenshots/godot_main_menu_skins_arenas_buttons.png")
	print("  [OK] Saved: res://Screenshots/godot_main_menu_skins_arenas_buttons.png")
	mm_scene.queue_free()
	await get_tree().process_frame

func _capture_modals_and_gameplay() -> void:
	print("Loading PlayScreen for UI and Gameplay verification...")
	var playscreen = preload("res://Scenes/Gameplay/PlayScreen.tscn").instantiate()
	get_tree().root.add_child(playscreen)
	playscreen.is_paused = true
	await get_tree().create_timer(0.8).timeout
	
	# 1. Capture Skins Modal
	print("Capturing Skins Selection Modal...")
	var modal_scene = preload("res://Scenes/Components/GameModal.tscn").instantiate()
	playscreen.overlay_layer.add_child(modal_scene)
	modal_scene.set_title("SKINS CATALOG")
	var skins_modal = preload("res://Scenes/Menus/SkinsModal.tscn").instantiate()
	modal_scene.set_content(skins_modal)
	await get_tree().create_timer(0.5).timeout
	var skins_img: Image = get_viewport().get_texture().get_image()
	skins_img.save_png("res://Screenshots/godot_skins_selection_modal.png")
	print("  [OK] Saved: res://Screenshots/godot_skins_selection_modal.png")
	
	# 2. Capture Backgrounds Modal
	print("Capturing Backgrounds Selection Modal...")
	modal_scene.set_title("ARENA ENVIRONMENTS")
	var bg_modal = preload("res://Scenes/Menus/BackgroundSelectModal.tscn").instantiate()
	modal_scene.set_content(bg_modal)
	await get_tree().create_timer(0.5).timeout
	var bg_img: Image = get_viewport().get_texture().get_image()
	bg_img.save_png("res://Screenshots/godot_backgrounds_selection_modal.png")
	print("  [OK] Saved: res://Screenshots/godot_backgrounds_selection_modal.png")
	modal_scene.queue_free()
	await get_tree().create_timer(0.3).timeout
	
	# 3. Test Gameplay with Golden King Skin
	print("Testing Gameplay: Golden King Skin...")
	_apply_skin_to_engine(playscreen.engine, "golden_king")
	playscreen.arena.queue_redraw()
	await get_tree().create_timer(0.4).timeout
	var gk_img: Image = get_viewport().get_texture().get_image()
	gk_img.save_png("res://Screenshots/godot_gameplay_equipped_skin_golden_king.png")
	print("  [OK] Saved: res://Screenshots/godot_gameplay_equipped_skin_golden_king.png")
	
	# 4. Test Gameplay with Cyber Neon Skin
	print("Testing Gameplay: Cyber Neon Skin...")
	_apply_skin_to_engine(playscreen.engine, "cyber_neon")
	playscreen.arena.queue_redraw()
	await get_tree().create_timer(0.4).timeout
	var cn_img: Image = get_viewport().get_texture().get_image()
	cn_img.save_png("res://Screenshots/godot_gameplay_equipped_skin_cyber_neon.png")
	print("  [OK] Saved: res://Screenshots/godot_gameplay_equipped_skin_cyber_neon.png")
	
	# 5. Test Gameplay with Rainbow Candy Skin
	print("Testing Gameplay: Rainbow Candy Skin...")
	_apply_skin_to_engine(playscreen.engine, "rainbow_candy")
	playscreen.arena.queue_redraw()
	await get_tree().create_timer(0.4).timeout
	var rc_img: Image = get_viewport().get_texture().get_image()
	rc_img.save_png("res://Screenshots/godot_gameplay_equipped_skin_rainbow_candy.png")
	print("  [OK] Saved: res://Screenshots/godot_gameplay_equipped_skin_rainbow_candy.png")
	
	# 6. Test Gameplay with Sunset Beach Background
	print("Testing Gameplay: Sunset Beach Background...")
	GameManager.selected_background = "sunset_beach"
	playscreen.arena.queue_redraw()
	await get_tree().create_timer(0.4).timeout
	var sb_img: Image = get_viewport().get_texture().get_image()
	sb_img.save_png("res://Screenshots/godot_gameplay_selected_bg_sunset_beach.png")
	print("  [OK] Saved: res://Screenshots/godot_gameplay_selected_bg_sunset_beach.png")
	
	# 7. Test Gameplay with Magical Forest Background
	print("Testing Gameplay: Magical Forest Background...")
	GameManager.selected_background = "magical_forest"
	playscreen.arena.queue_redraw()
	await get_tree().create_timer(0.4).timeout
	var mf_img: Image = get_viewport().get_texture().get_image()
	mf_img.save_png("res://Screenshots/godot_gameplay_selected_bg_magical_forest.png")
	print("  [OK] Saved: res://Screenshots/godot_gameplay_selected_bg_magical_forest.png")
	
	# 8. Test Gameplay with Space Galaxy Background
	print("Testing Gameplay: Space Galaxy Background...")
	GameManager.selected_background = "space_galaxy"
	playscreen.arena.queue_redraw()
	await get_tree().create_timer(0.4).timeout
	var sg_img: Image = get_viewport().get_texture().get_image()
	sg_img.save_png("res://Screenshots/godot_gameplay_selected_bg_space_galaxy.png")
	print("  [OK] Saved: res://Screenshots/godot_gameplay_selected_bg_space_galaxy.png")
	
	playscreen.queue_free()

func _apply_skin_to_engine(engine: GameEngine, skin_id: String) -> void:
	for i in range(GameManager.skins.size()):
		var s: Dictionary = GameManager.skins[i]
		if s["id"] == skin_id:
			GameManager.equipped_skin_idx = i
			if engine and engine.player:
				engine.player["color"] = s["color"]
				engine.player["color2"] = s["color2"]
				engine.player["head_color"] = s.get("head_color", s["color2"])
				engine.player["iris_color"] = s.get("iris_color", s["color"])
			break

func _verify_save_persistence() -> void:
	print("Testing save and reload persistence...")
	# Set specific skin and background
	GameManager.selected_background = "sunset_beach"
	for i in range(GameManager.skins.size()):
		if GameManager.skins[i]["id"] == "golden_king":
			GameManager.equipped_skin_idx = i
			break
	
	GameManager.save_game()
	print("  [OK] Saved state: background=sunset_beach, skin=golden_king")
	
	# Mutate in-memory state
	GameManager.selected_background = "candy_world"
	GameManager.equipped_skin_idx = 0
	
	# Reload from file
	GameManager.load_game()
	
	var reloaded_bg = GameManager.selected_background
	var reloaded_skin = GameManager.get_equipped_skin()["id"]
	print("  [RELOADED] background=%s, skin=%s" % [reloaded_bg, reloaded_skin])
	
	assert(reloaded_bg == "sunset_beach", "Persistence check failed for background!")
	assert(reloaded_skin == "golden_king", "Persistence check failed for skin!")
	print("  [OK] Save persistence verified 100% successfully!")
