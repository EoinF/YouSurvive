extends Node

export var total_frames = 50
export var speed = 0.2

var OFFSET_POSITION
var ORIGINAL_POSITION

var _shake_timeout = 0


func _ready():
	var parent = get_parent()
	ORIGINAL_POSITION = parent.position
	OFFSET_POSITION = Vector2(parent.position.x + 1, parent.position.y)


func _process(_delta):
	if (_shake_timeout > 0):
		var parent = get_parent()
		parent.position = ORIGINAL_POSITION.linear_interpolate(OFFSET_POSITION, sin(_shake_timeout * speed))
		_shake_timeout -= 1


func start():
	if _shake_timeout > 0:
		return
	_shake_timeout = total_frames
