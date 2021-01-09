extends Camera2D

var FOLLOW_SPEED = 400

var current_follow_target: Node2D = null
var is_following = false

func set_follow_target(target, _is_following=false):
	current_follow_target = target
	is_following = _is_following
	
func set_is_following(_is_following):
	is_following = _is_following


func _process(delta):
	if is_following:
		var direction_to_target = (current_follow_target.global_position - position)
		
		if direction_to_target.length() < FOLLOW_SPEED * delta:
			position = current_follow_target.global_position
		else:
			position += direction_to_target.normalized() * delta * FOLLOW_SPEED
