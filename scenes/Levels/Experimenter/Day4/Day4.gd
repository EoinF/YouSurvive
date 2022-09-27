extends Node

signal restart_scene
signal finish_scene(experiment_data)

var player_name: String
var is_islander_dead = false


func set_player_name(name: String):
	player_name = name
	get_node("HUDLayer/HUD/DialogueManager").set_variables({
		"player_name": player_name
	})


func set_attempt_number(attempt_number):
	$DifficultyManager.adjust_difficulty(attempt_number)


func _ready():
	$IslanderAIController.add_steer_goal(get_node("Objects/Props/Raft"))
	
	for sea_prop in $Objects/Props/SeaProps.get_children():
		sea_prop.deactivate()
	
	# Workaround for delay in CanvasModulate changing between scenes
	$Objects.hide()
	yield(get_tree(), "idle_frame")
	$Objects.show()
	
	_fade_in()


func _on_DialogueManager_finish_dialogue(section_name):
	if section_name == "Outro":
		_fade_out()


func _fade_in():
	$AnimationPlayer.play("fade")


func _fade_out():
	$AnimationPlayer.play("fade_out")


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "fade":
		get_node("HUDLayer/HUD/DialogueManager").start_section("Intro")
		return
	if anim_name == "fade_out":
		if is_islander_dead:
			emit_signal("restart_scene")
		else:
			var experiment_data = $Experimenter.get_experiment_data()
			emit_signal("finish_scene", experiment_data)
			queue_free()


func _on_GameOver_finish():
	get_node("AnimationPlayer").play("fade_out")


func _on_Props_enemy_struggle():
	$Objects/Props/Raft.hit()


func _on_Raft_health_change(new_amount):
	$HUDLayer/HUD/RaftHealthBar.set_health(new_amount)


func _on_Raft_start_sinking():
	$IslanderAIController.is_paused = true
	$MusicLoop.stop()


func _on_Raft_finish_sinking():
	$HUDLayer/HUD/DialogueManager.start_section("Capsized")


func _on_ScrollingManager_edge_reached():
	$HUDLayer/HUD/DialogueManager.start_section("Escaping")
	$Experimenter.set_follow_target($Objects/Props/Raft/Islander, true)


func _on_ScrollingManager_finish():
	$HUDLayer/HUD/DialogueManager.start_section("Survived")
	$MusicLoop.stop()
	$IslanderAIController.is_paused = true
	$Experimenter.disable_placement()


func _on_SeaGameOver_finish():
	$AnimationPlayer.play("fade_out")


func _on_Islander_die():
	var islander = get_node("Objects/Props/Islander")
	$Experimenter.set_follow_target(islander, true)
	$Experimenter.disable_controls()
	is_islander_dead = true
	$HUDLayer/HUD/DialogueManager.stop()
	$HUDLayer/HUD/SeaGameOver.start()
