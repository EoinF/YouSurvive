extends Node

var OFFSET_BEGIN_SCALE = 6
var OFFSET_END_SCALE = 0

var _anchor: Vector2
var _direction: Vector2

var _start
var _forward_cutoff
var _backward_cutoff
var is_forwards = false

func _ready():
	var parent = get_parent()


func start(anchor_position: Vector2, direction: Vector2):
	_direction = direction.normalized()
	_anchor = anchor_position
	_start_new_iteration()


func _start_new_iteration():
	var parent = get_parent()
	_start = parent.position
	_backward_cutoff = _anchor - (_direction * OFFSET_BEGIN_SCALE * (1 + randf()))
	_forward_cutoff = _anchor + (_direction * OFFSET_END_SCALE * (1 + randf()))
	
	$Tween.interpolate_property(parent, "position",
		_start, _backward_cutoff, 0.3,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()


func _on_Tween_tween_completed(object, key):
	var parent = get_parent()
	if is_forwards:
		_start_new_iteration()
	else:
		$Tween.interpolate_property(parent, "position", 
			_backward_cutoff, _forward_cutoff, 0.2,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Tween.start()
	is_forwards = not is_forwards
