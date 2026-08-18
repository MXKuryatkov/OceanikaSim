extends Configurator

func _ready() -> void:
	$CheckBox.button_pressed = config[key]
	$Label.text = key

func _on_check_box_pressed() -> void:
	config[key] = $CheckBox.button_pressed
