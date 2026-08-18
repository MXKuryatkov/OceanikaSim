class_name SimulatedPiranya
extends CharacterBody3D

signal command_finished

const variables = []

var target_speed: float = 0
var moving := false
var time_to_wait := INF
var target_basis := Basis.IDENTITY
var rotating := false
var target_depth := 0.0
var real_drone_speed = 0.4

func execute_command(command: Dictionary):
	match command.name:
		"Вперед":
			target_speed = real_drone_speed
			command_finished.emit()
		"Назад":
			target_speed = -real_drone_speed
			command_finished.emit()
		"Вверх":
			target_depth = 0
			command_finished.emit()
		"Вниз":
			target_depth = -0.4
			command_finished.emit()
		"Вперед (время)":
			target_speed = real_drone_speed
			time_to_wait = command.value
			moving = true
		"Назад (время)":
			target_speed = -real_drone_speed
			time_to_wait = command.value
			moving = true
		"Установить скорость (проценты)":
			target_speed = real_drone_speed * (command.value / 100)
			command_finished.emit()
		"Изменить глубину (глубина, время)":
			target_depth = clampf(-command.value / 100, -0.45, 0)
			time_to_wait = command.time
		"Поворот направо (угол)":
			target_basis = transform.basis.rotated(Vector3.UP, deg_to_rad(-command.value))
			rotating = true
			time_to_wait = 3
		"Поворот налево (угол)", "Поворот (угол)":
			target_basis = transform.basis.rotated(Vector3.UP, deg_to_rad(command.value))
			rotating = true
			time_to_wait = 3
		"Выключить фонари":
			$lights.hide()
			command_finished.emit()
		"Включить фонари":
			$lights.show()
			command_finished.emit()
		"Ждать":
			time_to_wait = command.value
		"end":
			target_speed = 0
			target_depth = global_position.y
		"Остановка":
			target_speed = 0
			target_depth = global_position.y
			command_finished.emit()
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
		if moving:
			target_speed = 0
			moving = false
		time_to_wait = INF
		command_finished.emit()
	var target_velocity = (transform.basis * Vector3.FORWARD).normalized() * target_speed
	var v = velocity
	v.x = move_toward(v.x, target_velocity.x, 1.6 * delta)
	v.y = move_toward(v.y, target_velocity.y, 1.6 * delta)
	v.z = move_toward(v.z, target_velocity.z, 1.6 * delta)
	velocity = v
	global_position.y = move_toward(global_position.y, target_depth, 0.5 * delta)
	if rotating:
		transform.basis = transform.basis.slerp(target_basis, 0.03)
	move_and_slide()
