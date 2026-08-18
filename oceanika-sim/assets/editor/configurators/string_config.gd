extends Configurator

func _ready() -> void:
	$LineEdit.text = config[key]
	$Label.text = key

func _on_line_edit_text_changed(new_text: String) -> void:
	config[key] = new_text
