extends ProgramBlock
class_name BlockWithTime



func _ready() -> void:
	block_packed = preload('res://assets/program_editor/blocks/program_block_with_time_preset.tscn')
	title = block_name
	$GridContainer/value_line_edit.text = str(value)
	$GridContainer/time_line_edit.text = str(time_value)

func _on_mouse_entered() -> void:
	can_press = true
	if spawner: 
		can_spawn = true


func _on_mouse_exited() -> void:
	can_press = false
	can_spawn = false



func _on_time_line_edit_text_changed(new_text: String) -> void:
	if new_text.is_valid_float():
		if (max_value != 0 and int(new_text) <= max_value) or max_value == 0:
			print('max: ', max_value)
			time_value = float(new_text)
			print(time_value)



func _on_value_line_edit_text_changed(new_text: String) -> void:
	if new_text.is_valid_float():
		if (max_value != 0 and int(new_text) <= max_value) or max_value == 0:
			print('max: ', max_value)
			value = float(new_text)
			print(value)
