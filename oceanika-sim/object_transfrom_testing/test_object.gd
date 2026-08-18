extends Node3D
class_name TestObject


@export var transorm_switcher: TransformSwitcher

@onready var position_arrows: PositionArrows = $position_arrows
@onready var rotation_circles: RotationCircles = $rotation_circles

var selected: bool = false

#func _ready() -> void:
	#transorm_switcher = get_tree().get_first_node_in_group('transform_switcher')
	#transorm_switcher.change_transfrom_type.connect(set_transform_type)


func set_transform_type(to: int):
	if !selected:
		position_arrows.hide()
		rotation_circles.hide()
		rotation_circles.rotating = false
		rotation_circles._on_circle_mouse_exited()
		position_arrows.moving = false
		position_arrows._on_arrow_mouse_exited()
		return
	match to:
		0:
			position_arrows.show()
			rotation_circles.hide()
			rotation_circles.rotating = false
			rotation_circles._on_circle_mouse_exited()
		1:
			position_arrows.hide()
			rotation_circles.show()
			position_arrows.moving = false
			position_arrows._on_arrow_mouse_exited()

func save() -> Dictionary:
	var save_dict: Dictionary = {
		'filepath': scene_file_path,
		'x_pos': global_position.x,
		'y_pos': global_position.y,
		'z_pos': global_position.z,
		'x_rot': global_rotation.x,
		'y_rot': global_rotation.y,
		'z_rot': global_rotation.z,
	}
	return save_dict
