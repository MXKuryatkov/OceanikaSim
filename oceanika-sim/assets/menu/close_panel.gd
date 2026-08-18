extends TextureButton


func _on_pressed() -> void:
	if get_parent_control() != null:
		get_parent().hide()
		
