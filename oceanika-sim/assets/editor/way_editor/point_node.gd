extends GraphNode
class_name PointNode

signal type_changed(node: PointNode)

var current_type_id: int = 0
var point_id := 0
var active := false

func _enter_tree() -> void:
	name = 'point_node'

func _on_option_button_item_selected(index: int) -> void:
	match index:
		0:
			set_slot_enabled_left(1, true)
			set_slot_enabled_right(1, true)
		1:
			set_slot_enabled_left(1, false)
			set_slot_enabled_right(1, true)
		2:
			set_slot_enabled_left(1, true)
			set_slot_enabled_right(1, false)
	current_type_id = index
	%OptionButton.selected = index
	type_changed.emit(self)

func set_node(id: int):
	active = false
	point_id = id
	$HBoxContainer2/choose_point_button.text = str(id)

func set_node_name(node_name: String):
	$HBoxContainer2/choose_point_button.text = node_name + " " + str(point_id)

func reset_id():
	active = false
	point_id = 0
	$HBoxContainer2/choose_point_button.text = "Выбор"

func _on_choose_point_button_pressed() -> void:
	if active:
		reset_id()
	else:
		active = true
		get_tree().call_group("selection_buttons", "configure_selector", self)
