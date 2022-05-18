extends Node2D

signal finish


func start():
	get_node("DialogueManager").start_section("Main")


func _on_DialogueManager_finish_dialogue(section_name):
	emit_signal("finish")
