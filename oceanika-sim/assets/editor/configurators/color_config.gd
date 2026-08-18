extends Configurator

func _ready() -> void:
	$OptionButton.selected = config[key]
	$Label.text = key

func _on_option_button_item_selected(index: int) -> void:
	config[key] = index
