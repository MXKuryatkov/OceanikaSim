class_name NodeConfigurator
extends Configurator

var active: bool = false

func _ready() -> void:
	if config[key]:
		$Button.text = str(config[key])
	else:
		$RemoveButton.hide()
	$Label.text = key

func set_node(id: int):
	active = false
	$Button.text = str(id)
	$RemoveButton.show()
	$Button.set_pressed_no_signal(false)
	config[key] = id

func set_node_name(node_name: String):
	$Button.text = node_name + " " + $Button.text

func _on_button_pressed() -> void:
	if active:
		active = false
		return
	active = true
	get_tree().call_group("selection_buttons", "configure_selector", self)

func _on_remove_button_pressed() -> void:
	config[key] = 0
	$Button.text = "Выбрать"
	$Button.set_pressed_no_signal(false)
	active = false
	$RemoveButton.hide()
