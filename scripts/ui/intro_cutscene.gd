extends CanvasLayer
# Đoạn phim giới thiệu (Intro Cutscene / Slideshow) cho Fluffy Farm
# Chạy 13 đoạn tranh truyện (Doan1.jpg -> Doan13.jpg) từ res://picture/GioiThieu/
# Tự động chuyển đoạn sau 5 giây (5s), có nút Bỏ qua (Skip), hoặc click trực tiếp vào tranh/lời để qua đoạn ngay.

const TextureGen := preload("res://scripts/texture_gen.gd")
const UIKit := preload("res://scripts/ui/ui_kit.gd")

signal intro_finished

const TOTAL_SEGMENTS: int = 13
const SEGMENT_DURATION: float = 5.0

var _texture_cache: Dictionary = {}
var _current_segment: int = 1
var _timer: float = 0.0
var _is_playing: bool = false
var _on_finished_cb: Callable

# Nodes UI
var _root: Control
var _img_rect_a: TextureRect
var _img_rect_b: TextureRect
var _active_is_a: bool = true
var _fade_tween: Tween

var _skip_btn: Button
var _timer_bar: ProgressBar
var _hint_label: Label


func _ready() -> void:
	layer = 32
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

	_build_ui()


func _build_ui() -> void:
	_root = Control.new()
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(_root)

	# 1. Nền tối điện ảnh (Cinematic black)
	var bg := ColorRect.new()
	bg.color = Color(0.04, 0.03, 0.02, 1.0)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(bg)

	# 2. Hai TextureRects để chuyển cảnh chéo (Crossfade) mượt mà
	_img_rect_a = TextureRect.new()
	_img_rect_a.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_img_rect_a.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_img_rect_a.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_img_rect_a.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(_img_rect_a)

	_img_rect_b = TextureRect.new()
	_img_rect_b.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_img_rect_b.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_img_rect_b.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_img_rect_b.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_img_rect_b.modulate.a = 0.0
	_root.add_child(_img_rect_b)

	# 3. Lớp tương tác click toàn màn hình (Click vào lời / tranh để qua đoạn ngay)
	var click_area := Control.new()
	click_area.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	click_area.mouse_filter = Control.MOUSE_FILTER_STOP
	click_area.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	click_area.gui_input.connect(_on_screen_gui_input)
	_root.add_child(click_area)

	# 4. Thanh tiến trình đếm ngược 5s ở cạnh dưới màn hình
	_timer_bar = ProgressBar.new()
	_timer_bar.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_timer_bar.offset_top = -6
	_timer_bar.offset_bottom = 0
	_timer_bar.show_percentage = false
	_timer_bar.max_value = SEGMENT_DURATION
	_timer_bar.value = SEGMENT_DURATION
	_timer_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var bar_bg := StyleBoxFlat.new()
	bar_bg.bg_color = Color(0.12, 0.08, 0.04, 0.6)
	_timer_bar.add_theme_stylebox_override("background", bar_bg)

	var bar_fill := StyleBoxFlat.new()
	bar_fill.bg_color = Color(1.0, 0.85, 0.40, 0.90)
	bar_fill.set_corner_radius_all(2)
	_timer_bar.add_theme_stylebox_override("fill", bar_fill)
	_root.add_child(_timer_bar)

	# 5. Dòng gợi ý thao tác ở đáy màn hình
	_hint_label = Label.new()
	_hint_label.text = "Nhấp chuột vào tranh/lời để qua đoạn · Tự chuyển sau 5s"
	_hint_label.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_hint_label.offset_top = -32
	_hint_label.offset_bottom = -10
	_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint_label.add_theme_font_size_override("font_size", 12)
	_hint_label.add_theme_color_override("font_color", Color(1.0, 0.92, 0.75, 0.75))
	_hint_label.add_theme_color_override("font_outline_color", Color(0.08, 0.05, 0.03, 0.95))
	_hint_label.add_theme_constant_override("outline_size", 3)
	_hint_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(_hint_label)



	# 7. Nút Bỏ qua (Skip / Ship) ở góc trên-phải
	_skip_btn = Button.new()
	_skip_btn.text = "Bỏ qua ⏭️"
	_skip_btn.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_skip_btn.offset_left = -140
	_skip_btn.offset_top = 20
	_skip_btn.offset_right = -24
	_skip_btn.offset_bottom = 58
	_skip_btn.custom_minimum_size = Vector2(116, 38)
	_skip_btn.add_theme_font_size_override("font_size", 13)
	_skip_btn.add_theme_stylebox_override("normal", UIKit.btn_style(Color(0.22, 0.15, 0.09, 0.90), UIKit.COLOR_BORDER_GOLD, 8, 1))
	_skip_btn.add_theme_stylebox_override("hover", UIKit.btn_style(Color(0.35, 0.24, 0.14, 0.95), UIKit.COLOR_BORDER_BRIGHT, 8, 2))
	_skip_btn.add_theme_stylebox_override("pressed", UIKit.btn_style(Color(0.16, 0.10, 0.05, 0.95), UIKit.COLOR_BORDER_GOLD, 8, 1))
	_skip_btn.add_theme_color_override("font_color", UIKit.COLOR_TEXT_GOLD)
	_skip_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_skip_btn.tooltip_text = "Bỏ qua phần giới thiệu và vào game ngay"
	_skip_btn.pressed.connect(skip_intro)
	_root.add_child(_skip_btn)


