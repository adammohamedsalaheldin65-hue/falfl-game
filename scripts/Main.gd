extends Node3D

# المحقق فلفل - Vertical Slice خفيف بدون أي Assets خارجية.
# Godot 4.x
#
# التحكم:
# W A S D / الأسهم = حركة
# Shift = جري
# الماوس = لف الكاميرا
# E = تفاعل / ركوب العربية / النزول منها
# Esc = تحرير/إمساك الماوس

var player: CharacterBody3D
var player_mesh: MeshInstance3D
var character_visual: Node3D
var left_arm_pivot: Node3D
var right_arm_pivot: Node3D
var left_leg_pivot: Node3D
var right_leg_pivot: Node3D
var head_mesh_node: MeshInstance3D
var hair_mesh_node: MeshInstance3D
var outfit_parts: Array[MeshInstance3D] = []
var walk_phase: float = 0.0
var idle_phase: float = 0.0
var car: CharacterBody3D
var car_mesh: MeshInstance3D
var camera: Camera3D

var game_active := false
var overlay_mode := ""
var in_car := false
var car_owned := false
var outfit_owned := false
var home_upgrade_owned := false
var money := 0
var case_files := 0
var phase := 0
var evidence_found := false
var asked := {}
var player_name := "فلفل"
var character_index := 0
var character_gender := "female"

var character_profiles := [
	{"label":"👩‍💼 المحامية الكلاسيكية", "gender":"female"},
	{"label":"🧕 المحامية الهادية", "gender":"female"},
	{"label":"👩‍🦱 المحامية الشقية", "gender":"female"},
	{"label":"👩‍🏫 المحامية الذكية", "gender":"female"},
	{"label":"👨‍💼 المحامي الكلاسيكي", "gender":"male"},
	{"label":"🧔 المحامي الجريء", "gender":"male"},
	{"label":"👨‍🏫 المحامي الذكي", "gender":"male"},
	{"label":"🕵️ المحقق الساخر", "gender":"male"}
]
var current_action := ""
var current_target := Vector3.ZERO

var camera_yaw := 0.0
var camera_pitch := -0.18
var camera_distance := 7.5
var car_speed := 0.0
var walk_speed := 5.2
var run_speed := 8.8
var jump_force := 7.0
var health := 100
var armor := 0
var objective_distance := 0.0
var game_time_minutes := 390.0
var npc_root: Node3D
var traffic_root: Node3D
var npcs: Array[CharacterBody3D] = []
var npc_targets: Array[Vector3] = []
var traffic_cars: Array[CharacterBody3D] = []
var traffic_dirs: Array[Vector3] = []
var minimap_panel: PanelContainer
var minimap_view: Control
var quality_level := 2
var sky_material: ProceduralSkyMaterial
var sun_light: DirectionalLight3D

var home_desk_pos := Vector3(0, 0.5, 2.2)
var station_file_pos := Vector3(0, 0.5, -24.5)
var interrogation_pos := Vector3(4.2, 0.5, -24.5)
var crime_evidence_pos := Vector3(22.0, 0.5, -15.0)
var clothes_shop_pos := Vector3(-20.0, 0.5, -10.0)
var car_shop_pos := Vector3(-33.0, 0.5, -10.0)
var home_shop_pos := Vector3(-7.0, 0.5, -10.0)
var garage_pos := Vector3(-4.0, 0.5, -5.5)

# مداخل أماكن القصة في المدينة.
var home_entrance_pos := Vector3(0.0, 0.5, -4.55)
var station_entrance_pos := Vector3(0.0, 0.5, -26.2)
var restaurant_entrance_pos := Vector3(23.0, 0.5, -16.15)

# أماكن القصة الداخلية معمولة في منطقة منفصلة عن المدينة.
var story_return_pos: Vector3 = Vector3.ZERO

var story_home_spawn := Vector3(300.0, 1.0, -4.8)
var story_home_exit := Vector3(300.0, 0.5, -4.4)
var story_home_desk := Vector3(300.0, 0.5, -13.0)

var story_station_spawn := Vector3(334.0, 1.0, -4.8)
var story_station_exit := Vector3(334.0, 0.5, -4.4)
var story_station_file := Vector3(330.0, 0.5, -13.6)
var story_station_interrogation := Vector3(339.0, 0.5, -13.2)

var story_restaurant_spawn := Vector3(372.0, 1.0, -4.8)
var story_restaurant_exit := Vector3(372.0, 0.5, -4.4)
var story_restaurant_evidence := Vector3(375.0, 0.5, -13.4)

# المحلات الداخلية معمولة في منطقة بعيدة عن المدينة، واللاعب يدخلها من الأبواب.
var current_interior: String = ""
var interior_return_pos: Vector3 = Vector3.ZERO

var clothes_inside_spawn := Vector3(210.0, 1.0, -4.8)
var clothes_inside_exit := Vector3(210.0, 0.5, -4.4)
var clothes_inside_counter := Vector3(210.0, 0.5, -14.0)

var car_inside_spawn := Vector3(238.0, 1.0, -3.8)
var car_inside_exit := Vector3(238.0, 0.5, -3.5)
var car_inside_counter := Vector3(243.0, 0.5, -15.0)

var home_inside_spawn := Vector3(268.0, 1.0, -4.8)
var home_inside_exit := Vector3(268.0, 0.5, -4.4)
var home_inside_counter := Vector3(268.0, 0.5, -14.0)

var ui_layer: CanvasLayer
var hud_panel: PanelContainer
var money_label: Label
var file_label: Label
var objective_label: Label
var distance_label: Label
var clock_label: Label
var status_label: Label
var prompt_label: Label
var dialogue_panel: PanelContainer
var dialogue_label: Label

var menu_layer: CanvasLayer
var menu_root: Control
var menu_panel: PanelContainer
var auth_mode := "login"
var auth_email: LineEdit
var auth_pass: LineEdit
var current_account_id := ""
var current_account_email := ""

var online_backend: Node
var online_setup_url: LineEdit
var online_setup_key: LineEdit
var online_cloud_save_cache: Dictionary = {}
var online_load_context := ""
var online_status_message := ""

# Mobile / touch input. Desktop keyboard+mouse remains unchanged.
var mobile_input: Node
var touch_controls_enabled: bool = false

var auth_message: Label
var name_input: LineEdit
var character_next_button: Button

var suspects := [
	{"name":"سيد السواق", "icon":"🚕", "line":"أنا كنت موصل طلبات طول الليل. وبعدين أنا ما بحبش الثوم... بيبوظ الهيبة."},
	{"name":"رمزي الجرسون", "icon":"🧑‍🍳", "line":"كنت بقفل الصالة. شوفت واحد داخل ناحية المخزن بقميص أحمر."},
	{"name":"هشام المحاسب", "icon":"🧾", "line":"أنا كنت براجع الحسابات. آخر حاجة ناقصة عندي سبعة وأربعين جنيه... مش كرتونة كشري."},
	{"name":"فتحي المخزنجي", "icon":"📦", "line":"أنا؟ مستحيل! القميص الأحمر ده قديم أصلاً، والزرار اللي ناقص منه وقع من أسبوع!"},
	{"name":"بولا الدليفري", "icon":"🛵", "line":"أنا كنت بره المطعم. ولو كنت خدت الكرتونة كنت هسيب لكم الإيصال على الأقل."}
]

func _g(male_text: String, female_text: String) -> String:
	if character_gender == "female":
		return female_text
	return male_text


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_build_world()
	_build_player()
	_build_camera()
	_build_hud()
	_build_mobile_input()
	_build_menu_layer()
	_build_online_backend()

	# Phones start on Low quality automatically. Desktop keeps High.
	if touch_controls_enabled:
		quality_level = 0
		_on_quality_selected(0)

	_show_start_menu()


func _build_online_backend() -> void:
	var backend_script: Script = load("res://scripts/OnlineBackend.gd") as Script
	if backend_script == null:
		online_status_message = "OnlineBackend.gd مش موجود."
		return

	online_backend = backend_script.new() as Node
	add_child(online_backend)

	online_backend.connect("auth_completed", Callable(self, "_on_online_auth_completed"))
	online_backend.connect("cloud_save_completed", Callable(self, "_on_online_cloud_save_completed"))
	online_backend.connect("cloud_load_completed", Callable(self, "_on_online_cloud_load_completed"))


func _online_is_configured() -> bool:
	if online_backend == null:
		return false
	return bool(online_backend.call("is_configured"))


func _online_has_session() -> bool:
	if online_backend == null:
		return false
	return bool(online_backend.call("has_session"))


func _build_mobile_input() -> void:
	var mobile_script: Script = load("res://scripts/MobileInput.gd") as Script
	if mobile_script == null:
		return

	mobile_input = mobile_script.new() as Node
	add_child(mobile_input)

	touch_controls_enabled = bool(mobile_input.call("is_touch_enabled"))
	mobile_input.connect("look_delta", Callable(self, "_on_mobile_look_delta"))
	mobile_input.connect("interact_pressed", Callable(self, "_on_mobile_interact"))
	mobile_input.connect("bag_pressed", Callable(self, "_on_mobile_bag"))
	mobile_input.connect("pause_pressed", Callable(self, "_on_mobile_pause"))


func _sync_mobile_controls_visibility() -> void:
	if mobile_input == null:
		return
	mobile_input.call("set_gameplay_visible", game_active and overlay_mode == "")


func _movement_input() -> Vector2:
	var input_vec: Vector2 = Vector2.ZERO

	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		input_vec.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		input_vec.y += 1.0
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		input_vec.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		input_vec.x += 1.0

	if input_vec.length() > 1.0:
		input_vec = input_vec.normalized()

	if mobile_input != null and touch_controls_enabled:
		var mobile_vec: Vector2 = mobile_input.call("get_move_vector")
		if mobile_vec.length() > input_vec.length():
			input_vec = mobile_vec

	return input_vec


func _run_requested() -> bool:
	if Input.is_key_pressed(KEY_SHIFT):
		return true
	if mobile_input != null and touch_controls_enabled:
		return bool(mobile_input.call("is_run_held"))
	return false


func _jump_requested() -> bool:
	if Input.is_key_pressed(KEY_SPACE):
		return true
	if mobile_input != null and touch_controls_enabled:
		return bool(mobile_input.call("is_jump_held"))
	return false


func _on_mobile_look_delta(relative: Vector2) -> void:
	if not game_active:
		return
	camera_yaw -= relative.x * 0.0060
	camera_pitch = clampf(camera_pitch - relative.y * 0.0048, -0.65, 0.35)


func _on_mobile_interact() -> void:
	if game_active:
		_do_interaction()


func _on_mobile_bag() -> void:
	if game_active:
		_open_case_bag()


func _on_mobile_pause() -> void:
	if game_active:
		_open_pause_menu()


func _set_gameplay_mouse_mode() -> void:
	if touch_controls_enabled:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)



# -----------------------------------------------------------------------------
# WORLD
# -----------------------------------------------------------------------------

func _build_world() -> void:
	var env_node := WorldEnvironment.new()
	env_node.name = "WorldEnvironment"
	var env := Environment.new()

	sky_material = ProceduralSkyMaterial.new()
	sky_material.sky_top_color = Color(0.12, 0.36, 0.68)
	sky_material.sky_horizon_color = Color(0.72, 0.80, 0.86)
	sky_material.ground_bottom_color = Color(0.12, 0.10, 0.08)
	sky_material.ground_horizon_color = Color(0.58, 0.52, 0.42)
	sky_material.sun_angle_max = 18.0
	sky_material.sun_curve = 0.08

	var sky := Sky.new()
	sky.sky_material = sky_material
	env.sky = sky
	env.background_mode = Environment.BG_SKY
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.reflected_light_source = Environment.REFLECTION_SOURCE_SKY
	env.ambient_light_energy = 0.72
	env_node.environment = env
	add_child(env_node)

	sun_light = DirectionalLight3D.new()
	sun_light.name = "Sun"
	sun_light.rotation_degrees = Vector3(-48, -30, 0)
	sun_light.light_color = Color(1.0, 0.92, 0.78)
	sun_light.light_energy = 1.25
	sun_light.shadow_enabled = true
	add_child(sun_light)

	_make_box("Ground", Vector3(0, -0.25, -18), Vector3(170, 0.5, 170), Color(0.48, 0.42, 0.28), true)

	# شوارع رئيسية
	_make_box("Road_NS", Vector3(0, 0.02, -18), Vector3(10, 0.05, 138), Color(0.12, 0.13, 0.14), false)
	_make_box("Road_EW", Vector3(2, 0.025, -15), Vector3(138, 0.05, 10), Color(0.12, 0.13, 0.14), false)
	_make_box("Road_Side_North", Vector3(-34, 0.024, -39), Vector3(54, 0.05, 7), Color(0.13, 0.14, 0.15), false)
	_make_box("Road_Side_South", Vector3(35, 0.024, 18), Vector3(60, 0.05, 7), Color(0.13, 0.14, 0.15), false)
	_make_box("Road_Side_West", Vector3(-37, 0.024, 8), Vector3(7, 0.05, 48), Color(0.13, 0.14, 0.15), false)
	_make_box("Road_Side_East", Vector3(39, 0.024, -36), Vector3(7, 0.05, 48), Color(0.13, 0.14, 0.15), false)

	# علامات الطريق
	for z in range(-72, 46, 6):
		_make_box("Dash", Vector3(0, 0.055, z), Vector3(0.18, 0.03, 2.2), Color(0.82, 0.78, 0.58), false)
	for x in range(-66, 70, 6):
		_make_box("Dash2", Vector3(x, 0.06, -15), Vector3(2.2, 0.03, 0.18), Color(0.82, 0.78, 0.58), false)

	_build_sidewalks_and_props()
	_build_house()
	_build_station()
	_build_crime_scene()
	_build_dealership()
	_build_shop_interiors()
	_build_story_interiors()
	_build_city_blocks()
	_build_far_city()
	_build_crosswalks()
	_build_street_furniture()
	_build_npcs()
	_build_traffic()

	_make_marker(station_entrance_pos, "قسم الشرطة", Color(0.85, 0.65, 0.16))
	_make_marker(restaurant_entrance_pos, "مطعم عم رجب", Color(0.85, 0.20, 0.12))
	_make_marker(home_entrance_pos, "بيت فلفل", Color(0.24, 0.45, 0.78))
	_make_marker(clothes_shop_pos, "محل اللبس", Color(0.84, 0.28, 0.62))
	_make_marker(car_shop_pos, "معرض العربيات", Color(0.18, 0.58, 0.48))
	_make_marker(home_shop_pos, "مكتب تطوير البيت", Color(0.95, 0.66, 0.18))


func _build_sidewalks_and_props() -> void:
	# أرصفة حول الشوارع عشان الإحساس يبقى أقرب لعالم مفتوح حقيقي.
	var sidewalk := Color(0.46, 0.46, 0.43)
	_make_box("Sidewalk_L", Vector3(-6.1, 0.03, -18), Vector3(2.2, 0.06, 138), sidewalk, false)
	_make_box("Sidewalk_R", Vector3(6.1, 0.03, -18), Vector3(2.2, 0.06, 138), sidewalk, false)
	_make_box("Sidewalk_T", Vector3(2, 0.03, -21.2), Vector3(138, 0.06, 2.2), sidewalk, false)
	_make_box("Sidewalk_B", Vector3(2, 0.03, -8.8), Vector3(138, 0.06, 2.2), sidewalk, false)

	# أعمدة إنارة بسيطة.
	var lamp_positions: Array[Vector3] = [
		Vector3(-6.1,0,-58), Vector3(6.1,0,-56),
		Vector3(-6.1,0,-42), Vector3(6.1,0,-40),
		Vector3(-6.1,0,-26), Vector3(6.1,0,-24),
		Vector3(-6.1,0,-10), Vector3(6.1,0,-8),
		Vector3(-6.1,0,6), Vector3(6.1,0,8),
		Vector3(-6.1,0,22), Vector3(6.1,0,24),
		Vector3(-30,0,-21), Vector3(-18,0,-21), Vector3(-6,0,-21),
		Vector3(12,0,-9), Vector3(24,0,-9), Vector3(36,0,-9),
		Vector3(-42,0,-9), Vector3(-54,0,-9)
	]
	for p in lamp_positions:
		_make_box("LampPost", p + Vector3(0,2.3,0), Vector3(0.16,4.6,0.16), Color(0.12,0.12,0.12), true)
		var lamp := OmniLight3D.new()
		lamp.position = p + Vector3(0,4.7,0)
		lamp.omni_range = 8.0
		lamp.light_energy = 0.45
		lamp.light_color = Color(1.0,0.78,0.48)
		add_child(lamp)

	# حواجز وأكشاك لإعطاء الشوارع تفاصيل.
	for x in [-26.0, -17.0, 17.0, 27.0]:
		_make_box("Kiosk", Vector3(x,0.8,-7.0), Vector3(2.2,1.6,2.0), Color(0.32,0.25,0.18), true)


func _build_npcs() -> void:
	npc_root = Node3D.new()
	npc_root.name = "NPCs"
	add_child(npc_root)

	var spawn_points: Array[Vector3] = [
		Vector3(-7,0.9,-2), Vector3(7,0.9,-5), Vector3(-7,0.9,-18),
		Vector3(7,0.9,-23), Vector3(-13,0.9,-11), Vector3(14,0.9,-11),
		Vector3(18,0.9,-8), Vector3(-18,0.9,-22), Vector3(24,0.9,-12),
		Vector3(-23,0.9,-12), Vector3(-8,0.9,-40), Vector3(8,0.9,-42),
		Vector3(-28,0.9,-9), Vector3(33,0.9,-9), Vector3(-32,0.9,12),
		Vector3(30,0.9,14), Vector3(-3,0.9,20), Vector3(3,0.9,22)
	]

	for i in range(spawn_points.size()):
		var npc := CharacterBody3D.new()
		npc.name = "NPC_%d" % i
		npc.position = spawn_points[i]
		npc.floor_snap_length = 0.3

		var cs := CollisionShape3D.new()
		var sh := CapsuleShape3D.new()
		sh.radius = 0.35
		sh.height = 1.6
		cs.shape = sh
		npc.add_child(cs)

		var body := MeshInstance3D.new()
		var mesh := CapsuleMesh.new()
		mesh.radius = 0.35
		mesh.height = 1.6
		body.mesh = mesh
		var mat := StandardMaterial3D.new()
		var colors: Array[Color] = [
			Color(0.24,0.31,0.42), Color(0.38,0.22,0.19),
			Color(0.18,0.38,0.27), Color(0.45,0.36,0.18),
			Color(0.30,0.24,0.40)
		]
		mat.albedo_color = colors[i % colors.size()]
		body.material_override = mat
		npc.add_child(body)

		var head := MeshInstance3D.new()
		var hm := SphereMesh.new()
		hm.radius = 0.28
		hm.height = 0.56
		head.mesh = hm
		head.position = Vector3(0,0.95,0)
		var skin := StandardMaterial3D.new()
		skin.albedo_color = Color(0.70,0.52,0.40)
		head.material_override = skin
		npc.add_child(head)

		npc_root.add_child(npc)
		npcs.append(npc)

		# كل NPC يمشي لنقطة معاكسة على الرصيف ويرجع.
		var target: Vector3 = spawn_points[i] + Vector3(0, 0, 8.0 if i % 2 == 0 else -8.0)
		npc_targets.append(target)


