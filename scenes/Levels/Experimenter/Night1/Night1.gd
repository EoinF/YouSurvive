extends Node2D

var is_ghost_shown = false
var is_tutorial_shown = false


func _ready():
	$IslanderController.disable_controls()
	$AnimationPlayer.play("ShowIslander")


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "ShowIslander":
		$IslanderController.enable_controls()
		$MovementTutorialTimer.start()
	if anim_name == "SpawnAndActivateGhost":
		# spawn the rock for the player
		get_node("Objects/Props/Tree").hit()
		get_node("AnimationPlayer").play("HighlightRock")
	if anim_name == "FadeOutFast":
		SceneManager.load_next_level()


func _on_StartingArea_body_exited(body):
	if not is_ghost_shown and body.is_in_group("Islander"):
		is_ghost_shown = true
		$AnimationPlayer.play("SpawnAndActivateGhost")


func _on_Ghost_health_change(health):
	if health <= 0:
		$IslanderController.disable_controls()
		$AnimationPlayer.play("FadeOutFast")


func _on_Islander_inventory_slot_change(inventory_slot):
	if not is_tutorial_shown:
		$HUDLayer/AttackTutorial.activate()
		is_tutorial_shown = true


func _on_MovementTutorialTimer_timeout():
	$HUDLayer/MovementTutorial.activate()


func _on_Islander_move():
	$MovementTutorialTimer.stop()
