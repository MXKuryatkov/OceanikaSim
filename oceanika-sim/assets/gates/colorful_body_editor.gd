extends EditorScene

@export var target: GeometryInstance3D

func _ready() -> void:
	target.material_override = StandardMaterial3D.new()

func update_config():
	if config.color < ColorfulBody3D.colors.size():
		target.material_override.albedo_color = ColorfulBody3D.colors[config.color]
