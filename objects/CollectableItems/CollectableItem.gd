tool
extends Node2D

const DEFAULT_DISPLAY_NAME = "Undefined"

export var item_type = "<not set>"
export var is_usable = true
export var fall_duration_seconds = 0.8
export var fall_sway = 1.0
export var display_name = DEFAULT_DISPLAY_NAME

var original_position = position
var destination_position = position
var shadow_position
var elapsed_fall_time = fall_duration_seconds

func _get_configuration_warning():
	if get_owner() != null:
		if get_node("Sprite") == null:
			return "Collectable Item must have a node named \"Sprite\""
		elif get_node("Shadow") == null:
			return "Collectable Item must have a node named \"Shadow\""
		if item_type == "<not set>":
			return "Item type must be set"

	return ""

func _process(delta):
	if elapsed_fall_time < fall_duration_seconds:
		elapsed_fall_time += delta
		var t = elapsed_fall_time / fall_duration_seconds
		position = original_position.linear_interpolate(destination_position, t)
		position.x += fall_sway * (3.0 + (100.0 / (1.0 + destination_position.y - original_position.y))) * sin(t * 5)
		get_node("Shadow").position = shadow_position + Vector2(0, destination_position.y - position.y)

func drop_item(from, to):
	original_position = from
	destination_position = to
	
	position = from
	var shadow = get_node("Shadow")
	shadow_position = shadow.position
	shadow.position.y += to.y - from.y
	elapsed_fall_time = 0

func interact():
	var parent = get_parent()
	if (parent.has_method("interact")):
		parent.interact()
	else:
		queue_free()

# Called when the node enters the scene tree for the first time.
func _ready():
	var rotation = randf() * PI
	get_node("Sprite").rotate(rotation)
	get_node("Shadow").rotate(rotation)

