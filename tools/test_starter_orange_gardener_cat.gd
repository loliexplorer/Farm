extends SceneTree

func _init() -> void:
	process_frame.connect(_run, CONNECT_ONE_SHOT)

func _run() -> void:
	print("==================================================")
	print("  TESTING STARTER ORANGE GARDENER CAT & DIRECT UI ")
	print("==================================================")

	var main_scene = load("res://scenes/main.tscn").instantiate()
	root.add_child(main_scene)
	await process_frame

	var calico = main_scene.cat_helper
	var orange = main_scene.cat_helper_orange
	var panel = main_scene.cat_panel
	var inter_mgr = main_scene.interaction_manager

	# -------------------------------------------------------------------------
	# 1. Verify Starter Cat on Game Open: Orange cat at yard, Calico at Junimo Hut
	# -------------------------------------------------------------------------
	print("\n--- 1. Testing Initial Arrival on Game Boot ---")
	assert(orange.visible == true, "Orange cat MUST be visible and arriving at farm!")
	assert(orange.cat_breed == "orange", "Breed must be orange")
	assert(orange.cat_role == "gardener", "Role must be gardener")
	assert(orange.state == orange.State.ARRIVING, "Orange cat state must be ARRIVING to front yard")
	assert(orange.waypoints.has(orange.WAITING_POS), "Waypoints must lead to front yard WAITING_POS")

	assert(calico.visible == false, "Calico cat MUST NOT be in the front yard at game start!")
	assert(calico.position == calico.get_sleep_pos(), "Calico cat must stay at Junimo Hut sleep pos")
	print("✓ Game start verified: Orange gardener cat arrives at yard, Calico stays in Hut")

	# -------------------------------------------------------------------------
	# 2. Verify Proximity Interaction Label
	# -------------------------------------------------------------------------
	print("\n--- 2. Testing Proximity Interaction Prompt ---")
	main_scene.player.position = orange.position + Vector2(10, 0)
	var interactable = inter_mgr.nearest_interactable()
	assert(not interactable.is_empty(), "There must be an interactable near orange cat")
	assert(interactable.label.contains("Mèo Mướp Vàng"), "Label must show cat name")
	assert(interactable.label.contains("Công việc làm vườn"), "Label must show gardening jobs explicitly: %s" % interactable.label)
	print("✓ Proximity label verified: '%s'" % interactable.label)

	# -------------------------------------------------------------------------
	# 3. Verify Direct Interaction: Unhired cat shows ONLY Gardener card (NOT all cats, NOT manage view)
	# -------------------------------------------------------------------------
	print("\n--- 3. Testing Direct Click Interaction with Unhired Orange Cat ---")
	interactable.cb.call()
	await process_frame

	assert(panel.visible == true, "Cat panel must be open")
	assert(orange.is_hired == false, "Unhired cat MUST NOT be automatically hired or in manage view!")
	assert(panel._manage_view.visible == false, "Panel MUST NOT show manage view for unhired cat!")
	assert(panel._hire_view.visible == true, "Panel MUST show hire view for unhired cat!")
	assert(panel._header_title_lbl.text.contains("CÔNG VIỆC LÀM VƯỜN"), "Header must show 'CÔNG VIỆC LÀM VƯỜN': %s" % panel._header_title_lbl.text)
	assert(panel._hire_cards_container.get_child_count() == 1, "Panel MUST show ONLY 1 card (Gardener cat), NOT the full cat list! (Got %d)" % panel._hire_cards_container.get_child_count())
	print("✓ Direct click on unhired cat shows ONLY Gardener card with gardening jobs (Not full cat list, not manage view)")

	# -------------------------------------------------------------------------
	# 3b. Verify Hiring from Card Transitions to Gardening Management View
	# -------------------------------------------------------------------------
	print("\n--- 3b. Testing Hiring Orange Cat Transitions to Management View ---")
	panel.cat = orange
	panel._on_hire_pressed()
	await process_frame

	assert(orange.is_hired == true, "Orange cat should be hired after clicking hire")
	assert(panel._manage_view.visible == true, "Panel should transition to manage view after hire")
	assert(panel._manage_title_lbl.text.contains("CÔNG VIỆC LÀM VƯỜN"), "Title must state 'CÔNG VIỆC LÀM VƯỜN': %s" % panel._manage_title_lbl.text)
	assert(panel._manage_title_lbl.text.contains("MÈO MƯỚP VÀNG"), "Title must contain 'MÈO MƯỚP VÀNG'")
	assert(panel._manage_back_list_btn.visible == false, "'« Danh sách mèo' button must be HIDDEN when hired from direct interaction")

	# Verify gardening elements are present
	assert(panel._status_label != null and panel._status_label.visible, "Gardening status label must be present")
	assert(panel._water_label != null and panel._water_label.visible, "Watering can label must be present")
	assert(panel._hoe_card != null and panel._hoe_card.visible, "Hoe assigning card must be present")
	assert(panel._right_box != null and panel._right_box.visible, "Seeds inventory box must be present")
	assert(panel._left_box != null and panel._left_box.visible, "Cat seed pouch box must be present")
	print("✓ Hiring transitions to gardening management view with all tools (Water, Hoes, Seeds)")

	# Close panel
	panel.close()
	assert(panel.visible == false)

	# -------------------------------------------------------------------------
	# 4. Verify Junimo Hut Still Opens Full Cat List
	# -------------------------------------------------------------------------
	print("\n--- 4. Testing Junimo Hut / Hub Opens Full Cat List ---")
	main_scene._open_cat_panel(null)
	await process_frame

	assert(panel.visible == true, "Cat panel must be open")
	assert(panel._hire_view.visible == true, "Junimo Hut / HUD MUST open the full cat list (_hire_view)")
	assert(panel._manage_view.visible == false, "Manage view must be hidden initially for hub")
	assert(panel._hire_cards_container.get_child_count() >= 2, "Must display cards for all cats in Junimo Hut")
	print("✓ Junimo Hut hub correctly displays full cat list for other cats")

	panel.close()
	assert(panel.visible == false)

	# -------------------------------------------------------------------------
	# 5. Verify New Game Reset in SaveLoadManager
	# -------------------------------------------------------------------------
	print("\n--- 5. Testing SaveLoadManager.start_new_game() ---")
	var slm = main_scene.save_load_manager
	slm.start_new_game()
	await process_frame

	assert(orange.visible == true, "Orange cat must be visible arriving at yard on new game")
	assert(orange.state == orange.State.ARRIVING, "Orange cat state must be ARRIVING")
	assert(calico.visible == false, "Calico cat must be hidden on new game")
	print("✓ start_new_game correctly spawns Orange cat to yard and dismisses Calico")

	print("\n==================================================")
	print("   ALL STARTER ORANGE CAT TESTS PASSED 100%! 🎉🐱 ")
	print("==================================================")
	quit(0)
