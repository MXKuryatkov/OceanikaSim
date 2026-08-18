class_name ColorfulBody3D
extends Node3D

@export var target: GeometryInstance3D

var color_number: int
static var colors := [
	Color.DARK_BLUE,
	Color.YELLOW,
	Color.DARK_RED,
	Color.DARK_GREEN,
	Color.WHITE
]

func configure(c: Dictionary):
	color_number = c.color

func _ready() -> void:
	if color_number < colors.size():
		var m := StandardMaterial3D.new()
		m.albedo_color = colors[color_number]
		target.material_override = m
