extends SceneTree

func _init() -> void:
	for i in range(1, 14):
		var p := "res://picture/GioiThieu/Doan%d.jpg" % i
		var img := Image.new()
		var err := img.load(p)
		if err != OK:
			var global_path := ProjectSettings.globalize_path(p)
			err = img.load(global_path)
		print("Doan %d: err=%d size=%s" % [i, err, str(img.get_size())])
		assert(err == OK, "Failed to load Doan %d" % i)
		var tex := ImageTexture.create_from_image(img)
		assert(tex != null, "Texture creation failed for Doan %d" % i)
	print("ALL 13 IMAGES LOADED SUCCESSFULLY AS TEXTURES!")
	quit(0)
