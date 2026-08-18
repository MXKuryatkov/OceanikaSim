extends ProgramBlock
class_name CycleBlock

enum CycleType{
	count,
	inf
}
var current_cycle: CycleType = CycleType.count
var repeats_count: int = 1

var cycle_array: Array = []

func _ready() -> void:
	block_packed = preload('res://assets/program_editor/blocks/cycle_block_preset.tscn')
	title = block_name
	$HBoxContainer/choose.selected = current_cycle
	$HBoxContainer2/count.value = repeats_count
	if current_cycle == CycleType.inf:
		$HBoxContainer2.hide()
		set_slot_enabled_right(1, true)
		set_slot_enabled_right(2, false)

func _on_mouse_entered() -> void:
	can_press = true
	if spawner: 
		can_spawn = true


func _on_mouse_exited() -> void:
	can_press = false
	can_spawn = false

func _on_choose_item_selected(index: int) -> void:
	current_cycle = index as CycleType
	if current_cycle == CycleType.count:
		$HBoxContainer2.show()
		set_slot_enabled_right(2, true)
		set_slot_enabled_right(1, false)
	else:
		$HBoxContainer2.hide()
		set_slot_enabled_right(1, true)
		set_slot_enabled_right(2, false)

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

func do_cycle_array():
	cycle_array = []
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
			cycle_array = first_block_in_cycle.get_connected_blocks()

	print('cycle_array: ', cycle_array)

func _on_count_value_changed(_value: float) -> void:
	repeats_count = int(_value)
