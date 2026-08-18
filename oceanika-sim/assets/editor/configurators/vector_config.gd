extends Configurator

func _ready() -> void:
	$X.value = config[key].x
	$Y.value = config[key].y
	$Z.value = config[key].z
	$Label.text = key

func _on_x_value_changed(value: float) -> void:
	config[key].x = value

func _on_y_value_changed(value: float) -> void:
	config[key].y = value

func _on_z_value_changed(value: float) -> void:
	config[key].z = value
