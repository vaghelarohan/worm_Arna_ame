extends Node

var bg_list = ["neon_blue", "candy_world", "jungle", "space_galaxy", "lava_world", "ice_kingdom"]

func _ready() -> void:
	print("STARTING COMPREHENSIVE SCREENSHOT CAPTURE...")
	var playscreen = get_parent().get_node_or_null("PlayScreen")
	if not playscreen:
		printerr("ERROR: PlayScreen not found")
		get_tree().quit(1)
		return
	
	playscreen.is_paused = true
	await get_tree().process_frame
	await get_tree().physics_frame
	await get_tree().create_timer(1.2).timeout
	
	# 1. Capture All 6 Backgrounds in Gameplay
	for bg_id in bg_list:
		GameManager.selected_background = bg_id
		playscreen.arena.queue_redraw()
		await get_tree().create_timer(0.35).timeout
		var img := get_viewport().get_texture().get_image()
		var out_path = "res://Screenshots/godot_gameplay_2d_%s.png" % bg_id
		img.save_png(out_path)
		print("SAVED: %s" % out_path)
	
	# Restore default neon_blue
	GameManager.selected_background = "neon_blue"
	playscreen.arena.queue_redraw()
	await get_tree().create_timer(0.35).timeout
	
	# 2. Save resolutions
	var base_img := get_viewport().get_texture().get_image()
	base_img.save_png("res://Screenshots/godot_gameplay_concept_match_1600x900.png")
	base_img.save_png("res://Screenshots/godot_gameplay_2d_1600x900.png")
	
	var img_1080 := Image.new()
	img_1080.copy_from(base_img)
	img_1080.resize(1920, 1080, Image.INTERPOLATE_LANCZOS)
	img_1080.save_png("res://Screenshots/godot_gameplay_1920x1080.png")
	
	var img_720 := Image.new()
	img_720.copy_from(base_img)
	img_720.resize(1280, 720, Image.INTERPOLATE_LANCZOS)
	img_720.save_png("res://Screenshots/godot_gameplay_1280x720.png")
	
	var img_20_9 := Image.new()
	img_20_9.copy_from(base_img)
	img_20_9.resize(2000, 900, Image.INTERPOLATE_LANCZOS)
	img_20_9.save_png("res://Screenshots/godot_gameplay_20_9_2000x900.png")
	
	var img_18_9 := Image.new()
	img_18_9.copy_from(base_img)
	img_18_9.resize(1800, 900, Image.INTERPOLATE_LANCZOS)
	img_18_9.save_png("res://Screenshots/godot_gameplay_18_9_1800x900.png")
	print("SAVED: Multi-resolution screenshots (1600x900, 1920x1080, 1280x720, 20:9, 18:9)")
	
	# 3. Capture Game Over Screen
	print("Capturing Game Over Screen...")
	var go_scene = preload("res://Scenes/Gameplay/GameOverScreen.tscn").instantiate()
	playscreen.overlay_layer.add_child(go_scene)
	go_scene.set_stats(1250, 4, 340, 1250)
	await get_tree().create_timer(0.4).timeout
	var go_img := get_viewport().get_texture().get_image()
	go_img.save_png("res://Screenshots/godot_gameplay_game_over.png")
	print("SAVED: res://Screenshots/godot_gameplay_game_over.png")
	go_scene.queue_free()
	
	# 4. Capture Skins Selection Modal
	print("Capturing Skins Selection Modal...")
	var modal_scene = preload("res://Scenes/Components/GameModal.tscn").instantiate()
	playscreen.overlay_layer.add_child(modal_scene)
	modal_scene.set_title("SKINS CATALOG")
	var skins_modal = preload("res://Scenes/Menus/SkinsModal.tscn").instantiate()
	modal_scene.set_content(skins_modal)
	await get_tree().create_timer(0.5).timeout
	var skins_img := get_viewport().get_texture().get_image()
	skins_img.save_png("res://Screenshots/godot_skins_selection_modal.png")
	print("SAVED: res://Screenshots/godot_skins_selection_modal.png")
	
	# 5. Capture Backgrounds Selection Modal
	print("Capturing Backgrounds Selection Modal...")
	modal_scene.set_title("ARENA ENVIRONMENTS")
	var bg_modal = preload("res://Scenes/Menus/BackgroundSelectModal.tscn").instantiate()
	modal_scene.set_content(bg_modal)
	await get_tree().create_timer(0.5).timeout
	var bg_img := get_viewport().get_texture().get_image()
	bg_img.save_png("res://Screenshots/godot_backgrounds_selection_modal.png")
	print("SAVED: res://Screenshots/godot_backgrounds_selection_modal.png")
	
	# 6. Capture Settings Audio Modal (with volume sliders and toggles)
	print("Capturing Settings Modal...")
	modal_scene.set_title("GAME SETTINGS")
	var settings_modal = preload("res://Scenes/Menus/SettingsModal.tscn").instantiate()
	modal_scene.set_content(settings_modal)
	await get_tree().create_timer(0.5).timeout
	var settings_img := get_viewport().get_texture().get_image()
	settings_img.save_png("res://Screenshots/godot_settings_audio_modal.png")
	print("SAVED: res://Screenshots/godot_settings_audio_modal.png")
	
	modal_scene.queue_free()
	await get_tree().create_timer(0.2).timeout
	
	# 7. Capture Real-time Kill Notification Bar
	print("Capturing Real-time Kill Notification Bar...")
	playscreen.hud.show_kill_notification("Shadow Viper", Color("#f43f5e"), 45)
	await get_tree().create_timer(0.35).timeout
	var kill_img := get_viewport().get_texture().get_image()
	kill_img.save_png("res://Screenshots/godot_gameplay_kill_notification.png")
	print("SAVED: res://Screenshots/godot_gameplay_kill_notification.png")
	
	# 8. Capture Boosting Worm with Sparkling Food Trail
	print("Capturing Boosting Worm & Food Trail...")
	playscreen.engine.input_boost = true
	playscreen.engine.player["boosting"] = true
	var p_head: Vector2 = playscreen.engine.player["segs"][0]
	var p_ang: float = float(playscreen.engine.player["angle"])
	var b_dir := -Vector2(cos(p_ang), sin(p_ang))
	for k in range(1, 16):
		var drop_pos = p_head + b_dir * (float(k) * 24.0) + Vector2(randf_range(-10, 10), randf_range(-10, 10))
		playscreen.engine.foods.append({
			"id": 88000 + k,
			"pos": drop_pos,
			"val": 3,
			"r": 6.5,
			"color": Color("#facc15"),
			"type": "drop",
			"ttl": 25.0
		})
	playscreen.arena.queue_redraw()
	await get_tree().create_timer(0.3).timeout
	var boost_img := get_viewport().get_texture().get_image()
	boost_img.save_png("res://Screenshots/godot_gameplay_food_trail_boost.png")
	print("SAVED: res://Screenshots/godot_gameplay_food_trail_boost.png")
	
	print("ALL SCREENSHOTS CAPTURED SUCCESSFULLY!")
	get_tree().quit(0)
