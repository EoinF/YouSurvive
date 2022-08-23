extends Node

export var BOB_X = 1.0
export var BOB_Y = 3.0

var tween_values: Array


func _ready():
	var parent = get_parent()
	var destination = Vector2(BOB_X, BOB_Y) + parent.position
	tween_values = [parent.position, destination]
	_start_tween()


func _start_tween():
	tween_values.invert()
	var tween: Tween = $Tween
	tween.interpolate_property(
		get_parent(), "position",
		tween_values[0], tween_values[1], 0.3,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
	)
	tween.start()


func _on_Tween_tween_all_completed():
	_start_tween()
