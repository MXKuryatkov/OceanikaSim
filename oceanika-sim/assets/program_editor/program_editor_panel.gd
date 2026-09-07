extends Control
class_name ProgramEditor

signal start_simulation()
signal stop_simulation()
signal reset()

@onready var program_editor: GraphEdit = %program_editor
@onready var types_kit: VBoxContainer = %types_kit
@onready var types_piranya: VBoxContainer = %types_piranya
@onready var start_block: StartBlock = $HSplitContainer/program_editor/block
@onready var saving_label: Label = $"saving_label"
@onready var program_text: VBoxContainer = %program_text
@onready var simulation_panel: HBoxContainer = %simulation_panel
@onready var connection_panel: HBoxContainer = %connection_panel
@onready var drone_panel: HBoxContainer = %drone_panel
@onready var compile_push_button: Button = %compile_push
@onready var device_list: OptionButton = %device_list
@onready var h_split_container: HSplitContainer = $HSplitContainer
@onready var compile_console: CompileConsole = %compile_console
@onready var upload_progress_bar: ProgressBar = %UploadProgressBar
@onready var program_load_window: ProgramLoadWindow = $ProgramLoadWindow

var commands_list: Array[ProgramBlock] = []

var file_path = 'user://name.py'
var file_name = 'Not saved project '

#region ineditor file
var program_file_path = ''
var program_file_type = '.ocsp'
#endregion

enum ProgramToDrone {
	BUILD,
	UPLOAD,
	RUN
}
var current_program_to_drone_state: ProgramToDrone = ProgramToDrone.BUILD

@export var kit_user: String = 'pi@192.168.88.155'
@export var kit_path: String = '/usr/local/drone_ros/src/drone/scripts/examples/'
@export var kit_password: String = 'oceanika'
var sshpass_command = 'sshpass'

var arduino_remote = preload('res://assets/program_editor/arduino_remote.tscn')
func _ready() -> void:
	if OS.get_name() == 'Windows':
		sshpass_command = '.\\sshpass'
	compile_console.hide()
	upload_progress_bar.hide()

	match DroneToProgram.current_drone:
		DroneToProgram.Drone.kit:
			types_piranya.hide()
			types_kit.show()
			%run_remotely.show()
			connection_panel.hide()
			compile_push_button.hide()
		DroneToProgram.Drone.piranya:
			types_kit.hide()
			types_piranya.show()
			%run_remotely.hide()
			connection_panel.show()
			compile_push_button.show()
			var ard_remo: ArduinoRemote = arduino_remote.instantiate()
			ard_remo.compile_push_button = compile_push_button
			ard_remo.device_list = device_list
			add_child(ard_remo)

func _on_program_panel_connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	for con in program_editor.get_connection_list():
		if con.from_node == from_node and con.from_port == from_port:
			return

	program_editor.connect_node(from_node, from_port, to_node, to_port)
	var from_block: ProgramBlock = program_editor.get_node(str(from_node))
	var to_block: ProgramBlock = program_editor.get_node(str(to_node))
	to_block.block_id = from_block.block_id + 1
	if from_block is Block or from_block is BlockWithoutValue or from_block is BlockWithTime:
		from_block.connected_block = to_block
	elif from_block is CycleBlock:
		if from_port == 0:
			from_block.get_next_block_in_main_array()
			from_block.connected_block = from_block.next_block_in_main_array
		else:
			from_block.do_cycle_array()
	elif from_block is ConditionBlock:
		if from_port == 0:
			from_block.get_next_block_in_main_array()
			from_block.connected_block = from_block.next_block_in_main_array
		else:
			from_block.do_arrays()

func _process(_delta: float) -> void:
	match current_program_to_drone_state:
		ProgramToDrone.BUILD:
			%build.disabled = false
			%run_remotely.disabled = true
		ProgramToDrone.UPLOAD:
			%build.disabled = false
			%run_remotely.disabled = true
		ProgramToDrone.RUN:
			%build.disabled = false
			%run_remotely.disabled = false

func do_array():
	commands_list = []
	var start_connections := program_editor.get_connection_list_from_node(start_block.name)
	if start_connections.is_empty():
		return
	var first_block := program_editor.get_node(String(start_connections[0]['to_node']))
	for connection: ProgramBlock in first_block.get_connected_blocks():
		commands_list.append(connection)
	BlockCodes.code_program(commands_list)


