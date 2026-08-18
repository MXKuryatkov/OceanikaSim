extends Configurator

func _ready() -> void:
	if config[key] is float:
		$SpinBox.step = 0
		$SpinBox.custom_arrow_step = 0.1
	elif config[key] is int:
		$SpinBox.rounded = true
		$SpinBox.step = 1
	$SpinBox.value = config[key]
	$Label.text = key

func _on_spin_box_value_changed(value: float) -> void:
	config[key] = value
