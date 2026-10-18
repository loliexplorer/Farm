extends SceneTree

func _init() -> void:
	process_frame.connect(_run, CONNECT_ONE_SHOT)

func _run() -> void:
	print("==================================================")
	print("   TESTING ROD TIER SEPARATION AND CAST DEDUCTION")
	print("==================================================")

	var main_scene = load("res://scenes/main.tscn").instantiate()
	root.add_child(main_scene)
	await process_frame

	var Inventory: Node = root.get_node("Inventory")
	var FishDB = load("res://scripts/fish_db.gd")
	var TextureGen = load("res://scripts/texture_gen.gd")

	# Reset inventory
	Inventory.reset()
	Inventory.rods.clear()
	assert(Inventory.total_casts() == 0, "Initial rods should be 0")

	# 1. Mua 1 cần sơ cấp (10 lượt) và 1 cần cao cấp (30 lượt)
	print("\n--- 1. Testing Buying Basic and High Rods ---")
	Inventory.add_rod("basic", 10)
	Inventory.add_rod("high", 30)

	assert(Inventory.rod_casts("basic") == 10, "Basic rod must have 10 casts")
	assert(Inventory.rod_casts("high") == 30, "High rod must have 30 casts")
	assert(Inventory.total_casts() == 40, "Total casts must be 40")

	# Tìm 2 slot trên hotbar
	var basic_slot: Dictionary = {}
	var high_slot: Dictionary = {}
	var basic_idx: int = -1
	var high_idx: int = -1

	for i in Inventory.HOTBAR_SIZE:
		var s: Dictionary = Inventory.get_hotbar_slot(i)
		if not s.is_empty() and str(s.get("type", "")) == "rod":
			var t: String = str(s.get("tier", s.get("id", "")))
			if t == "basic":
				basic_slot = s
				basic_idx = i
			elif t == "high":
				high_slot = s
				high_idx = i

	assert(not basic_slot.is_empty(), "Basic rod must exist in hotbar")
	assert(not high_slot.is_empty(), "High rod must exist in hotbar")
	assert(basic_idx != high_idx, "Basic rod and High rod must be in SEPARATE slots")

	# Kiểm tra số lượng hiển thị trên từng slot
	var basic_qty: int = Inventory.get_slot_qty(basic_slot)
	var high_qty: int = Inventory.get_slot_qty(high_slot)
	print("Basic slot: '%s' qty=%d" % [Inventory.get_slot_name(basic_slot), basic_qty])
	print("High slot:  '%s' qty=%d" % [Inventory.get_slot_name(high_slot), high_qty])

	assert(basic_qty == 10, "Basic rod slot MUST show 10 casts (NOT accumulated!)")
	assert(high_qty == 30, "High rod slot MUST show 30 casts (NOT accumulated!)")
	assert(Inventory.get_slot_name(basic_slot) == "Cần câu sơ cấp", "Basic rod name correct")
	assert(Inventory.get_slot_name(high_slot) == "Cần câu cao cấp", "High rod name correct")
	print("✓ Separate slot quantities verified: basic=10, high=30")

	# 2. Câu cá bằng Cần Cao Cấp (High)
	print("\n--- 2. Testing Fishing with High Rod ---")
	Inventory.select_hotbar_slot(high_idx)
	assert(str(Inventory.active_item.get("tier", "")) == "high", "Active item must be high rod")

	var f_mgr: RefCounted = main_scene.fishing_manager
	f_mgr.start_fishing()
	assert(f_mgr.fishing == true)
	assert(f_mgr._current_cast_tier == "high", "Current cast tier must be 'high'")
	f_mgr.finish_fishing()

	# Kiểm tra sau khi câu cần cao cấp: chỉ cần cao cấp bị trừ, cần sơ cấp giữ nguyên!
	assert(Inventory.rod_casts("high") == 29, "High rod must decrease from 30 to 29")
	assert(Inventory.rod_casts("basic") == 10, "Basic rod MUST REMAIN 10 (not deducted!)")
	assert(Inventory.get_slot_qty(Inventory.get_hotbar_slot(high_idx)) == 29, "High slot qty must be 29")
	assert(Inventory.get_slot_qty(Inventory.get_hotbar_slot(basic_idx)) == 10, "Basic slot qty must be 10")
	print("✓ Fished with High Rod: High rod = 29, Basic rod = 10 (unchanged)")

	# 3. Câu cá bằng Cần Sơ Cấp (Basic)
	print("\n--- 3. Testing Fishing with Basic Rod ---")
	Inventory.select_hotbar_slot(basic_idx)
	assert(str(Inventory.active_item.get("tier", "")) == "basic", "Active item must be basic rod")

	f_mgr.start_fishing()
	assert(f_mgr.fishing == true)
	assert(f_mgr._current_cast_tier == "basic", "Current cast tier must be 'basic'")
	f_mgr.finish_fishing()

	# Kiểm tra sau khi câu cần sơ cấp: chỉ cần sơ cấp bị trừ, cần cao cấp giữ nguyên!
	assert(Inventory.rod_casts("basic") == 9, "Basic rod must decrease from 10 to 9")
	assert(Inventory.rod_casts("high") == 29, "High rod MUST REMAIN 29 (not deducted!)")
	assert(Inventory.get_slot_qty(Inventory.get_hotbar_slot(basic_idx)) == 9, "Basic slot qty must be 9")
	assert(Inventory.get_slot_qty(Inventory.get_hotbar_slot(high_idx)) == 29, "High slot qty must be 29")
	print("✓ Fished with Basic Rod: Basic rod = 9, High rod = 29 (unchanged)")

	# 4. Giao Cần Tre cho Mèo Fisher (White Cat Snow)
	print("\n--- 4. Testing Cat Helper Giving Rods ---")
	var white: Node = main_scene.cat_helper_white
	white.is_hired = true

	# Giao 5 lượt câu sơ cấp cho mèo
	var give_ok: bool = white.give_rods(5, "basic")
	assert(give_ok == true)
	assert(Inventory.rod_casts("basic") == 4, "Basic rod should decrease to 4 after giving 5 to cat")
	assert(Inventory.rod_casts("high") == 29, "High rod MUST REMAIN 29 after giving basic to cat")
	assert(int(white.assigned_rods_data.get("basic", 0)) == 5, "Cat received 5 basic rods")
	print("✓ Cat received 5 basic rods. Bag now has: basic=4, high=29")

	# Lấy lại cần từ mèo
	white.take_back_rods(5)
	assert(Inventory.rod_casts("basic") == 9, "Basic rod restored to 9")
	assert(Inventory.rod_casts("high") == 29, "High rod remains 29")
	print("✓ Took back rods from cat: basic=9, high=29")

	print("\n==================================================")
	print("   ALL ROD TIER SEPARATION TESTS PASSED SUCCESSFULLY! ")
	print("==================================================")
	quit(0)
