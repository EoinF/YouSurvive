extends Node2D


func _ready():
	get_node("AIController").disable_ai()
	get_node("HUDLayer/HUD/MainDialogue1").start()

