extends Node2D

signal restart_scene
signal finish_scene

var experiment_data

func _on_Props_enemy_struggle():
	$Objects/Props/Raft.hit()


func set_experiment_data(_data):
	experiment_data = _data
	get_node("ExperimentReplay").set_experiment_data(_data)


func set_attempt_number(attempt_number):
	$DifficultyManager.adjust_difficulty(attempt_number)


func _ready():
	$AIController.enable_ai()
	$SeaAIController.enable_ai()
	$Objects/ScrollingManager.start()
	$AnimationPlayer.play("fade_in_music")
	$Objects/Props/Raft/Islander.pick_up_item("stick")


func _on_ScrollingManager_edge_reached():
	pass


func _on_ScrollingManager_finish():
	$HUDLayer/HUD/DialogueManager.start_section("Survived")


func _on_DialogueManager_finish_dialogue(section_name):
	if section_name == "Outro":
		$AnimationPlayer.play("fade_out")
		emit_signal("finish_scene")


func _on_Raft_finish_sinking():
	$HUDLayer/HUD/DialogueManager.start_section("Capsized")


func _on_Raft_start_sinking():
	$IslanderInput.disable_controls()


func _on_Islander_die():
	emit_signal("restart_scene")