func _build_traffic() -> void:
	traffic_root = Node3D.new()
	traffic_root.name = "Traffic"
	add_child(traffic_root)

	var starts: Array[Vector3] = [
		Vector3(-1.8,0.6,-38), Vector3(1.8,0.6,22),
		Vector3(-26,0.6,-13.2), Vector3(30,0.6,-16.8)
	]
	var dirs: Array[Vector3] = [
		Vector3(0,0,1), Vector3(0,0,-1),
		Vector3(1,0,0), Vector3(-1,0,0)
	]

	for i in range(starts.size()):
		var c := CharacterBody3D.new()
		c.name = "TrafficCar_%d" % i
		c.position = starts[i]
		c.floor_snap_length = 0.25

		var cs := CollisionShape3D.new()
		var sh := BoxShape3D.new()
		sh.size = Vector3(1.7,0.9,3.2)
		cs.shape = sh
		c.add_child(cs)

		var body := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = Vector3(1.7,0.75,3.2)
		body.mesh = bm
		var mat := StandardMaterial3D.new()
		var car_colors: Array[Color] = [
			Color(0.55,0.12,0.10), Color(0.10,0.22,0.48),
			Color(0.60,0.58,0.54), Color(0.10,0.10,0.11)
		]
		mat.albedo_color = car_colors[i % car_colors.size()]
		mat.metallic = 0.35
		body.material_override = mat
		c.add_child(body)

		var cabin := MeshInstance3D.new()
		var cm := BoxMesh.new()
		cm.size = Vector3(1.4,0.55,1.6)
		cabin.mesh = cm
		cabin.position = Vector3(0,0.62,-0.15)
		var glass := StandardMaterial3D.new()
		glass.albedo_color = Color(0.10,0.16,0.20)
		glass.metallic = 0.15
		cabin.material_override = glass
		c.add_child(cabin)

		if abs(dirs[i].x) > 0.5:
			c.rotation.y = -PI/2.0 if dirs[i].x > 0 else PI/2.0
		elif dirs[i].z > 0:
			c.rotation.y = PI

		traffic_root.add_child(c)
		traffic_cars.append(c)
		traffic_dirs.append(dirs[i])


func _update_npcs(delta: float) -> void:
	if npcs.is_empty():
		return

	for i in range(npcs.size()):
		var npc := npcs[i]
		if not is_instance_valid(npc):
			continue
		if not npc.is_on_floor():
			npc.velocity.y -= 18.0 * delta
		else:
			npc.velocity.y = -0.4

		var target := npc_targets[i]
		var flat := target - npc.global_position
		flat.y = 0
		if flat.length() < 0.8:
			# عكس اتجاه المشي بدل إنشاء هدف عشوائي غير متوقع.
			npc_targets[i] = npc.global_position - flat.normalized() * 8.0 if flat.length() > 0.01 else npc.global_position + Vector3(0,0,8)
			target = npc_targets[i]
			flat = target - npc.global_position
			flat.y = 0

		if flat.length() > 0.05:
			var dir := flat.normalized()
			npc.velocity.x = dir.x * 1.65
			npc.velocity.z = dir.z * 1.65
			npc.rotation.y = lerp_angle(npc.rotation.y, atan2(-dir.x,-dir.z), min(1.0,7.0*delta))
		else:
			npc.velocity.x = 0
			npc.velocity.z = 0
		npc.move_and_slide()


func _update_traffic(delta: float) -> void:
	for i in range(traffic_cars.size()):
		var c := traffic_cars[i]
		if not is_instance_valid(c):
			continue
		if not c.is_on_floor():
			c.velocity.y -= 18.0 * delta
		else:
			c.velocity.y = -0.4

		var dir := traffic_dirs[i]
		c.velocity.x = dir.x * 7.0
		c.velocity.z = dir.z * 7.0
		c.move_and_slide()

		# تدوير المرور عند حدود الخريطة.
		if c.global_position.z > 48:
			c.global_position.z = -72
		elif c.global_position.z < -74:
			c.global_position.z = 46
		if c.global_position.x > 72:
			c.global_position.x = -70
		elif c.global_position.x < -72:
			c.global_position.x = 70


func _update_day_night() -> void:
	var env_node := get_node_or_null("WorldEnvironment") as WorldEnvironment
	if env_node == null or env_node.environment == null:
		return

	var hour: float = fmod(game_time_minutes / 60.0, 24.0)
	var daylight: float = clampf(sin((hour - 6.0) / 12.0 * PI), 0.0, 1.0)
	var sunrise: float = clampf(1.0 - absf(hour - 7.0) / 2.2, 0.0, 1.0)

	if sky_material != null:
		var night_top := Color(0.015,0.025,0.07)
		var day_top := Color(0.10,0.34,0.70)
		var night_horizon := Color(0.07,0.08,0.13)
		var day_horizon := Color(0.72,0.81,0.88)
		var warm_horizon := Color(0.95,0.48,0.24)

		sky_material.sky_top_color = night_top.lerp(day_top, daylight)
		sky_material.sky_horizon_color = night_horizon.lerp(day_horizon, daylight).lerp(warm_horizon, sunrise * 0.55)
		sky_material.ground_horizon_color = Color(0.13,0.12,0.12).lerp(Color(0.57,0.50,0.39), daylight)

	env_node.environment.ambient_light_energy = lerpf(0.22,0.74,daylight)

	if sun_light != null:
		sun_light.light_energy = lerpf(0.08,1.30,daylight)
		sun_light.light_color = Color(0.46,0.52,0.72).lerp(Color(1.0,0.92,0.78), daylight)
		sun_light.shadow_enabled = quality_level >= 1

func _update_minimap() -> void:
	if minimap_panel != null:
		minimap_panel.visible = current_interior == ""

	if current_interior != "":
		return

	if minimap_view == null:
		return
	minimap_view.call("set_map_state", _player_pos(), _objective_position(), camera_yaw, in_car)

func _build_house() -> void:
	var wall := Color(0.78, 0.67, 0.47)
	var trim := Color(0.28, 0.36, 0.42)
	_make_box("HomeFloor", Vector3(0, 0.03, 0), Vector3(8, 0.06, 8), Color(0.62, 0.53, 0.38), false)
	_make_box("HomeBack", Vector3(0, 1.6, 4), Vector3(8, 3.2, 0.25), wall, true)
	_make_box("HomeLeft", Vector3(-4, 1.6, 0), Vector3(0.25, 3.2, 8), wall, true)
	_make_box("HomeRight", Vector3(4, 1.6, 0), Vector3(0.25, 3.2, 8), wall, true)
	_make_box("HomeFrontL", Vector3(-2.8, 1.6, -4), Vector3(2.4, 3.2, 0.25), wall, true)
	_make_box("HomeFrontR", Vector3(2.8, 1.6, -4), Vector3(2.4, 3.2, 0.25), wall, true)
	_make_box("HomeRoof", Vector3(0, 3.25, 0), Vector3(8.3, 0.2, 8.3), trim, true)
	_make_box("Desk", home_desk_pos + Vector3(0,0.3,0), Vector3(2.2, 0.65, 1.0), Color(0.30, 0.20, 0.12), true)
	_make_box("HomeAwning", Vector3(0,2.65,-4.15), Vector3(3.0,0.12,0.75), Color(0.22,0.32,0.42), false)
	_make_sign(Vector3(0, 3.65, -3.9), "بيت المحقق فلفل")

func _build_station() -> void:
	_make_box("Station", Vector3(0, 2.2, -30), Vector3(14, 4.4, 7), Color(0.64, 0.68, 0.66), true)
	_make_box("StationDoor", Vector3(0, 1.2, -26.45), Vector3(2.3, 2.4, 0.15), Color(0.16, 0.23, 0.27), false)
	_make_box("StationGlassL", Vector3(-3.6,2.15,-26.42), Vector3(2.6,1.45,0.08), Color(0.28,0.48,0.58), false)
	_make_box("StationGlassR", Vector3(3.6,2.15,-26.42), Vector3(2.6,1.45,0.08), Color(0.28,0.48,0.58), false)
	_make_sign(Vector3(0, 4.9, -26.4), "قسم الشرطة")
	_make_box("InterrogationWing", Vector3(5.0, 1.4, -25.5), Vector3(4.2, 2.8, 2.6), Color(0.43, 0.47, 0.48), true)

func _build_crime_scene() -> void:
	_make_box("Restaurant", Vector3(23, 1.8, -20), Vector3(11, 3.6, 7), Color(0.62, 0.32, 0.18), true)
	_make_box("RestaurantFront", Vector3(23, 1.0, -16.45), Vector3(5.0, 2.0, 0.12), Color(0.82, 0.70, 0.40), false)
	_make_box("RestaurantAwning", Vector3(23,2.65,-16.25), Vector3(6.5,0.16,1.0), Color(0.72,0.22,0.12), false)
	_make_sign(Vector3(23, 4.0, -16.4), "مطعم عم رجب")
	_make_box("CrimeCrate", Vector3(22, 0.45, -15.2), Vector3(1.1, 0.9, 1.1), Color(0.40, 0.25, 0.10), true)

func _build_dealership() -> void:
	# محل لبس مستقل
	_make_box("ClothesShop", Vector3(-20, 1.7, -14), Vector3(10, 3.4, 6), Color(0.46, 0.24, 0.42), true)
	_make_box("ClothesShopGlass", Vector3(-20,1.75,-10.95), Vector3(7.0,2.25,0.08), Color(0.48,0.30,0.52), false)
	_make_box("ClothesShopAwning", Vector3(-20,2.70,-10.35), Vector3(6.2,0.14,0.90), Color(0.74,0.24,0.56), false)
	_make_sign(Vector3(-20, 3.9, -10.9), "أتيليه فلفل للملابس")

	# معرض عربيات مستقل
	_make_box("CarShop", Vector3(-33, 1.8, -14), Vector3(10, 3.6, 6), Color(0.22, 0.34, 0.38), true)
	_make_box("CarShopGlass", Vector3(-33,1.85,-10.95), Vector3(7.2,2.4,0.08), Color(0.18,0.42,0.52), false)
	_make_sign(Vector3(-33, 3.95, -10.9), "معرض فلفل للعربيات")

	# مكتب تطوير البيت مستقل
	_make_box("HomeUpgradeShop", Vector3(-7, 1.7, -14), Vector3(10, 3.4, 6), Color(0.52, 0.40, 0.22), true)
	_make_box("HomeUpgradeShopGlass", Vector3(-7,1.75,-10.95), Vector3(7.0,2.25,0.08), Color(0.54,0.40,0.20), false)
	_make_box("HomeUpgradeShopAwning", Vector3(-7,2.65,-10.35), Vector3(6.0,0.14,0.90), Color(0.84,0.60,0.20), false)
	_make_sign(Vector3(-7, 3.9, -10.9), "مكتب تطوير البيت")

	# جراج العربية عند البيت
	_make_box("GaragePad", garage_pos, Vector3(5, 0.08, 4), Color(0.26, 0.26, 0.26), false)

func _build_shop_interiors() -> void:
	# أتيليه الملابس
	_build_room_shell(
		"ClothesInterior",
		Vector3(210,0,-10),
		Vector2(11,12),
		Color(0.34,0.20,0.32),
		Color(0.20,0.17,0.20)
	)
	_make_sign(Vector3(210,3.3,-15.78), "أتيليه فلفل — الملابس")
	_make_box("ClothesCounter", Vector3(210,0.65,-14.2), Vector3(4.2,1.3,0.8), Color(0.26,0.13,0.10), true)

	# ترابيزات ورَكّات لبس
	for x: float in [-3.6, 3.6]:
		_make_box("ClothesRackPole", Vector3(210+x,1.25,-10.0), Vector3(0.15,2.5,0.15), Color(0.16,0.16,0.17), false)
		_make_box("ClothesRackBar", Vector3(210+x,2.35,-10.0), Vector3(0.15,0.15,4.6), Color(0.16,0.16,0.17), false)
		for i in range(4):
			var garment_color: Color = [
				Color(0.12,0.23,0.42),
				Color(0.38,0.12,0.20),
				Color(0.17,0.35,0.25),
				Color(0.15,0.15,0.16)
			][i]
			_make_box(
				"Garment_%s_%d" % [str(x), i],
				Vector3(210+x,1.55,-11.4 + float(i)*0.95),
				Vector3(0.12,1.10,0.65),
				garment_color,
				false
			)

	_build_mannequin(Vector3(208.0,0.95,-7.2), Color(0.10,0.10,0.11))
	_build_mannequin(Vector3(212.0,0.95,-7.2), Color(0.28,0.16,0.36))

	_make_marker(clothes_inside_counter, "الكاشير", Color(0.88,0.35,0.67))
	_make_marker(clothes_inside_exit, "الخروج", Color(0.42,0.72,0.95))

	# معرض العربيات
	_build_room_shell(
		"CarInterior",
		Vector3(238,0,-10),
		Vector2(18,14),
		Color(0.18,0.27,0.31),
		Color(0.17,0.18,0.19)
	)
	_make_sign(Vector3(238,3.4,-16.78), "معرض فلفل للعربيات")
	_make_box("CarCounter", Vector3(243.0,0.65,-15.2), Vector3(4.0,1.3,0.9), Color(0.20,0.24,0.26), true)

	_build_display_car(Vector3(234.2,0.58,-10.5), Color(0.12,0.27,0.48))
	_build_display_car(Vector3(240.0,0.58,-10.5), Color(0.52,0.12,0.08))
	_build_display_car(Vector3(237.0,0.58,-14.0), Color(0.12,0.12,0.13))

	_make_box("ShowroomPodium", Vector3(234.2,0.10,-10.5), Vector3(4.4,0.20,6.0), Color(0.27,0.27,0.27), false)
	_make_box("ShowroomPodium2", Vector3(240.0,0.10,-10.5), Vector3(4.4,0.20,6.0), Color(0.27,0.27,0.27), false)

	_make_marker(car_inside_counter, "المبيعات", Color(0.22,0.72,0.63))
	_make_marker(car_inside_exit, "الخروج", Color(0.42,0.72,0.95))

	# مكتب تطوير البيت
	_build_room_shell(
		"HomeInterior",
		Vector3(268,0,-10),
		Vector2(12,12),
		Color(0.46,0.35,0.20),
		Color(0.31,0.28,0.23)
	)
	_make_sign(Vector3(268,3.3,-15.78), "مكتب تطوير البيت")
	_make_box("HomeUpgradeCounter", Vector3(268,0.65,-14.2), Vector3(4.2,1.3,0.8), Color(0.30,0.20,0.12), true)

	# نموذج صالون
	_make_box("DisplaySofaSeat", Vector3(265.2,0.55,-9.5), Vector3(3.6,0.65,1.4), Color(0.38,0.26,0.18), true)
	_make_box("DisplaySofaBack", Vector3(265.2,1.25,-10.0), Vector3(3.6,1.1,0.40), Color(0.38,0.26,0.18), true)
	_make_box("DisplayCoffeeTable", Vector3(265.2,0.42,-7.4), Vector3(2.4,0.25,1.2), Color(0.34,0.21,0.11), true)

	# نموذج مكتب
	_make_box("DisplayDesk", Vector3(271.0,0.75,-9.6), Vector3(3.3,1.2,1.4), Color(0.32,0.20,0.10), true)
	_make_box("DisplayChairSeat", Vector3(271.0,0.55,-7.8), Vector3(1.0,0.18,1.0), Color(0.18,0.18,0.18), true)
	_make_box("DisplayChairBack", Vector3(271.0,1.15,-7.35), Vector3(1.0,1.1,0.16), Color(0.18,0.18,0.18), true)

	_make_marker(home_inside_counter, "مهندس التطوير", Color(0.95,0.68,0.22))
	_make_marker(home_inside_exit, "الخروج", Color(0.42,0.72,0.95))


func _build_room_shell(prefix: String, center: Vector3, room_size: Vector2, wall_color: Color, floor_color: Color) -> void:
	var width: float = room_size.x
	var depth: float = room_size.y
	var half_w: float = width * 0.5
	var half_d: float = depth * 0.5

	_make_box(prefix + "Floor", center + Vector3(0,0.02,0), Vector3(width,0.06,depth), floor_color, true)
	_make_box(prefix + "Back", center + Vector3(0,1.65,-half_d), Vector3(width,3.3,0.24), wall_color, true)
	_make_box(prefix + "Left", center + Vector3(-half_w,1.65,0), Vector3(0.24,3.3,depth), wall_color, true)
	_make_box(prefix + "Right", center + Vector3(half_w,1.65,0), Vector3(0.24,3.3,depth), wall_color, true)

	# واجهة بباب مفتوح في المنتصف.
	var side_width: float = (width - 2.4) * 0.5
	_make_box(prefix + "FrontL", center + Vector3(-(1.2 + side_width*0.5),1.65,half_d), Vector3(side_width,3.3,0.24), wall_color, true)
	_make_box(prefix + "FrontR", center + Vector3(1.2 + side_width*0.5,1.65,half_d), Vector3(side_width,3.3,0.24), wall_color, true)
	_make_box(prefix + "Ceiling", center + Vector3(0,3.30,0), Vector3(width,0.16,depth), Color(0.22,0.22,0.22), true)

	# إضاءة داخلية
	var light := OmniLight3D.new()
	light.position = center + Vector3(0,2.55,0)
	light.light_color = Color(1.0,0.91,0.76)
	light.light_energy = 1.6
	light.omni_range = maxf(width,depth) * 0.72
	light.shadow_enabled = quality_level >= 2
	add_child(light)


