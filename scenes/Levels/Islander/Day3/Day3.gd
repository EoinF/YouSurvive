extends Node2D

var experiment_data
var is_islander_dead = false

var IS_DEBUG_ACTIVE = false

func _ready():
	get_node("Day3Objectives").set_objective_active("collect_items", true)
	get_node("AIController").enable_ai()
	
	# Run this only if scene is run standalone
	if IS_DEBUG_ACTIVE:
		var test_file = File.new()
		
		test_file.open("utils/test_data.json", File.READ)
		var test_data = parse_json(test_file.get_as_text())
		test_file.close()
		$ExperimentReplay.set_experiment_data(test_data["Day3"])
		return
	
	var save_data = SaveManager.save_data
	$ExperimentReplay.set_experiment_data(save_data["Day3"])
	$DifficultyManager.adjust_difficulty(save_data["current_attempt"])


func _on_Day3Objectives_objectives_updated(objectives):
	if objectives[0]["is_complete"] and objectives[1]["is_complete"]:
		get_node("HUDLayer/HUD/DialogueManager").start_section("Main")
		get_node("MusicLoop").stop()
		$AIController.set_is_peaceful(true)


func _on_DialogueManager_finish_dialogue(section_name):
	if section_name == "Main":
		$AnimationPlayer.play("fade_out")


func _on_Islander_die():
	$AnimationPlayer.play("fade_out")
	is_islander_dead = true


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "fade_out":
		if is_islander_dead:
			SceneManager.restart_level()
		else:
			SceneManager.load_next_level()