func save_program():
	program_load_window.main_directory_path = ''

	saving_label.show()
	if program_file_path == "": return
	var save_list := []
	var program_editor_data = {
		"drone": DroneToProgram.current_drone,
		"nodes": [],
		"connections": []
	}
	for child in program_editor.get_children():
		if child is ProgramBlock and child is not StartBlock:
			var block_dict = {"name": child.name,
					"offset_x": child.position_offset.x,
					"offset_y": child.position_offset.y,
					'title': child.title,
					}
			if child.connected_block != null:
				block_dict['connected_block'] = child.connected_block.name

			if child is Block:
				block_dict["value"] = child.value
				block_dict["set_code_line"] = child.set_code_line
				block_dict["change_code_line"] = child.change_code_line
				block_dict["max_value"] = child.max_value
				block_dict["has_type"] = child.has_type
				block_dict['current_type'] = child.current_type
			elif child is CycleBlock:
				block_dict["code_lines"] = child.code_lines
				block_dict["current_cycle"] = child.current_cycle
				block_dict["repeats_count"] = child.repeats_count
			elif child is ConditionBlock:
				block_dict["param1_value"] = child.param1_value
				block_dict["param2_value"] = child.param2_value
				block_dict["param1_dict"] = child.param1_dict
				block_dict["sign"] = child.sign
			elif child is BlockWithTime:
				block_dict["value"] = child.value
				block_dict['time_value'] = child.time_value
				block_dict["set_code_line"] = child.set_code_line

			elif child is BlockWithoutValue:
				block_dict['no_value'] = true
				block_dict["set_code_line"] = child.set_code_line

			program_editor_data['nodes'].append(block_dict)
	program_editor_data["connections"] = program_editor.connections
	save_list.append(program_editor_data)
	var save_file := FileAccess.open(program_file_path, FileAccess.WRITE)
	save_file.store_var(save_list)
	await get_tree().create_timer(1).timeout
	saving_label.hide()



func load_program():
	program_load_window.main_directory_path = ''
	clear()
	Log.message("Loading" + program_file_path)
	var save_file := FileAccess.open(program_file_path, FileAccess.READ)
	var save_data = save_file.get_var()
	if save_data[0]['drone'] != DroneToProgram.current_drone:
		ErrorWindow.push_error("Ошибка загрузки программы", "загружаемая программа несовместима с выбранным дроном.")
		return
	var block_preset = preload('res://assets/program_editor/blocks/program_block_preset.tscn')
	var cycle_block_preset = preload('res://assets/program_editor/blocks/cycle_block_preset.tscn')
	var condition_block_preset = preload('res://assets/program_editor/blocks/condition_block_preset.tscn')
	var block_without_value_preset = preload('res://assets/program_editor/blocks/program_block_without_value_preset.tscn')
	var block_with_time_preset = preload("res://assets/program_editor/blocks/program_block_with_time_preset.tscn")
	for object_data:Dictionary in save_data:
		if object_data.has('nodes'):
			for block_dict in object_data['nodes']:
				var new_block
				if block_dict['name'] != 'program_start_block':
					if block_dict.has('value') and not block_dict.has('time_value'):
						new_block = block_preset.instantiate()
						new_block.value = block_dict['value']
						new_block.set_code_line = block_dict['set_code_line']
						new_block.change_code_line = block_dict['change_code_line']
						new_block.max_value = block_dict['max_value']
						new_block.has_type = block_dict['has_type']
						new_block.current_type = block_dict['current_type']
					elif block_dict.has('current_cycle'):
						new_block = cycle_block_preset.instantiate()
						new_block.code_lines = block_dict["code_lines"]
						new_block.repeats_count = block_dict["repeats_count"]
						new_block.current_cycle = block_dict["current_cycle"]
					elif block_dict.has('sign'):
						new_block = condition_block_preset.instantiate()
						new_block.param1_value = block_dict["param1_value"]
						new_block.param2_value = block_dict["param2_value"]
						new_block.param1_dict = block_dict["param1_dict"]
						new_block.sign = block_dict["sign"]
					elif block_dict.has('time_value'):
						new_block = block_with_time_preset.instantiate()
						new_block.value = block_dict['value']
						new_block.time_value = block_dict['time_value']
						new_block.set_code_line = block_dict['set_code_line']

					elif block_dict.has('no_value'):
						new_block = block_without_value_preset.instantiate()
						new_block.set_code_line = block_dict['set_code_line']

					new_block.spawner = false
					new_block.position_offset = Vector2(block_dict["offset_x"], block_dict["offset_y"])
					program_editor.add_child(new_block)
					new_block.name = block_dict['name']
					new_block.title = block_dict['title']
			for block_dict in object_data['nodes']:
				if block_dict.has('connected_block'):
					var block = program_editor.get_node(str(block_dict['name']))
					block.connected_block = program_editor.get_node(str(block_dict['connected_block']))
			for connection in object_data["connections"]:
				program_editor.connect_node(connection["from_node"], connection["from_port"], connection["to_node"], connection["to_port"])

func new_program():
	program_load_window.main_directory_path = ''

	clear()
	program_file_path = ''

