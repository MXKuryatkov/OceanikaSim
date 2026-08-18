extends Camera3D
class_name ControllableCamera

@export var speed: int = 5
@export var mouse_sensitivity: float = 0.2

var current_speed := speed
var velocity := Vector3.ZERO

func _input(event: InputEvent) -> void:
	# mouse visibility
	if event is InputEventMouseButton:
		if event.is_action_pressed("control_camera"):
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		elif event.is_action_released("control_camera"):
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	# rotation
	elif event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotation.y -= deg_to_rad(event.relative.x * mouse_sensitivity)
		rotation.x -= deg_to_rad(event.relative.y * mouse_sensitivity)
		rotation.x = clamp(rotation.x, deg_to_rad(-90),deg_to_rad(90)) #limit of x axis rotation

var move:Vector3
func _process(delta: float) -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var input := Input.get_vector("A", "D", "W", "S")
		var vertical_input := Input.get_axis("Q", "E")
		move = lerp(move, (transform.basis * Vector3(input.x, vertical_input, input.y)).normalized(), 6*delta)
		velocity = move * current_speed
	else:
		move = lerp(move, Vector3.ZERO, 10*delta)
		velocity = move * current_speed
		

	position += velocity * delta
