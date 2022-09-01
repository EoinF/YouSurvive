extends Node

signal finish_scene(experiment_data)

var player_name: String


func set_player_name(name: String):
	player_name = name
	get_node("HUDLayer/HUD/DialogueManager").set_variables({
		"player_name": player_name
	})


func _ready():
	$IslanderAIController.add_steer_goal(get_node("Objects/Props/Raft"))
	
	for sea_prop in $Objects/Props/SeaProps.get_children():
		sea_prop.deactivate()
	
	# Workaround for delay in CanvasModulate changing between scenes
	$Objects.hide()
	yield(get_tree(), "idle_frame")
	$Objects.show()
	
	#$HUDLayer/HUD/DialogueManager.start_section("Capsized")
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
	pass


func _on_Raft_finish_sinking():
	$HUDLayer/HUD/DialogueManager.start_section("Capsized")
	$IslanderAIController.is_paused = true


func _on_ScrollingManager_edge_reached():
	$HUDLayer/HUD/DialogueManager.start_section("Escaping")


func _on_ScrollingManager_finish():
	$HUDLayer/HUD/DialogueManager.start_section("Survived")
