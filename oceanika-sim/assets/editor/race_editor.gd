class_name RaceEditor
extends Node3D

@export var save_maps: Dictionary[EditorObject, String]

const configurators: Dictionary[Variant.Type, PackedScene] = {
	TYPE_BOOL: preload("uid://b50w2mllo2sbw"),
	TYPE_FLOAT: preload("uid://cmd1hsrqpy6lv"),
	TYPE_STRING: preload("uid://bnkp0hgbul1hg"),
	TYPE_VECTOR3: preload("uid://cke7cuf20ro4r")
}

# some properties like node id and number have the same type
# so when you make default_config with these types you have to set the type here
# example: default_config: {..., "score": 10, "object": 0}
# type_map: {"score": "int", "object": "node_id"}
const mapped_configurators: Dictionary[String, PackedScene] = {
	"int": preload("uid://cmd1hsrqpy6lv"),
	"node_id": preload("uid://dt086icrduu1d"), # id 0 is null
	"color": preload("uid://dckwjxuroe5hd")
}

@onready var objects: Node3D = %Objects
@onready var move_arrows: PositionArrows = $position_arrows
@onready var scene_list: VBoxContainer = %ObjectList
@onready var config_list: VBoxContainer = %ConfigList
@onready var window: Window = $Window
@onready var stop_race_button: TextureButton = %StopRaceButton
@onready var start_race_button: TextureButton = %StartRaceButton
@onready var transform_panel: TransformPanel = %transform_panel
@onready var ui: CanvasLayer = $CanvasLayer
@onready var config_container: Panel = %ConfigContainer
@onready var way_editor: WayEditor = %way_editor

var selected_scene: EditorScene = null # don't set directly, use select_scene
var race_controller: Node3D = null
var running := false
var last_id := 1
var configuring_selector = null
var file_path := ""

func start_race():
	running = true
	race_controller = RaceController.new()
	race_controller.point_connections = way_editor.do_array([way_editor.way_editor.get_node(str(way_editor.start_node)).point_id], way_editor.start_node)
	print(race_controller.point_connections)
	race_controller.race_finished.connect(stop_race)
	for scene: EditorScene in objects.get_children():
		var o := scene.object.race_scene.instantiate()
		if o.has_method("configure"):
			o.configure(scene.config)
		o.transform = scene.transform
		o.name = str(scene.id)
		race_controller.add_child(o)
	add_child(race_controller)
	start_race_button.hide()
	objects.hide()
	ui.hide()
	stop_race_button.show()
	window.hide()
	move_arrows.hide()

func stop_race():
	race_controller.queue_free()
	objects.show()
	ui.show()
	start_race_button.show()
	%Stopwatch.reset()
	%Stopwatch.elapsed_time = 0
	stop_race_button.hide()

	running = false

func new_mission():
	clear()
	file_path = ""

func save_mission():
	if file_path == "" and objects.get_child_count() == 0: return
	var save_list := []
	for scene: EditorScene in objects.get_children():
		save_list.append({
			"object": save_maps[scene.object],
			"transform": scene.global_transform,
			"config": scene.config,
			"id": scene.id
		})

	var way_editor_data = {
		"nodes": [],
		"connections": []
	}
	for child in %way_editor.get_child(0).get_children():
		if child is PointNode:
			way_editor_data["nodes"].append({
				"name": child.name,
				"offset_x": child.position_offset.x,
				"offset_y": child.position_offset.y,
				"type_id": child.current_type_id,
				"point_id": child.point_id
			})
	way_editor_data["connections"] = way_editor.way_editor.connections
	print('data: ', way_editor_data["connections"])
	save_list.append(way_editor_data)
	var save_file := FileAccess.open(file_path, FileAccess.WRITE)
	save_file.store_var(save_list)

func clear():
	way_editor.way_editor.clear_connections()
	for child in way_editor.way_editor.get_children():
		if child is PointNode:
			way_editor.way_editor.remove_child(child) #we cant call .queue_free() 'cause it deletes only on next frame, bruh...
	print('points deleted: ', way_editor.way_editor.get_children())
	select_scene(null)
	for b: SelectionButton in scene_list.get_children(): b.queue_free()
	for scene: EditorScene in objects.get_children(): scene.queue_free()