func _build_mannequin(pos: Vector3, suit_color: Color) -> void:
	_make_box("MannequinBody", pos + Vector3(0,0.45,0), Vector3(0.65,0.95,0.35), suit_color, false)

	var head := MeshInstance3D.new()
	var head_mesh := SphereMesh.new()
	head_mesh.radius = 0.25
	head_mesh.height = 0.50
	head.mesh = head_mesh
	head.position = pos + Vector3(0,1.18,0)
	var head_mat := StandardMaterial3D.new()
	head_mat.albedo_color = Color(0.70,0.57,0.45)
	head_mat.roughness = 0.75
	head.material_override = head_mat
	add_child(head)

	_make_box("MannequinLegL", pos + Vector3(-0.17,-0.35,0), Vector3(0.20,0.75,0.24), suit_color, false)
	_make_box("MannequinLegR", pos + Vector3(0.17,-0.35,0), Vector3(0.20,0.75,0.24), suit_color, false)


func _build_display_car(pos: Vector3, body_color: Color) -> void:
	_make_box("DisplayCarBody", pos + Vector3(0,0.40,0), Vector3(2.1,0.75,4.0), body_color, false)
	_make_box("DisplayCarCabin", pos + Vector3(0,1.0,-0.15), Vector3(1.65,0.75,1.9), Color(0.13,0.22,0.28), false)

	var wheel_positions: Array[Vector3] = [
		Vector3(-1.02,0.28,-1.25),
		Vector3(1.02,0.28,-1.25),
		Vector3(-1.02,0.28,1.25),
		Vector3(1.02,0.28,1.25)
	]
	for wp: Vector3 in wheel_positions:
		var wheel := MeshInstance3D.new()
		var wheel_mesh := CylinderMesh.new()
		wheel_mesh.top_radius = 0.34
		wheel_mesh.bottom_radius = 0.34
		wheel_mesh.height = 0.22
		wheel.mesh = wheel_mesh
		wheel.position = pos + wp
		wheel.rotation_degrees = Vector3(0,0,90)

		var wheel_mat := StandardMaterial3D.new()
		wheel_mat.albedo_color = Color(0.035,0.035,0.035)
		wheel_mat.roughness = 0.95
		wheel.material_override = wheel_mat
		add_child(wheel)


func _build_story_interiors() -> void:
	# -----------------------------------------------------------------
	# بيت المحقق — مساحة داخلية فعلية
	# -----------------------------------------------------------------
	_build_room_shell(
		"StoryHome",
		Vector3(300,0,-10),
		Vector2(13,13),
		Color(0.66,0.55,0.39),
		Color(0.36,0.27,0.19)
	)
	_make_sign(Vector3(300,3.25,-16.38), "بيت فلفل")

	# مكتب القضية
	_make_box("StoryHomeDesk", Vector3(300,0.72,-13.1), Vector3(3.0,1.15,1.35), Color(0.29,0.18,0.09), true)
	_make_box("StoryHomeDeskDrawer", Vector3(300.8,0.42,-13.1), Vector3(0.75,0.62,1.15), Color(0.23,0.13,0.07), true)
	_make_marker(story_home_desk, "مكتب القضية", Color(0.31,0.56,0.95))

	# كنبة وترابيزة
	_make_box("StoryHomeSofaSeat", Vector3(296.7,0.55,-9.5), Vector3(3.8,0.68,1.45), Color(0.27,0.31,0.34), true)
	_make_box("StoryHomeSofaBack", Vector3(296.7,1.28,-10.0), Vector3(3.8,1.05,0.42), Color(0.27,0.31,0.34), true)
	_make_box("StoryHomeCoffeeTable", Vector3(296.7,0.42,-7.35), Vector3(2.6,0.24,1.25), Color(0.32,0.20,0.10), true)

	# سرير ودولاب
	_make_box("StoryHomeBedBase", Vector3(304.0,0.45,-9.8), Vector3(2.9,0.55,4.6), Color(0.39,0.27,0.18), true)
	_make_box("StoryHomeMattress", Vector3(304.0,0.82,-9.8), Vector3(2.7,0.32,4.25), Color(0.78,0.75,0.66), false)
	_make_box("StoryHomeWardrobe", Vector3(304.5,1.45,-14.5), Vector3(3.0,2.9,1.1), Color(0.30,0.20,0.11), true)

	# رف ملفات
	for i in range(4):
		_make_box(
			"HomeShelf_%d" % i,
			Vector3(296.0,0.55 + float(i)*0.55,-14.6),
			Vector3(2.7,0.12,0.70),
			Color(0.26,0.16,0.08),
			false
		)

	_make_marker(story_home_exit, "الخروج للمدينة", Color(0.40,0.76,0.95))

	# -----------------------------------------------------------------
	# قسم الشرطة — استقبال + ملفات + استجواب
	# -----------------------------------------------------------------
	_build_room_shell(
		"StoryStation",
		Vector3(334,0,-10),
		Vector2(20,14),
		Color(0.46,0.51,0.52),
		Color(0.26,0.27,0.27)
	)
	_make_sign(Vector3(334,3.35,-16.85), "قسم الشرطة")

	# مكتب الاستقبال
	_make_box("StationReception", Vector3(334,0.72,-8.8), Vector3(6.5,1.25,1.1), Color(0.24,0.28,0.29), true)
	_make_box("StationReceptionTop", Vector3(334,1.42,-8.8), Vector3(6.7,0.12,1.2), Color(0.14,0.16,0.17), false)

	# كراسي انتظار
	for x: float in [-3.0,-1.0,1.0,3.0]:
		_make_box("StationChairSeat", Vector3(334+x,0.55,-6.2), Vector3(0.9,0.18,0.95), Color(0.17,0.21,0.22), true)
		_make_box("StationChairBack", Vector3(334+x,1.12,-5.78), Vector3(0.9,0.95,0.16), Color(0.17,0.21,0.22), true)

	# قسم الملفات
	_make_box("StationFilesDesk", Vector3(330.0,0.72,-13.6), Vector3(4.2,1.2,1.2), Color(0.31,0.24,0.15), true)
	for i in range(5):
		_make_box(
			"FileCabinet_%d" % i,
			Vector3(327.0,0.58 + float(i%2)*1.05,-11.0 - float(i/2)*1.35),
			Vector3(1.15,1.0,1.05),
			Color(0.30,0.34,0.35),
			true
		)
	_make_marker(story_station_file, "استلام ملف القضية", Color(0.92,0.70,0.18))

	# جناح الاستجواب
	_make_box("InterrogationDivider", Vector3(337.0,1.65,-12.5), Vector3(0.20,3.3,7.0), Color(0.30,0.33,0.34), true)
	_make_box("InterrogationTable", Vector3(339.0,0.72,-13.2), Vector3(3.1,1.0,1.45), Color(0.19,0.20,0.20), true)
	_make_box("InterrogationChairA", Vector3(339.0,0.48,-11.6), Vector3(0.9,0.16,0.9), Color(0.16,0.17,0.18), true)
	_make_box("InterrogationChairB", Vector3(339.0,0.48,-14.8), Vector3(0.9,0.16,0.9), Color(0.16,0.17,0.18), true)
	_make_marker(story_station_interrogation, "غرفة الاستجواب", Color(0.76,0.31,0.24))
	_make_marker(story_station_exit, "الخروج للمدينة", Color(0.40,0.76,0.95))

	# لمبات باردة للقسم
	var station_light_a := OmniLight3D.new()
	station_light_a.position = Vector3(330,2.55,-10)
	station_light_a.light_color = Color(0.74,0.86,1.0)
	station_light_a.light_energy = 1.2
	station_light_a.omni_range = 10.0
	station_light_a.shadow_enabled = quality_level >= 2
	add_child(station_light_a)

	var station_light_b := OmniLight3D.new()
	station_light_b.position = Vector3(339,2.55,-12)
	station_light_b.light_color = Color(0.74,0.86,1.0)
	station_light_b.light_energy = 1.0
	station_light_b.omni_range = 8.0
	station_light_b.shadow_enabled = quality_level >= 2
	add_child(station_light_b)

	# -----------------------------------------------------------------
	# مطعم عم رجب — صالة + كاونتر + مطبخ + مسرح الجريمة
	# -----------------------------------------------------------------
	_build_room_shell(
		"StoryRestaurant",
		Vector3(372,0,-10),
		Vector2(18,14),
		Color(0.56,0.28,0.17),
		Color(0.34,0.25,0.18)
	)
	_make_sign(Vector3(372,3.35,-16.85), "مطعم عم رجب")

	# ترابيزات وكراسي
	var table_positions: Array[Vector3] = [
		Vector3(368.3,0.68,-7.2),
		Vector3(372.0,0.68,-7.2),
		Vector3(375.7,0.68,-7.2),
		Vector3(368.3,0.68,-10.3),
		Vector3(372.0,0.68,-10.3)
	]
	for i in range(table_positions.size()):
		var tp: Vector3 = table_positions[i]
		_make_box("RestaurantTable_%d" % i, tp, Vector3(1.7,1.0,1.7), Color(0.33,0.19,0.08), true)
		_make_box("RestaurantChair_%dA" % i, tp + Vector3(0,0,-1.25), Vector3(0.8,0.75,0.8), Color(0.25,0.14,0.07), true)
		_make_box("RestaurantChair_%dB" % i, tp + Vector3(0,0,1.25), Vector3(0.8,0.75,0.8), Color(0.25,0.14,0.07), true)

	# الكاونتر
	_make_box("RestaurantCounter", Vector3(377.0,0.78,-9.0), Vector3(1.2,1.45,6.5), Color(0.48,0.26,0.10), true)
	_make_box("RestaurantCounterTop", Vector3(376.55,1.58,-9.0), Vector3(1.45,0.12,6.6), Color(0.69,0.50,0.27), false)

	# منطقة مطبخ / مخزن
	_make_box("KitchenDivider", Vector3(372.0,1.65,-12.0), Vector3(9.0,3.3,0.20), Color(0.40,0.24,0.17), true)
	_make_box("KitchenPrep", Vector3(369.5,0.75,-14.5), Vector3(4.0,1.0,1.3), Color(0.45,0.45,0.42), true)
	_make_box("CrimeKosharyCrate", Vector3(375.0,0.52,-13.4), Vector3(1.2,0.95,1.2), Color(0.38,0.23,0.09), true)

	# الدليل الرئيسي: زرار أحمر
	var evidence_mesh := MeshInstance3D.new()
	var evidence_sphere := SphereMesh.new()
	evidence_sphere.radius = 0.13
	evidence_sphere.height = 0.26
	evidence_mesh.mesh = evidence_sphere
	evidence_mesh.position = story_restaurant_evidence + Vector3(0,0.62,0)
	var evidence_mat := StandardMaterial3D.new()
	evidence_mat.albedo_color = Color(0.82,0.05,0.03)
	evidence_mat.emission_enabled = true
	evidence_mat.emission = Color(0.40,0.015,0.01)
	evidence_mesh.material_override = evidence_mat
	add_child(evidence_mesh)

	_make_marker(story_restaurant_evidence, "الدليل الرئيسي", Color(0.92,0.18,0.10))
	_make_marker(story_restaurant_exit, "الخروج للمدينة", Color(0.40,0.76,0.95))


func _build_city_blocks() -> void:
	var colors: Array[Color] = [
		Color(0.52,0.48,0.43),
		Color(0.63,0.58,0.50),
		Color(0.46,0.50,0.53),
		Color(0.70,0.61,0.47),
		Color(0.58,0.52,0.46)
	]
	var positions: Array[Vector3] = [
		Vector3(-15,2,-28), Vector3(16,2,-30),
		Vector3(-17,2,8), Vector3(16,2,7),
		Vector3(31,2,-4), Vector3(-31,2,-24),
		Vector3(-48,3,-30), Vector3(-49,2.5,-8), Vector3(-48,3.5,12),
		Vector3(47,3,-31), Vector3(47,2.5,-8), Vector3(46,3.5,13),
		Vector3(-24,2,-50), Vector3(1,2,-52), Vector3(27,2,-50),
		Vector3(-26,2,28), Vector3(0,2,30), Vector3(27,2,28)
	]
	var sizes: Array[Vector3] = [
		Vector3(8,4,8), Vector3(10,4,9),
		Vector3(10,4,8), Vector3(9,4,7),
		Vector3(8,4,10), Vector3(8,4,10),
		Vector3(11,6,11), Vector3(10,5,9), Vector3(11,7,10),
		Vector3(11,6,11), Vector3(10,5,9), Vector3(11,7,10),
		Vector3(10,5,10), Vector3(14,5,11), Vector3(10,5,10),
		Vector3(10,4,9), Vector3(13,4,10), Vector3(10,4,9)
	]

	for i in range(positions.size()):
		_make_box("Block_%d" % i, positions[i], sizes[i], colors[i % colors.size()], true)
		_add_windows_to_building(positions[i], sizes[i], i)
		_decorate_building(positions[i], sizes[i], i)

	var palm_positions: Array[Vector3] = [
		Vector3(-8,0,-10), Vector3(10,0,-8), Vector3(12,0,-22),
		Vector3(-12,0,-20), Vector3(28,0,-10), Vector3(-25,0,5),
		Vector3(38,0,8), Vector3(-40,0,-12), Vector3(0,0,20),
		Vector3(-2,0,-44), Vector3(18,0,22), Vector3(-18,0,22)
	]
	for p: Vector3 in palm_positions:
		_make_box("PalmTrunk", p + Vector3(0,1.5,0), Vector3(0.35,3,0.35), Color(0.36,0.24,0.13), true)
		var top := MeshInstance3D.new()
		var sphere := SphereMesh.new()
		sphere.radius = 1.35
		sphere.height = 2.35
		top.mesh = sphere
		top.position = p + Vector3(0,3.6,0)
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(0.12,0.34,0.13)
		mat.roughness = 0.92
		top.material_override = mat
		add_child(top)

func _build_far_city() -> void:
	# مباني ديكورية أكتر بعيدًا عن منطقة اللعب الأساسية عشان المدينة تبان أكبر.
	var far_colors: Array[Color] = [
		Color(0.45,0.45,0.48),
		Color(0.56,0.52,0.48),
		Color(0.40,0.42,0.44),
		Color(0.62,0.57,0.50)
	]
	var far_positions: Array[Vector3] = [
		Vector3(-66,3,-56), Vector3(-50,3,-62), Vector3(-32,3,-60), Vector3(-12,3,-60),
		Vector3(10,3,-61), Vector3(30,3,-60), Vector3(50,3,-62), Vector3(67,3,-56),
		Vector3(-68,3,40), Vector3(-48,3,46), Vector3(-26,3,44), Vector3(-5,3,45),
		Vector3(18,3,44), Vector3(40,3,46), Vector3(61,3,40),
		Vector3(-72,3,-20), Vector3(72,3,-20), Vector3(-72,3,8), Vector3(72,3,8)
	]
	var far_sizes: Array[Vector3] = [
		Vector3(12,6,12), Vector3(12,6,11), Vector3(12,6,10), Vector3(14,6,12),
		Vector3(13,6,11), Vector3(12,6,10), Vector3(12,6,11), Vector3(12,6,12),
		Vector3(12,6,12), Vector3(11,6,10), Vector3(12,6,11), Vector3(14,6,10),
		Vector3(12,6,11), Vector3(11,6,10), Vector3(12,6,12),
		Vector3(10,6,14), Vector3(10,6,14), Vector3(10,6,13), Vector3(10,6,13)
	]

	for i in range(far_positions.size()):
		_make_box("FarBlock_%d" % i, far_positions[i], far_sizes[i], far_colors[i % far_colors.size()], true)
		_add_windows_to_building(far_positions[i], far_sizes[i], i + 30)
		_decorate_building(far_positions[i], far_sizes[i], i + 30)

	var tower_positions: Array[Vector3] = [
		Vector3(-58,7,-28), Vector3(57,8,-31),
		Vector3(-55,6,22), Vector3(58,7,24),
		Vector3(24,9,-66), Vector3(-24,8,-67)
	]
	var tower_sizes: Array[Vector3] = [
		Vector3(13,14,12), Vector3(14,16,13),
		Vector3(12,12,12), Vector3(13,14,12),
		Vector3(15,18,14), Vector3(14,16,13)
	]
	for i in range(tower_positions.size()):
		var mix_amount: float = float(i) / float(maxi(1, tower_positions.size() - 1))
		var tower_color: Color = Color(0.36,0.39,0.42).lerp(Color(0.60,0.56,0.50), mix_amount)
		_make_box("Tower_%d" % i, tower_positions[i], tower_sizes[i], tower_color, true)
		_add_windows_to_building(tower_positions[i], tower_sizes[i], 80 + i)
		_decorate_building(tower_positions[i], tower_sizes[i], 80 + i)

