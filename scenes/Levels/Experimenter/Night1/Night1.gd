extends Node2D

signal finish_scene

var is_ghost_shown = false


func _ready():
	$IslanderController.disable_controls()
	$AnimationPlayer.play("ShowIslander")
	
	# Workaround for delay in CanvasModulate changing between scenes
	$Objects.hide()
	yield(get_tree(), "idle_frame")
	$Objects.show()


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "ShowIslander":
		get_node("IslanderController").enable_controls()
	if anim_name == "SpawnAndActivateGhost":
		# spawn the rock for the player
		get_node("Objects/Props/Tree").hit()
		get_node("AnimationPlayer").play("HighlightRock")
	if anim_name == "FadeOutFast":
		emit_signal("finish_scene")
		queue_free()


func _on_StartingArea_body_exited(body):
	if not is_ghost_shown and body.is_in_group("Islander"):
		is_ghost_shown = true
		$AnimationPlayer.play("SpawnAndActivateGhost")


func _on_Ghost_health_change(health):
	if health <= 0:
		$IslanderController.disable_controls()
		$AnimationPlayer.play("FadeOutFast")


func _onFadeOutFinish():
	emit_signal("finish_scene")
