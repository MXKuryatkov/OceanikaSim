class_name DroneSimulation
extends Node3D

signal executed

const simulated_kit_scene = preload("res://assets/program_editor/drone_simulation/SimulatedKit.tscn")
const simulated_piranya_scene = preload("res://assets/program_editor/drone_simulation/SimulatedPiranya.tscn")

@onready var program_editor: ProgramEditor = %ProgramEditor

var program_executor: Node3D
var program_list: Array
var execution_point := 0
var variables := {}
var executing = false
var drone_start_position : Vector3
var drone_start_rotation : Vector3

func _ready() -> void:
	var drone_scene: PackedScene
	if DroneToProgram.current_drone == DroneToProgram.Drone.kit:
		drone_scene = simulated_kit_scene
	elif DroneToProgram.current_drone == DroneToProgram.Drone.piranya:
		drone_scene = simulated_piranya_scene
	var new_drone = drone_scene.instantiate()
	new_drone.command_finished.connect(_on_simulated_drone_command_finished)
	add_child(new_drone)
	program_executor = new_drone

	drone_start_position = program_executor.global_position
	drone_start_rotation = program_executor.global_rotation

@onready var space_state = get_world_3d().direct_space_state
@onready var query := PhysicsRayQueryParameters3D.create(Vector3.ZERO, Vector3.ZERO)
@onready var viewport: Viewport = $VSplitContainer/SubViewportContainer/SubViewport
@onready var camera: Camera3D = $VSplitContainer/SubViewportContainer/SubViewport/Camera3D
var selected := false
var click := false
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		if selected:
			program_executor.global_position.y = 0
			selected = false
		else:
			var result = shot_ray(0b00000000_00000000_00000000_00000010)
			if result != {}:
				var target = result.collider
				if target == program_executor and not executing:
					selected = true

func shot_ray(mask) -> Dictionary:
	var mouse := viewport.get_mouse_position()
	var origin := camera.project_ray_origin(mouse)
	query.from = origin
	query.to = origin + camera.project_ray_normal(mouse) * 1000
	query.collision_mask = mask
	var result := space_state.intersect_ray(query)

	return result

var water_plane := Plane(Vector3.UP, Vector3(0, 0.1, 0))
func mouse_point() -> Vector3:
	var mouse := viewport.get_mouse_position()
	var result = water_plane.intersects_ray(camera.project_ray_origin(mouse), camera.project_ray_normal(mouse))
	if result != null:
		return result
	return program_executor.global_position

func _process(_delta: float) -> void:
	if selected:
		program_executor.global_position = mouse_point()

## Makes the Ultimate Array [br]
## [i]There's never too many Arrays[/i]
func do_my_array(blocks: Array, array_size: int = 0):
	var array := []

	for block in blocks:
		if block is Block:
			array.push_back({
				"name": block.title,
				"value": block.value,
				"type": block.current_type
			})
		elif block is BlockWithoutValue:
			array.push_back({"name": block.title})
		elif block is BlockWithTime:
			array.push_back({
				"name": block.title,
				"value": block.value,
				"time": block.time_value
			})
		elif block is ConditionBlock:
			block.do_arrays()
			var if_array: Array = do_my_array(block.if_array, array_size + array.size() + 1)
			var else_array: Array = do_my_array(block.else_array, array_size + array.size() + if_array.size() + 2)
			array.push_back({
				"name": "goto_if",
				"not": true,
				"first": block.param1_value,
				"operation": block.sign,
				"second": block.param2_value,
				"target": array_size + array.size() + if_array.size() + 2
			})
			for i in if_array:
				array.push_back(i)
			array.push_back({
				"name": "goto",
				"target": array_size + array.size() + else_array.size() + 1
			})
			for i in else_array:
				array.push_back(i)
		elif block is CycleBlock:
			block.do_cycle_array()
			if block.current_cycle == CycleBlock.CycleType.count:
				var counter_id := str(array_size + array.size())
				array.push_back({
					"name": "set",
					"variable": "counter" + counter_id,
					"value": 0
				})
				var cycle_array: Array = do_my_array(block.cycle_array, array_size + array.size())
				for i in cycle_array:
					array.push_back(i)
				array.push_back({
					"name": "increase",
					"variable": "counter" + counter_id
				})
				array.push_back({
					"name": "goto_if",
					"first": "counter" + counter_id,
					"operation": "<",
					"second": block.repeats_count,
					"target": int(counter_id) + 1
				})
			else:
				var first_command := array_size + array.size()
				var cycle_array: Array = do_my_array(block.cycle_array, array_size + array.size())
				for i in cycle_array:
					array.push_back(i)
				array.push_back({
					"name": "goto",
					"target": first_command
				})
	return array

func goto_if(first_str, second_str, operation, target, inverse):
	var first
	var second
	if first_str in variables:
		first = variables[first_str]
	elif first_str in program_executor.variables:
		first = program_executor.get_variable(first_str)
	else:
		first = first_str
	if second_str in variables:
		second = variables[second_str]
	elif second_str in program_executor.variables:
		second = program_executor.get_variable(second_str)
	else:
		second = float(second_str)
	var condition: bool = false
	match operation:
		"==":
			if first is float && second is float:
				condition = is_equal_approx(first, second)
			else:
				condition = first == second
		"<":
			condition = first < second
		">":
			condition = first > second
		">=":
			condition = first >= second
		"<=":
			condition = first <= second
		"!=":
			if first is float && second is float:
				condition = !is_equal_approx(first, second)
			else:
				condition = first != second
	print(first, " ", second, " ", condition)
	if inverse: condition = !condition
	if condition:
		execution_point = target
	return condition

func execute_command(command: Dictionary):
	if not executing: return
	var builtin_command := true
	var jumped := false
	Log.message("executing " + command.name)
	match command.name:
		"goto_if":
			var inverse := false
			if "not" in command:
				inverse = command.not
			jumped = goto_if(command.first, command.second, command.operation, command.target, inverse)
		"goto":
			execution_point = command.target
			jumped = true
		"set":
			variables[command.variable] = command.value
		"increase":
			if command.variable in variables:
				variables[command.variable] = variables[command.variable] + 1
				print(variables)
		"end":
			program_executor.execute_command(command)
			stop_execution()
			return
		_:
			builtin_command = false
			program_executor.execute_command(command)
	if builtin_command:
		if !jumped:
			execution_point += 1
		execute_command(program_list[execution_point])

func execute_program():
	variables = {}
	executing = true
	program_editor.do_array()
	program_list = do_my_array(program_editor.commands_list)
	program_list.push_back({"name": "end"})
	print(program_list)
	execution_point = 0
	execute_command(program_list[execution_point])

func stop_execution():
	executing = false
	executed.emit()

func _on_start_program() -> void:
	drone_start_position = program_executor.global_position
	drone_start_rotation = program_executor.global_rotation
	execute_program()

func _on_simulated_drone_command_finished() -> void:
	execution_point += 1
	execute_command(program_list[execution_point])

func _on_reset() -> void:
	program_executor.global_position = drone_start_position
	program_executor.global_rotation = drone_start_rotation
	program_executor.execute_command({"name": "reset"})
	print('reseted')
	stop_execution()

func _on_stop_simulation() -> void:
	program_executor.execute_command({"name": "end"})
	stop_execution()
