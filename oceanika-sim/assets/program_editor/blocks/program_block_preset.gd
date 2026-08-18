extends ProgramBlock
class_name Block

@onready var type_selecter: HBoxContainer = $type_selecter


func _ready() -> void:
	block_packed = preload('res://assets/program_editor/blocks/program_block_preset.tscn')
	title = block_name
	if has_type:
		type_selecter.show()
	else:
		type_selecter.hide()
	$type_selecter/OptionButton.selected = int(current_type)
	$HBoxContainer/LineEdit.text = str(value)

func _on_mouse_entered() -> void:
	can_press = true
	if spawner: 
		can_spawn = true


func _on_mouse_exited() -> void:
	can_press = false
	can_spawn = false


func _on_line_edit_text_submitted(new_text: String) -> void:
	if new_text.is_valid_float():
		if (max_value != 0 and int(new_text) <= max_value) or max_value == 0:
			print('max: ', max_value)
			value = float(new_text)
			print(value)


func _on_option_button_item_selected(index: int) -> void:
	current_type = index as CommandType
