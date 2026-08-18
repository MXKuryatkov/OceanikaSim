extends Node3D

@onready var arrows: PositionArrows = $position_arrows
@onready var test_object = $test_object
@onready var test_object2 = $test_object2

var counter = 0

func _ready() -> void:
	arrows.visible = false

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.keycode == KEY_ENTER and event.pressed == true:
		match counter:
			0:
				arrows.object_to_move = test_object
				arrows.show()
				counter += 1
			1:
				arrows.object_to_move = test_object2

				counter += 1
			2:
				counter = 0
				arrows.hide()
