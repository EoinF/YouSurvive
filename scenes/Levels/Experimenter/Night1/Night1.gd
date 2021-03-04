extends Node2D


func _ready():
	get_node("IslanderController").disable_controls()
	get_node("AnimationPlayer").play("ShowIslander")


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "ShowIslander":
		get_node("IslanderController").enable_controls()
