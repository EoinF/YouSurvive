extends Control


var max_health = 1000.0
var health = max_health


func set_max_health(amount):
	max_health = amount
	var health_segment = get_node("Background/HealthSegmentBackground/HealthSegment")
	health_segment.rect_scale.x = health / max_health

func set_health(amount):
	health = amount
	var health_segment = get_node("Background/HealthSegmentBackground/HealthSegment")
	health_segment.rect_scale.x = health / max_health
