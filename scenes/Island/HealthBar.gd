tool
extends Control

export var LABEL_TEXT = "Test Subject" setget set_label_text

var health = 0
var max_health = 0

func set_label_text(_text):
	LABEL_TEXT = _text
	$Background/Label.text = LABEL_TEXT


func _ready():
	health = 0
	var health_segment = get_node("Background/HealthSegmentBackground/HealthSegment")
	health_segment.rect_scale.x = 1


func set_health(amount):
	health = amount
	max_health = amount if amount > max_health else max_health
	var health_segment = get_node("Background/HealthSegmentBackground/HealthSegment")
	health_segment.rect_scale.x = float(health) / max_health


func _on_Raft_health_change(new_amount):
	set_health(new_amount)
