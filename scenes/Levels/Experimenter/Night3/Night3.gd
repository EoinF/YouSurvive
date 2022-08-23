extends Node2D

var rocks_hit = 0
var sea_props

func _ready():
	sea_props = $Objects/Props/SeaProps.get_children()
	sea_props.pop_front()
	for sea_prop in sea_props:
		sea_prop.deactivate()
	#$IslanderController.disable_controls()
	$AnimationPlayer.play("ShowIslander")
	

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "ShowIslander":
		get_node("IslanderController").enable_controls()
	if anim_name == "FadeOutFast":
		emit_signal("finish_scene")
		queue_free()


func _on_SeaProps_hit_raft(_damage_amount):
	rocks_hit += 1
	print(rocks_hit)
	if sea_props.empty():
		return
	print(sea_props.front())
	sea_props.front().activate()
	sea_props.pop_front()
