extends Label

@onready var stopwatch: Stopwatch = %Stopwatch


func _ready() -> void:
	pass 

var started: bool = false

func _process(_delta: float) -> void:
	text = stopwatch.get_elapsed_time_as_formatted_string('{MM}:{ss}:{mmm}')
	
	
	
	
	
	
	#fine_label.text = 'Штраф: ' + str(RacePointsManager.fine) + ' секунд'

	#if not started and RacePointsManager.waiting_id != 0:
		#started = true
		#stopwatch.paused = false
	#if RacePointsManager.waiting_id == RacePointsManager.max_id:
		#stopwatch.paused = true
		#started = false
	##if stopwatch.paused == false:
	##var time = stopwatch.get_elapsed_time_as_formatted_string('{MM}:{ss}:{mmm}').split(':')
	##var minutes = time[0]
	##var seconds = str(int(time[1]) + 5)
	##var miliseconds = time[2]
