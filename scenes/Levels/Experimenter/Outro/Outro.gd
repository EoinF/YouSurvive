extends Control

signal finish_scene

func _ready():
	get_node("DialogueManager").start_section("Main")


func _on_DialogueManager_finish_dialogue(section_name):
	if section_name == "Main":
		emit_signal("finish_scene")
		queue_free()
