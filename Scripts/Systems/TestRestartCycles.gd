extends Node

func _ready() -> void:
	print("==================================================")
	print("STARTING 5-CYCLE RESTART VALIDATION TEST...")
	print("==================================================")
	
	# Wait for scene tree to initialize
	await get_tree().process_frame
	await get_tree().physics_frame
	
	var playscreen = get_parent().get_node_or_null("PlayScreen")
	if not playscreen:
		printerr("TEST FAILED: PlayScreen not found!")
		get_tree().quit(1)
		return
	
	var engine: GameEngine = playscreen.engine
	if not engine:
		printerr("TEST FAILED: GameEngine is null!")
		get_tree().quit(1)
		return
	
	for cycle in range(1, 6):
		print("\n--- [CYCLE %d / 5] ---" % cycle)
		
		# 1. Assert game is initially running
		assert(not engine.over, "Cycle %d: Game should be running initially" % cycle)
		assert(engine.player["alive"], "Cycle %d: Player should be alive" % cycle)
		
		# Let the engine run a few frames
		for frame in range(15):
			await get_tree().physics_frame
		
		print("Cycle %d: Simulating player death..." % cycle)
		# 2. Kill player worm
		engine._kill_worm(engine.player)
		assert(engine.over, "Cycle %d: engine.over must be true after death" % cycle)
		assert(not engine.player["alive"], "Cycle %d: player alive must be false after death" % cycle)
		
		# Wait for PlayScreen to process the death frame and trigger game over
		await get_tree().physics_frame
		assert(playscreen.has_recorded_over, "Cycle %d: playscreen has_recorded_over must be true" % cycle)
		
		# Wait for GameOver modal animation timeout (0.7s)
		print("Cycle %d: Waiting for GameOverModal instantiation..." % cycle)
		await get_tree().create_timer(0.85).timeout
		
		# Verify GameOver modal exists in overlay_layer
		var overlay_count = playscreen.overlay_layer.get_child_count()
		print("Cycle %d: Overlay children count: %d" % [cycle, overlay_count])
		assert(overlay_count >= 1, "Cycle %d: GameOverModal must be present in overlay_layer" % cycle)
		
		# 3. Simulate clicking "PLAY AGAIN"
		print("Cycle %d: Triggering 'PLAY AGAIN' (_restart_game())..." % cycle)
		playscreen._restart_game()
		
		# Wait 2 physics frames for restart to take effect
		await get_tree().physics_frame
		await get_tree().physics_frame
		
		# 4. Strict assertions after restart
		print("Cycle %d: Verifying restart state..." % cycle)
		assert(not engine.over, "CRITICAL: Cycle %d: engine.over MUST BE FALSE after restart!" % cycle)
		assert(not playscreen.has_recorded_over, "CRITICAL: Cycle %d: has_recorded_over MUST BE FALSE after restart!" % cycle)
		assert(playscreen.overlay_layer.get_child_count() == 0, "CRITICAL: Cycle %d: Overlay layer MUST BE EMPTY after restart!" % cycle)
		assert(engine.player["alive"], "Cycle %d: Player must be alive after restart!" % cycle)
		assert(engine.time >= 0.0 and engine.time < 0.5, "Cycle %d: Game time must reset back to start (got %f)!" % [cycle, engine.time])
		assert(engine.kills == 0, "Cycle %d: Match kills must reset to 0!" % cycle)
		assert(engine.coins_earned == 0, "Cycle %d: Match coins earned must reset to 0!" % cycle)
		assert(engine.shake == 0.0, "Cycle %d: Screen shake must reset to 0!" % cycle)
		
		# Verify gameplay advances for 20 frames without re-triggering Game Over
		for frame in range(20):
			await get_tree().physics_frame
			assert(not engine.over, "Cycle %d frame %d: Game should remain running and NOT re-trigger game over!" % [cycle, frame])
			assert(not playscreen.has_recorded_over, "Cycle %d frame %d: has_recorded_over must remain false while playing!" % [cycle, frame])
			assert(playscreen.overlay_layer.get_child_count() == 0, "Cycle %d frame %d: No ghost modals should appear!" % [cycle, frame])
		
		print("✓ Cycle %d PASSED cleanly!" % cycle)
	
	print("\n==================================================")
	print("ALL 5 RESTART CYCLES PASSED WITH 100% SUCCESS!")
	print("Critical Game Over -> Play Again bug is COMPLETELY RESOLVED.")
	print("==================================================")
	
	get_tree().quit(0)
