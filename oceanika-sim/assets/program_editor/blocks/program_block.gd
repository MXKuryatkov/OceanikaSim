extends GraphNode
class_name ProgramBlock

@export var spawner: bool = true

var program_editor: GraphEdit
var can_spawn = false

var block_packed: PackedScene
var connected_block: ProgramBlock = null
var block_id: int = 0

var value: float = 0
var block_name: String = 'block name not setted'
var max_value = 0
var has_type:bool = true
var set_code_line: String = ''
var change_code_line: String = ''
var code_lines: Array = []

enum CommandType{
	SET,
	CHANGE,
	TIME,
}
var current_type: CommandType
var param1_dict = {}
var time_value = 0
var can_delete = true
var can_press = false

func _enter_tree() -> void:
	if spawner:
		program_editor = get_parent().program_editor
	else:
		program_editor = get_parent()
	name = 'block'

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
			if can_spawn:
				spawn()
		elif event.is_pressed() and event.button_index == MOUSE_BUTTON_RIGHT:
			print(get_connected_blocks())
			if can_delete and can_press:
				queue_free()

func spawn():
	if spawner:
		var block: ProgramBlock = block_packed.instantiate()
		block.spawner = false
		block.block_name = block_name
		block.max_value = max_value
		block.has_type = has_type
		block.set_code_line = set_code_line
		block.change_code_line = change_code_line
		block.code_lines = code_lines
		block.param1_dict = param1_dict
		program_editor.add_child(block)


func get_connected_blocks(visited: Array = []) -> Array:
	if self in visited:
		return []
	visited.append(self)
	var result: Array = [self]
	if connected_block != null and not connected_block in visited:
		result += connected_block.get_connected_blocks(visited)
	print('func called from: ', self.name, '\nresult: ', result)
	return result
