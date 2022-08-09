tool
extends Control

export var LABEL_TEXT = "Test Subject" setget set_label_text
export var MAX_HEALTH = 1000

var health = MAX_HEALTH

func set_label_text(_text):
	LABEL_TEXT = _text
	$Background/Label.text = LABEL_TEXT


func _ready():
	health = MAX_HEALTH
	var health_segment = get_node("Background/HealthSegmentBackground/HealthSegment")
	health_segment.rect_scale.x = health / MAX_HEALTH


func set_health(amount):
	health = amount
	var health_segment = get_node("Background/HealthSegmentBackground/HealthSegment")
	health_segment.rect_scale.x = float(health) / MAX_HEALTH
