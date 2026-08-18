@tool
extends VBoxContainer
class_name BlocktypeContainer


@export var type_color: Color = Color.WHITE
@export var type_name: StringName = 'block type'
@export var blocks_array: Array[BlockRes] = []
@onready var texture_rect: TextureRect = $TextureRect
@onready var label: Label = $Label

var can_press: bool = false

func _ready() -> void:
	label.text = type_name
	var grad:Gradient = Gradient.new()
	grad.set_offset(0, 0.548)
	grad.set_offset(1, 0.626)
	grad.set_color(0, type_color)
	grad.set_color(1, Color(type_color.r, type_color.g, type_color.b, 0))
	texture_rect.texture.gradient = grad

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
			if can_press:
				add_blocks()

func remove_blocks():
	for block in %blocks.get_children():
		block.queue_free()

func add_blocks():
	remove_blocks()
	for block_res in blocks_array:
		var preset = block_res.block_preset
		var new_block:ProgramBlock = preset.instantiate()
		if block_res is CycleRes:
			new_block.code_lines = block_res.code_lines
		if block_res is ConditionRes:
			new_block.param1_dict = block_res.param1_dict
		new_block.block_name = block_res.block_name
		new_block.max_value = block_res.max_value
		new_block.has_type = block_res.has_type
		new_block.set_code_line = block_res.set_code_line
		new_block.change_code_line = block_res.change_code_line
		%blocks.add_child(new_block)
		
		
		
func _on_mouse_entered() -> void:
	can_press = true


func _on_mouse_exited() -> void:
	can_press = false
