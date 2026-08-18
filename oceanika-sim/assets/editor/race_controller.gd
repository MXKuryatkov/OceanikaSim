class_name RaceController
extends Node3D

signal race_finished

var point_connections: Array
var laps: int = 1
var current_lap: int = 0
var race_score: int = 0
var fine: int = 0
var stopwatch: Stopwatch
var branch := []
var branch_starts := []
var branch_ends := []
var branch_index := 0
var index := 0

var in_branch: bool = false
var in_branch_index: int = 0
var branch_connections_array: Array = []

func _ready() -> void:
	if point_connections != []:
		get_node(str(point_connections[index])).set_active(true)

func _process(_delta: float) -> void:
	Log.monitor('branch_connections_array', branch_connections_array)
	Log.monitor('in_branch', in_branch)
	Log.monitor('in_branch_id', in_branch_index)
	Log.monitor('index', index)
	Log.monitor('point_connections', point_connections)
	Log.monitor('branch', branch)

func on_point_activation(id: int):
	print('point_activate_id: ', id)
	if index == 0:
		start_stopwatch()
	if branch_starts.size() > 0:
		if id in branch_starts:
			for i in branch_connections_array:
				if id == i[0]:
					in_branch_index = 0
					branch = i
			for start_id in branch_starts:
				if id != start_id: get_node(str(start_id)).set_active(false)
		if id in branch_ends:
			#exit the branch
			branch_connections_array.erase(branch)
			branch_starts.erase(branch[0])
			branch_ends.erase(branch[-1])
			branch = []
			if len(branch_connections_array) == 0:
				in_branch = false
			for i in branch_starts:
				get_node(str(i)).set_active(true)
			branch_index += 1
			if in_branch:
				return
		if in_branch:
			in_branch_index += 1
			get_node(str(branch[in_branch_index])).set_active(true)
	var connection = null
	if not in_branch:
		index += 1
		if index == point_connections.size():
			finish_lap()
			return
		connection = point_connections[index]
	else:
		connection = branch[in_branch_index]

	if connection is int:
		if not in_branch:
			get_node(str(connection)).set_active(true)
	else:
		#detects entering to branch, make br_arrays
		in_branch = true
		branch_starts.clear()
		branch_ends.clear()
		branch_index = 0
		branch_connections_array = connection
		for i in connection:
			branch_starts.append(i[0])
			branch_ends.append(i[-1])
			get_node(str(i[0])).set_active(true)

func start_stopwatch():
	stopwatch = get_parent().get_node('Stopwatch')
	stopwatch.reset()
	stopwatch.paused = false

func stop_stopwatch():
	stopwatch.paused = true

func finish_lap():
	current_lap += 1
	if current_lap == laps:
		Log.message("finish")
		Log.monitor("fine", fine)
		race_finished.emit()
		#stop_stopwatch()
	else:
		Log.message("lap")
		get_node("1").set_active(true)
