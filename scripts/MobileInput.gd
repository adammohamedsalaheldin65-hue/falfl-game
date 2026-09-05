extends CanvasLayer

# المحقق فلفل — Touch Controls
# يظهر فقط على Android/iOS أو جهاز/متصفح فيه Touch.
# على الكمبيوتر يختفي بالكامل ويظل التحكم Keyboard + Mouse.

signal look_delta(relative: Vector2)
signal interact_pressed
signal bag_pressed
signal pause_pressed

var touch_enabled: bool = false
var move_vector: Vector2 = Vector2.ZERO
var run_held: bool = false
var jump_held: bool = false

var root: Control
var move_zone: Panel
var move_knob: Panel
var move_touch_id: int = -1

var look_zone: Control
var look_touch_id: int = -1

const JOYSTICK_RADIUS: float = 76.0


func _ready() -> void:
	layer = 20
	touch_enabled = _detect_touch_device()

	if not touch_enabled:
		visible = false
		return

	_build_touch_ui()
	set_gameplay_visible(false)


func _detect_touch_device() -> bool:
	var platform_name: String = OS.get_name()
	if platform_name == "Android" or platform_name == "iOS":
		return true

	if DisplayServer.is_touchscreen_available():
		return true

	# Extra detection for a phone opening the GitHub Pages Web build.
	if OS.has_feature("web"):
		var navigator: Object = JavaScriptBridge.get_interface("navigator")
		if navigator != null:
			var points: int = int(navigator.get("maxTouchPoints"))
			if points > 0:
				return true

	return false


func is_touch_enabled() -> bool:
	return touch_enabled


func get_move_vector() -> Vector2:
	return move_vector


func is_run_held() -> bool:
	return run_held


func is_jump_held() -> bool:
	return jump_held


func set_gameplay_visible(value: bool) -> void:
	visible = touch_enabled and value
	if not visible:
		_reset_inputs()


func _build_touch_ui() -> void:
	root = Control.new()
	root.name = "TouchControlsRoot"
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	# Right side is a transparent swipe area for the camera.
	look_zone = Control.new()
	look_zone.name = "LookSwipeZone"
	look_zone.anchor_left = 0.43
	look_zone.anchor_top = 0.0
	look_zone.anchor_right = 1.0
	look_zone.anchor_bottom = 1.0
	look_zone.offset_left = 0.0
	look_zone.offset_top = 0.0
	look_zone.offset_right = 0.0
	look_zone.offset_bottom = 0.0
	look_zone.mouse_filter = Control.MOUSE_FILTER_STOP
	look_zone.gui_input.connect(_on_look_gui_input)
	root.add_child(look_zone)

	var look_hint: Label = Label.new()
	look_hint.text = "اسحب هنا للكاميرا"
	look_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	look_hint.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	look_hint.modulate = Color(1.0, 1.0, 1.0, 0.28)
	look_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	look_hint.anchor_left = 0.18
	look_hint.anchor_top = 0.38
	look_hint.anchor_right = 0.82
	look_hint.anchor_bottom = 0.52
	look_zone.add_child(look_hint)

	# Left virtual joystick.
	move_zone = Panel.new()
	move_zone.name = "MoveJoystick"
	move_zone.anchor_left = 0.0
	move_zone.anchor_top = 1.0
	move_zone.anchor_right = 0.0
	move_zone.anchor_bottom = 1.0
	move_zone.offset_left = 28.0
	move_zone.offset_top = -238.0
	move_zone.offset_right = 238.0
	move_zone.offset_bottom = -28.0
	move_zone.mouse_filter = Control.MOUSE_FILTER_STOP
	move_zone.gui_input.connect(_on_move_gui_input)
	move_zone.add_theme_stylebox_override("panel", _round_style(Color(0.03, 0.04, 0.07, 0.48), 105))
	root.add_child(move_zone)

	move_knob = Panel.new()
	move_knob.name = "Knob"
	move_knob.size = Vector2(74.0, 74.0)
	move_knob.mouse_filter = Control.MOUSE_FILTER_IGNORE
	move_knob.add_theme_stylebox_override("panel", _round_style(Color(0.92, 0.94, 1.0, 0.70), 37))
	move_zone.add_child(move_knob)
	_center_knob()

	var move_hint: Label = Label.new()
	move_hint.text = "حركة"
	move_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	move_hint.position = Vector2(72.0, 145.0)
	move_hint.size = Vector2(66.0, 30.0)
	move_hint.modulate = Color(1.0, 1.0, 1.0, 0.55)
	move_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	move_zone.add_child(move_hint)

	# Main action buttons.
	var interact: Button = _make_touch_button("تفاعل\nE", Vector2(-150.0, -184.0), Vector2(-24.0, -58.0))
	interact.pressed.connect(_emit_interact)

	var jump: Button = _make_touch_button("قفز\nفرامل", Vector2(-286.0, -156.0), Vector2(-166.0, -50.0))
	jump.button_down.connect(_set_jump.bind(true))
	jump.button_up.connect(_set_jump.bind(false))

	var run: Button = _make_touch_button("جري", Vector2(-416.0, -134.0), Vector2(-306.0, -50.0))
	run.button_down.connect(_set_run.bind(true))
	run.button_up.connect(_set_run.bind(false))

	var bag: Button = _make_top_button("👜 القضايا", -226.0, -118.0)
	bag.pressed.connect(_emit_bag)

	var pause: Button = _make_top_button("⏸", -108.0, -24.0)
	pause.pressed.connect(_emit_pause)


