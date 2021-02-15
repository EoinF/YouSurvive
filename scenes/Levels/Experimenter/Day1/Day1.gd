extends Node

signal finish_scene(experiment_data)

var player_name: String


func set_player_name(name: String):
	player_name = name
	get_node("HUD/DialogueContainer/MainDialogue1").set_variables({
		"player_name": player_name
	})


func _ready():
	get_node("HUD/DialogueContainer/MainDialogue1").start()


func _on_ObjectivesFast_finish_dialogue():
	get_node("HUD/DialogueContainer/MainDialogue2").start()


func _on_ObjectivesSlow_finish_dialogue():
	get_node("HUD/DialogueContainer/MainDialogue2").start()


func _on_MainDialogue2_finish_dialogue():
	var experiment_data = get_node("Experimenter").get_experiment_data()
	emit_signal("finish_scene", experiment_data)
	queue_free()


func _on_Day1Objectives_objectives_updated(objectives):
	var is_complete = true
	for objective in objectives:
		if not objective["is_complete"]:
			is_complete = false
			
	if is_complete:
		var timer: Timer = get_node("Day1Objectives/SlowCompletionTimer")
		if timer.time_left > 0:
			get_node("HUD/DialogueContainer/ObjectivesFast").start()
		else:
			get_node("HUD/DialogueContainer/ObjectivesSlow").start()
