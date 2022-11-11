extends Node2D

var current_time = 0.0
var current_action = null

var is_islander_dead = false
var is_predator_placement_complete = false
var is_weapon_placement_complete = false
var is_kill_predators_complete = false

var IS_DEBUG_ACTIVE = false

func _ready():
	get_node("Day2Objectives").set_objective_active("kill_predators", true)
	get_node("AIController").enable_ai()
	
	# Run this only if scene is run standalone
	if IS_DEBUG_ACTIVE:
		var test_file = File.new()
		
		test_file.open("utils/test_data.json", File.READ)
		var test_data = parse_json(test_file.get_as_text())
		test_file.close()
		$ExperimentReplay.set_experiment_data(test_data["Day2"])
		return
	
	var save_data = SaveManager.save_data
	$ExperimentReplay.set_experiment_data(save_data["Day2"])
	$DifficultyManager.adjust_difficulty(save_data["current_attempt"])


func _is_objective_complete(objective):
	return objective.is_complete and objective.is_active


func _on_Day2Objectives_objectives_updated(objectives):
	var replay_manager = get_node("ExperimentReplay")
	if not objectives[0]["is_complete"] or not objectives[1]["is_complete"]:
		replay_manager.trigger_next_action()
	if objectives[0]["is_complete"] \
	and objectives[1]["is_complete"] \
	and _is_objective_complete(objectives[2]) \
	and _is_objective_complete(objectives[3]) \
	and _is_objective_complete(objectives[4]):
		if replay_manager.is_finished():
			get_node("HUDLayer/HUD/DialogueManager").start_section("Main")
			get_node("MusicLoop").stop()
		while not replay_manager.is_finished():
			replay_manager.trigger_next_action()


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
