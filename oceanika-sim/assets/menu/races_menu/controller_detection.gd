extends Control


@onready var contorllers_panel: Panel = $"../contorllers_panel"


func _on_choose_pressed() -> void:
	contorllers_panel.show()
