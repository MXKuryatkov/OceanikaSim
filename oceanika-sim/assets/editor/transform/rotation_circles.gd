extends Node3D
class_name RotationCircles

@onready var x_area: Area3D = $X
@onready var y_area: Area3D = $Y
@onready var z_area: Area3D = $Z

@onready var z_plane: StaticBody3D = $z_plane
@onready var x_plane: StaticBody3D = $x_plane
@onready var y_plane: StaticBody3D = $y_plane

@onready var collision_shape_x: CollisionShape3D = $X/CollisionShape3D
@onready var collision_shape_y: CollisionShape3D = $Y/CollisionShape3D
@onready var collision_shape_z: CollisionShape3D = $Z/CollisionShape3D



var disabled: bool = false

var mouse_sensitivity: float = 0.2

var can_press: bool = false
var can_rotate: bool = false
var first_press: bool = true
var pressing: bool = false
var rotating: bool = false

enum axis {
	none,
	x,
	y,
	z
}
var current_axis: axis = axis.none

var object_to_rotate: Node3D = null

var first_point: Vector3 = Vector3.ZERO

var camera: Camera3D

func _ready() -> void:
	top_level = true

	camera = get_viewport().get_camera_3d()
	object_to_rotate = get_parent()
	global_rotation = Vector3.ZERO
	x_plane.get_child(0).disabled = true
	y_plane.get_child(0).disabled = true
	z_plane.get_child(0).disabled = true

	x_area.mouse_entered.connect(_on_circle_mouse_entered.bind(x_area))
	y_area.mouse_entered.connect(_on_circle_mouse_entered.bind(y_area))
	z_area.mouse_entered.connect(_on_circle_mouse_entered.bind(z_area))


#algo:
#1) press mouse -- done
#2) calc point where mouse landed in 3D space -- done
#3) drag mouse -- done
#4) calc new point where mouse landed after dragging in 3D space -- done
#5) object_to_rotate.rotate_x/y/z(angle)



func get_point(global:bool = false) -> Vector3:
	var mouse_position = get_viewport().get_mouse_position()
	var ray_length = 1000
	var from = camera.project_ray_origin(mouse_position)
	var to = from + camera.project_ray_normal(mouse_position) * ray_length
	var space = get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = from
	ray_query.to = to
	var result = space.intersect_ray(ray_query)
	var point: Vector3 = Vector3.ZERO
	if result != {}:
		if !global:
			match current_axis:
				axis.x: point = Vector3(object_to_rotate.global_position.x, result['position'].y, result['position'].z)
				axis.y: point = Vector3(result['position'].x, object_to_rotate.global_position.y, result['position'].z)
				axis.z: point = Vector3(result['position'].x, result['position'].y, object_to_rotate.global_position.z)
		else:
			point = result['position']
	return point


	
func rotate_object(angle: float):
	match current_axis:
		axis.x: object_to_rotate.rotate_x(angle)
		axis.y: object_to_rotate.rotate_y(angle)
		axis.z: object_to_rotate.rotate_z(angle)
	

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if !first_press and event.screen_velocity.length() > 20:
			var angle: float = 0
			match current_axis:
				axis.x:
					angle = get_point().signed_angle_to(first_point, Vector3.RIGHT)
					print('first: ', get_point(true).x)
					if camera.global_position.x >= 0:
						angle *= -1
						
				axis.y:
					angle = get_point().signed_angle_to(first_point, Vector3.UP)
					if camera.global_position.x >= 0:
						angle *= -1
				axis.z:
					angle = get_point().signed_angle_to(first_point, Vector3.FORWARD)
					if camera.global_position.x <= 0:
						angle *= -1
			rotate_object(angle * mouse_sensitivity)
			
			rotating = true
		else:
			first_point = get_point()
			
	
func _process(_delta: float) -> void:
	if disabled:return

	scale.x = get_viewport().get_camera_3d().global_position.distance_to(object_to_rotate.global_position)/2
	scale.y = scale.x
	scale.z = scale.x

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if can_press:
			if first_press:
				first_point = get_point()
				first_press = false
		#print('press')
	else:
		if rotating:
			current_axis = axis.none
			x_plane.get_child(0).disabled = true
			y_plane.get_child(0).disabled = true
			z_plane.get_child(0).disabled = true
		first_point = Vector3.ZERO
		first_press = true
		rotating = false
		
	
	global_rotation = Vector3.ZERO
	global_position = object_to_rotate.global_position
	

func _on_circle_mouse_entered(circle: Area3D) -> void:
	if rotating: return
	match circle.name:
		'X': 
			current_axis = axis.x
			x_plane.get_child(0).disabled = false
			y_plane.get_child(0).disabled = true
			z_plane.get_child(0).disabled = true
		'Y': 
			current_axis = axis.y
			x_plane.get_child(0).disabled = true
			y_plane.get_child(0).disabled = false
			z_plane.get_child(0).disabled = true
		'Z': 
			current_axis = axis.z
			x_plane.get_child(0).disabled = true
			y_plane.get_child(0).disabled = true
			z_plane.get_child(0).disabled = false
	can_press = true

func _on_circle_mouse_exited() -> void:
	if rotating: return
	can_press = false
	first_press = true
	current_axis = axis.none
	x_plane.get_child(0).disabled = true
	y_plane.get_child(0).disabled = true
	z_plane.get_child(0).disabled = true


func _on_visibility_changed() -> void:
	collision_shape_x.disabled = !collision_shape_x.disabled
	collision_shape_y.disabled = !collision_shape_y.disabled
	collision_shape_z.disabled = !collision_shape_z.disabled