func _add_windows_to_building(center: Vector3, size: Vector3, seed_index: int) -> void:
	var columns: int = maxi(2, int(size.x / 2.2))
	var rows: int = maxi(2, int(size.y / 1.65))
	var front_z: float = center.z - size.z * 0.5 - 0.04
	var side_x: float = center.x + size.x * 0.5 + 0.04
	var spacing_x: float = size.x / float(columns + 1)
	var spacing_y: float = size.y / float(rows + 1)

	for row in range(rows):
		for col in range(columns):
			if ((row * 7 + col * 3 + seed_index) % 11) == 0:
				continue
			var wx: float = center.x - size.x * 0.5 + spacing_x * float(col + 1)
			var wy: float = center.y - size.y * 0.5 + spacing_y * float(row + 1)

			var window := MeshInstance3D.new()
			var wm := BoxMesh.new()
			wm.size = Vector3(0.92,0.72,0.06)
			window.mesh = wm
			window.position = Vector3(wx, wy, front_z)

			var glass := StandardMaterial3D.new()
			var warm: bool = ((row + col + seed_index) % 4) == 0
			glass.albedo_color = Color(0.34,0.52,0.62) if not warm else Color(0.82,0.65,0.34)
			glass.metallic = 0.48
			glass.roughness = 0.23
			if warm:
				glass.emission_enabled = true
				glass.emission = Color(0.18,0.10,0.025)
			window.material_override = glass
			add_child(window)

	var side_columns: int = maxi(2, int(size.z / 2.8))
	var spacing_z: float = size.z / float(side_columns + 1)
	for row in range(rows):
		for col in range(side_columns):
			if ((row + col + seed_index) % 5) == 0:
				continue
			var wz: float = center.z - size.z * 0.5 + spacing_z * float(col + 1)
			var wy: float = center.y - size.y * 0.5 + spacing_y * float(row + 1)

			var side_window := MeshInstance3D.new()
			var swm := BoxMesh.new()
			swm.size = Vector3(0.06,0.68,0.82)
			side_window.mesh = swm
			side_window.position = Vector3(side_x, wy, wz)

			var smat := StandardMaterial3D.new()
			smat.albedo_color = Color(0.30,0.47,0.56)
			smat.metallic = 0.42
			smat.roughness = 0.26
			side_window.material_override = smat
			add_child(side_window)


func _decorate_building(center: Vector3, size: Vector3, seed_index: int) -> void:
	var top_y: float = center.y + size.y * 0.5

	if seed_index % 3 == 0:
		var tank := MeshInstance3D.new()
		var tank_mesh := CylinderMesh.new()
		tank_mesh.top_radius = 0.78
		tank_mesh.bottom_radius = 0.78
		tank_mesh.height = 1.5
		tank.mesh = tank_mesh
		tank.position = Vector3(center.x + size.x * 0.22, top_y + 0.85, center.z + size.z * 0.16)
		var tmat := StandardMaterial3D.new()
		tmat.albedo_color = Color(0.12,0.18,0.20)
		tmat.roughness = 0.72
		tank.material_override = tmat
		add_child(tank)

	if seed_index % 4 == 1:
		var dish := MeshInstance3D.new()
		var dm := CylinderMesh.new()
		dm.top_radius = 0.62
		dm.bottom_radius = 0.62
		dm.height = 0.12
		dish.mesh = dm
		dish.position = Vector3(center.x - size.x * 0.20, top_y + 0.70, center.z)
		dish.rotation_degrees = Vector3(68,0,18)
		var dmat := StandardMaterial3D.new()
		dmat.albedo_color = Color(0.68,0.68,0.64)
		dmat.metallic = 0.15
		dish.material_override = dmat
		add_child(dish)

	if seed_index % 3 != 1:
		var ac_count: int = mini(4, maxi(1, int(size.x / 3.0)))
		for i in range(ac_count):
			var xoff: float = -size.x * 0.35 + float(i) * 1.9
			var ac := MeshInstance3D.new()
			var acm := BoxMesh.new()
			acm.size = Vector3(0.72,0.42,0.34)
			ac.mesh = acm
			ac.position = Vector3(center.x + xoff, center.y, center.z - size.z * 0.5 - 0.20)
			var amat := StandardMaterial3D.new()
			amat.albedo_color = Color(0.78,0.78,0.74)
			amat.roughness = 0.76
			ac.material_override = amat
			add_child(ac)

	if seed_index % 3 == 1 and size.y <= 8.0:
		var balcony_rows: int = maxi(1, int(size.y / 2.2))
		for row in range(balcony_rows):
			var by: float = center.y - size.y * 0.25 + float(row) * 1.65
			var balcony := MeshInstance3D.new()
			var bm := BoxMesh.new()
			bm.size = Vector3(minf(3.2,size.x*0.45),0.16,0.95)
			balcony.mesh = bm
			balcony.position = Vector3(center.x, by, center.z - size.z * 0.5 - 0.48)
			var bmat := StandardMaterial3D.new()
			bmat.albedo_color = Color(0.56,0.53,0.48)
			balcony.material_override = bmat
			add_child(balcony)

			var rail := MeshInstance3D.new()
			var rm := BoxMesh.new()
			rm.size = Vector3(minf(3.2,size.x*0.45),0.62,0.07)
			rail.mesh = rm
			rail.position = balcony.position + Vector3(0,0.34,-0.42)
			var rmat := StandardMaterial3D.new()
			rmat.albedo_color = Color(0.12,0.12,0.12)
			rmat.metallic = 0.55
			rail.material_override = rmat
			add_child(rail)

	if seed_index % 5 == 2:
		var sign_names: Array[String] = ["بقالة","كافيه","موبايلات","مكتبة","صيدلية"]
		var shop_sign := Label3D.new()
		shop_sign.text = sign_names[seed_index % sign_names.size()]
		shop_sign.position = Vector3(center.x, center.y - size.y * 0.5 + 1.0, center.z - size.z * 0.5 - 0.10)
		shop_sign.font_size = 38
		shop_sign.outline_size = 8
		shop_sign.modulate = Color(1.0,0.86,0.50)
		shop_sign.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		add_child(shop_sign)


func _build_crosswalks() -> void:

	for i in range(6):
		_make_box(
			"Crosswalk_%d" % i,
			Vector3(-2.6 + float(i) * 1.05, 0.075, -21.0),
			Vector3(0.62,0.025,2.4),
			Color(0.88,0.86,0.79),
			false
		)

	for i in range(5):
		_make_box(
			"Crosswalk_EW_%d" % i,
			Vector3(6.2,0.076,-17.0 + float(i) * 1.05),
			Vector3(2.4,0.025,0.62),
			Color(0.88,0.86,0.79),
			false
		)


func _build_street_furniture() -> void:
	var bench_positions: Array[Vector3] = [
		Vector3(-7.2,0.38,-15),
		Vector3(7.2,0.38,-27),
		Vector3(15,0.38,-8)
	]
	for i in range(bench_positions.size()):
		var p: Vector3 = bench_positions[i]
		_make_box("BenchSeat_%d" % i, p, Vector3(2.0,0.18,0.55), Color(0.28,0.16,0.08), false)
		_make_box("BenchBack_%d" % i, p + Vector3(0,0.48,0.24), Vector3(2.0,0.75,0.15), Color(0.28,0.16,0.08), false)

	var bin_positions: Array[Vector3] = [
		Vector3(-6.5,0.45,-24),
		Vector3(7.0,0.45,-12),
		Vector3(20,0.45,-10)
	]
	for i in range(bin_positions.size()):
		_make_box("StreetBin_%d" % i, bin_positions[i], Vector3(0.55,0.9,0.55), Color(0.11,0.23,0.19), false)


func _make_visual_material(node_name: String, color: Color) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.82

	var texture_path := ""
	var uv_scale := Vector3(1,1,1)

	if node_name.contains("Glass"):
		mat.metallic = 0.45
		mat.roughness = 0.22
	elif node_name.contains("Awning"):
		mat.roughness = 0.55
	elif node_name == "Road_NS" or node_name == "Road_EW":
		texture_path = "res://assets/textures/asphalt.png"
		uv_scale = Vector3(7,7,7)
		mat.roughness = 0.96
	elif node_name.begins_with("Sidewalk") or node_name == "GaragePad":
		texture_path = "res://assets/textures/concrete.png"
		uv_scale = Vector3(4,4,4)
		mat.roughness = 0.92
	elif node_name == "Ground":
		texture_path = "res://assets/textures/sand.png"
		uv_scale = Vector3(8,8,8)
		mat.roughness = 1.0
	elif node_name.begins_with("Restaurant"):
		texture_path = "res://assets/textures/brick.png"
		uv_scale = Vector3(3,3,3)
		mat.roughness = 0.88
	elif node_name.begins_with("Block_") or node_name.begins_with("Home") or node_name.begins_with("Station") or node_name.begins_with("Dealership") or node_name.begins_with("Interrogation"):
		texture_path = "res://assets/textures/plaster.png"
		uv_scale = Vector3(2.5,2.5,2.5)
		mat.roughness = 0.86
	elif node_name.begins_with("Desk") or node_name.begins_with("CrimeCrate") or node_name.begins_with("Kiosk") or node_name.begins_with("Bench"):
		texture_path = "res://assets/textures/wood.png"
		uv_scale = Vector3(2,2,2)
		mat.roughness = 0.84

	if texture_path != "":
		var tex: Texture2D = load(texture_path) as Texture2D
		if tex != null:
			mat.albedo_texture = tex
			mat.uv1_scale = uv_scale

	return mat

func _make_box(node_name: String, pos: Vector3, size: Vector3, color: Color, collision: bool) -> Node3D:
	var root_node: Node3D
	if collision:
		root_node = StaticBody3D.new()
	else:
		root_node = Node3D.new()
	root_node.name = node_name
	root_node.position = pos

	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mesh.mesh = box
	var mat: StandardMaterial3D = _make_visual_material(node_name, color)
	mesh.material_override = mat
	root_node.add_child(mesh)

	if collision:
		var cs := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = size
		cs.shape = shape
		root_node.add_child(cs)

	add_child(root_node)
	return root_node

func _make_marker(pos: Vector3, text: String, color: Color) -> void:
	var marker := Node3D.new()
	marker.position = pos + Vector3(0, 0.45, 0)
	var mesh := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.28
	sphere.height = 0.56
	mesh.mesh = sphere
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.emission_enabled = true
	mat.emission = color * 0.7
	mesh.material_override = mat
	marker.add_child(mesh)
	var label := Label3D.new()
	label.text = text
	label.position = Vector3(0, 1.0, 0)
	label.font_size = 32
	label.outline_size = 8
	label.modulate = Color.WHITE
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	marker.add_child(label)
	add_child(marker)

func _make_sign(pos: Vector3, text: String) -> void:
	var label := Label3D.new()
	label.text = text
	label.position = pos
	label.font_size = 52
	label.outline_size = 10
	label.modulate = Color(1.0,0.90,0.55)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(label)


# -----------------------------------------------------------------------------
# PLAYER + CAMERA
# -----------------------------------------------------------------------------

func _build_player() -> void:
	player = CharacterBody3D.new()
	player.name = "Felfel"
	player.position = Vector3(0, 1.0, -0.5)
	player.floor_snap_length = 0.35
	player.floor_max_angle = deg_to_rad(50.0)

	var collision := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.radius = 0.38
	shape.height = 1.75
	collision.shape = shape
	player.add_child(collision)

	character_visual = Node3D.new()
	character_visual.name = "CharacterVisual"
	player.add_child(character_visual)

	# الجسم/الجاكيت
	player_mesh = _make_character_box(
		"Torso",
		Vector3(0.72, 0.90, 0.34),
		Vector3(0, 0.10, 0),
		Color(0.18,0.30,0.50)
	)
	character_visual.add_child(player_mesh)
	outfit_parts.append(player_mesh)

	# منطقة الوسط
	var hips := _make_character_box(
		"Hips",
		Vector3(0.60, 0.28, 0.32),
		Vector3(0,-0.46,0),
		Color(0.14,0.24,0.40)
	)
	character_visual.add_child(hips)
	outfit_parts.append(hips)

	# الرجل الشمال
	left_leg_pivot = Node3D.new()
	left_leg_pivot.name = "LeftLegPivot"
	left_leg_pivot.position = Vector3(-0.20,-0.48,0)
	character_visual.add_child(left_leg_pivot)

	var left_leg := _make_character_capsule(
		"LeftLeg",
		0.115,
		0.82,
		Vector3(0,-0.39,0),
		Color(0.12,0.20,0.34)
	)
	left_leg_pivot.add_child(left_leg)
	outfit_parts.append(left_leg)

	var left_shoe := _make_character_box(
		"LeftShoe",
		Vector3(0.27,0.16,0.48),
		Vector3(0,-0.83,-0.08),
		Color(0.055,0.055,0.060)
	)
	left_leg_pivot.add_child(left_shoe)

	# الرجل اليمين
	right_leg_pivot = Node3D.new()
	right_leg_pivot.name = "RightLegPivot"
	right_leg_pivot.position = Vector3(0.20,-0.48,0)
	character_visual.add_child(right_leg_pivot)

	var right_leg := _make_character_capsule(
		"RightLeg",
		0.115,
		0.82,
		Vector3(0,-0.39,0),
		Color(0.12,0.20,0.34)
	)
	right_leg_pivot.add_child(right_leg)
	outfit_parts.append(right_leg)

	var right_shoe := _make_character_box(
		"RightShoe",
		Vector3(0.27,0.16,0.48),
		Vector3(0,-0.83,-0.08),
		Color(0.055,0.055,0.060)
	)
	right_leg_pivot.add_child(right_shoe)

	# الذراع الشمال
	left_arm_pivot = Node3D.new()
	left_arm_pivot.name = "LeftArmPivot"
	left_arm_pivot.position = Vector3(-0.48,0.38,0)
	character_visual.add_child(left_arm_pivot)

	var left_arm := _make_character_capsule(
		"LeftArm",
		0.105,
		0.70,
		Vector3(0,-0.32,0),
		Color(0.18,0.30,0.50)
	)
	left_arm_pivot.add_child(left_arm)
	outfit_parts.append(left_arm)

	var left_hand := _make_character_sphere(
		"LeftHand",
		0.13,
		Vector3(0,-0.70,0),
		Color(0.72,0.54,0.42)
	)
	left_arm_pivot.add_child(left_hand)

	# الذراع اليمين
	right_arm_pivot = Node3D.new()
	right_arm_pivot.name = "RightArmPivot"
	right_arm_pivot.position = Vector3(0.48,0.38,0)
	character_visual.add_child(right_arm_pivot)

	var right_arm := _make_character_capsule(
		"RightArm",
		0.105,
		0.70,
		Vector3(0,-0.32,0),
		Color(0.18,0.30,0.50)
	)
	right_arm_pivot.add_child(right_arm)
	outfit_parts.append(right_arm)

	var right_hand := _make_character_sphere(
		"RightHand",
		0.13,
		Vector3(0,-0.70,0),
		Color(0.72,0.54,0.42)
	)
	right_arm_pivot.add_child(right_hand)

	# الرقبة والرأس
	var neck := _make_character_capsule(
		"Neck",
		0.11,
		0.25,
		Vector3(0,0.67,0),
		Color(0.72,0.54,0.42)
	)
	character_visual.add_child(neck)

	head_mesh_node = _make_character_sphere(
		"Head",
		0.31,
		Vector3(0,0.98,0),
		Color(0.72,0.54,0.42)
	)
	head_mesh_node.scale = Vector3(0.92,1.10,0.94)
	character_visual.add_child(head_mesh_node)

	hair_mesh_node = _make_character_sphere(
		"Hair",
		0.315,
		Vector3(0,1.09,0.01),
		Color(0.055,0.040,0.032)
	)
	hair_mesh_node.scale = Vector3(0.96,0.58,0.98)
	character_visual.add_child(hair_mesh_node)

	# شنطة ملفات على جنب الشخصية.
	var bag := _make_character_box(
		"CaseBag",
		Vector3(0.47,0.40,0.18),
		Vector3(0.48,-0.10,0.04),
		Color(0.16,0.09,0.05)
	)
	character_visual.add_child(bag)

	var bag_handle := _make_character_box(
		"CaseBagHandle",
		Vector3(0.28,0.06,0.06),
		Vector3(0.48,0.14,0.04),
		Color(0.11,0.065,0.04)
	)
	character_visual.add_child(bag_handle)

	add_child(player)


func _make_character_box(part_name: String, size: Vector3, pos: Vector3, color: Color) -> MeshInstance3D:
	var mesh_node := MeshInstance3D.new()
	mesh_node.name = part_name
	var box := BoxMesh.new()
	box.size = size
	mesh_node.mesh = box
	mesh_node.position = pos

	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.72
	mesh_node.material_override = mat
	return mesh_node


func _make_character_capsule(part_name: String, radius: float, height: float, pos: Vector3, color: Color) -> MeshInstance3D:
	var mesh_node := MeshInstance3D.new()
	mesh_node.name = part_name
	var capsule := CapsuleMesh.new()
	capsule.radius = radius
	capsule.height = height
	mesh_node.mesh = capsule
	mesh_node.position = pos

	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.74
	mesh_node.material_override = mat
	return mesh_node


func _make_character_sphere(part_name: String, radius: float, pos: Vector3, color: Color) -> MeshInstance3D:
	var mesh_node := MeshInstance3D.new()
	mesh_node.name = part_name
	var sphere := SphereMesh.new()
	sphere.radius = radius
	sphere.height = radius * 2.0
	mesh_node.mesh = sphere
	mesh_node.position = pos

	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.68
	mesh_node.material_override = mat
	return mesh_node


func _set_outfit_color(color: Color, metallic: float = 0.0) -> void:
	for part: MeshInstance3D in outfit_parts:
		var mat := StandardMaterial3D.new()
		mat.albedo_color = color
		mat.roughness = 0.70
		mat.metallic = metallic
		part.material_override = mat


func _apply_head_style() -> void:
	if hair_mesh_node == null:
		return

	var hair_mat := StandardMaterial3D.new()
	hair_mat.roughness = 0.82

	if character_gender == "male":
		hair_mat.albedo_color = Color(0.045,0.032,0.025)
		hair_mesh_node.scale = Vector3(0.94,0.50,0.96)
		hair_mesh_node.position = Vector3(0,1.105,0.015)
	else:
		if character_index == 1:
			# الشخصية المحجبة: غطاء رأس بلون هادي.
			hair_mat.albedo_color = Color(0.20,0.17,0.24)
			hair_mesh_node.scale = Vector3(1.08,0.90,1.08)
			hair_mesh_node.position = Vector3(0,1.02,0.015)
		else:
			hair_mat.albedo_color = Color(0.075,0.045,0.028)
			hair_mesh_node.scale = Vector3(0.98,0.64,1.0)
			hair_mesh_node.position = Vector3(0,1.08,0.015)

	hair_mesh_node.material_override = hair_mat


func _build_camera() -> void:
	camera = Camera3D.new()
	camera.current = true
	camera.fov = 68
	add_child(camera)

