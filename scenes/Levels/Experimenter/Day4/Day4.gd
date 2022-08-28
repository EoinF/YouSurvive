extends Node

signal finish_scene(experiment_data)

var player_name: String
var is_islander_dead = false


func set_player_name(name: String):
	player_name = name
	get_node("HUDLayer/HUD/DialogueManager").set_variables({
		"player_name": player_name
	})


func _ready():
	$Experimenter.enable_controls()
	$IslanderAIController.is_paused = false
	$AIController.enable_ai()
	$SeaAIController.enable_ai()
	$IslanderAIController.add_steer_goal(get_node("Objects/Props/Raft"))
	
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
			get_tree().change_scene("res://scenes/Levels/Experimenter/Day4/Day4.tscn")
		else:
			var experiment_data = $Experimenter.get_experiment_data()
			emit_signal("finish_scene", experiment_data)
			queue_free()


func _on_Islander_die():
	var islander = get_node("Objects/Props/Raft/Islander")
	var experimenter = get_node("Experimenter")
	experimenter.set_follow_target(islander, true)
	experimenter.disable_controls()
	is_islander_dead = true
	get_node("HUDLayer/HUD/DialogueManager").stop()
	get_node("HUDLayer/HUD/GameOver").start()


func _on_GameOver_finish():
	get_node("AnimationPlayer").play("fade_out")


func _on_Props_enemy_struggle():
	$Objects/Props/Raft.hit()


func _on_Raft_health_change(new_amount):
	$HUDLayer/HUD/RaftHealthBar.set_health(new_amount)


func _on_Raft_start_sinking():
	pass

func _on_Raft_finish_sinking():
	$IslanderAIController.is_paused = true
	$AnimationPlayer.play("fade_out")
	is_islander_dead = true
