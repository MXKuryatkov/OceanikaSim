class_name ColorfulEditorScene
extends EditorSceneSelectable

@export var color_target: GeometryInstance3D

var material := StandardMaterial3D.new()

func _ready() -> void:
	super._ready()
	color_target.material_override = material

func update_config():
	if config.color < ColorfulBody3D.colors.size():
		color_target.material_override.albedo_color = ColorfulBody3D.colors[config.color]