func _physics_process(delta: float) -> void:
	_sync_mobile_controls_visibility()

	if not game_active:
		_update_camera(delta)
		return

	game_time_minutes += delta * 2.0
	if game_time_minutes >= 1440.0:
		game_time_minutes -= 1440.0

	_update_npcs(delta)
	_update_traffic(delta)
	_update_day_night()
	_update_minimap()

	if in_car:
		_drive_car(delta)
	else:
		_move_player(delta)
		_update_character_animation(delta)

	objective_distance = _player_pos().distance_to(_objective_position())
	_update_camera(delta)
	_update_interaction()
	_sync_hud()

func _move_player(delta: float) -> void:
	if not player.is_on_floor():
		player.velocity.y -= 20.0 * delta
	else:
		player.velocity.y = -0.5
		if _jump_requested():
			player.velocity.y = jump_force

	var forward: Vector3 = Vector3(-sin(camera_yaw), 0, -cos(camera_yaw))
	var right: Vector3 = Vector3(cos(camera_yaw), 0, -sin(camera_yaw))
	var move_input: Vector2 = _movement_input()
	var dir: Vector3 = (forward * -move_input.y) + (right * move_input.x)

	if dir.length() > 0.01:
		var analog_strength: float = clampf(dir.length(), 0.0, 1.0)
		dir = dir.normalized()
		var speed: float = walk_speed
		if _run_requested():
			speed = run_speed
		speed *= maxf(0.35, analog_strength)
		player.velocity.x = move_toward(player.velocity.x, dir.x * speed, 38.0 * delta)
		player.velocity.z = move_toward(player.velocity.z, dir.z * speed, 38.0 * delta)
		player.rotation.y = lerp_angle(player.rotation.y, atan2(-dir.x, -dir.z), minf(1.0, 10.0 * delta))
	else:
		player.velocity.x = move_toward(player.velocity.x, 0.0, 28.0 * delta)
		player.velocity.z = move_toward(player.velocity.z, 0.0, 28.0 * delta)

	player.move_and_slide()

func _update_character_animation(delta: float) -> void:
	if character_visual == null:
		return

	idle_phase += delta
	var horizontal_speed: float = Vector2(player.velocity.x, player.velocity.z).length()
	var moving: bool = horizontal_speed > 0.25
	var running: bool = horizontal_speed > 6.4
	var on_floor: bool = player.is_on_floor()

	if moving and on_floor:
		var anim_speed: float = 11.0 if running else 7.0
		var swing_amount: float = 0.78 if running else 0.48
		walk_phase += delta * anim_speed

		var swing: float = sin(walk_phase) * swing_amount
		var arm_swing: float = swing * 0.82
		var blend: float = minf(1.0, delta * 14.0)

		left_leg_pivot.rotation.x = lerpf(left_leg_pivot.rotation.x, swing, blend)
		right_leg_pivot.rotation.x = lerpf(right_leg_pivot.rotation.x, -swing, blend)
		left_arm_pivot.rotation.x = lerpf(left_arm_pivot.rotation.x, -arm_swing, blend)
		right_arm_pivot.rotation.x = lerpf(right_arm_pivot.rotation.x, arm_swing, blend)

		var bob_amount: float = 0.050 if running else 0.028
		var target_bob: float = absf(sin(walk_phase * 2.0)) * bob_amount
		character_visual.position.y = lerpf(character_visual.position.y, target_bob, blend)

		var lean: float = -0.075 if running else -0.025
		character_visual.rotation.x = lerpf(character_visual.rotation.x, lean, blend)
		character_visual.rotation.z = lerpf(character_visual.rotation.z, sin(walk_phase) * 0.018, blend)

	elif not on_floor:
		var air_blend: float = minf(1.0, delta * 8.0)
		left_leg_pivot.rotation.x = lerpf(left_leg_pivot.rotation.x, 0.18, air_blend)
		right_leg_pivot.rotation.x = lerpf(right_leg_pivot.rotation.x, -0.14, air_blend)
		left_arm_pivot.rotation.x = lerpf(left_arm_pivot.rotation.x, -0.28, air_blend)
		right_arm_pivot.rotation.x = lerpf(right_arm_pivot.rotation.x, -0.28, air_blend)
		character_visual.position.y = lerpf(character_visual.position.y, 0.0, air_blend)
		character_visual.rotation.x = lerpf(character_visual.rotation.x, 0.04, air_blend)
		character_visual.rotation.z = lerpf(character_visual.rotation.z, 0.0, air_blend)

	else:
		# Idle: رجوع الأطراف لوضعها الطبيعي مع نفس/حركة خفيفة.
		var idle_blend: float = minf(1.0, delta * 9.0)
		left_leg_pivot.rotation.x = lerpf(left_leg_pivot.rotation.x, 0.0, idle_blend)
		right_leg_pivot.rotation.x = lerpf(right_leg_pivot.rotation.x, 0.0, idle_blend)
		left_arm_pivot.rotation.x = lerpf(left_arm_pivot.rotation.x, 0.025, idle_blend)
		right_arm_pivot.rotation.x = lerpf(right_arm_pivot.rotation.x, -0.025, idle_blend)

		var breathe: float = sin(idle_phase * 2.2) * 0.008
		character_visual.position.y = lerpf(character_visual.position.y, breathe, idle_blend)
		character_visual.rotation.x = lerpf(character_visual.rotation.x, 0.0, idle_blend)
		character_visual.rotation.z = lerpf(character_visual.rotation.z, 0.0, idle_blend)


func _drive_car(delta: float) -> void:
	if car == null:
		return

	if not car.is_on_floor():
		car.velocity.y -= 20.0 * delta
	else:
		car.velocity.y = -0.5

	var move_input: Vector2 = _movement_input()
	var throttle: float = clampf(-move_input.y, -1.0, 1.0)
	var steer: float = clampf(-move_input.x, -1.0, 1.0)

	var max_speed: float = 25.0
	var accel: float = 20.0
	car_speed = move_toward(car_speed, throttle * max_speed, accel * delta)

	# Space on desktop / Jump-Brake button on mobile.
	if _jump_requested():
		car_speed = move_toward(car_speed, 0.0, 42.0 * delta)

	if abs(car_speed) < 0.08:
		car_speed = 0.0

	var speed_ratio: float = clampf(absf(car_speed) / max_speed, 0.0, 1.0)
	if abs(car_speed) > 0.4:
		car.rotation.y += steer * (1.25 - speed_ratio * 0.45) * delta * sign(car_speed)

	var fwd := -car.transform.basis.z.normalized()
	car.velocity.x = fwd.x * car_speed
	car.velocity.z = fwd.z * car_speed
	car.move_and_slide()

func _update_camera(delta: float) -> void:
	var target := Vector3.ZERO
	if in_car and car != null:
		target = car.global_position + Vector3(0, 1.2, 0)
	else:
		target = player.global_position + Vector3(0, 1.25, 0)

	var horizontal := cos(camera_pitch) * camera_distance
	var height := -sin(camera_pitch) * camera_distance + 1.2
	var offset := Vector3(sin(camera_yaw) * horizontal, height, cos(camera_yaw) * horizontal)
	camera.global_position = camera.global_position.lerp(target + offset, min(1.0, 9.0 * delta))
	camera.look_at(target, Vector3.UP)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and not touch_controls_enabled and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED and game_active:
		camera_yaw -= event.relative.x * 0.0032
		camera_pitch = clamp(camera_pitch - event.relative.y * 0.0024, -0.65, 0.35)

	if event is InputEventMouseButton and event.pressed and game_active:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera_distance = max(4.0, camera_distance - 0.7)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera_distance = min(11.0, camera_distance + 0.7)

	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			if overlay_mode == "pause" or overlay_mode == "bag":
				_resume_game_from_overlay()
			elif game_active:
				_open_pause_menu()
		elif event.keycode == KEY_B:
			if overlay_mode == "bag":
				_resume_game_from_overlay()
			elif game_active:
				_open_case_bag()
		elif event.keycode == KEY_E and game_active:
			_do_interaction()


# -----------------------------------------------------------------------------
# HUD + INTERACTIONS
# -----------------------------------------------------------------------------

func _build_hud() -> void:
	ui_layer = CanvasLayer.new()
	add_child(ui_layer)

	hud_panel = PanelContainer.new()
	hud_panel.position = Vector2(18, 18)
	hud_panel.size = Vector2(460, 190)
	hud_panel.visible = false
	ui_layer.add_child(hud_panel)

	var vbox := VBoxContainer.new()
	vbox.layout_direction = Control.LAYOUT_DIRECTION_RTL
	hud_panel.add_child(vbox)

	var title := Label.new()
	title.text = "🌶️ المحقق فلفل"
	title.add_theme_font_size_override("font_size", 24)
	vbox.add_child(title)

	var controls_hint := Label.new()
	controls_hint.text = "B: شنطة القضايا   |   Esc: إيقاف/حفظ"
	controls_hint.add_theme_font_size_override("font_size", 14)
	vbox.add_child(controls_hint)

	money_label = Label.new()
	vbox.add_child(money_label)

	file_label = Label.new()
	vbox.add_child(file_label)

	status_label = Label.new()
	vbox.add_child(status_label)

	clock_label = Label.new()
	vbox.add_child(clock_label)

	objective_label = Label.new()
	objective_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(objective_label)

	distance_label = Label.new()
	vbox.add_child(distance_label)

	prompt_label = Label.new()
	prompt_label.layout_direction = Control.LAYOUT_DIRECTION_RTL
	prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt_label.add_theme_font_size_override("font_size", 22)
	prompt_label.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	prompt_label.position = Vector2(-340, -78)
	prompt_label.size = Vector2(680, 52)
	prompt_label.visible = false
	ui_layer.add_child(prompt_label)

	dialogue_panel = PanelContainer.new()
	dialogue_panel.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	dialogue_panel.position = Vector2(-390, -190)
	dialogue_panel.size = Vector2(780, 92)
	dialogue_panel.visible = false
	ui_layer.add_child(dialogue_panel)

	dialogue_label = Label.new()
	dialogue_label.layout_direction = Control.LAYOUT_DIRECTION_RTL
	dialogue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dialogue_label.add_theme_font_size_override("font_size", 19)
	dialogue_panel.add_child(dialogue_label)

	# Mini-map حقيقية مرسومة بدل عرض X و Z.
	minimap_panel = PanelContainer.new()
	minimap_panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	minimap_panel.position = Vector2(-260, 18)
	minimap_panel.size = Vector2(240, 180)
	ui_layer.add_child(minimap_panel)

	var minimap_script: Script = load("res://scripts/Minimap.gd") as Script
	minimap_view = minimap_script.new() as Control
	minimap_view.custom_minimum_size = Vector2(230, 170)
	minimap_view.mouse_filter = Control.MOUSE_FILTER_IGNORE
	minimap_panel.add_child(minimap_view)

	_sync_hud()

func _sync_hud() -> void:
	if money_label:
		money_label.text = "💵 الفلوس: %d جنيه" % money
	if file_label:
		file_label.text = "👜 الملفات في الشنطة: %d" % case_files
	if status_label:
		status_label.text = "❤️ %d   🛡️ %d   %s" % [health, armor, ("🚗 %d كم/س" % int(abs(car_speed) * 4.2)) if in_car else "🚶 مشي"]
	if current_interior != "":
		status_label.text += " | جوه: " + current_interior
	if clock_label:
		var hour := int(game_time_minutes / 60.0) % 24
		var minute := int(game_time_minutes) % 60
		clock_label.text = "🕒 %02d:%02d" % [hour, minute]
	if objective_label:
		objective_label.text = "🎯 الهدف: " + _objective_text()
	if distance_label:
		distance_label.text = "📍 المسافة للهدف: %d متر" % int(objective_distance)

func _objective_position() -> Vector3:
	if current_interior == "station":
		if phase == 0:
			return story_station_file
		if phase == 3:
			return story_station_interrogation
		return story_station_exit

	if current_interior == "house":
		if phase == 1:
			return story_home_desk
		return story_home_exit

	if current_interior == "restaurant":
		if phase == 2:
			return story_restaurant_evidence
		return story_restaurant_exit

	if current_interior == "car" or current_interior == "clothes" or current_interior == "home":
		return _interior_counter_pos(current_interior)

	match phase:
		0:
			return station_entrance_pos
		1:
			return home_entrance_pos
		2:
			return restaurant_entrance_pos
		3:
			return station_entrance_pos
		4:
			return car_shop_pos
		_:
			return _player_pos()


func _objective_text() -> String:
	if current_interior == "station":
		if phase == 0:
			return _g("إنت جوه القسم. روح لمكتب الملفات واستلم القضية.", "إنتِ جوه القسم. روحي لمكتب الملفات واستلمي القضية.")
		if phase == 3:
			return _g("إنت جوه القسم. روح لغرفة الاستجواب.", "إنتِ جوه القسم. روحي لغرفة الاستجواب.")
		return _g("خلصت المطلوب هنا. اخرج من القسم وكمل القضية.", "خلصتي المطلوب هنا. اخرجي من القسم وكملي القضية.")

	if current_interior == "house":
		if phase == 1:
			return _g("إنت في بيتك. روح للمكتب واقرأ ملف القضية.", "إنتِ في بيتك. روحي للمكتب واقري ملف القضية.")
		return _g("اخرج من البيت وكمل القضية.", "اخرجي من البيت وكملي القضية.")

	if current_interior == "restaurant":
		if phase == 2:
			return _g("فتش المطعم والمخزن واعثر على الدليل الرئيسي.", "فتشي المطعم والمخزن واعثري على الدليل الرئيسي.")
		return _g("الدليل معاك. اخرج من المطعم وارجع للقسم.", "الدليل معاكي. اخرجي من المطعم وارجعي للقسم.")

	if current_interior == "car":
		return _g("إنت جوه معرض العربيات. روح لموظف المبيعات أو اخرج من الباب.", "إنتِ جوه معرض العربيات. روحي لموظف المبيعات أو اخرجي من الباب.")
	if current_interior == "clothes":
		return _g("إنت جوه الأتيليه. روح للكاشير عشان تشتري اللبس.", "إنتِ جوه الأتيليه. روحي للكاشير عشان تشتري اللبس.")
	if current_interior == "home":
		return _g("إنت جوه مكتب تطوير البيت. روح لمهندس التطوير.", "إنتِ جوه مكتب تطوير البيت. روحي لمهندس التطوير.")

	match phase:
		0:
			return _g("روح قسم الشرطة وادخل من الباب لاستلام أول قضية.", "روحي قسم الشرطة وادخلي من الباب لاستلام أول قضية.")
		1:
			return _g("ارجع بيتك وادخل واقرأ الملف على مكتبك.", "ارجعي بيتك وادخلي واقري الملف على مكتبك.")
		2:
			return _g("روح مطعم عم رجب وادخل فتش مسرح الجريمة.", "روحي مطعم عم رجب وادخلي فتشي مسرح الجريمة.")
		3:
			return _g("ارجع قسم الشرطة وادخل غرفة الاستجواب.", "ارجعي قسم الشرطة وادخلي غرفة الاستجواب.")
		4:
			return _g("القضية اتحلت! عندك محلات للعربيات واللبس وتطوير البيت.", "القضية اتحلت! عندك محلات للعربيات واللبس وتطوير البيت.")
		_:
			return _g("اتجول في المدينة.", "اتجولي في المدينة.")

func _player_pos() -> Vector3:
	if in_car and car != null:
		return car.global_position
	return player.global_position

func _update_interaction() -> void:
	current_action = ""
	prompt_label.visible = false

	if in_car:
		current_action = "exit_car"
		prompt_label.text = "E — " + _g("انزل من العربية", "انزلي من العربية")
		prompt_label.visible = true
		return

	var p: Vector3 = _player_pos()

	# -----------------------------
	# الأماكن الداخلية الخاصة بالقصة
	# -----------------------------
	if current_interior == "station":
		if p.distance_to(story_station_exit) < 2.3:
			current_action = "exit_story_place"
			prompt_label.text = "E — " + _g("اخرج من القسم", "اخرجي من القسم")
			prompt_label.visible = true
			return

		if phase == 0 and p.distance_to(story_station_file) < 2.8:
			current_action = "take_case"
			prompt_label.text = "E — " + _g("استلم ملف القضية", "استلمي ملف القضية")
			prompt_label.visible = true
			return

		if phase == 3 and p.distance_to(story_station_interrogation) < 3.0:
			current_action = "interrogate"
			prompt_label.text = "E — " + _g("ابدأ الاستجواب", "ابدئي الاستجواب")
			prompt_label.visible = true
			return

		return

	if current_interior == "house":
		if p.distance_to(story_home_exit) < 2.3:
			current_action = "exit_story_place"
			prompt_label.text = "E — " + _g("اخرج من البيت", "اخرجي من البيت")
			prompt_label.visible = true
			return

		if phase == 1 and p.distance_to(story_home_desk) < 2.7:
			current_action = "read_file"
			prompt_label.text = "E — " + _g("اقعد واقرأ ملف القضية", "اقعدي واقري ملف القضية")
			prompt_label.visible = true
			return

		return

	if current_interior == "restaurant":
		if p.distance_to(story_restaurant_exit) < 2.3:
			current_action = "exit_story_place"
			prompt_label.text = "E — " + _g("اخرج من المطعم", "اخرجي من المطعم")
			prompt_label.visible = true
			return

		if phase == 2 and p.distance_to(story_restaurant_evidence) < 2.6:
			current_action = "inspect_evidence"
			prompt_label.text = "E — " + _g("افحص الزرار الأحمر", "افحصي الزرار الأحمر")
			prompt_label.visible = true
			return

		return

	# -----------------------------
	# المحلات الداخلية
	# -----------------------------
	if current_interior == "car" or current_interior == "clothes" or current_interior == "home":
		var exit_pos: Vector3 = _interior_exit_pos(current_interior)
		var counter_pos: Vector3 = _interior_counter_pos(current_interior)

		if p.distance_to(exit_pos) < 2.3:
			current_action = "exit_shop"
			prompt_label.text = "E — " + _g("اخرج من المحل", "اخرجي من المحل")
			prompt_label.visible = true
			return

		if p.distance_to(counter_pos) < 2.8:
			current_action = "shop_" + current_interior
			if current_interior == "car":
				prompt_label.text = "E — " + _g("اتكلم مع موظف المبيعات", "اتكلمي مع موظف المبيعات")
			elif current_interior == "clothes":
				prompt_label.text = "E — " + _g("اتكلم مع الكاشير", "اتكلمي مع الكاشير")
			else:
				prompt_label.text = "E — " + _g("اتكلم مع مهندس التطوير", "اتكلمي مع مهندس التطوير")
			prompt_label.visible = true
			return

		return

	# -----------------------------
	# المدينة
	# -----------------------------
	if car_owned and car != null and p.distance_to(car.global_position) < 2.6:
		current_action = "enter_car"
		prompt_label.text = "E — " + _g("اركب العربية", "اركبي العربية")
		prompt_label.visible = true
		return

	# الأماكن الأساسية يمكن دخولها من أبوابها.
	if p.distance_to(station_entrance_pos) < 3.0:
		current_action = "enter_story_station"
		prompt_label.text = "E — " + _g("ادخل قسم الشرطة", "ادخلي قسم الشرطة")
		prompt_label.visible = true
		return

	if p.distance_to(home_entrance_pos) < 2.8:
		current_action = "enter_story_house"
		prompt_label.text = "E — " + _g("ادخل البيت", "ادخلي البيت")
		prompt_label.visible = true
		return

	if p.distance_to(restaurant_entrance_pos) < 3.0:
		current_action = "enter_story_restaurant"
		prompt_label.text = "E — " + _g("ادخل مطعم عم رجب", "ادخلي مطعم عم رجب")
		prompt_label.visible = true
		return

	if phase >= 4 and p.distance_to(car_shop_pos) < 3.5:
		current_action = "enter_shop_car"
		prompt_label.text = "E — " + _g("ادخل معرض العربيات", "ادخلي معرض العربيات")
		prompt_label.visible = true
	elif phase >= 4 and p.distance_to(clothes_shop_pos) < 3.5:
		current_action = "enter_shop_clothes"
		prompt_label.text = "E — " + _g("ادخل أتيليه الملابس", "ادخلي أتيليه الملابس")
		prompt_label.visible = true
	elif phase >= 4 and p.distance_to(home_shop_pos) < 3.5:
		current_action = "enter_shop_home"
		prompt_label.text = "E — " + _g("ادخل مكتب تطوير البيت", "ادخلي مكتب تطوير البيت")
		prompt_label.visible = true

