extends Node

export var BOB_X = 2.0
export var BOB_Y = 5.0

var tween_values: Array
var tween_variance: Vector2
var rand = RandomNumberGenerator.new()

func _ready():
	rand.randomize()
	var parent = get_parent()
	var destination = Vector2(BOB_X, BOB_Y) + parent.position
	tween_values = [parent.position, destination]
	tween_variance = Vector2.ZERO
	_start_tween()


func _start_tween():
	tween_values.invert()
	var rx = rand.randf_range(0, 0.1)
	var ry = rand.randf_range(0, 2.0)
	
	var new_variance = Vector2(rx, ry)
	var tween: Tween = $Tween
	tween.interpolate_property(
		get_parent(), "position",
		tween_values[0] + tween_variance, tween_values[1] + new_variance, 0.8,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
	)
	tween_variance = new_variance
	tween.start()


func _on_Tween_tween_all_completed():
	_start_tween()
