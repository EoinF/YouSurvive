tool
extends Node2D

const DEFAULT_DISPLAY_NAME = "Undefined"

export var object_type = "<not set>"
export var is_usable = true
export var fall_duration_seconds = 0.8
export var fall_sway = 1.0
export var display_name = DEFAULT_DISPLAY_NAME

var original_position
var destination_position
var shadow_position
var elapsed_fall_time = fall_duration_seconds
var is_falling = false

var _owner_instance_id = null


func get_owner_instance_id():
	return _owner_instance_id
	
	
func set_owner_instance_id(_instance_id):
	_owner_instance_id = _instance_id


func get_resting_position():
	return destination_position


func _get_configuration_warning():
	if get_owner() != null:
		if get_node("Sprite") == null:
			return "Collectable Item must have a node named \"Sprite\""
		elif get_node("Shadow") == null:
			return "Collectable Item must have a node named \"Shadow\""
		if object_type == "<not set>":
			return "Object type must be set"

	return ""


func _process(delta):
	if not is_falling:
		return
	
	elapsed_fall_time += delta
	
	var t = elapsed_fall_time / fall_duration_seconds
	position = original_position.linear_interpolate(destination_position, t)
	position.x += fall_sway * (3.0 + (100.0 / (1.0 + destination_position.y - original_position.y))) * sin(t * 5)
	get_node("Shadow").position = shadow_position + Vector2(0, destination_position.y - position.y)
	
	if elapsed_fall_time < fall_duration_seconds:
		return
	
	is_falling = false
	if has_node("DropSound"):
		get_node("DropSound").play()

func drop_item(from, to):
	original_position = from
	destination_position = to
	
	position = from
	var shadow = get_node("Shadow")
	shadow_position = shadow.position
	shadow.position.y += to.y - from.y
	elapsed_fall_time = 0
	is_falling = true

func interact():
	var parent = get_parent()
	if (parent.has_method("interact")):
		parent.interact()
	else:
		queue_free()

# Called when the node enters the scene tree for the first time.
func _ready():
	if (destination_position == null):
		destination_position = global_position
	if (original_position == null):
		original_position = global_position
	var rotation = randf() * PI
	get_node("Sprite").rotate(rotation)
	get_node("Shadow").rotate(rotation)

