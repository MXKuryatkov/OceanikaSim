extends RigidBody3D

@onready var viewport: Viewport = get_viewport()
@onready var camera: Camera3D = viewport.get_camera_3d()

func _physics_process(_delta: float) -> void:
	var mouse = viewport.get_mouse_position()
	var target = Plane.PLANE_XZ.intersects_ray(camera.project_ray_origin(mouse),camera.project_ray_normal(mouse))
	target.y = global_position.y
	if target:
		apply_central_force((target - global_position).normalized() * 15)
