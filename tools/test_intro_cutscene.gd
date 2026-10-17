extends SceneTree

func _init() -> void:
	process_frame.connect(_run, CONNECT_ONE_SHOT)

func _run() -> void:
	print("==================================================")
	print("   TESTING INTRO CUTSCENE (GIOI THIEU 13 DOAN)   ")
	print("==================================================")

	var main_scene = load("res://scenes/main.tscn").instantiate()
	root.add_child(main_scene)
	await process_frame

	var intro: CanvasLayer = main_scene.intro_cutscene
	assert(intro != null, "IntroCutscene must exist in main scene")
	assert(intro.visible == false, "IntroCutscene should initially be hidden")
	assert(intro.is_playing() == false, "IntroCutscene should not be playing initially")
	print("✓ 1. IntroCutscene initialized cleanly under Main scene")

	# -------------------------------------------------------------------------
	# 2. Test Starting Intro
	# -------------------------------------------------------------------------
	print("\n--- 2. Testing Starting Intro ---")
	var finished_called: Array = [false]
	intro.start_intro(func():
		finished_called[0] = true
	)

	assert(intro.visible == true, "IntroCutscene should become visible")
	assert(intro.is_playing() == true, "IntroCutscene should be playing")
	assert(intro.get_current_segment() == 1, "Should start at Doan 1")
	print("✓ 2. Intro started at Doan 1 with 5s countdown bar")

	# -------------------------------------------------------------------------
	# 3. Test Direct Click to Advance (Qua đoạn mới không phải đợi 5s)
	# -------------------------------------------------------------------------
	print("\n--- 3. Testing Direct Click to Advance Immediately ---")
	intro.next_segment()
	assert(intro.get_current_segment() == 2, "Should advance to Doan 2 on click")

	intro.next_segment()
	assert(intro.get_current_segment() == 3, "Should advance to Doan 3 on click")
	print("✓ 3. Direct click advances immediately to next segment without waiting")

	# -------------------------------------------------------------------------
	# 4. Test Auto-advance Timer (5s per segment)
	# -------------------------------------------------------------------------
	print("\n--- 4. Testing 5-Second Timer Auto-Advance ---")
	var prev_seg: int = intro.get_current_segment()
	# Simulating 4.5s elapsed: should NOT advance yet
	intro._process(4.5)
	assert(intro.get_current_segment() == prev_seg, "Should not advance before 5.0s")

	# Simulating another 0.6s elapsed (total 5.1s): should advance to next segment
	intro._process(0.6)
	assert(intro.get_current_segment() == prev_seg + 1, "Should advance after 5.0s elapsed")
	print("✓ 4. Auto-advance triggered precisely at 5.0 seconds")

	# -------------------------------------------------------------------------
	# 5. Advance all the way through Doan 13 -> Enters Game
	# -------------------------------------------------------------------------
	print("\n--- 5. Testing Completion of All 13 Segments ---")
	while intro.get_current_segment() < 13:
		intro.next_segment()
	assert(intro.get_current_segment() == 13, "Should reach final Doan 13")
	assert(intro.is_playing() == true, "Should still be playing at Doan 13")

	# Final advance from Doan 13 completes the intro
	intro.next_segment()
	assert(intro.is_playing() == false, "Intro should end after segment 13")
	assert(intro.visible == false, "Intro should be hidden after finishing")
	assert(finished_called[0] == true, "Finish callback must be triggered")
	print("✓ 5. Reached Doan 13 and successfully completed intro cutscene")

	# -------------------------------------------------------------------------
	# 6. Test Skip Button ("Nút ship" / Bỏ qua)
	# -------------------------------------------------------------------------
	print("\n--- 6. Testing Skip Button ('Nút ship') ---")
	var skip_called: Array = [false]
	intro.start_intro(func():
		skip_called[0] = true
	)
	assert(intro.is_playing() == true, "Intro should be playing again")
	assert(intro.get_current_segment() == 1, "Reset to segment 1")

	# Nhấn nút Bỏ qua
	intro.skip_intro()
	assert(intro.is_playing() == false, "Intro must stop immediately upon Skip")
	assert(intro.visible == false, "Intro must hide immediately upon Skip")
	assert(skip_called[0] == true, "Callback must be invoked on Skip to enter game")
	print("✓ 6. Skip button successfully bypasses intro cutscene directly into game")

	# -------------------------------------------------------------------------
	# 7. Integration: Title Screen "Bắt đầu mới" -> Intro Cutscene -> Game
	# -------------------------------------------------------------------------
	print("\n--- 7. Testing Title Screen -> Intro Cutscene Flow ---")
	main_scene.title_screen.show_me()
	assert(main_scene.title_screen.visible == true, "Title screen visible")

	# Bấm nút Bắt đầu mới
	main_scene.title_screen.start_btn.pressed.emit()
	await process_frame

	assert(main_scene.title_screen.visible == false, "Title screen should hide")
	assert(intro.is_playing() == true, "Intro cutscene should launch when starting new game")
	assert(intro.get_current_segment() == 1, "Intro should be at Doan 1")

	# Bấm bỏ qua để vào game
	intro.skip_intro()
	await process_frame

	assert(intro.is_playing() == false)
	assert(main_scene.mode == main_scene.Mode.PLAY, "Game mode should be PLAY after intro")
	print("✓ 7. Complete flow from Title Screen to Intro Cutscene to New Game verified!")

	print("\n==================================================")
	print("   ALL INTRO CUTSCENE TESTS PASSED 100%! 🎉📖   ")
	print("==================================================")
	quit(0)
