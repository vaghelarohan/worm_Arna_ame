extends Node

func _ready() -> void:
	# Let 2 frames run so the game engine initializes and pushes the initial HUD & leaderboard
	await get_tree().process_frame
	await get_tree().physics_frame
	
	var playscreen = get_parent().get_node_or_null("PlayScreen")
	if playscreen:
		# Freeze physics movement so the character remains in the showcase center pose
		playscreen.is_paused = true
	
	# Wait 1.2 seconds for 3D meshes, shadows, and shaders to settle
	await get_tree().create_timer(1.2).timeout
	
	var vp := get_viewport()
	var tex := vp.get_texture()
	if tex:
		var img := tex.get_image()
		if img:
			# 1. 1600x900 (Native Viewport matching concept)
			img.save_png("res://Screenshots/godot_gameplay_concept_match_1600x900.png")
			img.save_png("res://Screenshots/godot_gameplay_2d_1600x900.png")
			print("SUCCESS: Saved godot_gameplay_concept_match_1600x900.png")
			
			# 2. 1920x1080 (FHD mobile resolution 16:9)
			var img_1080 := Image.new()
			img_1080.copy_from(img)
			img_1080.resize(1920, 1080, Image.INTERPOLATE_LANCZOS)
			img_1080.save_png("res://Screenshots/godot_gameplay_1920x1080.png")
			print("SUCCESS: Saved godot_gameplay_1920x1080.png")
			
			# 3. 1280x720 (HD compact mobile resolution 16:9)
			var img_720 := Image.new()
			img_720.copy_from(img)
			img_720.resize(1280, 720, Image.INTERPOLATE_LANCZOS)
			img_720.save_png("res://Screenshots/godot_gameplay_1280x720.png")
			print("SUCCESS: Saved godot_gameplay_1280x720.png")
			
			# 4. 20:9 Modern Android aspect ratio (2000x900)
			var img_20_9 := Image.new()
			img_20_9.copy_from(img)
			img_20_9.resize(2000, 900, Image.INTERPOLATE_LANCZOS)
			img_20_9.save_png("res://Screenshots/godot_gameplay_20_9_2000x900.png")
			print("SUCCESS: Saved godot_gameplay_20_9_2000x900.png")
			
			# 5. 18:9 (2:1) Android aspect ratio (1800x900)
			var img_18_9 := Image.new()
			img_18_9.copy_from(img)
			img_18_9.resize(1800, 900, Image.INTERPOLATE_LANCZOS)
			img_18_9.save_png("res://Screenshots/godot_gameplay_18_9_1800x900.png")
			print("SUCCESS: Saved godot_gameplay_18_9_1800x900.png")
	
	await get_tree().create_timer(0.4).timeout
	get_tree().quit(0)
