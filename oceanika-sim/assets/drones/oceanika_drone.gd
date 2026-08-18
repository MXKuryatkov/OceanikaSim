extends RigidBody3D
class_name OceanikaDrone


@export var rotation_speed: float = 5
@export var move_speed: float = 10
@export var water_level: Node3D
var height_strength: float = 0
var forward_strength: float = 0
var right_strength: float = 0
var yaw_strength: float = 0
#There isnt pitch_strength

var angle_lim: float = 10



var delta_param = 0.1
@onready var height_particles: Node3D = $height_particles
@onready var move_particles: Node3D = $move_particles
@onready var camera: Camera3D = %Camera
@onready var lights: Node3D = $lights
@onready var drone_panel: DronePanel = $drone_panel




var pref_ = ''
var height_direction = 1
var height_coef = 0.5

enum SpeedMode {
	low,
	medium,
	high,
}
var current_speed_mode: SpeedMode = SpeedMode.low

@export var low_speed = 15
@export var medium_speed = 20
@export var high_speed = 25

var stabilized: bool = false
var height: float = 0


func _ready() -> void:
	camera.current = true
	
	water_level = get_tree().get_first_node_in_group('water')
	pref_ = OceanikaMode.controller_prefix
	
	match current_speed_mode:
		SpeedMode.low:
			move_speed = low_speed
			current_speed_mode = SpeedMode.low
		SpeedMode.medium:
			move_speed = medium_speed
			current_speed_mode = SpeedMode.medium
		SpeedMode.high:
			move_speed = high_speed
			current_speed_mode = SpeedMode.high
	rotation_speed = move_speed/2
	
	if stabilized:
		gravity_scale = 0
	else:
		gravity_scale = 0.1
	for particle: GPUParticles3D in height_particles.get_children():
			particle.emitting = false
	for particle: GPUParticles3D in move_particles.get_children():
		particle.emitting = false

var prev_camera_rotation: Vector3 = Vector3.ZERO
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	pref_ = OceanikaMode.controller_prefix
	delta_param = delta
	
	if Input.is_action_just_pressed(pref_ + 'lights'):
		lights.visible = !lights.visible
	
	if OS.get_name() == 'Linux' and OceanikaMode.controller_prefix == 'rm_':
		if snapped(Input.get_action_strength(pref_+'left_up_lin'), 0.1) == 0.5:
			height_direction = 0
			height_coef = 0
		elif snapped(Input.get_action_strength(pref_+'left_up_lin'), 0.1) < 0.5:
			height_direction = -1
			height_coef = 0.5
		elif snapped(Input.get_action_strength(pref_+'left_up_lin'), 0.1) > 0.5:
			height_direction = 1
			height_coef = 0.5
		height_strength = Input.get_action_strength(pref_+'left_up_lin') * height_direction - height_coef
	else:
		height_strength = Input.get_axis(pref_+'left_down', pref_+'left_up')
		
	forward_strength = Input.get_axis(pref_+'right_down', pref_+'right_up')
	yaw_strength = Input.get_axis(pref_+'right_right', pref_+'right_left')

	apply_force(Vector3.UP * height_strength * move_speed * delta, Vector3.ZERO)
	apply_force(-transform.basis.z*forward_strength*move_speed * delta)
	apply_torque((Vector3.UP*yaw_strength) * rotation_speed * delta)

	camera.global_rotation.z = 0
	
	if Input.is_action_just_pressed("camera1"):
		camera.current = true
	elif Input.is_action_just_pressed("camera2"):
		get_tree().get_first_node_in_group('camera2').current = true
	prev_camera_rotation = camera.global_rotation
	
	
	if abs(height_strength) >= 0.1:
		for particle: GPUParticles3D in height_particles.get_children():
			particle.emitting = true
	else:
		for particle: GPUParticles3D in height_particles.get_children():
			particle.emitting = false
	if abs(yaw_strength) >= 0.1 or abs(forward_strength) >= 0.1:
		for particle: GPUParticles3D in move_particles.get_children():
			particle.emitting = true
	else:
		for particle: GPUParticles3D in move_particles.get_children():
			particle.emitting = false
	
	drone_panel.speed_mode.text = str(current_speed_mode + 1)
	drone_panel.stab.text = 'вкл.' if stabilized else 'выкл.'
	drone_panel.light.text = 'вкл.' if lights.visible else 'выкл.'

	
	if Input.is_action_just_pressed(OceanikaMode.controller_prefix + 'speed_mode'):
		match current_speed_mode:
			SpeedMode.low:
				move_speed = medium_speed
				current_speed_mode = SpeedMode.medium
			SpeedMode.medium:
				move_speed = high_speed
				current_speed_mode = SpeedMode.high
			SpeedMode.high:
				move_speed = low_speed
				current_speed_mode = SpeedMode.low
		rotation_speed = move_speed/2
	Log.monitor('move_speed', move_speed)
	Log.monitor('rot_speed', rotation_speed)
	Log.monitor('global_position.y', global_position.y)
	
	if Input.is_action_just_pressed(OceanikaMode.controller_prefix + 'stabilization'):
		stabilized = !stabilized
		if stabilized:
			gravity_scale = 0
			height = global_position.y
		else:
			gravity_scale = 0.1
	Log.monitor('stabilized', stabilized)
	Log.monitor('height', height)
	Log.monitor('height_strength', height_strength)
	
func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var current_rotation = state.transform.basis.get_euler()
	var current_position = state.transform.origin
	current_rotation.z = lerp_angle(current_rotation.z, clampf(current_rotation.z, deg_to_rad(-angle_lim), deg_to_rad(angle_lim)), 2*delta_param)
	current_rotation.x = lerp_angle(current_rotation.x, clampf(current_rotation.x, deg_to_rad(-angle_lim), deg_to_rad(angle_lim)), 2*delta_param)
	
	if abs(height_strength) <= 0.1:
		current_rotation.x = lerp_angle(current_rotation.x, 0, .3*delta_param)
	if abs(right_strength) <= 0.1:
		current_rotation.z = lerp_angle(current_rotation.z, 0, .3*delta_param)
	
	if stabilized:
		if abs(height_strength) <= 0.1:
			current_position.y = lerp(current_position.y, height, 0.1*delta_param)
			if current_position.y < water_level.global_position.y:
				gravity_scale = 0
			else:
				gravity_scale = 0.1
		else:
			if current_position.y < water_level.global_position.y:
				gravity_scale = 0
				height = current_position.y
			else:
				gravity_scale = 0.1
	
	state.transform.basis = Basis.from_euler(current_rotation)
	state.transform.origin = current_position



	