func clear():
	program_editor.clear_connections()
	for child in program_editor.get_children():
		if child is ProgramBlock and child is not StartBlock:
			program_editor.remove_child(child)

func _on_program_editor_disconnection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	program_editor.disconnect_node(from_node, from_port, to_node, to_port)
	var from_block := program_editor.get_node(str(from_node))
	var to_block := program_editor.get_node(str(to_node))
	if from_block is Block or from_block is BlockWithoutValue or from_block is BlockWithTime:
		if from_block.connected_block == to_block:
			from_block.connected_block = null
		elif to_block.connected_block == from_block:
			to_block.connected_block = null
	elif from_block is CycleBlock:
		if from_port == 0:
			from_block.connected_block = null
		else:
			from_block.cycle_array = []
	elif from_block is ConditionBlock:
		if from_port == 0:
			from_block.connected_block = null
		else:
			from_block.if_array = []
			from_block.else_array = []

func build_file(file_type):
	file_name = program_file_path.get_file().split('.')[0]
	file_path = 'user://'+file_name+file_type
	if DroneToProgram.current_drone == DroneToProgram.Drone.kit:
		var file = FileAccess.open(file_path, FileAccess.WRITE)
		if file:
			file.store_string(BlockCodes.python_script)
			current_program_to_drone_state = ProgramToDrone.UPLOAD
		file.flush()
		file.close()

func _on_upload_pressed() -> void:
	Log.message("Uploading")
	do_array()
	await build_file('.py')
	var global_path = ProjectSettings.globalize_path(file_path)
	var check = FileAccess.open(global_path, FileAccess.READ)
	if check:
		Log.message("File size before upload: %d bytes" % check.get_length())
	check.close()
	var output = []

	var exit_code = OS.execute(
		sshpass_command,
		['-p', kit_password, 
		'scp', 
		'-O',
		'-o', 'StrictHostKeyChecking=no', 
		'-o', 'RequestTTY=no',
		global_path, 
		kit_user + ':' + kit_path],
		output,
		true
	)


	if exit_code != 0:
		Log.message("SCP failed. Exit code: " + exit_code, Log.Level.Error)
		Log.message("Output:", Log.Level.Error)
		for line in output:
			Log.message(line, Log.Level.Error)
	else:
		Log.message("SCP succeeded.", Log.Level.Error)
		current_program_to_drone_state = ProgramToDrone.RUN

func _on_run_remotely_pressed() -> void:
	Log.message('run on Kit', Log.Level.Error)
	var output = []
	var pythonpath = "/usr/local/drone_ros/devel/lib/python3/dist-packages:/opt/ros/noetic/lib/python3/dist-packages"
	var remote_cmd = 'PYTHONPATH=' + pythonpath + ' python3 ' + kit_path + file_name + '.py'
	var exit_code = OS.execute(
		sshpass_command,
		['-p', kit_password, 'ssh', '-o', 'StrictHostKeyChecking=no', kit_user, remote_cmd],
		output,
		true
	)

	if exit_code != 0:
		Log.message("SSH command failed. Output:", Log.Level.Error)
		for line in output:
			Log.message(line, Log.Level.Error)
	else:
		Log.message("SSH command succeeded.", Log.Level.Error)
		Log.message('RUNNING: ' + kit_path + file_name + '.py', Log.Level.Error)
		for line in output:
			Log.message(line, Log.Level.Error)

func _on_build_pressed() -> void:
	do_array()
	program_load_window.popup()
	if commands_list == []:
		ErrorWindow.push_error("Ошибка в программе", "программа не может быть пустой. Стартовый блок должен быть подключен к остальным.")
		return
	if DroneToProgram.current_drone == DroneToProgram.Drone.kit:
		build_file('.py')
		$ProgramLoadWindow/VBoxContainer/program_text/program_text.text = BlockCodes.python_script
	elif DroneToProgram.current_drone == DroneToProgram.Drone.piranya:
		build_file('.ino')
		$ProgramLoadWindow/VBoxContainer/program_text/program_text.text = BlockCodes.arduino_script

func _on_run_simulation_pressed() -> void:
	%stop_simulation.show()
	%run_simulation.hide()
	%reset.disabled = true
	start_simulation.emit()

func _on_stop_simulation_pressed() -> void:
	%stop_simulation.hide()
	%run_simulation.show()
	%reset.disabled = false
	stop_simulation.emit()

func _on_reset_pressed() -> void:
	reset.emit()

func _on_drone_simulation_executed() -> void:
	%stop_simulation.hide()
	%run_simulation.show()
	%reset.disabled = false

func upload_kit():
	_on_upload_pressed()

func _on_program_editor_child_entered_tree(_node: Node) -> void:
	current_program_to_drone_state = ProgramToDrone.BUILD