func _make_touch_button(text_value: String, top_left: Vector2, bottom_right: Vector2) -> Button:
	var button: Button = Button.new()
	button.text = text_value
	button.anchor_left = 1.0
	button.anchor_top = 1.0
	button.anchor_right = 1.0
	button.anchor_bottom = 1.0
	button.offset_left = top_left.x
	button.offset_top = top_left.y
	button.offset_right = bottom_right.x
	button.offset_bottom = bottom_right.y
	button.add_theme_font_size_override("font_size", 18)
	button.modulate = Color(1.0, 1.0, 1.0, 0.82)
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	root.add_child(button)
	return button


func _make_top_button(text_value: String, left_offset: float, right_offset: float) -> Button:
	var button: Button = Button.new()
	button.text = text_value
	button.anchor_left = 1.0
	button.anchor_top = 0.0
	button.anchor_right = 1.0
	button.anchor_bottom = 0.0
	button.offset_left = left_offset
	button.offset_top = 24.0
	button.offset_right = right_offset
	button.offset_bottom = 78.0
	button.add_theme_font_size_override("font_size", 17)
	button.modulate = Color(1.0, 1.0, 1.0, 0.82)
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	root.add_child(button)
	return button


func _round_style(color_value: Color, radius: int) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = color_value
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(1.0, 1.0, 1.0, 0.18)
	return style


func _on_move_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var touch: InputEventScreenTouch = event as InputEventScreenTouch
		if touch.pressed and move_touch_id == -1:
			move_touch_id = touch.index
			_update_joystick(touch.position)
			get_viewport().set_input_as_handled()
		elif not touch.pressed and touch.index == move_touch_id:
			_reset_move()
			get_viewport().set_input_as_handled()

	elif event is InputEventScreenDrag:
		var drag: InputEventScreenDrag = event as InputEventScreenDrag
		if drag.index == move_touch_id:
			_update_joystick(drag.position)
			get_viewport().set_input_as_handled()

	# Lets developers test the joystick with mouse clicks in the editor.
	elif event is InputEventMouseButton:
		var mouse_button: InputEventMouseButton = event as InputEventMouseButton
		if mouse_button.button_index == MOUSE_BUTTON_LEFT:
			if mouse_button.pressed:
				move_touch_id = -2
				_update_joystick(mouse_button.position)
			else:
				_reset_move()

	elif event is InputEventMouseMotion and move_touch_id == -2:
		var mouse_motion: InputEventMouseMotion = event as InputEventMouseMotion
		if (mouse_motion.button_mask & MOUSE_BUTTON_MASK_LEFT) != 0:
			_update_joystick(mouse_motion.position)


func _update_joystick(local_position: Vector2) -> void:
	if move_zone == null or move_knob == null:
		return

	var center: Vector2 = move_zone.size * 0.5
	var delta: Vector2 = local_position - center

	if delta.length() > JOYSTICK_RADIUS:
		delta = delta.normalized() * JOYSTICK_RADIUS

	move_vector = delta / JOYSTICK_RADIUS
	if move_vector.length() > 1.0:
		move_vector = move_vector.normalized()

	move_knob.position = center + delta - (move_knob.size * 0.5)


func _center_knob() -> void:
	if move_zone == null or move_knob == null:
		return
	move_knob.position = (move_zone.size * 0.5) - (move_knob.size * 0.5)


func _reset_move() -> void:
	move_vector = Vector2.ZERO
	move_touch_id = -1
	_center_knob()


func _on_look_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var touch: InputEventScreenTouch = event as InputEventScreenTouch
		if touch.pressed and look_touch_id == -1:
			look_touch_id = touch.index
			get_viewport().set_input_as_handled()
		elif not touch.pressed and touch.index == look_touch_id:
			look_touch_id = -1
			get_viewport().set_input_as_handled()

	elif event is InputEventScreenDrag:
		var drag: InputEventScreenDrag = event as InputEventScreenDrag
		if drag.index == look_touch_id:
			look_delta.emit(drag.relative)
			get_viewport().set_input_as_handled()


func _set_run(value: bool) -> void:
	run_held = value


func _set_jump(value: bool) -> void:
	jump_held = value


func _emit_interact() -> void:
	interact_pressed.emit()


func _emit_bag() -> void:
	bag_pressed.emit()


func _emit_pause() -> void:
	pause_pressed.emit()


func _reset_inputs() -> void:
	run_held = false
	jump_held = false
	look_touch_id = -1
	_reset_move()
