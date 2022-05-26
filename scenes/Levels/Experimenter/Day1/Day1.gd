extends Node

signal finish_scene(experiment_data)

var player_name: String

var is_find_test_subject_complete = false
var is_collect_branches_complete = false


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
	if not is_find_test_subject_complete and objectives[0]["is_complete"]:
		is_find_test_subject_complete = true
		get_node("HUDLayer/HUD/DialogueManager").start_section("Main1")
		
	if not is_collect_branches_complete and objectives[1]["is_complete"]:
		is_collect_branches_complete = true
		var timer: Timer = get_node("Day1Objectives/SlowCompletionTimer")
		if timer.time_left > 0:
			get_node("HUDLayer/HUD/DialogueManager").start_section("Complete - Fast")
		else:
			get_node("HUDLayer/HUD/DialogueManager").start_section("Complete - Slow")


func _fade_in():
	var animation_player = get_node("AnimationPlayer")
	animation_player.play("fade")


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "fade":
		get_node("HUDLayer/HUD/DialogueManager").start_section("Intro")
	if anim_name == "fade_out":
		get_tree().reload_current_scene()


func _on_Islander_die():
	get_node("HUDLayer/HUD/DialogueManager").stop()
	get_node("HUDLayer/HUD/GameOver").start()


func _on_GameOver_finish():
	get_node("AnimationPlayer").play("fade_out")
