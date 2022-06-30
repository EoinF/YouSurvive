extends Node2D


func _ready():
	get_node("GhostAIController").enable_ai()


func _on_Night3Objectives_complete_objective():
	print("done")
