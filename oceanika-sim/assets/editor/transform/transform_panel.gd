extends Panel
class_name TransformPanel

@onready var x_pos: LineEdit = $VBoxContainer/pos_params/x/x_pos
@onready var y_pos: LineEdit = $VBoxContainer/pos_params/y/y_pos
@onready var z_pos: LineEdit = $VBoxContainer/pos_params/z/z_pos
@onready var x_rot: LineEdit = $VBoxContainer/rot_params/x/x_rot
@onready var y_rot: LineEdit = $VBoxContainer/rot_params/y/y_rot
@onready var z_rot: LineEdit = $VBoxContainer/rot_params/z/z_rot

var track_object: EditorScene = null
var track: bool = true

func _process(_delta: float) -> void:
	if track_object != null and track:
		load_transform(track_object)

func load_transform(object: EditorScene):
	track_object = object
	if track_object == null: return

	x_pos.text = str(object.global_position.x)
	y_pos.text = str(object.global_position.y)
	z_pos.text = str(object.global_position.z)
	x_rot.text = str(object.global_rotation_degrees.x)
	y_rot.text = str(object.global_rotation_degrees.y)
	z_rot.text = str(object.global_rotation_degrees.z)

func _on_x_pos_text_changed(new_text: String) -> void:
	if track_object == null: return
	if new_text.is_valid_float():
		track_object.global_position.x = float(new_text)

func _on_y_pos_text_changed(new_text: String) -> void:
	if track_object == null: return

	if new_text.is_valid_float():
		track_object.global_position.y = float(new_text)

func _on_z_pos_text_changed(new_text: String) -> void:
	if track_object == null: return

	if new_text.is_valid_float():
		track_object.global_position.z = float(new_text)

func _on_x_rot_text_changed(new_text: String) -> void:
	if track_object == null: return

	if new_text.is_valid_float():
		track_object.global_rotation_degrees.x = float(new_text)

func _on_y_rot_text_changed(new_text: String) -> void:
	if track_object == null: return

	if new_text.is_valid_float():
		track_object.global_rotation_degrees.y = float(new_text)

func _on_z_rot_text_changed(new_text: String) -> void:
	if track_object == null: return

	if new_text.is_valid_float():
		track_object.global_rotation_degrees.z = float(new_text)

func _on_editing_toggled(toggled_on: bool) -> void:
	track = !toggled_on


func _on_rotate_y_pressed() -> void:
	if track_object != null and track:
		track_object.rotation.y += PI/2
		
		
		
