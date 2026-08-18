extends HBoxContainer
class_name TransformSwitcher

signal change_transfrom_type(to: TransformType)

enum TransformType{
	Position,
	Rotation,
}
var current_transform_type: TransformType = TransformType.Position

func _ready() -> void:
	change_transfrom_type.emit(TransformType.Position)

func _on_position_pressed() -> void:
	current_transform_type = TransformType.Position
	change_transfrom_type.emit(current_transform_type)
	$position.disabled = true
	$rotation.disabled = false

func _on_rotation_pressed() -> void:
	current_transform_type = TransformType.Rotation
	change_transfrom_type.emit(current_transform_type)
	$position.disabled = false
	$rotation.disabled = true
