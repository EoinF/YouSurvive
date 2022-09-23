extends Control

signal finish


func start():
	get_node("DialogueManager").start_section("Main")


func _on_DialogueManager_finish_dialogue(_section_name):
	emit_signal("finish")
