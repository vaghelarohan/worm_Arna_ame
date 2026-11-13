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
			img.save_png("res://Screenshots/godot_gameplay_3d.png")
			print("SUCCESS: Saved godot_gameplay_concept_match_1600x900.png & godot_gameplay_3d.png")
			
			# 2. 1920x1080 (FHD mobile resolution)
			var img_1080 := Image.new()
			img_1080.copy_from(img)
			img_1080.resize(1920, 1080, Image.INTERPOLATE_LANCZOS)
			img_1080.save_png("res://Screenshots/godot_gameplay_1920x1080.png")
			print("SUCCESS: Saved godot_gameplay_1920x1080.png")
			
			# 3. 1280x720 (HD compact mobile resolution)
			var img_720 := Image.new()
			img_720.copy_from(img)
			img_720.resize(1280, 720, Image.INTERPOLATE_LANCZOS)
			img_720.save_png("res://Screenshots/godot_gameplay_1280x720.png")
			print("SUCCESS: Saved godot_gameplay_1280x720.png")
	
	await get_tree().create_timer(0.4).timeout
	get_tree().quit(0)
