extends Node

# Global Arabic font fallback for the game's programmatic UI.
# Desktop uses an installed Arabic-capable system font immediately.
# Web/unsupported platforms download and cache Noto Sans Arabic at runtime.

const ARABIC_FONT_URL: String = "https://raw.githubusercontent.com/google/fonts/main/ofl/notosansarabic/NotoSansArabic%5Bwdth%2Cwght%5D.ttf"
const ARABIC_FONT_CACHE: String = "user://felfel_noto_sans_arabic.ttf"
const ARABIC_TEST_CHAR: int = 0x0627 # ALEF

var ui_font: Font
var font_request: HTTPRequest


func _ready() -> void:
	var system_font: SystemFont = SystemFont.new()
	system_font.font_names = PackedStringArray([
		"Tahoma",
		"Segoe UI",
		"Arial",
		"Noto Sans Arabic",
		"DejaVu Sans"
	])
	system_font.allow_system_fallback = true
	_install_font(system_font)

	get_tree().node_added.connect(_on_node_added)
	call_deferred("_apply_to_existing_nodes")

	# SystemFont is not implemented on Web and some mobile targets.
	# Download a real Arabic font there (also covers any desktop missing Arabic glyphs).
	if OS.has_feature("web") or not system_font.has_char(ARABIC_TEST_CHAR):
		_load_cached_or_download()


func _install_font(font: Font) -> void:
	ui_font = font
	ThemeDB.fallback_font = ui_font
	_apply_to_existing_nodes()


func _load_cached_or_download() -> void:
	if FileAccess.file_exists(ARABIC_FONT_CACHE):
		var cached_font: FontFile = FontFile.new()
		var load_error: Error = cached_font.load_dynamic_font(ARABIC_FONT_CACHE)
		if load_error == OK and cached_font.has_char(ARABIC_TEST_CHAR):
			_add_current_font_as_fallback(cached_font)
			_install_font(cached_font)
			return

	_start_font_download()


func _start_font_download() -> void:
	if font_request != null:
		return

	font_request = HTTPRequest.new()
	font_request.timeout = 25.0
	add_child(font_request)
	font_request.request_completed.connect(_on_font_download_completed)

	var request_error: Error = font_request.request(ARABIC_FONT_URL)
	if request_error != OK:
		push_warning("Arabic font download could not start: %s" % error_string(request_error))


func _on_font_download_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or response_code < 200 or response_code >= 300 or body.is_empty():
		push_warning("Arabic font download failed. result=%d http=%d" % [result, response_code])
		return

	var downloaded_font: FontFile = FontFile.new()
	downloaded_font.data = body
	if not downloaded_font.has_char(ARABIC_TEST_CHAR):
		push_warning("Downloaded font does not contain Arabic glyphs.")
		return

	_add_current_font_as_fallback(downloaded_font)
	_install_font(downloaded_font)

	var cache_file: FileAccess = FileAccess.open(ARABIC_FONT_CACHE, FileAccess.WRITE)
	if cache_file != null:
		cache_file.store_buffer(body)


func _add_current_font_as_fallback(font: Font) -> void:
	if ui_font == null or ui_font == font:
		return
	var fallbacks: Array[Font] = []
	fallbacks.append(ui_font)
	font.fallbacks = fallbacks


func _on_node_added(node: Node) -> void:
	if ui_font == null:
		return
	_apply_font_to_node(node)


func _apply_to_existing_nodes() -> void:
	if ui_font == null or get_tree() == null:
		return
	_apply_font_recursive(get_tree().root)


func _apply_font_recursive(node: Node) -> void:
	_apply_font_to_node(node)
	for child: Node in node.get_children():
		_apply_font_recursive(child)


func _apply_font_to_node(node: Node) -> void:
	if ui_font == null:
		return

	if node is Control:
		var control: Control = node as Control
		# Most Godot UI controls use the theme item named "font".
		control.add_theme_font_override("font", ui_font)

		# RichTextLabel uses dedicated font item names.
		if control is RichTextLabel:
			var rich_text: RichTextLabel = control as RichTextLabel
			rich_text.add_theme_font_override("normal_font", ui_font)
			rich_text.add_theme_font_override("bold_font", ui_font)
			rich_text.add_theme_font_override("italics_font", ui_font)
			rich_text.add_theme_font_override("bold_italics_font", ui_font)
			rich_text.add_theme_font_override("mono_font", ui_font)

		control.queue_redraw()

	elif node is Label3D:
		var label_3d: Label3D = node as Label3D
		label_3d.font = ui_font
