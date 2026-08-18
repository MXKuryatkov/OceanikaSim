extends Node3D

@export var water_y: float = 0.0
@export var grab_distance: float = 1000.0
@export var grab_collision_mask: int = 0xFFFFFFFF

var dragging: bool = false
var grabbed_object: SimulatedKit = null
var active_viewport: Viewport = null   # store the viewport that the camera belongs to

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_try_grab_object(event.position)   # use event.position (relative to the viewport that received the event)
		else:
			_release_object()

func _process(_delta: float) -> void:
	if dragging and grabbed_object:
		_update_dragged_object_position()

func _get_camera_and_viewport() -> Array:
	# Returns an array [camera, viewport] for the camera we want to use.
	# By default, we use the current camera of the viewport that has focus.
	var viewport = $"../VSplitContainer/SubViewportContainer/SubViewport"   # root viewport? we'll adjust later
	var camera = $"../VSplitContainer/SubViewportContainer/SubViewport/Camera3D"
	if camera == null:
		# If no current camera, try to find the first Camera3D in the scene
		camera = get_tree().get_first_node_in_group("player_camera")
		if camera:
			viewport = camera.get_viewport()
	return [camera, viewport]

func _try_grab_object(mouse_pos: Vector2) -> void:
	var cam_info = _get_camera_and_viewport()
	var camera = cam_info[0]
	var viewport = cam_info[1]
	if camera == null:
		print("No camera found!")
		return

	# If we don't have mouse_pos from event, get it from the viewport
	if mouse_pos == Vector2.INF:
		mouse_pos = viewport.get_mouse_position()

	var from = camera.project_ray_origin(mouse_pos)
	var dir = camera.project_ray_normal(mouse_pos)

	var space_state = camera.get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, from + dir * grab_distance, grab_collision_mask)
	var result = space_state.intersect_ray(query)

	if result:
		var collider = result.collider
		print("Hit: ", collider.name)
		if collider is SimulatedKit:
			dragging = true
			grabbed_object = collider
			active_viewport = viewport   # store the viewport for later use
			print("Grabbed!")

func _release_object() -> void:
	dragging = false
	grabbed_object = null
	active_viewport = null

func _update_dragged_object_position() -> void:
	if active_viewport == null:
		return

	var camera = active_viewport.get_camera_3d()
	if camera == null:
		# Fallback: try to get the camera from the stored viewport
		camera = active_viewport.get_camera_3d()
		if camera == null:
			return

	var mouse_pos = active_viewport.get_mouse_position()

	var from = camera.project_ray_origin(mouse_pos)
	var dir = camera.project_ray_normal(mouse_pos)

	# Intersect with horizontal plane at water_y
	if abs(dir.y) > 0.0001:
		var t = (water_y - from.y) / dir.y
		if t > 0:
			var target_position = from + dir * t
			grabbed_object.global_position = target_position
