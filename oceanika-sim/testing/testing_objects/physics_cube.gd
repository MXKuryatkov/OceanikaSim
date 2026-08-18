extends RigidBody3D

var flying: bool

func configure(conf: Dictionary):
	flying = conf.flying

func _physics_process(_delta: float) -> void:
	if flying:
		apply_central_force(Vector3.UP * 10)
