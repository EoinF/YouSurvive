extends Node

signal finish_scene(experiment_data)

var player_name: String

var is_level_complete = false


func set_player_name(name: String):
	player_name = name
	get_node("HUDLayer/HUD/MainDialogue1").set_variables({
		"player_name": player_name
	})


func _ready():
	get_node("HUDLayer/HUD/Intro").start()


func _on_ObjectivesFast_finish_dialogue():
	get_node("HUDLayer/HUD/MainDialogue2").start()


func _on_ObjectivesSlow_finish_dialogue():
	get_node("HUDLayer/HUD/MainDialogue2").start()


func _on_MainDialogue2_finish_dialogue():
	print("main dialogue 2 finish dialogue")
	var experiment_data = get_node("Experimenter").get_experiment_data()
	emit_signal("finish_scene", experiment_data)
	queue_free()


func _on_Day1Objectives_objectives_updated(objectives):
	if not is_level_complete:
		for objective in objectives:
			if not objective["is_complete"]:
				return
		
		is_level_complete = true
		var timer: Timer = get_node("Day1Objectives/SlowCompletionTimer")
		if timer.time_left > 0:
			get_node("HUDLayer/HUD/ObjectivesFast").start()
		else:
			get_node("HUDLayer/HUD/ObjectivesSlow").start()


func _on_Islander_die():
	get_node("HUDLayer/HUD/Experimenter game over").start()


func _on_Experimenter_game_over_finish_dialogue():
	get_tree().reload_current_scene()


var is_first_time_seeing_islander = true

func _on_Experimenter_sees_islander():
	if is_first_time_seeing_islander:
		get_node("HUDLayer/HUD/MainDialogue1").start()
		is_first_time_seeing_islander = false
