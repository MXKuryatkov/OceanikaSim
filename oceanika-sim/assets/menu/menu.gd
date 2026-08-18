extends Control

@export var races_menu: PackedScene
@export var maps_making: PackedScene
@export var programming: PackedScene


func _on_races_pressed() -> void:
	get_tree().change_scene_to_packed(races_menu)


func _on_maps_making_pressed() -> void:
	get_tree().change_scene_to_packed(maps_making)


func _on_programming_pressed() -> void:
	DroneToProgram.current_drone = $Panel/VBoxContainer/HBoxContainer/OptionButton.selected as DroneToProgram.Drone
	get_tree().change_scene_to_packed(programming)

func _on_close_pressed() -> void:
	get_tree().quit()


func _on_about_authors_pressed() -> void:
	pass # Replace with function body.
