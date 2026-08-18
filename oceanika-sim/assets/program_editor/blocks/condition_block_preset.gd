extends ProgramBlock
class_name ConditionBlock

var if_array: Array = []
var else_array: Array = []

var param1_value = 'param1'
var param2_value = '0'
@warning_ignore("shadowed_global_identifier")
var sign = '=='

@onready var param_1: OptionButton = $HBoxContainer/param1
@onready var param_2: LineEdit = $HBoxContainer/param2

func _ready() -> void:
	for id in range(len(param1_dict.keys())):
		param_1.add_item(param1_dict.keys()[id], id)
	param1_value = param1_dict.keys()[0]
	param_2.text = str(param2_value)
	block_packed = preload('res://assets/program_editor/blocks/condition_block_preset.tscn')
	title = block_name
	for i in $HBoxContainer/sign.item_count:
		if $HBoxContainer/sign.get_item_text(i) == sign:
			$HBoxContainer/sign.select(i)

func _on_mouse_entered() -> void:
	can_press = true
	if spawner: 
		can_spawn = true


func _on_mouse_exited() -> void:
	can_press = false
	can_spawn = false

var first_block_in_cycle: ProgramBlock
var next_block_in_main_array: ProgramBlock
func get_next_block_in_main_array():
	var connections = program_editor.get_connection_list_from_node(self.name)
	for conn in connections:
		if conn['to_node'] == self.name:
			connections.erase(conn)
	for connection in connections:
		if connection['from_port'] == 0:
			next_block_in_main_array = program_editor.get_node(str(connection['to_node']))

func do_arrays():
	if_array = []
	else_array = []
	var connections = program_editor.get_connection_list_from_node(self.name)
	for conn in connections:
		if conn['to_node'] == self.name:
			connections.erase(conn)
	for connection in connections:
		print('connections: ', connections)
		print('self.name: ', self.name)
		print('conn: ', connection)
		if connection['from_port'] == 1 and connection['to_node'] != self.name:
			print('do')
			first_block_in_cycle = program_editor.get_node(str(connection['to_node']))
			if_array = first_block_in_cycle.get_connected_blocks()
		if connection['from_port'] == 2 and connection['to_node'] != self.name:
			print('do')
			first_block_in_cycle = program_editor.get_node(str(connection['to_node']))
			else_array = first_block_in_cycle.get_connected_blocks()
	print('if_array: ', if_array)
	print('else_array: ', if_array)


func _on_sign_item_selected(index: int) -> void:
	sign = $HBoxContainer/sign.get_item_text(index)


func _on_param_1_item_selected(index: int) -> void:
	param1_value = param_1.get_item_text(index)


func _on_param_2_text_changed(new_text: String) -> void:
	if new_text.is_valid_float():
		param2_value = float(new_text)
