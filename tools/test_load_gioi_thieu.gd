extends SceneTree

func _init() -> void:
	for i in range(1, 14):
		var p := "res://picture/GioiThieu/Doan%d.jpg" % i
		assert(ResourceLoader.exists(p), "ResourceLoader must find Doan %d" % i)
		var res: Resource = ResourceLoader.load(p)
		assert(res != null, "Failed to load resource for Doan %d" % i)
		assert(res is Texture2D, "Resource for Doan %d must be a Texture2D" % i)
		var tex: Texture2D = res as Texture2D
		print("Doan %d: type=%s size=%s" % [i, tex.get_class(), str(tex.get_size())])
		assert(tex.get_size().x > 0 and tex.get_size().y > 0, "Texture size must be valid for Doan %d" % i)
	print("ALL 13 IMAGES LOADED SUCCESSFULLY VIA RESOURCELOADER!")
	quit(0)
