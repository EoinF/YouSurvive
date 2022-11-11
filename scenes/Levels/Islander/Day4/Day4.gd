extends Node2D

var is_islander_dead = false

var IS_DEBUG_ACTIVE = false

func _on_Props_enemy_struggle():
	$Objects/Props/Raft.hit()


func _ready():
	$AIController.enable_ai()
	$SeaAIController.enable_ai()
	$Objects/ScrollingManager.start()
	$AnimationPlayer.play("fade_in_music")
	$Objects/Props/Raft/Islander.pick_up_item("stick")
	
	# Run this only if scene is run standalone
	if IS_DEBUG_ACTIVE:
		var test_file = File.new()
		
		test_file.open("utils/test_data.json", File.READ)
		var test_data = parse_json(test_file.get_as_text())
		test_file.close()
		$ExperimentReplay.set_experiment_data(test_data["Day4"])
	
	var save_data = SaveManager.save_data
	$ExperimentReplay.set_experiment_data(save_data["Day4"])
	$DifficultyManager.adjust_difficulty(save_data["current_attempt"])


func _on_ScrollingManager_edge_reached():
	pass


func _on_ScrollingManager_finish():
	$HUDLayer/HUD/DialogueManager.start_section("Survived")
	$ExperimentReplay.stop()
	$IslanderInput.disable_controls()
	$SeaAIController.start_wandering()
	get_node("MusicLoop").stop()


func _on_DialogueManager_finish_dialogue(section_name):
	if section_name == "Outro":
		$AnimationPlayer.play("fade_out")


func _on_Raft_finish_sinking():
	$HUDLayer/HUD/DialogueManager.start_section("Capsized")


func _on_Raft_start_sinking():
	$SeaAIController.start_wandering()
	$IslanderInput.disable_controls()
	$ExperimentReplay.stop()
	get_node("MusicLoop").stop()


func _on_Islander_die():
	$AnimationPlayer.play("fade_out")


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "fade_out":
		if is_islander_dead:
			SceneManager.restart_level()
		else:
			SceneManager.load_next_level()

