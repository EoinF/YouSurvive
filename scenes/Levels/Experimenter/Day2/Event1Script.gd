extends Node

signal finish_event

func trigger():
	var animation_player = get_owner().get_node("AnimationPlayer")
	animation_player.connect("animation_finished", self, "_on_AnimationPlayer_animation_finished")
	animation_player.play("fade")


func after_complete():
	var ai_controller = get_owner().get_node("IslanderAIController")
	ai_controller.add_collection_goal("stone", 1)
	ai_controller.add_kill_goal("crab", 99999)


func _on_AnimationPlayer_animation_finished(anim_name):
	get_owner().get_node("AnimationPlayer").disconnect("animation_finished", self, "_on_AnimationPlayer_animation_finished")
	if anim_name == "fade":
		after_complete()
		emit_signal("finish_event")

