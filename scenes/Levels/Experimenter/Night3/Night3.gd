extends Node2D

var rocks_hit = 0
var sea_props

func _ready():
	sea_props = $Objects/Props/SeaProps.get_children()
	for sea_prop in sea_props:
		sea_prop.deactivate()
	$IslanderController.disable_controls()
	$Objects/Props/Raft.disable_steering()
	$AnimationPlayer.play("ShowIslander")


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "ShowIslander":
		$IslanderController.enable_controls()
		$Objects/Props/SeaProps.reset()
		sea_props.front().activate()
		sea_props.pop_front()
	if anim_name == "FadeOut":
		emit_signal("finish_scene")
		queue_free()


func _on_SeaProps_hit_raft(_damage_amount):
	rocks_hit += 1
	
	if sea_props.empty():
		$IslanderController.disable_controls()
		$AnimationPlayer.play("FadeOut")
		return
	sea_props.front().activate()
	sea_props.pop_front()
	
	if rocks_hit == 1:
		$AnimationPlayer.play("RevealLeftSteering")
		$Objects/Props/Raft.enable_steering()
	if rocks_hit == 2:
		$AnimationPlayer.play("RevealRightSteering")