func _do_interaction() -> void:
	match current_action:
		"take_case":
			case_files = 1
			phase = 1
			_show_dialogue("الريس عطية: %s يا %s. القضية اسمها «اختفاء كرتونة الكشري الملكي»... والموضوع فيه شطة!" % [_g("خد الملف", "خدي الملف"), player_name])
			_sync_hud()
			_autosave()
		"read_file":
			phase = 2
			_show_dialogue("%s: الكاميرا فصلت 11:47... وخمسة مشتبه بهم. واحد منهم كان لابس قميص أحمر. يلا على مسرح الجريمة." % player_name)
			_sync_hud()
			_autosave()
		"inspect_evidence":
			evidence_found = true
			phase = 3
			_show_dialogue("%s: لقيت زرار أحمر عليه نقطة صوص ثوم! الدليل الوحيد... يبقى لازم أركز في القميص الأحمر." % player_name)
			_sync_hud()
			_autosave()
		"interrogate":
			_open_interrogation()
		"enter_story_station":
			_enter_story_place("station")
		"enter_story_house":
			_enter_story_place("house")
		"enter_story_restaurant":
			_enter_story_place("restaurant")
		"exit_story_place":
			_exit_story_place()
		"enter_shop_car":
			_enter_shop("car")
		"enter_shop_clothes":
			_enter_shop("clothes")
		"enter_shop_home":
			_enter_shop("home")
		"shop_car":
			_open_shop("car")
		"shop_clothes":
			_open_shop("clothes")
		"shop_home":
			_open_shop("home")
		"exit_shop":
			_exit_shop()
		"enter_car":
			_enter_car()
		"exit_car":
			_exit_car()

func _enter_story_place(place_type: String) -> void:
	if current_interior != "":
		return

	current_interior = place_type
	story_return_pos = _story_return_position(place_type)
	player.velocity = Vector3.ZERO
	player.global_position = _story_spawn_position(place_type)
	player.rotation.y = PI

	if minimap_panel != null:
		minimap_panel.visible = false

	if place_type == "station":
		if phase == 0:
			_show_dialogue(_g("دخلت القسم. مكتب الملفات ناحية الشمال، خد القضية وروح راجعها في البيت.", "دخلتي القسم. مكتب الملفات ناحية الشمال، خدي القضية وروحي راجعيها في البيت."))
		elif phase == 3:
			_show_dialogue(_g("رجعت القسم بالدليل. غرفة الاستجواب في الجناح اليمين.", "رجعتي القسم بالدليل. غرفة الاستجواب في الجناح اليمين."))
		else:
			_show_dialogue("قسم الشرطة مفتوح. تقدر تتجول جواه.")
	elif place_type == "house":
		_show_dialogue(_g("رجعت البيت. مكتبك في آخر الأوضة وملف القضية مستنيك.", "رجعتي البيت. مكتبك في آخر الأوضة وملف القضية مستنيكي."))
	elif place_type == "restaurant":
		_show_dialogue(_g("دخلت مطعم عم رجب. فتش الصالة والمطبخ، والدليل لازم يكون واحد بس.", "دخلتي مطعم عم رجب. فتشي الصالة والمطبخ، والدليل لازم يكون واحد بس."))


func _exit_story_place() -> void:
	if current_interior != "station" and current_interior != "house" and current_interior != "restaurant":
		return

	player.velocity = Vector3.ZERO
	player.global_position = story_return_pos
	player.rotation.y = 0.0
	current_interior = ""

	if minimap_panel != null:
		minimap_panel.visible = true


func _story_spawn_position(place_type: String) -> Vector3:
	match place_type:
		"station":
			return story_station_spawn
		"house":
			return story_home_spawn
		"restaurant":
			return story_restaurant_spawn
		_:
			return player.global_position


func _story_return_position(place_type: String) -> Vector3:
	match place_type:
		"station":
			return station_entrance_pos + Vector3(0,0.5,1.8)
		"house":
			return home_entrance_pos + Vector3(0,0.5,-1.8)
		"restaurant":
			return restaurant_entrance_pos + Vector3(0,0.5,1.8)
		_:
			return Vector3.ZERO


func _enter_shop(shop_type: String) -> void:
	current_interior = shop_type
	interior_return_pos = _shop_return_pos(shop_type)
	player.velocity = Vector3.ZERO
	player.global_position = _interior_spawn_pos(shop_type)
	player.rotation.y = PI

	if minimap_panel != null:
		minimap_panel.visible = false

	if shop_type == "car":
		_show_dialogue(_g("دخلت معرض العربيات. العربيات المعروضة قدامك والمبيعات في آخر المعرض.", "دخلتي معرض العربيات. العربيات المعروضة قدامك والمبيعات في آخر المعرض."))
	elif shop_type == "clothes":
		_show_dialogue(_g("دخلت أتيليه الملابس. اتفرج على اللبس وروح للكاشير.", "دخلتي أتيليه الملابس. اتفرجي على اللبس وروحي للكاشير."))
	else:
		_show_dialogue(_g("دخلت مكتب تطوير البيت. شوف نماذج الأثاث وروح لمهندس التطوير.", "دخلتي مكتب تطوير البيت. شوفي نماذج الأثاث وروحي لمهندس التطوير."))


func _exit_shop() -> void:
	if current_interior == "":
		return

	player.velocity = Vector3.ZERO
	player.global_position = interior_return_pos
	player.rotation.y = 0.0
	current_interior = ""

	if minimap_panel != null:
		minimap_panel.visible = true


func _interior_spawn_pos(shop_type: String) -> Vector3:
	match shop_type:
		"car":
			return car_inside_spawn
		"clothes":
			return clothes_inside_spawn
		"home":
			return home_inside_spawn
		_:
			return player.global_position


func _interior_counter_pos(shop_type: String) -> Vector3:
	match shop_type:
		"car":
			return car_inside_counter
		"clothes":
			return clothes_inside_counter
		"home":
			return home_inside_counter
		_:
			return player.global_position


func _interior_exit_pos(shop_type: String) -> Vector3:
	match shop_type:
		"car":
			return car_inside_exit
		"clothes":
			return clothes_inside_exit
		"home":
			return home_inside_exit
		_:
			return player.global_position


func _shop_return_pos(shop_type: String) -> Vector3:
	match shop_type:
		"car":
			return Vector3(car_shop_pos.x,1.0,car_shop_pos.z + 2.2)
		"clothes":
			return Vector3(clothes_shop_pos.x,1.0,clothes_shop_pos.z + 2.2)
		"home":
			return Vector3(home_shop_pos.x,1.0,home_shop_pos.z + 2.2)
		_:
			return Vector3.ZERO


func _show_dialogue(text: String) -> void:
	dialogue_label.text = text
	dialogue_panel.visible = true
	var timer := get_tree().create_timer(6.5)
	timer.timeout.connect(_hide_dialogue)

func _hide_dialogue() -> void:
	dialogue_panel.visible = false


# -----------------------------------------------------------------------------
# CASE BAG + PAUSE + SAVE / LOAD
# -----------------------------------------------------------------------------

func _open_pause_menu() -> void:
	if not game_active:
		return

	overlay_mode = "pause"
	game_active = false
	menu_root.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	var account_text: String = current_account_email if current_account_email != "" else "Guest"
	var online_text: String = "Online" if _online_has_session() else "Offline"
	var box := _new_menu_panel(
		"⏸️ إيقاف اللعبة",
		"الحساب: %s — %s" % [account_text, online_text]
	)

	var save_button := Button.new()
	save_button.text = "💾 حفظ محلي + Cloud"
	save_button.custom_minimum_size.y = 50
	save_button.pressed.connect(_manual_save)
	box.add_child(save_button)

	var local_load := Button.new()
	local_load.text = "📂 تحميل الحفظ المحلي"
	local_load.custom_minimum_size.y = 50
	local_load.disabled = not FileAccess.file_exists(_current_save_path())
	local_load.pressed.connect(_manual_load)
	box.add_child(local_load)

	var cloud_load := Button.new()
	cloud_load.text = "☁️ تحميل Cloud Save"
	cloud_load.custom_minimum_size.y = 50
	cloud_load.disabled = not _online_has_session()
	cloud_load.pressed.connect(_request_cloud_load_from_pause)
	box.add_child(cloud_load)

	var bag_button := Button.new()
	bag_button.text = "👜 شنطة القضايا"
	bag_button.custom_minimum_size.y = 50
	bag_button.pressed.connect(_open_case_bag)
	box.add_child(bag_button)

	var save_status := Label.new()
	save_status.name = "SaveStatus"
	save_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	save_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	save_status.text = "الحفظ المحلي شغال، والـCloud يتزامن لما تكون داخل Online Account."
	box.add_child(save_status)

	var resume := Button.new()
	resume.text = "▶️ كمل اللعب"
	resume.custom_minimum_size.y = 50
	resume.pressed.connect(_resume_game_from_overlay)
	box.add_child(resume)


func _open_case_bag() -> void:
	overlay_mode = "bag"
	game_active = false
	menu_root.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	var box := _new_menu_panel("👜 شنطة القضايا", "ملفاتك وأدلتك الحالية.")

	var case_title := Label.new()
	case_title.add_theme_font_size_override("font_size", 22)
	case_title.text = "📁 القضية 001 — اختفاء كرتونة الكشري الملكي"
	box.add_child(case_title)

	var status := Label.new()
	status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status.custom_minimum_size.y = 56

	if phase == 0:
		status.text = "الشنطة فاضية. لسه ما استلمتش ملف القضية من قسم الشرطة."
	elif phase == 1:
		status.text = "✅ الملف في الشنطة.\n🔒 لسه ما قريتش تفاصيله — ارجع البيت وافتحه على المكتب."
	elif phase == 2:
		status.text = "✅ الملف اتقري.\n📌 الكاميرا فصلت الساعة 11:47، وفي 5 مشتبه بهم، وشاهد شاف قميص أحمر."
	elif phase == 3:
		status.text = "✅ الملف اتقري.\n🔎 الدليل الرئيسي: زرار أحمر عليه صوص ثوم طازة.\n⚖️ المطلوب: استجواب المشتبه بهم وتحديد الجاني."
	else:
		status.text = "🏆 القضية اتحلت وتم أرشفتها.\nالجاني: فتحي المخزنجي.\nالمكافأة: 15,000 جنيه."

	box.add_child(status)

	var evidence_title := Label.new()
	evidence_title.text = "🔬 الأدلة"
	evidence_title.add_theme_font_size_override("font_size", 20)
	box.add_child(evidence_title)

	var evidence_text := Label.new()
	evidence_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if evidence_found:
		evidence_text.text = "• زرار قميص أحمر.\n• عليه أثر صوص ثوم حديث.\n• يتعارض مع كلام فتحي إن الزرار ضاع من أسبوع."
	else:
		evidence_text.text = "لا يوجد دليل مسجل في الشنطة حتى الآن."
	box.add_child(evidence_text)

	var suspects_title := Label.new()
	suspects_title.text = "👥 المشتبه بهم"
	suspects_title.add_theme_font_size_override("font_size", 20)
	box.add_child(suspects_title)

	var suspects_text := Label.new()
	suspects_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if phase >= 2:
		suspects_text.text = "سيد السواق — رمزي الجرسون — هشام المحاسب — فتحي المخزنجي — بولا الدليفري"
	else:
		suspects_text.text = "الأسماء هتظهر بعد قراءة ملف القضية."
	box.add_child(suspects_text)

	var close := Button.new()
	close.text = "إغلاق الشنطة"
	close.custom_minimum_size.y = 50
	close.pressed.connect(_resume_game_from_overlay)
	box.add_child(close)


func _resume_game_from_overlay() -> void:
	if overlay_mode != "pause" and overlay_mode != "bag":
		return

	overlay_mode = ""
	menu_root.visible = false
	game_active = true
	_set_gameplay_mouse_mode()
	_sync_hud()


func _manual_save() -> void:
	var ok: bool = _save_game()
	var status := menu_panel.find_child("SaveStatus", true, false) as Label
	if status != null:
		if ok and _online_has_session():
			status.text = "✅ اتحفظ محليًا، وجاري رفع Cloud Save..."
		elif ok:
			status.text = "✅ اتحفظ محليًا. مفيش جلسة Online لرفع الـCloud."
		else:
			status.text = "❌ حصل خطأ أثناء الحفظ المحلي."


func _manual_load() -> void:
	var ok: bool = _load_game()
	if ok:
		overlay_mode = ""
		menu_root.visible = false
		hud_panel.visible = true
		game_active = true
		_set_gameplay_mouse_mode()
		_show_dialogue("📂 تم تحميل آخر حفظ.")
	else:
		var status := menu_panel.find_child("SaveStatus", true, false) as Label
		if status != null:
			status.text = "مفيش ملف حفظ صالح."


func _save_game() -> bool:
	var cfg := ConfigFile.new()

	cfg.set_value("account", "account_id", current_account_id)
	cfg.set_value("account", "email", current_account_email)

	cfg.set_value("player", "name", player_name)
	cfg.set_value("player", "character_index", character_index)
	cfg.set_value("player", "character_gender", character_gender)
	cfg.set_value("player", "position", _player_pos())
	cfg.set_value("player", "rotation_y", player.rotation.y)

	cfg.set_value("progress", "phase", phase)
	cfg.set_value("progress", "money", money)
	cfg.set_value("progress", "case_files", case_files)
	cfg.set_value("progress", "evidence_found", evidence_found)
	cfg.set_value("progress", "game_time_minutes", game_time_minutes)
	cfg.set_value("progress", "current_interior", current_interior)

	cfg.set_value("upgrades", "car_owned", car_owned)
	cfg.set_value("upgrades", "outfit_owned", outfit_owned)
	cfg.set_value("upgrades", "home_upgrade_owned", home_upgrade_owned)

	var save_error: int = cfg.save(_current_save_path())
	var local_ok: bool = save_error == OK

	if local_ok and _online_has_session():
		online_backend.call("save_cloud", _make_cloud_save_payload())

	return local_ok


func _load_game() -> bool:
	var cfg := ConfigFile.new()
	var load_error: int = cfg.load(_current_save_path())
	if load_error != OK:
		return false

	var save_account_id: String = str(cfg.get_value("account", "account_id", current_account_id))
	if current_account_id != "" and save_account_id != "" and save_account_id != current_account_id:
		return false

	player_name = str(cfg.get_value("player", "name", "فلفل"))
	character_index = int(cfg.get_value("player", "character_index", 0))
	character_index = clampi(character_index, 0, character_profiles.size() - 1)
	character_gender = str(cfg.get_value("player", "character_gender", "male"))

	phase = int(cfg.get_value("progress", "phase", 0))
	money = int(cfg.get_value("progress", "money", 0))
	case_files = int(cfg.get_value("progress", "case_files", 0))
	evidence_found = bool(cfg.get_value("progress", "evidence_found", false))
	game_time_minutes = float(cfg.get_value("progress", "game_time_minutes", 390.0))

	car_owned = bool(cfg.get_value("upgrades", "car_owned", false))
	outfit_owned = bool(cfg.get_value("upgrades", "outfit_owned", false))
	home_upgrade_owned = bool(cfg.get_value("upgrades", "home_upgrade_owned", false))

	var saved_interior: String = str(cfg.get_value("progress", "current_interior", ""))
	var allowed_interiors: Array[String] = ["", "station", "house", "restaurant", "car", "clothes", "home"]
	current_interior = saved_interior if allowed_interiors.has(saved_interior) else ""

	_apply_character_style()
	if outfit_owned:
		_set_outfit_color(Color(0.08,0.08,0.09), 0.18)
	if home_upgrade_owned:
		_upgrade_home()

	if car_owned:
		if car == null:
			_spawn_car()
	elif car != null:
		car.queue_free()
		car = null
		car_mesh = null

	in_car = false
	player.visible = true
	player.velocity = Vector3.ZERO

	var saved_position: Variant = cfg.get_value("player", "position", Vector3(0,1,-0.5))
	if saved_position is Vector3:
		player.global_position = saved_position
	else:
		player.global_position = Vector3(0,1,-0.5)

	player.rotation.y = float(cfg.get_value("player", "rotation_y", 0.0))

	if current_interior == "station" or current_interior == "house" or current_interior == "restaurant":
		story_return_pos = _story_return_position(current_interior)
	elif current_interior == "car" or current_interior == "clothes" or current_interior == "home":
		interior_return_pos = _shop_return_pos(current_interior)

	if minimap_panel != null:
		minimap_panel.visible = current_interior == ""

	hud_panel.visible = true
	_sync_hud()
	return true


