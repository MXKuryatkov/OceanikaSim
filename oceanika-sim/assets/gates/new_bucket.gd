extends RacePoint

@export var mesh: GeometryInstance3D

func _ready() -> void:
	super._ready()
	if config.color < ColorfulBody3D.colors.size():
		var m := StandardMaterial3D.new()
		m.albedo_color = ColorfulBody3D.colors[config.color]
		mesh.material_override = m
