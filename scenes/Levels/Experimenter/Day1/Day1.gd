extends Node

signal finish_scene

var player_name: String


func set_player_name(name: String):
	player_name = name
	get_node("HUD/DialogueContainer/MainDialogue1").set_variables({
		"player_name": player_name
	})


func _ready():
	get_node("HUD/DialogueContainer/MainDialogue1").start()


func _on_Day1Objectives_objective_completed(_objective_key):
	var timer: Timer = get_node("Day1Objectives/SlowCompletionTimer")
	if timer.time_left > 0:
		get_node("HUD/DialogueContainer/ObjectivesFast").start()
	else:
		get_node("HUD/DialogueContainer/ObjectivesSlow").start()


func _on_ObjectivesFast_finish_dialogue():
	get_node("HUD/DialogueContainer/MainDialogue2").start()


func _on_ObjectivesSlow_finish_dialogue():
	get_node("HUD/DialogueContainer/MainDialogue2").start()
