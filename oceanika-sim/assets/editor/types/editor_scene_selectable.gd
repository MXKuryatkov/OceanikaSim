class_name EditorSceneSelectable
extends EditorScene

@export var target: Node3D

func _ready():
	target.hide()

func select():
	target.show()

func deselect():
	target.hide()
