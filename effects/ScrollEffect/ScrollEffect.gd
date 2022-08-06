extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var parent = get_parent()
	$Tween.interpolate_property(parent, "global_position:x",
		32, 0, 1,
		Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()
