class_name ObjectAdder
extends Button

@export var object: EditorObject
@export var target: RaceEditor

func _ready() -> void:
	pressed.connect(func():
		target.add_object(object)
	)
	if not text:
		text = object.display_name