func _make_cloud_save_payload() -> Dictionary:
	var p: Vector3 = _player_pos()
	return {
		"version": 1,
		"player": {
			"name": player_name,
			"character_index": character_index,
			"character_gender": character_gender,
			"position": [p.x, p.y, p.z],
			"rotation_y": player.rotation.y
		},
		"progress": {
			"phase": phase,
			"money": money,
			"case_files": case_files,
			"evidence_found": evidence_found,
			"game_time_minutes": game_time_minutes,
			"current_interior": current_interior
		},
		"upgrades": {
			"car_owned": car_owned,
			"outfit_owned": outfit_owned,
			"home_upgrade_owned": home_upgrade_owned
		}
	}


func _apply_cloud_save_payload(data: Dictionary) -> bool:
	var player_data_variant: Variant = data.get("player", {})
	var progress_data_variant: Variant = data.get("progress", {})
	var upgrades_data_variant: Variant = data.get("upgrades", {})

	if not (player_data_variant is Dictionary):
		return false
	if not (progress_data_variant is Dictionary):
		return false
	if not (upgrades_data_variant is Dictionary):
		return false

	var player_data: Dictionary = player_data_variant
	var progress_data: Dictionary = progress_data_variant
	var upgrades_data: Dictionary = upgrades_data_variant

	player_name = str(player_data.get("name", "فلفل"))
	character_index = int(player_data.get("character_index", 0))
	character_index = clampi(character_index, 0, character_profiles.size() - 1)
	character_gender = str(player_data.get("character_gender", "male"))

	phase = int(progress_data.get("phase", 0))
	money = int(progress_data.get("money", 0))
	case_files = int(progress_data.get("case_files", 0))
	evidence_found = bool(progress_data.get("evidence_found", false))
	game_time_minutes = float(progress_data.get("game_time_minutes", 390.0))

	var saved_interior: String = str(progress_data.get("current_interior", ""))
	var allowed_interiors: Array[String] = ["", "station", "house", "restaurant", "car", "clothes", "home"]
	current_interior = saved_interior if allowed_interiors.has(saved_interior) else ""

	car_owned = bool(upgrades_data.get("car_owned", false))
	outfit_owned = bool(upgrades_data.get("outfit_owned", false))
	home_upgrade_owned = bool(upgrades_data.get("home_upgrade_owned", false))

	_apply_character_style()

	if outfit_owned:
		_set_outfit_color(Color(0.08,0.08,0.09), 0.18)

	if home_upgrade_owned:
		_upgrade_home()

	if car_owned:
		if car == null:
			_spawn_car()
	elif car != null:
		car.queue_free()
		car = null
		car_mesh = null

	in_car = false
	player.visible = true
	player.velocity = Vector3.ZERO

	var pos_variant: Variant = player_data.get("position", [])
	if pos_variant is Array:
		var pos_array: Array = pos_variant
		if pos_array.size() >= 3:
			player.global_position = Vector3(
				float(pos_array[0]),
				float(pos_array[1]),
				float(pos_array[2])
			)
		else:
			player.global_position = Vector3(0,1,-0.5)
	else:
		player.global_position = Vector3(0,1,-0.5)

	player.rotation.y = float(player_data.get("rotation_y", 0.0))

	if current_interior == "station" or current_interior == "house" or current_interior == "restaurant":
		story_return_pos = _story_return_position(current_interior)
	elif current_interior == "car" or current_interior == "clothes" or current_interior == "home":
		interior_return_pos = _shop_return_pos(current_interior)

	if minimap_panel != null:
		minimap_panel.visible = current_interior == ""

	hud_panel.visible = true
	_sync_hud()

	# نحتفظ بنسخة Local كـ fallback من غير ما نعمل Cloud request تاني.
	var cfg := ConfigFile.new()
	cfg.set_value("account", "account_id", current_account_id)
	cfg.set_value("account", "email", current_account_email)
	cfg.set_value("player", "name", player_name)
	cfg.set_value("player", "character_index", character_index)
	cfg.set_value("player", "character_gender", character_gender)
	cfg.set_value("player", "position", player.global_position)
	cfg.set_value("player", "rotation_y", player.rotation.y)
	cfg.set_value("progress", "phase", phase)
	cfg.set_value("progress", "money", money)
	cfg.set_value("progress", "case_files", case_files)
	cfg.set_value("progress", "evidence_found", evidence_found)
	cfg.set_value("progress", "game_time_minutes", game_time_minutes)
	cfg.set_value("progress", "current_interior", current_interior)
	cfg.set_value("upgrades", "car_owned", car_owned)
	cfg.set_value("upgrades", "outfit_owned", outfit_owned)
	cfg.set_value("upgrades", "home_upgrade_owned", home_upgrade_owned)
	cfg.save(_current_save_path())

	return true


func _autosave() -> void:
	_save_game()


func _show_continue_menu() -> void:
	game_active = false
	menu_root.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	var source_text: String = "Cloud Save موجود للحساب."
	if online_cloud_save_cache.is_empty():
		source_text = "فيه تقدم محفوظ محليًا."

	var box := _new_menu_panel("🌶️ المحقق فلفل", source_text)

	var continue_button := Button.new()
	continue_button.text = "▶️ كمل آخر لعبة"
	continue_button.custom_minimum_size.y = 54
	continue_button.pressed.connect(_continue_saved_game)
	box.add_child(continue_button)

	var new_game := Button.new()
	new_game.text = "🆕 ابدأ لعبة جديدة"
	new_game.custom_minimum_size.y = 54
	new_game.pressed.connect(_show_character_select)
	box.add_child(new_game)

	var back := Button.new()
	back.text = "رجوع للقائمة"
	back.pressed.connect(_show_start_menu)
	box.add_child(back)


func _continue_saved_game() -> void:
	var loaded: bool = false

	if not online_cloud_save_cache.is_empty():
		loaded = _apply_cloud_save_payload(online_cloud_save_cache)
	else:
		loaded = _load_game()

	if not loaded:
		_show_character_select()
		return

	overlay_mode = ""
	menu_root.visible = false
	hud_panel.visible = true
	game_active = true
	_set_gameplay_mouse_mode()
	_show_dialogue("أهلاً برجوعك يا %s. كمل القضية من آخر حفظ." % player_name)


# -----------------------------------------------------------------------------
# LOGIN / SIGN IN / CHARACTER
# -----------------------------------------------------------------------------

func _build_menu_layer() -> void:
	menu_layer = CanvasLayer.new()
	menu_layer.layer = 5
	add_child(menu_layer)

	menu_root = Control.new()
	menu_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	menu_root.layout_direction = Control.LAYOUT_DIRECTION_RTL
	menu_layer.add_child(menu_root)

func _new_menu_panel(title_text: String, subtitle_text: String = "") -> VBoxContainer:
	if menu_panel != null and is_instance_valid(menu_panel):
		menu_panel.queue_free()

	menu_panel = PanelContainer.new()
	menu_panel.set_anchors_preset(Control.PRESET_CENTER)
	menu_panel.offset_left = -260
	menu_panel.offset_right = 260
	menu_panel.offset_top = -240
	menu_panel.offset_bottom = 240
	menu_root.add_child(menu_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 22)
	margin.add_theme_constant_override("margin_bottom", 22)
	menu_panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	margin.add_child(vbox)

	var title := Label.new()
	title.text = title_text
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 30)
	vbox.add_child(title)

	if subtitle_text != "":
		var sub := Label.new()
		sub.text = subtitle_text
		sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		sub.modulate = Color(0.75,0.75,0.75)
		vbox.add_child(sub)

	return vbox

func _show_start_menu() -> void:
	game_active = false
	overlay_mode = ""
	menu_root.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	var online_label: String = "🟢 Online متوصل" if _online_is_configured() else "🔴 Online غير متاح"
	var box := _new_menu_panel("🌶️ المحقق فلفل", "Online Accounts + Cloud Save — %s" % online_label)

	var spacer := Control.new()
	spacer.custom_minimum_size.y = 16
	box.add_child(spacer)

	var login := Button.new()
	login.text = "Log In — تسجيل دخول Online"
	login.custom_minimum_size.y = 54
	login.pressed.connect(_on_auth_choice.bind("login"))
	box.add_child(login)

	var signup := Button.new()
	signup.text = "Sign Up — إنشاء حساب Online"
	signup.custom_minimum_size.y = 54
	signup.pressed.connect(_on_auth_choice.bind("signup"))
	box.add_child(signup)

	var setup := Button.new()
	setup.text = "⚙️ Online Settings"
	setup.custom_minimum_size.y = 50
	setup.pressed.connect(_show_online_setup)
	box.add_child(setup)

	var quality := OptionButton.new()
	quality.add_item("Low — أخف أداء", 0)
	quality.add_item("Medium — متوازن", 1)
	quality.add_item("High — الأفضل حاليًا", 2)
	quality.select(quality_level)
	quality.item_selected.connect(_on_quality_selected)
	box.add_child(quality)

	var note := Label.new()
	if touch_controls_enabled:
		note.text = "📱 Touch Mode شغال تلقائيًا: عصاية حركة + سحب للكاميرا + أزرار تفاعل/جري/قفز."
	else:
		note.text = "🖥️ PC Mode: WASD/الأسهم + Mouse + Shift + Space + E. الحساب والـCloud Save شغالين Online."
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(note)

func _on_quality_selected(index: int) -> void:
	quality_level = index

	if npc_root:
		npc_root.visible = quality_level >= 1
	if traffic_root:
		traffic_root.visible = quality_level >= 1
	if sun_light:
		sun_light.shadow_enabled = quality_level >= 1

	for child in get_children():
		if child is OmniLight3D:
			child.visible = quality_level >= 2

func _on_auth_choice(mode: String) -> void:
	auth_mode = mode

	var title := "Log In — تسجيل الدخول Online"
	if mode == "signup":
		title = "Sign Up — حساب Online جديد"

	var subtitle: String = "الحساب ده هيشتغل على أي جهاز بعد تسجيل الدخول."
	if not _online_is_configured():
		subtitle = "Online backend غير متاح حاليًا."

	var box := _new_menu_panel(title, subtitle)

	auth_email = LineEdit.new()
	auth_email.placeholder_text = "الإيميل"
	auth_email.custom_minimum_size.y = 48
	box.add_child(auth_email)

	auth_pass = LineEdit.new()
	auth_pass.placeholder_text = "كلمة السر"
	auth_pass.secret = true
	auth_pass.custom_minimum_size.y = 48
	box.add_child(auth_pass)

	auth_message = Label.new()
	auth_message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if not _online_is_configured():
		auth_message.text = "الاتصال بالسيرفر غير متاح حاليًا."
	box.add_child(auth_message)

	var cont := Button.new()
	cont.text = "اتصل بالسيرفر"
	cont.custom_minimum_size.y = 50
	cont.disabled = not _online_is_configured()
	cont.pressed.connect(_submit_auth)
	box.add_child(cont)

	var setup := Button.new()
	setup.text = "⚙️ فتح Online Setup"
	setup.pressed.connect(_show_online_setup)
	box.add_child(setup)

	var back := Button.new()
	back.text = "رجوع"
	back.pressed.connect(_show_start_menu)
	box.add_child(back)

func _submit_auth() -> void:
	var email: String = auth_email.text.strip_edges().to_lower()
	var password: String = auth_pass.text

	if not _online_is_configured():
		auth_message.text = "Online backend مش متظبط. افتح Online Setup."
		return

	if email.length() < 5 or not email.contains("@") or password.length() < 6:
		auth_message.text = "اكتب إيميل صحيح وكلمة سر 6 حروف على الأقل."
		return

	auth_message.text = "🌐 جاري الاتصال..."
	current_account_email = email

	if auth_mode == "signup":
		online_backend.call("sign_up", email, password)
	else:
		online_backend.call("sign_in", email, password)


func _show_online_setup() -> void:
	game_active = false
	menu_root.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	var box := _new_menu_panel(
		"⚙️ Online Setup",
		"اربط اللعبة بمشروع Supabase. استخدم Publishable Key فقط، وممنوع تحط Secret Key داخل اللعبة."
	)

	online_setup_url = LineEdit.new()
	online_setup_url.placeholder_text = "https://YOUR_PROJECT.supabase.co"
	online_setup_url.custom_minimum_size.y = 48
	box.add_child(online_setup_url)

	online_setup_key = LineEdit.new()
	online_setup_key.placeholder_text = "sb_publishable_..."
	online_setup_key.custom_minimum_size.y = 48
	box.add_child(online_setup_key)

	if online_backend != null and _online_is_configured():
		online_setup_url.text = str(online_backend.get("project_url"))
		online_setup_key.text = str(online_backend.get("publishable_key"))

	var help := Label.new()
	help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	help.text = "قبل الحفظ: شغّل backend/supabase_setup.sql مرة واحدة من Supabase SQL Editor."
	box.add_child(help)

	var status := Label.new()
	status.name = "OnlineSetupStatus"
	status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(status)

	var save := Button.new()
	save.text = "💾 حفظ إعدادات Online"
	save.custom_minimum_size.y = 50
	save.pressed.connect(_save_online_setup)
	box.add_child(save)

	var back := Button.new()
	back.text = "رجوع للقائمة"
	back.pressed.connect(_show_start_menu)
	box.add_child(back)


func _save_online_setup() -> void:
	var status := menu_panel.find_child("OnlineSetupStatus", true, false) as Label
	if online_backend == null:
		if status != null:
			status.text = "OnlineBackend غير متاح."
		return

	var url: String = online_setup_url.text.strip_edges()
	var key: String = online_setup_key.text.strip_edges()

	if key.begins_with("sb_secret_") or key.contains("service_role"):
		if status != null:
			status.text = "❌ ماينفعش تحط Secret/Service Role key داخل اللعبة. استخدم Publishable Key."
		return

	var ok: bool = bool(online_backend.call("configure", url, key))
	if status != null:
		status.text = "✅ تم حفظ إعدادات Online." if ok else "❌ راجع Project URL والـ Publishable Key."


func _on_online_auth_completed(success: bool, _mode: String, data: Dictionary, message: String) -> void:
	if auth_message != null and is_instance_valid(auth_message):
		auth_message.text = message

	if not success:
		return

	var needs_confirmation: bool = bool(data.get("needs_confirmation", false))
	if needs_confirmation:
		if auth_message != null and is_instance_valid(auth_message):
			auth_message.text = "✅ الحساب اتعمل. افتح رسالة التفعيل في الإيميل وبعدها اعمل Log In."
		return

	current_account_id = str(data.get("user_id", ""))
	current_account_email = str(data.get("email", current_account_email))

	if current_account_id == "":
		if auth_message != null and is_instance_valid(auth_message):
			auth_message.text = "السيرفر رجع جلسة ناقصة."
		return

	online_load_context = "login"
	online_cloud_save_cache.clear()

	if auth_message != null and is_instance_valid(auth_message):
		auth_message.text = "✅ تم الدخول. جاري فحص Cloud Save..."

	online_backend.call("load_cloud_save")


func _on_online_cloud_save_completed(success: bool, message: String) -> void:
	online_status_message = message
	if not success:
		print("Cloud save failed: ", message)


func _on_online_cloud_load_completed(success: bool, found: bool, data: Dictionary, message: String) -> void:
	online_status_message = message

	if online_load_context == "login":
		online_load_context = ""
		if success and found:
			online_cloud_save_cache = data.duplicate(true)
			_show_continue_menu()
		else:
			online_cloud_save_cache.clear()
			_show_character_select()
		return

	if online_load_context == "pause":
		online_load_context = ""
		if success and found:
			var applied: bool = _apply_cloud_save_payload(data)
			if applied:
				overlay_mode = ""
				menu_root.visible = false
				hud_panel.visible = true
				game_active = true
				_set_gameplay_mouse_mode()
				_show_dialogue("☁️ تم تحميل آخر Cloud Save.")
			else:
				var status := menu_panel.find_child("SaveStatus", true, false) as Label
				if status != null:
					status.text = "Cloud Save وصل لكن بياناته غير صالحة."
		else:
			var status := menu_panel.find_child("SaveStatus", true, false) as Label
			if status != null:
				status.text = "مفيش Cloud Save متاح للحساب."


func _request_cloud_load_from_pause() -> void:
	if not _online_has_session():
		var status := menu_panel.find_child("SaveStatus", true, false) as Label
		if status != null:
			status.text = "مفيش جلسة Online شغالة."
		return

	online_load_context = "pause"
	var status := menu_panel.find_child("SaveStatus", true, false) as Label
	if status != null:
		status.text = "☁️ جاري تحميل Cloud Save..."
	online_backend.call("load_cloud_save")


func _accounts_path() -> String:
	return "user://felfel_accounts.json"


func _current_save_path() -> String:
	if current_account_id == "":
		return "user://felfel_save_guest.cfg"
	return "user://felfel_save_%s.cfg" % current_account_id


func _load_accounts_db() -> Dictionary:
	var path: String = _accounts_path()

	if not FileAccess.file_exists(path):
		return {"version": 1, "accounts": {}}

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {"version": 1, "accounts": {}}

	var raw: String = file.get_as_text()
	var parsed: Variant = JSON.parse_string(raw)

	if parsed is Dictionary:
		var db: Dictionary = parsed
		if not db.has("accounts") or not (db["accounts"] is Dictionary):
			db["accounts"] = {}
		if not db.has("version"):
			db["version"] = 1
		return db

	return {"version": 1, "accounts": {}}


func _save_accounts_db(db: Dictionary) -> bool:
	var file := FileAccess.open(_accounts_path(), FileAccess.WRITE)
	if file == null:
		return false

	file.store_string(JSON.stringify(db, "\t"))
	return true


func _normalize_email(email: String) -> String:
	return email.strip_edges().to_lower()


