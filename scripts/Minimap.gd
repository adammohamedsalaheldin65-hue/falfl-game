extends Control

var player_world: Vector3 = Vector3.ZERO
var objective_world: Vector3 = Vector3.ZERO
var player_yaw: float = 0.0
var player_in_car: bool = false

const WORLD_MIN_X: float = -80.0
const WORLD_MAX_X: float = 80.0
const WORLD_MIN_Z: float = -80.0
const WORLD_MAX_Z: float = 55.0

func _ready() -> void:
	queue_redraw()

func set_map_state(player_pos: Vector3, objective_pos: Vector3, yaw: float, in_car: bool) -> void:
	player_world = player_pos
	objective_world = objective_pos
	player_yaw = yaw
	player_in_car = in_car
	queue_redraw()

func _map_pos(world: Vector3) -> Vector2:
	var px: float = inverse_lerp(WORLD_MIN_X, WORLD_MAX_X, world.x) * size.x
	var py: float = inverse_lerp(WORLD_MIN_Z, WORLD_MAX_Z, world.z) * size.y
	return Vector2(px, py)

func _draw() -> void:
	var w: float = maxf(size.x, 1.0)
	var h: float = maxf(size.y, 1.0)

	draw_rect(Rect2(0, 0, w, h), Color(0.045, 0.055, 0.065), true)

	# مباني تخطيطية.
	var blocks: Array[Rect2] = [
		Rect2(w*0.05,h*0.08,w*0.15,h*0.14),
		Rect2(w*0.24,h*0.07,w*0.12,h*0.13),
		Rect2(w*0.42,h*0.06,w*0.15,h*0.15),
		Rect2(w*0.64,h*0.08,w*0.13,h*0.14),
		Rect2(w*0.80,h*0.08,w*0.14,h*0.16),
		Rect2(w*0.06,h*0.32,w*0.12,h*0.14),
		Rect2(w*0.77,h*0.34,w*0.14,h*0.14),
		Rect2(w*0.05,h*0.70,w*0.15,h*0.16),
		Rect2(w*0.24,h*0.70,w*0.13,h*0.15),
		Rect2(w*0.42,h*0.72,w*0.16,h*0.14),
		Rect2(w*0.64,h*0.69,w*0.14,h*0.15),
		Rect2(w*0.81,h*0.70,w*0.13,h*0.16)
	]
	for r: Rect2 in blocks:
		draw_rect(r, Color(0.14,0.16,0.17), true)
		draw_rect(r, Color(0.25,0.27,0.29), false, 1.0)

	# الطرق الرئيسية.
	var road_color: Color = Color(0.29,0.31,0.32)
	var edge_color: Color = Color(0.50,0.52,0.53)

	draw_rect(Rect2(w*0.455, 0, w*0.09, h), road_color, true)
	draw_rect(Rect2(0, h*0.50, w, h*0.09), road_color, true)
	draw_rect(Rect2(w*0.10,h*0.28,w*0.32,h*0.045), road_color, true)
	draw_rect(Rect2(w*0.59,h*0.68,w*0.31,h*0.045), road_color, true)
	draw_rect(Rect2(w*0.24,h*0.42,w*0.045,h*0.34), road_color, true)
	draw_rect(Rect2(w*0.73,h*0.18,w*0.045,h*0.32), road_color, true)

	draw_line(Vector2(w*0.455,0), Vector2(w*0.455,h), edge_color, 1.0)
	draw_line(Vector2(w*0.545,0), Vector2(w*0.545,h), edge_color, 1.0)
	draw_line(Vector2(0,h*0.50), Vector2(w,h*0.50), edge_color, 1.0)
	draw_line(Vector2(0,h*0.59), Vector2(w,h*0.59), edge_color, 1.0)

	# أماكن مهمة.
	_draw_place(Vector3(0,0,2.2), Color(0.20,0.52,0.95))       # البيت
	_draw_place(Vector3(0,0,-24.5), Color(0.25,0.72,0.95))    # القسم
	_draw_place(Vector3(22,0,-15), Color(0.95,0.32,0.18))     # مسرح الجريمة
	_draw_place(Vector3(-20,0,-10), Color(0.25,0.80,0.48))    # المعرض

	# الهدف الحالي.
	var obj: Vector2 = _map_pos(objective_world)
	draw_circle(obj, 8.0, Color(1.0,0.72,0.12,0.22))
	draw_circle(obj, 4.5, Color(1.0,0.72,0.12))
	draw_arc(obj, 8.5, 0.0, TAU, 24, Color(1.0,0.92,0.42), 1.5)

	# سهم اللاعب.
	var p: Vector2 = _map_pos(player_world)
	var forward: Vector2 = Vector2(-sin(player_yaw), -cos(player_yaw))
	var right: Vector2 = Vector2(forward.y, -forward.x)
	var tip: Vector2 = p + forward * 10.0
	var left: Vector2 = p - forward * 6.0 + right * 5.0
	var right_p: Vector2 = p - forward * 6.0 - right * 5.0
	var arrow: PackedVector2Array = PackedVector2Array([tip, left, right_p])
	draw_colored_polygon(arrow, Color(0.97,0.98,1.0))
	draw_polyline(PackedVector2Array([tip,left,right_p,tip]), Color(0.04,0.05,0.06), 1.5)

	if player_in_car:
		draw_arc(p, 12.5, 0.0, TAU, 24, Color(0.15,0.76,1.0), 2.0)

	draw_rect(Rect2(1,1,w-2,h-2), Color(0.62,0.65,0.68), false, 1.5)

func _draw_place(world: Vector3, color: Color) -> void:
	var p: Vector2 = _map_pos(world)
	draw_circle(p, 3.2, color)
	draw_arc(p, 5.0, 0.0, TAU, 18, Color(color.r,color.g,color.b,0.55), 1.0)
