extends Node

signal finish_iteration

var OFFSET_BEGIN_SCALE = 6
var OFFSET_END_SCALE = 0

var _anchor: Node2D
var _direction: Vector2

var _forward_cutoff
var _backward_cutoff
var is_forwards = false
var is_playing = false
var is_starting = false


func start(anchor_node: Node2D, direction: Vector2):
	_direction = direction.normalized()
	_anchor = anchor_node
	is_playing = true
	is_starting = true
	
	var parent = get_parent()
	
	$Tween.follow_property(parent, "global_position",
		parent.global_position, _anchor, "global_position", 0.3,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()


func stop():
	is_playing = false


func _start_new_iteration():
	var parent = get_parent()
	_backward_cutoff = _anchor.global_position - (_direction * OFFSET_BEGIN_SCALE * (1 + randf()))
	
	$Tween.interpolate_property(parent, "global_position",
		_anchor.global_position, _backward_cutoff, 0.3,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()


func _on_Tween_tween_completed(_object, _key):
	var parent = get_parent()
	if not is_playing:
		return
	if is_starting:
		is_starting = false
		_start_new_iteration()
		return

	if is_forwards:
		emit_signal("finish_iteration")
		_start_new_iteration()
	else:
		$Tween.follow_property(parent, "global_position",
			_backward_cutoff, _anchor, "global_position", 0.2,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Tween.start()
	is_forwards = not is_forwards
