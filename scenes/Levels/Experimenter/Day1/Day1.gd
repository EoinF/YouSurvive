extends Node

signal finish_scene(experiment_data)

var player_name: String

var is_level_complete = false
var is_first_time_seeing_islander = true


func set_player_name(name: String):
	player_name = name
	get_node("HUDLayer/HUD/DialogueManager").set_variables({
		"player_name": player_name
	})


func _ready():
	_fade_in()


func _on_DialogueManager_finish_dialogue(section_name):
	if section_name == "Outro":
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
			get_node("HUDLayer/HUD/DialogueManager").start_section("Complete - Fast")
		else:
			get_node("HUDLayer/HUD/DialogueManager").start_section("Complete - Slow")


func _on_Experimenter_sees_islander():
	if is_first_time_seeing_islander:
		get_node("HUDLayer/HUD/DialogueManager").start_section("Main1")
		is_first_time_seeing_islander = false


func _fade_in():
	var animation_player = get_node("AnimationPlayer")
	animation_player.play("fade")


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "fade":
		get_node("HUDLayer/HUD/DialogueManager").start_section("Intro")


func _on_Islander_die():
	get_node("HUDLayer/HUD/GameOver").start()


func _on_GameOver_finish():
	get_tree().reload_current_scene()
