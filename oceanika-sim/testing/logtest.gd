extends Control

@onready var logger: LoggerDisplay = $CanvasLayer/Logger
var clicked = false

func _ready() -> void:
	Log.message("error", Log.Level.Error)
	Log.message("warning", Log.Level.Warning)
	Log.message("info", Log.Level.Info)
	Log.message("debug")
	logger.message("local debug")

	for i in range(100): Log.message("ERROR", Log.Level.Error)

	Log.monitor("x", -10)
	Log.monitor("y", 1.5)
	Log.monitor("z", 5.678)

	Log.monitor("timer", false)
	get_tree().create_timer(10).timeout.connect(t)

func t():
	Log.monitor("timer", true)
	$Stopwatch.paused = true

func _on_button_pressed() -> void:
	clicked = not clicked
	Log.monitor("clicked", clicked)
