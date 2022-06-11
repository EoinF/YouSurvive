extends Node2D

var COLOUR_VALID = Color(1.0, 1.0, 1.0, 0.5)
var COLOUR_INVALID = Color(1.0, 0.0, 0.5, 0.5)

var active_colour = COLOUR_VALID

func set_valid(is_valid: bool):
	active_colour = COLOUR_VALID if is_valid else COLOUR_INVALID

func _draw():
	draw_circle(position, 12, active_colour)