func load_mission():
	clear()
	var save_file := FileAccess.open(file_path, FileAccess.READ)
	var save_data = save_file.get_var()
	var point_node: PackedScene = preload("res://assets/editor/way_editor/point_node.tscn")
	for object_data:Dictionary in save_data:
		if object_data.has('nodes'):
			for node_dict in object_data['nodes']:
				var new_pnode: PointNode = point_node.instantiate()
				new_pnode.position_offset = Vector2(node_dict["offset_x"], node_dict["offset_y"])
				new_pnode.set_node(node_dict["point_id"])
				for i: EditorScene in objects.get_children():
					if i.id == node_dict.point_id:
						new_pnode.set_node_name(i.object.display_name)
				new_pnode._on_option_button_item_selected(node_dict['type_id'])
				new_pnode.type_changed.connect(way_editor.on_node_type_changed)
				way_editor.way_editor.add_child(new_pnode)
				new_pnode.name = node_dict['name']

			for node in way_editor.way_editor.get_children():
				if node is PointNode:
					way_editor.on_node_type_changed(node)
			for connection in object_data["connections"]:
				way_editor.way_editor.connect_node(connection["from_node"], connection["from_port"], connection["to_node"], connection["to_port"])
			return
		var object: EditorObject = save_maps.find_key(object_data.object)
		var scene: EditorScene = object.editor_scene.instantiate()
		scene.global_transform = object_data.transform
		scene.config = object_data.config
		scene.id = object_data.id
		scene.object = object
		objects.add_child(scene)
		add_button(scene)
		last_id = max(last_id, scene.id+1)

func select_scene(scene: EditorScene):
	config_container.visible = scene != null
	selected_scene = scene
	for button: SelectionButton in scene_list.get_children():
		button.update_selection()
	update_config()
	update_arrows()
	transform_panel.visible = scene != null
	transform_panel.load_transform(selected_scene)

func add_object(object: EditorObject):
	config_container.visible = true
	var scene: EditorScene = object.editor_scene.instantiate()
	scene.object = object
	scene.id = last_id
	scene.name = str(last_id)
	last_id += 1
	if "position" in object.default_config:
		scene.position = object.position
	if "rotation" in object.default_config:
		scene.rotation = object.rotation
	scene.config = object.default_config.duplicate(true)
	objects.add_child(scene)
	add_button(scene)
	select_scene(scene)

func delete_scene():
	if not selected_scene: return
	for scene: EditorScene in objects.get_children():
		for conf in scene.object.type_map.keys():
			if scene.object.type_map[conf] == "node_id" && scene.config[conf] == selected_scene.id:
				scene.config[conf] = 0
	for point_or_not in way_editor.way_editor.get_children():
		if point_or_not is PointNode:
			var point := point_or_not as PointNode
			if point.point_id == selected_scene.id:
				point.reset_id()
	selected_scene.queue_free()
	remove_button(selected_scene)
	select_scene(null)

func add_button(scene: EditorScene):
	$Window.visible = false

	var button := SelectionButton.new()
	button.text = scene.object.display_name + " " + str(scene.id)
	button.scene = scene
	button.editor = self
	button.flat = true
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	scene_list.add_child(button)

func remove_button(scene: EditorScene):
	for b: SelectionButton in scene_list.get_children():
		if b.scene == scene:
			b.queue_free()

func update_config():
	for i in config_list.get_children(): i.queue_free()
	if not selected_scene: return
	for k in selected_scene.config:
		var conf: Configurator
		if k in selected_scene.object.type_map:
			conf = mapped_configurators[selected_scene.object.type_map[k]].instantiate()
		else:
			conf = configurators[typeof(selected_scene.config[k])].instantiate()
		conf.config = selected_scene.config
		conf.key = k
		config_list.add_child(conf)
		if conf is NodeConfigurator:
			for i: EditorScene in objects.get_children():
				if i.id == selected_scene.config[k]:
					conf.set_node_name(i.object.display_name)

func update_arrows():
	move_arrows.object_to_move = selected_scene
	move_arrows.visible = selected_scene != null

func configure_selector(button):
	configuring_selector = button

@onready var space_state = get_world_3d().direct_space_state
@onready var query := PhysicsRayQueryParameters3D.create(Vector3.ZERO, Vector3.ZERO)
@onready var viewport: Viewport = get_viewport()
@onready var camera: Camera3D = viewport.get_camera_3d()
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		var mouse := viewport.get_mouse_position()
		var origin := camera.project_ray_origin(mouse)
		query.from = origin
		query.to = origin + camera.project_ray_normal(mouse) * 1000
		query.collide_with_areas = true
		query.collide_with_bodies = false
		query.collision_mask = 0b00000000_00000000_00000000_00000010
		var result := space_state.intersect_ray(query)
		if result != {}:
			var target = result.collider.get_parent()
			if target is EditorScene:
				if configuring_selector:
					if configuring_selector.active:
						configuring_selector.set_node(target.id)
						if configuring_selector.has_method("set_node_name"):
							configuring_selector.set_node_name(target.object.display_name)
					else:
						select_scene(target)
					configuring_selector = null
				else:
					select_scene(target)
			Log.monitor("selected", target.name)
	elif event.is_action_pressed("save"):
		save_mission()

func open_object_window():
	$Window.visible = true

func close_object_window():
	$Window.visible = false

func _on_way_editor_button_pressed() -> void:
	%WayEditorWindow.visible = !%WayEditorWindow.visible

func _on_way_editor_window_close_requested() -> void:
	%WayEditorWindow.visible = false
