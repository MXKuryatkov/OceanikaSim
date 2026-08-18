extends Node3D
class_name PositionArrows

@onready var x_area: Area3D = $X
@onready var y_area: Area3D = $Y
@onready var z_area: Area3D = $Z

@onready var collision_shape_x: CollisionShape3D = $X/CollisionShape3D
@onready var collision_shape_y: CollisionShape3D = $Y/CollisionShape3D
@onready var collision_shape_z: CollisionShape3D = $Z/CollisionShape3D
@onready var viewport: Viewport = get_viewport()
@onready var camera: Camera3D = viewport.get_camera_3d()


var disabled: bool = false

var can_press: bool = false
var first_press: bool = true
var moving: bool = false

enum axis { none, x, y, z }
var current_axis: axis = axis.none
var object_to_move: Node = null
var offset: float = 0


func _ready() -> void:
	top_level = true
	x_area.mouse_entered.connect(_on_arrow_mouse_entered.bind(x_area))
	y_area.mouse_entered.connect(_on_arrow_mouse_entered.bind(y_area))
	z_area.mouse_entered.connect(_on_arrow_mouse_entered.bind(z_area))
	_on_visibility_changed()

func get_point_pos():
	var plane: Plane
	match current_axis:
		axis.x: plane = Plane(Vector3.FORWARD, global_position)
		axis.y: plane = Plane(Vector3.FORWARD, global_position)
		axis.z: plane = Plane(Vector3.UP, global_position)

	var mouse = viewport.get_mouse_position()
	var result = plane.intersects_ray(camera.project_ray_origin(mouse), camera.project_ray_normal(mouse))
	if result == null: return Vector3.ZERO

	if first_press:
		match current_axis:
			axis.x: offset = abs(object_to_move.global_position.x - result.x)
			axis.y: offset = abs(object_to_move.global_position.y - result.y)
			axis.z: offset = abs(object_to_move.global_position.z - result.z)
		first_press = false

	return result

func move_object(to: Vector3):
	moving = true
	var new_position: Vector3 = object_to_move.global_position
	match current_axis:
		axis.x: new_position.x = to.x - offset
		axis.y: new_position.y = to.y - offset
		axis.z: new_position.z = to.z - offset
	object_to_move.global_position = new_position

func _process(_delta: float) -> void:
	print(not ($"../CanvasLayer/top_panel/FileDialog".visible))
	if disabled: return
	if not object_to_move:
		hide()
		return

	scale.x = get_viewport().get_camera_3d().global_position.distance_to(object_to_move.global_position)/2
	scale.y = scale.x
	scale.z = scale.x

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if can_press:
			if not (%WayEditorWindow.visible) and not ($"../Window".visible) and not ($"../CanvasLayer/top_panel/FileDialog".visible):
				var target = get_point_pos()
				if target:
					move_object(target)
	else:
		if moving:
			current_axis = axis.none
		moving = false
		first_press = true
		offset = 0
	global_position = object_to_move.global_position

func _on_arrow_mouse_entered(arrow: Area3D) -> void:
	if moving: return
	match arrow.name:
		'X':
			current_axis = axis.x
		'Y':
			current_axis = axis.y
		'Z':
			current_axis = axis.z
	can_press = true

func _on_arrow_mouse_exited() -> void:
	if moving: return
	can_press = false
	first_press = true
	offset = 0
	current_axis = axis.none

func _on_visibility_changed() -> void:
	collision_shape_x.disabled = !collision_shape_x.disabled
	collision_shape_y.disabled = !collision_shape_y.disabled
	collision_shape_z.disabled = !collision_shape_z.disabled
