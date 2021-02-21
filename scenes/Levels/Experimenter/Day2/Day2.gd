extends Node2D


func set_player_name(player_name):
	get_node("HUDLayer/HUD/MainDialogue1").set_variables({
		"player_name": player_name
	})


func _ready():
	get_node("HUDLayer/HUD/MainDialogue1").start()
