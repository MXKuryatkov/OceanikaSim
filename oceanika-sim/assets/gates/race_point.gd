class_name RacePoint
extends Area3D

signal activated(id: int)

@onready var controller: RaceController = get_parent()

var config: Dictionary
var score: int = 25
var object_to_wait: Node3D = null
var active = true
var can_pass = false

# called before _ready, so can't get_node here
func configure(conf: Dictionary):
	config = conf

func _ready() -> void:
	score = config.score
	if config.object_to_wait != 0: # id is the name and all objects are under the controller
		object_to_wait = controller.get_node(str(config.object_to_wait))
	set_active(false)

func set_active(a: bool):
	$Sprite3D.visible = a
	active = a

func _on_body_entered(body: Node3D) -> void:
	if body == object_to_wait and active and can_pass:
		controller.race_score += score
		controller.on_point_activation(int(name))
		set_active(false)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body == object_to_wait:
		can_pass = true
func _on_area_3d_body_exited(body: Node3D) -> void:
	if body == object_to_wait:
		can_pass = false
