extends Node2D

var is_ghost_shown = false


func _ready():
	get_node("IslanderController").disable_controls()
	get_node("AnimationPlayer").play("ShowIslander")


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "ShowIslander":
		get_node("IslanderController").enable_controls()
	if anim_name == "SpawnAndActivateGhost":
		# spawn the rock for the player
		get_node("Objects/Props/Tree").hit()
		get_node("AnimationPlayer").play("HighlightRock")


func _on_StartingArea_body_exited(body):
	if not is_ghost_shown and body.is_in_group("Islander"):
		is_ghost_shown = true
		get_node("AnimationPlayer").play("SpawnAndActivateGhost")