func _make_account_id(email: String) -> String:
	# ID ثابت وغير قابل للقراءة مباشرة من اسم الملف.
	return _normalize_email(email).sha256_text().substr(0, 20)


func _make_password_salt(email: String) -> String:
	var seed_text: String = "%s|%s|%s" % [
		_normalize_email(email),
		str(Time.get_unix_time_from_system()),
		str(randi())
	]
	return seed_text.sha256_text().substr(0, 32)


func _password_hash(password: String, salt: String) -> String:
	return (salt + "|" + password).sha256_text()


func _register_account(email: String, password: String) -> Dictionary:
	var normalized_email: String = _normalize_email(email)
	var db: Dictionary = _load_accounts_db()
	var accounts: Dictionary = db.get("accounts", {})

	for key: Variant in accounts.keys():
		var account: Variant = accounts[key]
		if account is Dictionary and str(account.get("email", "")).to_lower() == normalized_email:
			return {
				"ok": false,
				"message": "الإيميل ده مسجل بالفعل. استخدم Log In."
			}

	var account_id: String = _make_account_id(normalized_email)
	var salt: String = _make_password_salt(normalized_email)
	var now: int = int(Time.get_unix_time_from_system())

	accounts[account_id] = {
		"email": normalized_email,
		"password_salt": salt,
		"password_hash": _password_hash(password, salt),
		"created_at": now,
		"last_login": now
	}

	db["accounts"] = accounts

	if not _save_accounts_db(db):
		return {
			"ok": false,
			"message": "مقدرتش أحفظ بيانات الحساب على الجهاز."
		}

	return {
		"ok": true,
		"account_id": account_id
	}


func _authenticate_account(email: String, password: String) -> Dictionary:
	var normalized_email: String = _normalize_email(email)
	var db: Dictionary = _load_accounts_db()
	var accounts: Dictionary = db.get("accounts", {})

	for key: Variant in accounts.keys():
		var account_variant: Variant = accounts[key]
		if not (account_variant is Dictionary):
			continue

		var account: Dictionary = account_variant
		if str(account.get("email", "")).to_lower() != normalized_email:
			continue

		var salt: String = str(account.get("password_salt", ""))
		var expected_hash: String = str(account.get("password_hash", ""))

		if salt == "" or expected_hash == "":
			return {
				"ok": false,
				"message": "بيانات الحساب غير صالحة."
			}

		if _password_hash(password, salt) != expected_hash:
			return {
				"ok": false,
				"message": "الإيميل أو كلمة السر مش صح."
			}

		account["last_login"] = int(Time.get_unix_time_from_system())
		accounts[key] = account
		db["accounts"] = accounts
		_save_accounts_db(db)

		return {
			"ok": true,
			"account_id": str(key)
		}

	return {
		"ok": false,
		"message": "الحساب مش موجود. اعمل Sign In الأول."
	}


func _accounts_count() -> int:
	var db: Dictionary = _load_accounts_db()
	var accounts: Dictionary = db.get("accounts", {})
	return accounts.size()


func _show_character_select() -> void:
	var box := _new_menu_panel("اختار شخصيتك", "اختار ولد أو بنت؛ كل الحوار والأوامر هتتغير تلقائيًا حسب الشخصية.")

	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	box.add_child(grid)

	for i in range(character_profiles.size()):
		var b := Button.new()
		var profile = character_profiles[i]
		var gender_tag := "♀" if profile["gender"] == "female" else "♂"
		b.text = "%s  %s" % [gender_tag, profile["label"]]
		b.custom_minimum_size = Vector2(210, 58)
		b.pressed.connect(_choose_character.bind(i, b))
		grid.add_child(b)

	character_next_button = Button.new()
	character_next_button.text = "التالي"
	character_next_button.disabled = true
	character_next_button.custom_minimum_size.y = 50
	character_next_button.pressed.connect(_show_name_screen)
	box.add_child(character_next_button)

func _choose_character(index: int, button: Button) -> void:
	character_index = index
	character_gender = str(character_profiles[index]["gender"])
	character_next_button.disabled = false
	for child in button.get_parent().get_children():
		if child is Button:
			child.modulate = Color.WHITE
	button.modulate = Color(0.80, 1.0, 0.80)

func _show_name_screen() -> void:
	var box := _new_menu_panel("اسم الشخصية", "الاسم ده هيظهر في الحوار والقضايا.")

	name_input = LineEdit.new()
	name_input.placeholder_text = "مثلاً: لولو فلفل"
	name_input.max_length = 18
	name_input.custom_minimum_size.y = 50
	box.add_child(name_input)

	var start := Button.new()
	start.text = "ابدأ أول قضية"
	start.custom_minimum_size.y = 54
	start.pressed.connect(_start_game)
	box.add_child(start)

func _start_game() -> void:
	var n := name_input.text.strip_edges()
	if n != "":
		player_name = n

	phase = 0
	money = 0
	case_files = 0
	evidence_found = false
	car_owned = false
	outfit_owned = false
	home_upgrade_owned = false
	current_interior = ""
	game_time_minutes = 390.0
	player.global_position = Vector3(0,1.0,-0.5)
	player.velocity = Vector3.ZERO

	_apply_character_style()
	menu_root.visible = false
	hud_panel.visible = true
	game_active = true
	_set_gameplay_mouse_mode()
	_sync_hud()
	_autosave()
	_show_dialogue("صباح الفل يا %s! %s بـ W A S D، Shift للجري، Space للقفز، %s الكاميرا بالماوس، عجلة الماوس للزوم، و%s E للتفاعل. B للشنطة وEsc للحفظ. أول محطة: قسم الشرطة." % [player_name, _g("اتحرك", "اتحركي"), _g("لف", "لفي"), _g("اضغط", "اضغطي")])

func _apply_character_style() -> void:
	var palette: Array[Color] = [
		Color(0.16,0.28,0.50),
		Color(0.34,0.22,0.42),
		Color(0.42,0.25,0.18),
		Color(0.45,0.34,0.12),
		Color(0.12,0.35,0.28),
		Color(0.18,0.18,0.22),
		Color(0.30,0.24,0.13),
		Color(0.22,0.30,0.36)
	]
	var chosen_color: Color = palette[character_index % palette.size()]
	_set_outfit_color(chosen_color)
	_apply_head_style()


# -----------------------------------------------------------------------------
# INTERROGATION
# -----------------------------------------------------------------------------

func _open_interrogation() -> void:
	game_active = false
	menu_root.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	asked.clear()

	var box := _new_menu_panel("قسم استجواب المتهمين", "اسأل 3 أشخاص على الأقل، وبعدها اختار صاحب الجريمة.")

	for i in range(suspects.size()):
		var s = suspects[i]
		var b := Button.new()
		b.text = "%s  %s" % [s["icon"], s["name"]]
		b.custom_minimum_size.y = 45
		b.pressed.connect(_ask_suspect.bind(i, b))
		box.add_child(b)

	var talk := Label.new()
	talk.name = "TalkLabel"
	talk.text = "اختار متهم واسأله."
	talk.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	talk.custom_minimum_size.y = 72
	box.add_child(talk)

	var accuse := Button.new()
	accuse.name = "AccuseButton"
	accuse.text = "⚖️ اختار صاحب الجريمة"
	accuse.disabled = true
	accuse.custom_minimum_size.y = 50
	accuse.pressed.connect(_show_accusation_choices)
	box.add_child(accuse)

func _ask_suspect(index: int, button: Button) -> void:
	asked[index] = true
	button.text = "✅ " + button.text
	button.disabled = true

	var talk := menu_panel.find_child("TalkLabel", true, false) as Label
	talk.text = "%s: %s" % [suspects[index]["name"], suspects[index]["line"]]

	if asked.size() >= 3:
		var accuse := menu_panel.find_child("AccuseButton", true, false) as Button
		accuse.disabled = false

func _show_accusation_choices() -> void:
	var box := _new_menu_panel("مين صاحب الجريمة؟", "الدليل: زرار أحمر عليه صوص ثوم، وأحدهم ذكر القميص الأحمر الناقص زرار.")

	for i in range(suspects.size()):
		var s = suspects[i]
		var b := Button.new()
		b.text = "%s  %s" % [s["icon"], s["name"]]
		b.custom_minimum_size.y = 46
		b.pressed.connect(_accuse.bind(i))
		box.add_child(b)

	var result := Label.new()
	result.name = "ResultLabel"
	result.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	result.custom_minimum_size.y = 70
	box.add_child(result)

func _accuse(index: int) -> void:
	var result := menu_panel.find_child("ResultLabel", true, false) as Label
	if index == 3:
		result.text = "صح! فتحي المخزنجي قال إن الزرار وقع من أسبوع، لكن الزرار اتلاقى عليه صوص ثوم طازة في مسرح الجريمة. القضية اتحلت!"
		money += 15000
		case_files = 0
		phase = 4
		_sync_hud()
		_autosave()

		var finish := Button.new()
		finish.text = "🏆 استلم 15,000 جنيه وارجع للمدينة"
		finish.custom_minimum_size.y = 52
		finish.pressed.connect(_finish_case)
		menu_panel.find_child("VBoxContainer", true, false)
		# أضفه في آخر الـVBox الموجود داخل اللوحة
		var margin := menu_panel.get_child(0)
		var box := margin.get_child(0)
		box.add_child(finish)
	else:
		result.text = "مش هو. راجع المتهم اللي مرتبط بالقميص الأحمر الناقص زرار."

func _finish_case() -> void:
	menu_root.visible = false
	game_active = true
	_set_gameplay_mouse_mode()
	_show_dialogue("الريس عطية: برافو يا %s! الكشري رجع لأصحابه والعدالة أخدت شطة زيادة. %s" % [player_name, _g("روح المعرض وطور حاجتك.", "روحي المعرض وطوري حاجتك.")])


# -----------------------------------------------------------------------------
# SHOP + CAR + UPGRADES
# -----------------------------------------------------------------------------

func _open_shop(shop_type: String) -> void:
	game_active = false
	menu_root.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	var title := "متجر فلفل"
	var subtitle := "فلوسك: %d جنيه" % money

	match shop_type:
		"car":
			title = "معرض فلفل للعربيات"
			subtitle = "فلوسك: %d جنيه — اشتري عربيتك من هنا." % money
		"clothes":
			title = "أتيليه فلفل للملابس"
			subtitle = "فلوسك: %d جنيه — اللبس الفخم ليه هيبة." % money
		"home":
			title = "مكتب تطوير البيت"
			subtitle = "فلوسك: %d جنيه — طور البيت والمكتب." % money

	var box := _new_menu_panel(title, subtitle)

	match shop_type:
		"car":
			_add_shop_button(box, "🚗 عربية مستعملة محترمة — 10,000", 10000, "car", shop_type)
		"clothes":
			_add_shop_button(box, "👔 بدلة/لبس فخم — 4,000", 4000, "outfit", shop_type)
		"home":
			_add_shop_button(box, "🏠 تطوير البيت والمكتب — 7,000", 7000, "home", shop_type)

	var msg := Label.new()
	msg.name = "ShopMessage"
	msg.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	msg.text = "اختار الحاجة اللي عايز تشتريها."
	box.add_child(msg)

	var close := Button.new()
	close.text = "ارجع للمحل" if current_interior != "" else "ارجع للمدينة"
	close.pressed.connect(_close_shop)
	box.add_child(close)

func _add_shop_button(box: VBoxContainer, text: String, price: int, item: String, shop_type: String) -> void:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size.y = 48
	b.pressed.connect(_buy_item.bind(price, item, b, shop_type))
	box.add_child(b)

func _buy_item(price: int, item: String, button: Button, _shop_type: String) -> void:
	var msg := menu_panel.find_child("ShopMessage", true, false) as Label

	if item == "car" and car_owned:
		msg.text = "إنت اشتريت العربية دي قبل كده."
		return
	if item == "outfit" and outfit_owned:
		msg.text = "اللبس ده اتشرى خلاص."
		return
	if item == "home" and home_upgrade_owned:
		msg.text = "البيت متطور بالفعل."
		return

	if money < price:
		msg.text = "فلوسك مش مكفية. حل قضايا أكتر."
		return

	money -= price
	_sync_hud()
	button.disabled = true
	button.text = "✅ " + button.text

	if item == "car":
		car_owned = true
		_spawn_car()
		msg.text = _g("مبروك! عربيتك مستنياك قدام البيت. قرب منها واضغط E.", "مبروك! عربيتك مستنياكي قدام البيت. اقربي منها واضغطي E.")
	elif item == "outfit":
		outfit_owned = true
		_set_outfit_color(Color(0.08,0.08,0.09), 0.18)
		msg.text = _g("مبروك! اشتريت لبس فخم من الأتيليه. فلفل دخل مود المحامي الـVIP.", "مبروك! اشتريتي لبس فخم من الأتيليه. فلفل دخلت مود المحامية الـVIP.")
	elif item == "home":
		home_upgrade_owned = true
		_upgrade_home()
		msg.text = "البيت اتطور! زودنا دور علوي ولمسة فخامة."

	_autosave()

func _close_shop() -> void:
	menu_root.visible = false
	game_active = true
	_set_gameplay_mouse_mode()

func _spawn_car() -> void:
	if car != null:
		return

	car = CharacterBody3D.new()
	car.name = "FelfelCar"
	car.position = garage_pos + Vector3(0, 0.65, 0)

	var cs := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(1.8, 1.0, 3.5)
	cs.shape = shape
	car.add_child(cs)

	car_mesh = MeshInstance3D.new()
	var body_mesh := BoxMesh.new()
	body_mesh.size = Vector3(1.8, 0.8, 3.5)
	car_mesh.mesh = body_mesh
	car_mesh.position.y = 0.15
	var car_mat := StandardMaterial3D.new()
	car_mat.albedo_color = Color(0.10,0.18,0.24)
	car_mat.metallic = 0.45
	car_mesh.material_override = car_mat
	car.add_child(car_mesh)

	# كابينة
	var cabin := MeshInstance3D.new()
	var cabin_mesh := BoxMesh.new()
	cabin_mesh.size = Vector3(1.5, 0.65, 1.8)
	cabin.mesh = cabin_mesh
	cabin.position = Vector3(0,0.7,-0.2)
	var cabin_mat := StandardMaterial3D.new()
	cabin_mat.albedo_color = Color(0.12,0.20,0.26)
	cabin_mat.metallic = 0.3
	cabin.material_override = cabin_mat
	car.add_child(cabin)

	# تفاصيل أكتر لجسم العربية
	var hood := MeshInstance3D.new()
	var hood_mesh := BoxMesh.new()
	hood_mesh.size = Vector3(1.68,0.20,0.95)
	hood.mesh = hood_mesh
	hood.position = Vector3(0,0.46,-1.18)
	hood.material_override = car_mat
	car.add_child(hood)

	var trunk := MeshInstance3D.new()
	var trunk_mesh := BoxMesh.new()
	trunk_mesh.size = Vector3(1.65,0.24,0.65)
	trunk.mesh = trunk_mesh
	trunk.position = Vector3(0,0.46,1.30)
	trunk.material_override = car_mat
	car.add_child(trunk)

	var headlight_positions: Array[Vector3] = [
		Vector3(-0.58,0.38,-1.78),
		Vector3(0.58,0.38,-1.78)
	]
	for hp: Vector3 in headlight_positions:
		var light_mesh := MeshInstance3D.new()
		var lm := BoxMesh.new()
		lm.size = Vector3(0.38,0.20,0.08)
		light_mesh.mesh = lm
		light_mesh.position = hp
		var lmat := StandardMaterial3D.new()
		lmat.albedo_color = Color(1.0,0.90,0.60)
		lmat.emission_enabled = true
		lmat.emission = Color(0.50,0.36,0.14)
		light_mesh.material_override = lmat
		car.add_child(light_mesh)

	var tail_positions: Array[Vector3] = [
		Vector3(-0.58,0.38,1.78),
		Vector3(0.58,0.38,1.78)
	]
	for tp: Vector3 in tail_positions:
		var tail := MeshInstance3D.new()
		var tm := BoxMesh.new()
		tm.size = Vector3(0.34,0.18,0.08)
		tail.mesh = tm
		tail.position = tp
		var tmat := StandardMaterial3D.new()
		tmat.albedo_color = Color(0.70,0.06,0.03)
		tmat.emission_enabled = true
		tmat.emission = Color(0.30,0.015,0.01)
		tail.material_override = tmat
		car.add_child(tail)

	# عجلات
	for wheel_pos in [Vector3(-0.92,-0.25,-1.15), Vector3(0.92,-0.25,-1.15), Vector3(-0.92,-0.25,1.15), Vector3(0.92,-0.25,1.15)]:
		var wheel := MeshInstance3D.new()
		var wheel_mesh := CylinderMesh.new()
		wheel_mesh.top_radius = 0.34
		wheel_mesh.bottom_radius = 0.34
		wheel_mesh.height = 0.22
		wheel.mesh = wheel_mesh
		wheel.position = wheel_pos
		wheel.rotation_degrees = Vector3(0,0,90)
		var wheel_mat := StandardMaterial3D.new()
		wheel_mat.albedo_color = Color(0.04,0.04,0.04)
		wheel.material_override = wheel_mat
		car.add_child(wheel)

	add_child(car)

func _enter_car() -> void:
	if car == null:
		return
	in_car = true
	player.visible = false
	car_speed = 0.0
	_show_dialogue("%s: أهو بقينا بنروح القسم بعربية بدل ما نوصل والقضية تكون خلصت لوحدها!" % player_name)

func _exit_car() -> void:
	if car == null:
		return
	in_car = false
	player.visible = true
	player.global_position = car.global_position + car.transform.basis.x * 2.2 + Vector3(0,0.5,0)
	player.velocity = Vector3.ZERO
	car_speed = 0.0

func _upgrade_home() -> void:
	if has_node("HomeUpgrade"):
		return
	var upgrade := _make_box("HomeUpgrade", Vector3(0, 4.55, 0), Vector3(7.2, 2.4, 7.2), Color(0.72,0.61,0.42), true)
	upgrade.name = "HomeUpgrade"
	_make_box("HomeUpgradeRoof", Vector3(0, 5.85, 0), Vector3(7.6, 0.2, 7.6), Color(0.22,0.30,0.36), true)
