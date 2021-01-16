extends Node

signal finish_event

func trigger():
	get_owner().get_node("AnimationPlayer").play("fade")


func after_complete():
	var camera = get_owner().get_node("Camera")
	var islander = get_owner().get_node("Objects/Props/Islander")
	var ai_controller = get_owner().get_node("IslanderAIController")
	camera.set_follow_target(islander, true)
	ai_controller.add_collection_goal("branch", 10)


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "fade":
		after_complete()
		emit_signal("finish_event")

