extends ProgramBlock
class_name BlockWithoutValue

#var no_value_block = true

func _ready() -> void:
	#no_value_block = true
	block_packed = preload('res://assets/program_editor/blocks/program_block_without_value_preset.tscn')
	title = block_name


func _on_mouse_entered() -> void:
	can_press = true
	if spawner: 
		can_spawn = true


func _on_mouse_exited() -> void:
	can_press = false
	can_spawn = false
