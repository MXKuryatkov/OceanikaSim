class_name EditorScene
extends Node3D

var object: EditorObject
var config: Dictionary
var id: int

func _process(_delta: float) -> void:
	update_config()

func update_config():
	pass