func _process(delta: float) -> void:
	if not _is_playing:
		return

	_timer += delta
	_timer_bar.value = clampf(SEGMENT_DURATION - _timer, 0.0, SEGMENT_DURATION)

	if _timer >= SEGMENT_DURATION:
		next_segment()


func _unhandled_input(event: InputEvent) -> void:
	if not _is_playing or not visible:
		return

	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		if event.keycode == KEY_ESCAPE:
			get_viewport().set_input_as_handled()
			skip_intro()
		elif event.keycode in [KEY_SPACE, KEY_ENTER, KEY_E]:
			get_viewport().set_input_as_handled()
			next_segment()


func _on_screen_gui_input(event: InputEvent) -> void:
	if not _is_playing:
		return
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		next_segment()


# Bắt đầu trình chiếu giới thiệu
func start_intro(callback: Callable = Callable()) -> void:
	_on_finished_cb = callback
	_current_segment = 1
	_timer = 0.0
	_is_playing = true
	visible = true

	# Tải trước và hiển thị đoạn 1 ngay lập tức
	var tex := _get_texture(1)
	_img_rect_a.texture = tex
	_img_rect_a.modulate.a = 1.0
	_img_rect_b.texture = null
	_img_rect_b.modulate.a = 0.0
	_active_is_a = true
	_update_header()

	# Tải trước đoạn 2 trong bộ nhớ đệm để chuyển mượt mà
	_preload_texture(2)


# Chuyển sang đoạn tiếp theo
func next_segment() -> void:
	if not _is_playing:
		return

	_timer = 0.0

	if _current_segment >= TOTAL_SEGMENTS:
		finish_intro()
		return

	_current_segment += 1
	_show_segment(_current_segment)


# Hiển thị đoạn cụ thể với hiệu ứng chuyển cảnh mềm mại
func _show_segment(idx: int) -> void:
	var next_tex := _get_texture(idx)
	if next_tex == null:
		push_warning("IntroCutscene: Không thể nạp ảnh Doan%d.jpg" % idx)
		if idx >= TOTAL_SEGMENTS:
			finish_intro()
		return

	if _fade_tween != null and _fade_tween.is_valid():
		_fade_tween.kill()

	var incoming_rect: TextureRect = _img_rect_b if _active_is_a else _img_rect_a
	var outgoing_rect: TextureRect = _img_rect_a if _active_is_a else _img_rect_b

	incoming_rect.texture = next_tex
	incoming_rect.modulate.a = 0.0

	_fade_tween = create_tween().set_parallel(true)
	_fade_tween.tween_property(incoming_rect, "modulate:a", 1.0, 0.35).set_trans(Tween.TRANS_SINE)
	_fade_tween.tween_property(outgoing_rect, "modulate:a", 0.0, 0.35).set_trans(Tween.TRANS_SINE)

	_active_is_a = not _active_is_a
	_update_header()

	# Nạp trước đoạn kế tiếp
	if idx + 1 <= TOTAL_SEGMENTS:
		_preload_texture(idx + 1)


func _update_header() -> void:
	_timer_bar.value = SEGMENT_DURATION


# Bỏ qua toàn bộ phần giới thiệu vào thẳng game
func skip_intro() -> void:
	finish_intro()


# Hoàn tất đoạn giới thiệu và chuyển vào game mới
func finish_intro() -> void:
	if not _is_playing:
		return
	_is_playing = false
	visible = false

	if _fade_tween != null and _fade_tween.is_valid():
		_fade_tween.kill()

	intro_finished.emit()

	if _on_finished_cb.is_valid():
		var cb := _on_finished_cb
		_on_finished_cb = Callable()
		cb.call()


func is_playing() -> bool:
	return _is_playing


func get_current_segment() -> int:
	return _current_segment


func _get_texture(idx: int) -> Texture2D:
	if _texture_cache.has(idx):
		return _texture_cache[idx]
	return _load_texture(idx)


func _preload_texture(idx: int) -> void:
	if not _texture_cache.has(idx):
		_load_texture(idx)


func _load_texture(idx: int) -> Texture2D:
	var path := "res://picture/GioiThieu/Doan%d.jpg" % idx
	var img := Image.new()
	var err := img.load(path)
	if err != OK:
		var global_path := ProjectSettings.globalize_path(path)
		err = img.load(global_path)
	if err == OK:
		var tex := ImageTexture.create_from_image(img)
		_texture_cache[idx] = tex
		return tex
	return null
