extends Node
class_name MissionSaver

var path: String = 'Новая миссия.ocs'

@export var transorm_switcher: TransformSwitcher



@export var main_node: Node3D


func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed('save'):
		save_mission()

func new_mission():
	save_mission()
	clear_main_node()
	path = 'Новая миссия.ocs'
	print(path)


func clear_main_node():
	for child in main_node.get_children():
		child.queue_free()

func save_mission():
	var save_nodes: Array = main_node.get_children()
	if save_nodes == []: return
	var save_file = FileAccess.open(path, FileAccess.WRITE)
	for node: EditorScene in save_nodes:
		var node_data = node.save()
		save_file.store_line(JSON.stringify(node_data))
		print(JSON.stringify(node_data))
	save_file.close()

func load_mission():
	var load_file = FileAccess.open(path, FileAccess.READ)
	clear_main_node()
	while load_file.get_position() < load_file.get_length():
		var json_str = load_file.get_line()
		var json: JSON = JSON.new()
		var parse = json.parse(json_str)
		if not parse == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_str, " at line ", json.get_error_line())
			continue
		var node_data = json.data

		var object = load(node_data["filepath"]).instantiate()
		main_node.add_child(object)
		print(Vector3(
			node_data['x_pos'],
			node_data['y_pos'],
			node_data['z_pos'],
		))
		object.global_position = Vector3(
			node_data['x_pos'],
			node_data['y_pos'],
			node_data['z_pos'],
		)
		object.global_rotation = Vector3(
			node_data['x_rot'],
			node_data['y_rot'],
			node_data['z_rot'],
		)
		transorm_switcher.change_transfrom_type.emit(transorm_switcher.TransformType.Position)
	load_file.close()
