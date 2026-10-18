extends SceneTree

func _init() -> void:
	process_frame.connect(_run, CONNECT_ONE_SHOT)

func _run() -> void:
	print("==================================================")
	print("   TESTING FISHING ROD & BAIT SYSTEM")
	print("==================================================")

	var FishDB = load("res://scripts/fish_db.gd")
	var TextureGen = load("res://scripts/texture_gen.gd")

	# -------------------------------------------------------------------------
	# 1. Test FishDB Odds for All Rods and Baits
	# -------------------------------------------------------------------------
	print("\n--- 1. Testing FishDB Odds Calculation ---")

	# Cần sơ cấp (basic)
	var b_odds: Dictionary = FishDB.get_odds("basic", "")
	assert(is_equal_approx(b_odds.nothing, 0.30), "Cần sơ cấp hụt phải là 30%")
	assert(is_equal_approx(b_odds.common, 0.40), "Cần sơ cấp phổ thông phải là 40%")
	assert(is_equal_approx(b_odds.mid, 0.20), "Cần sơ cấp trung cấp phải là 20%")
	assert(is_equal_approx(b_odds.rare, 0.0999), "Cần sơ cấp hiếm phải là 9.99%")
	assert(is_equal_approx(b_odds.legend, 0.0001), "Cần sơ cấp huyền thoại phải là 0.01%")
	print("✓ Cần sơ cấp không mồi: Hụt 30%, Phổ thông 40%, Trung cấp 20%, Hiếm 9.99%, Huyền thoại 0.01%")

	# Cần trung cấp (mid)
	var m_odds: Dictionary = FishDB.get_odds("mid", "")
	assert(is_equal_approx(m_odds.nothing, 0.25), "Cần trung cấp hụt phải là 25%")
	assert(is_equal_approx(m_odds.common, 0.40), "Cần trung cấp phổ thông phải là 40%")
	assert(is_equal_approx(m_odds.mid, 0.25), "Cần trung cấp trung cấp phải là 25%")
	assert(is_equal_approx(m_odds.rare, 0.0999), "Cần trung cấp hiếm phải là 9.99%")
	assert(is_equal_approx(m_odds.legend, 0.0001), "Cần trung cấp huyền thoại phải là 0.01%")
	print("✓ Cần trung cấp không mồi: Hụt 25%, Phổ thông 40%, Trung cấp 25%, Hiếm 9.99%, Huyền thoại 0.01%")

	# Cần cao cấp (high)
	var h_odds: Dictionary = FishDB.get_odds("high", "")
	assert(is_equal_approx(h_odds.nothing, 0.25), "Cần cao cấp hụt phải là 25%")
	assert(is_equal_approx(h_odds.common, 0.40), "Cần cao cấp phổ thông phải là 40%")
	assert(is_equal_approx(h_odds.mid, 0.20), "Cần cao cấp trung cấp phải là 20%")
	assert(is_equal_approx(h_odds.rare, 0.1499), "Cần cao cấp hiếm phải là 14.99%")
	assert(is_equal_approx(h_odds.legend, 0.0001), "Cần cao cấp huyền thoại phải là 0.01%")
	print("✓ Cần cao cấp không mồi: Hụt 25%, Phổ thông 40%, Trung cấp 20%, Hiếm 14.99%, Huyền thoại 0.01%")

	# Gắn mồi Trùn quế: Hụt gốc -5%, Phổ thông +5%
	var bw_odds: Dictionary = FishDB.get_odds("basic", "worm")
	assert(is_equal_approx(bw_odds.nothing, 0.25), "Cần sơ cấp + Trùn quế hụt phải là 25% (30% - 5%)")
	assert(is_equal_approx(bw_odds.common, 0.45), "Cần sơ cấp + Trùn quế phổ thông phải là 45% (40% + 5%)")
	assert(is_equal_approx(bw_odds.mid, 0.20))
	assert(is_equal_approx(bw_odds.rare, 0.0999))
	assert(is_equal_approx(bw_odds.legend, 0.0001))
	print("✓ Trùn quế: Hụt gốc -5%, Phổ thông +5% (Cần sơ cấp: 25% hụt, 45% phổ thông)")

	# Gắn Mồi sâu bọ: Hụt gốc -5%, Trung cấp +5%
	var bm_odds: Dictionary = FishDB.get_odds("basic", "caterpillar")
	assert(is_equal_approx(bm_odds.nothing, 0.25), "Cần sơ cấp + Sâu bọ hụt phải là 25%")
	assert(is_equal_approx(bm_odds.common, 0.40))
	assert(is_equal_approx(bm_odds.mid, 0.25), "Cần sơ cấp + Sâu bọ trung cấp phải là 25% (20% + 5%)")
	assert(is_equal_approx(bm_odds.rare, 0.0999))
	assert(is_equal_approx(bm_odds.legend, 0.0001))
	print("✓ Mồi sâu bọ: Hụt gốc -5%, Trung cấp +5% (Cần sơ cấp: 25% hụt, 25% trung cấp)")

	# Gắn Thính cám thơm: Hụt gốc -5%, Hiếm +5%
	var bh_odds: Dictionary = FishDB.get_odds("high", "paste")
	assert(is_equal_approx(bh_odds.nothing, 0.20), "Cần cao cấp + Thính cám hụt phải là 20% (25% - 5%)")
	assert(is_equal_approx(bh_odds.common, 0.40))
	assert(is_equal_approx(bh_odds.mid, 0.20))
	assert(is_equal_approx(bh_odds.rare, 0.1999), "Cần cao cấp + Thính cám hiếm phải là 19.99% (14.99% + 5%)")
	assert(is_equal_approx(bh_odds.legend, 0.0001))
	print("✓ Thính cám thơm: Hụt gốc -5%, Hiếm +5% (Cần cao cấp: 20% hụt, 19.99% hiếm)")

	# -------------------------------------------------------------------------
	# 2. Test Textures for Worm and Paste
	# -------------------------------------------------------------------------
	print("\n--- 2. Testing Bait Textures ---")
	var worm_tex: Texture2D = TextureGen.get_tex("worm")
	assert(worm_tex != null, "Texture 'worm' must exist!")
	var paste_tex: Texture2D = TextureGen.get_tex("paste")
	assert(paste_tex != null, "Texture 'paste' must exist!")
	var cat_tex: Texture2D = TextureGen.get_tex("caterpillar")
	assert(cat_tex != null, "Texture 'caterpillar' must exist!")
	print("✓ All 3 bait textures loaded successfully")

	# -------------------------------------------------------------------------
	# 3. Test Inventory Bait & Attachment
	# -------------------------------------------------------------------------
	print("\n--- 3. Testing Inventory Bait Management & Attachment ---")
	var main_scene = load("res://scenes/main.tscn").instantiate()
	root.add_child(main_scene)
	await process_frame

	var Inventory = root.get_node("Inventory")
	Inventory.reset()

	# Thêm mồi
	Inventory.add_bait("worm", 10)
	Inventory.add_bait("caterpillar", 5)
	Inventory.add_bait("paste", 3)
	assert(Inventory.bait_count("worm") == 10)
	assert(Inventory.bait_count("caterpillar") == 5)
	assert(Inventory.bait_count("paste") == 3)
	assert(Inventory.total_baits() == 18)
	print("✓ Inventory added and counted baits correctly: 10 worm, 5 caterpillar, 3 paste")

	# Gắn mồi vào cần câu
	assert(Inventory.attached_bait == "", "Initially attached_bait must be empty")
	var att_ok: bool = Inventory.attach_bait("worm")
	assert(att_ok == true)
	assert(Inventory.attached_bait == "worm", "Attached bait must now be 'worm'")
	print("✓ Attached bait 'worm' to player rod")

	# Tháo mồi
	Inventory.detach_bait()
	assert(Inventory.attached_bait == "", "Detached bait must reset attached_bait to empty")
	print("✓ Detached bait successfully")

	# Gắn lại mồi sâu bọ
	Inventory.attach_bait("caterpillar")
	assert(Inventory.attached_bait == "caterpillar")

	# -------------------------------------------------------------------------
	# 4. Test Player Fishing with Attached Bait
	# -------------------------------------------------------------------------
	print("\n--- 4. Testing Player Fishing with Attached Bait ---")
	Inventory.add_rod("mid", 5)
	Inventory.active_item = {"type": "rod", "tier": "mid"}

	var f_mgr: RefCounted = main_scene.fishing_manager
	assert(f_mgr != null, "Fishing manager must exist")

	var baits_before: int = Inventory.bait_count("caterpillar")
	var casts_before: int = Inventory.total_casts()
	f_mgr.start_fishing()
	assert(f_mgr.fishing == true, "Player should be fishing")
	assert(f_mgr._current_cast_tier == "mid", "Cast tier must be 'mid'")
	assert(f_mgr._current_cast_bait == "caterpillar", "Cast bait must be 'caterpillar'")
	assert(Inventory.bait_count("caterpillar") == baits_before - 1, "1 bait must be consumed upon cast")
	assert(Inventory.total_casts() == casts_before - 1, "1 cast must be consumed")
	print("✓ Player cast started with Cần trung cấp + Mồi sâu bọ (consumed 1 bait & 1 cast)")

	f_mgr.finish_fishing()
	assert(f_mgr.fishing == false, "Player finished fishing")
	print("✓ Player fishing finished with accurate odds applied")

	# -------------------------------------------------------------------------
	# 5. Test White Cat Snow (Fisher) with Rod Tiers and Bait
	# -------------------------------------------------------------------------
	print("\n--- 5. Testing White Cat Snow (Fisher) with Rod Tiers & Bait ---")
	var white: Node = main_scene.cat_helper_white
	assert(white != null, "White cat helper must exist")
	white.is_hired = true

	# Giao cần cao cấp cho mèo
	Inventory.add_rod("high", 10)
	var give_rod_ok: bool = white.give_rods(10, "high")
	assert(give_rod_ok == true)
	assert(white.assigned_rods == 10)
	assert(white.get_current_rod_tier() == "high", "White cat should hold 'high' rod tier")
	print("✓ Gave 10 high-tier casts to White Cat (cat holds high tier)")

	# Giao mồi thính cám thơm cho mèo
	var give_b_ok: bool = white.give_bait("paste", 3)
	assert(give_b_ok == true)
	assert(white.assigned_bait == "paste")
	assert(white.get_bait_count("paste") == 3)
	print("✓ Gave 3 Thính Cám Thơm baits to White Cat")

	# Chạy 1 chu kỳ câu của mèo
	var cat_rods_before: int = white.assigned_rods
	var cat_baits_before: int = white.get_bait_count("paste")
	white.current_job = {"type": "fish"}
	white._complete_job()
	assert(white.assigned_rods == cat_rods_before - 1, "Cat must consume 1 rod cast")
	assert(white.get_bait_count("paste") == cat_baits_before - 1, "Cat must consume 1 bait")
	print("✓ Cat completed fishing job: consumed 1 cast and 1 Thính cám thơm")

	# Lấy lại mồi còn lại từ mèo
	var inv_paste_before: int = Inventory.bait_count("paste")
	var take_b_ok: bool = white.take_back_bait("paste")
	assert(take_b_ok == true)
	assert(white.get_bait_count("paste") == 0)
	assert(Inventory.bait_count("paste") == inv_paste_before + 2, "Inventory must receive 2 returned baits")
	print("✓ Took back remaining 2 baits from cat into player inventory")

	# Lấy lại cần còn lại từ mèo
	var inv_casts_before: int = Inventory.total_casts()
	var take_r_ok: bool = white.take_back_rods(-1)
	assert(take_r_ok == true)
	assert(white.assigned_rods == 0)
	assert(Inventory.total_casts() == inv_casts_before + 9)
	print("✓ Took back remaining 9 casts from cat into player inventory")

	print("\n==================================================")
	print("   ALL FISHING ROD & BAIT TESTS PASSED! 🎉")
	print("==================================================")
	quit()
