extends Node3D

@export var save_maps: SaveMaps
@export var objects: Node3D
@onready var panel: Panel = $Control/panel
@onready var label: Label = $Control/Contatiner/Label
@onready var stopwatch: Stopwatch = %Stopwatch
@onready var way_editor: WayEditor = %way_editor


@export var medal_colors: Dictionary = {
	0: Color(1.0, 1.0, 1.0, 0.0),
	1: Color(0.918, 0.769, 0.304, 1.0),
	2: Color(0.753, 0.753, 0.753),
	3: Color(0.875, 0.631, 0.486),
}
var race_controller: RaceController
var rc_added: bool = false

func _ready() -> void:
	RaceHandler.race_places.get_or_add(RaceHandler.race.name)
	stopwatch.paused = true
	load_race()

func load_race():
	var file_path = RaceHandler.race.race_file_path
	var save_file := FileAccess.open(file_path, FileAccess.READ)
	var save_data = save_file.get_var()
	race_controller = RaceController.new()
	race_controller.race_finished.connect(stop_race)
	var point_node: PackedScene = preload("res://assets/editor/way_editor/point_node.tscn")
	for object_data:Dictionary in save_data:
		if object_data.has('nodes'):
			for node_dict in object_data['nodes']:
				var new_pnode: PointNode = point_node.instantiate()
				new_pnode.position_offset = Vector2(node_dict["offset_x"], node_dict["offset_y"])
				new_pnode.set_node(node_dict["point_id"])
				new_pnode._on_option_button_item_selected(node_dict['type_id'])
				new_pnode.type_changed.connect(way_editor.on_node_type_changed)
				way_editor.way_editor.add_child(new_pnode)
				new_pnode.name = node_dict['name']
				
			for node in way_editor.way_editor.get_children():
				if node is PointNode:
					way_editor.on_node_type_changed(node)
			for connection in object_data["connections"]:
				way_editor.way_editor.connect_node(connection["from_node"], connection["from_port"], connection["to_node"], connection["to_port"])
		else:
			var object: EditorObject = save_maps.save_maps.find_key(object_data.object)
			var scene: EditorScene = object.editor_scene.instantiate()
			scene.global_transform = object_data.transform
			scene.config = object_data.config
			scene.id = object_data.id
			scene.object = object
			objects.add_child(scene)
	objects.hide()
	if not way_editor.way_editor.get_node(str(way_editor.start_node)) == null:
		race_controller.point_connections = way_editor.do_array([way_editor.way_editor.get_node(str(way_editor.start_node)).point_id], way_editor.start_node)
	
	for scene: EditorScene in objects.get_children():
		var o := scene.object.race_scene.instantiate()
		if o.has_method("configure"):
			o.configure(scene.config)
		o.transform = scene.transform
		o.name = str(scene.id)
		race_controller.add_child(o)
	add_child(race_controller)
	rc_added = true

func _process(_delta: float) -> void:
	if rc_added:
		$Control/Contatiner/points.text = str(race_controller.race_score)

func stop_race():
	panel.pause = true
	panel.pause_check()
	%topic_label.text = 'Поздравляю,\nВаш результат'
	%time.text = label.text
	%score.text = str(race_controller.race_score)
	if stopwatch.get_elapsed_time_in_seconds() <= 60:
		RaceHandler.race_places[RaceHandler.race.name] = 1
	elif stopwatch.get_elapsed_time_in_seconds() > 60 and stopwatch.get_elapsed_time_in_seconds() < 90:
		RaceHandler.race_places[RaceHandler.race.name] = 2
	else:
		RaceHandler.race_places[RaceHandler.race.name] = 3
	set_medal(RaceHandler.race_places[RaceHandler.race.name])
	%race_info.show()
	
func set_medal(place: int):
	%medal.modulate = medal_colors[place]
	%medal.show()
