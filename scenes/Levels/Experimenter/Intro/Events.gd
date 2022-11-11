extends Node


func _on_DialogueManager_trigger_event(event_name):
	call(event_name)


func fade_out():
	print("fade out")
	get_node("../../AnimationPlayer").play("fadeOut")
