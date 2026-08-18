class_name SimulatedKit
extends CharacterBody3D

signal command_finished

const variables = [
	"Значение глубины",
	"Значение крена",
	"Значение курса",
	"Значение тангажа"
]

var target_speed: float = 0
var time_to_wait := INF
var target_basis := Basis.IDENTITY
var rotating := false
var target_depth := 0.0
var changing_depth := false
var real_drone_speed = 0.8

func get_variable(var_name: String):
	match var_name:
		"Значение глубины":
			return abs(global_position.y)
		"Значение крена":
			return global_rotation_degrees.z
		"Значение курса":
			return global_rotation_degrees.y
		"Значение тангажа":
			return global_rotation_degrees.x

func execute_command(command: Dictionary):
	match command.name:
		"Скорость":
			if command.type == 0:
				target_speed = real_drone_speed * (command.value/100)
			else:
				target_speed += real_drone_speed * (command.value/100)
			command_finished.emit()
		"Фонари":
			$lights.visible = command.value > 0
			command_finished.emit()
		"Ждать":
			time_to_wait = command.value
		"Курс":
			rotating = true
			time_to_wait = 3
			if command.type == 0:
				target_basis = Basis.from_euler(Vector3(rotation.x, 0, rotation.z)).rotated(Vector3.UP, deg_to_rad(command.value))
			else:
				target_basis = target_basis.rotated(Vector3.UP, deg_to_rad(command.value))
		"Тангаж":
			rotating = true
			time_to_wait = 3
			if command.type == 0:
				target_basis = Basis.from_euler(Vector3(0, rotation.y, rotation.z)).rotated(Vector3.RIGHT, deg_to_rad(command.value))
			else:
				target_basis = target_basis.rotated(Vector3.RIGHT, deg_to_rad(command.value))
		"Крен":
			rotating = true
			time_to_wait = 3
			if command.type == 0:
				target_basis = Basis.from_euler(Vector3(rotation.x, rotation.y, 0)).rotated(Vector3.FORWARD, deg_to_rad(command.value))
			else:
				target_basis = target_basis.rotated(Vector3.FORWARD, deg_to_rad(command.value))
		"Глубина":
			if command.type == 0:
				target_depth = -(command.value/100)
			else:
				target_depth -= (command.value/100)
			target_depth = clampf(target_depth, -0.45, 0)
			changing_depth = true
		"Нагрузка":
			time_to_wait = 1
		"Манипулятор":
			time_to_wait = 1
		"end":
			target_speed = 0
			target_depth = global_position.y
		"reset":
			target_speed = 0
			target_depth = 0
		_:
			Log.message("Unknown command: " + command.name, Log.Level.Warning)
			command_finished.emit()

func _physics_process(delta: float) -> void:
	time_to_wait -= delta
	if time_to_wait < 0:
		if rotating:
			rotating = false
			transform.basis = target_basis
		time_to_wait = INF
		command_finished.emit()
	var target_velocity = (transform.basis * Vector3.FORWARD).normalized() * target_speed
	var v = velocity
	v.x = move_toward(v.x, target_velocity.x, 0.8 * delta)
	v.y = move_toward(v.y, target_velocity.y, 0.8 * delta)
	v.z = move_toward(v.z, target_velocity.z, 0.8 * delta)
	velocity = v
	global_position.y = move_toward(global_position.y, target_depth, 0.5 * delta)
	if changing_depth && is_equal_approx(global_position.y, target_depth):
		changing_depth = false
		command_finished.emit()
	if rotating:
		transform.basis = transform.basis.slerp(target_basis, 0.03)
	move_and_slide()
