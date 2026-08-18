extends Control
class_name WayEditor

@export var point_node: PackedScene = preload('res://assets/editor/way_editor/point_node.tscn')
@onready var way_editor: GraphEdit = $way_editor

var start_node: StringName
var end_node: StringName



func _on_add_point_pressed() -> void:
	var point: PointNode = point_node.instantiate()
	way_editor.add_child(point)
	point.type_changed.connect(on_node_type_changed)

func get_connections(name: StringName) -> Array:
	var result := []
	for i in way_editor.connections:
		if i.from_node == name:
			result.append(i.to_node)
	return result

func get_connected_to(node_name: StringName) -> Array:
	var result := []
	for i in way_editor.connections:
		if i.to_node == node_name:
			result.append(i.from_node)
	return result

func get_name_by_id(id: int):
	for i in way_editor.get_children():
		if i is PointNode && i.point_id == id:
			return StringName(i.name)

func do_array(nodes: Array, node_name: StringName, ignore_branch=false):
	var connections = get_connections(node_name)
	if connections.size() == 1:
		if get_connected_to(connections[0]).size() == 1 || ignore_branch:
			nodes.append(way_editor.get_node(str(connections[0])).point_id)
			return do_array(nodes, connections[0])
		else:
			return nodes
	elif connections.size() == 0:
		return nodes
	else:
		var branch := []
		for c in connections:
			branch.append(do_array([way_editor.get_node(str(c)).point_id], c))
		nodes.append(branch)
		return do_array(nodes, get_name_by_id(branch[0][-1]), true)

func on_node_type_changed(node: PointNode):
	if not node.is_slot_enabled_left(1):
		start_node = node.name
	if not node.is_slot_enabled_right(1):
		end_node = node.name

func _on_way_editor_connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	way_editor.connect_node(from_node, from_port, to_node, to_port)

	var from_point: PointNode = way_editor.get_node(NodePath(from_node))
	var to_point: PointNode = way_editor.get_node(NodePath(to_node))
	if not from_point.is_slot_enabled_left(1):
		start_node = from_node
	if not to_point.is_slot_enabled_right(1):
		end_node = to_node

func _on_way_editor_disconnection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	way_editor.disconnect_node(from_node, from_port, to_node, to_port)
