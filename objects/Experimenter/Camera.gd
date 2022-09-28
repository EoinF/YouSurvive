extends Camera2D

var FOLLOW_SPEED_RATIO = 50

var MIN_FOLLOW_SPEED = 5
var MAX_FOLLOW_SPEED = 300

var current_follow_target: Node2D = null
var is_following = false

func set_follow_target(target, _is_following=false):
	current_follow_target = target
	is_following = _is_following


func set_is_following(_is_following):
	is_following = _is_following


func _process(delta):
	if is_following and current_follow_target != null:
		var direction_to_target = current_follow_target.global_position - position
		var distance_to_target = direction_to_target.length()
		
		if distance_to_target > FOLLOW_SPEED_RATIO * MAX_FOLLOW_SPEED * delta:
			translate(direction_to_target.normalized() * delta * MAX_FOLLOW_SPEED)
		elif distance_to_target > FOLLOW_SPEED_RATIO * MIN_FOLLOW_SPEED * delta:
			var follow_speed = lerp(MIN_FOLLOW_SPEED, MAX_FOLLOW_SPEED, distance_to_target / (FOLLOW_SPEED_RATIO * MAX_FOLLOW_SPEED * delta))
			translate(direction_to_target.normalized() * delta * follow_speed)
