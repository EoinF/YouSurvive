tool
extends KinematicBody2D

signal finish_launching(node)

export var duration: float = 0.4
export var MOVE_SPEED = 200
export var spawned_object_type = "<not set>"
export var object_type = "<not set>"
export var attack_power = 1

var original_position: Vector2
var direction: Vector2

var elapsed_time: float = 0
var is_started = false

var _owner_instance_id = null


func get_owner_instance_id():
	return _owner_instance_id


func set_owner_instance_id(_instance_id):
	_owner_instance_id = _instance_id


func _get_configuration_warning():
	if get_owner() != null:
		if get_node("Sprite") == null:
			return "Projectile must have a node named \"Sprite\""
		elif get_node("Shadow") == null:
			return "Projectile must have a node named \"Shadow\""
		if spawned_object_type == "<not set>":
			return "Spawned object type must be set"

	return ""


func _process(_delta):
	if is_started:
		if (elapsed_time <= duration):
			get_node("Sprite").offset.y = -15 * sin(0.1 * PI + 0.9 * PI * (elapsed_time / duration))
		else:
			get_node("Sprite").offset.y = 0
			emit_signal("finish_launching", self)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if (elapsed_time <= duration):
		move_and_collide(direction * delta * MOVE_SPEED)
		elapsed_time += delta


func launch_item(launch_origin, launch_direction):
	position = launch_origin
	original_position = launch_origin
	direction = launch_direction
	is_started = true
