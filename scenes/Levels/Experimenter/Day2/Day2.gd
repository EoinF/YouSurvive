extends Node2D

var is_islander_dead = false

func set_player_name(player_name):
	get_node("HUDLayer/HUD/DialogueManager").set_variables({
		"player_name": player_name
	})


func set_attempt_number(attempt_number):
	$DifficultyManager.adjust_difficulty(attempt_number)


func _enter_tree():
	$Objects.color = Color.black


func _ready():
	get_node("AIController").disable_ai()
	var save_data = SaveManager.save_data
	get_node("HUDLayer/HUD/DialogueManager").set_variables({
		"player_name": save_data["player_name"]
	})
	$DifficultyManager.adjust_difficulty(save_data["current_attempt"])
	_fade_in()


func _fade_in():
	$AnimationPlayer.play("fade")


func _fade_out():
	$AnimationPlayer.play("fade_out")


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "fade":
		get_node("HUDLayer/HUD/DialogueManager").start_section("Intro")
	if anim_name == "fade_out":
		if is_islander_dead:
			SceneManager.restart_level()
		else:
			var experiment_data = $Experimenter.get_experiment_data()
			SceneManager.load_next_level(experiment_data)


func _on_DialogueManager_finish_dialogue(section_name):
	if section_name == "Outro":
		_fade_out()


var enemies_score = 0
var SCORE_THRESHOLD = 30

var score_map = {
	"crab": 1,
	"porcupine": 2,
	"boar": 3,
	"stick": -1,
	"stone": -5
}

var is_predator_placement_complete = false
var is_weapon_placement_complete = false
var is_kill_predators_complete = false


func _is_objective_complete(objective):
	return objective.is_complete and objective.is_active


func _on_Day2Objectives_objectives_updated(objectives):
	var dialogue_manager = get_node("HUDLayer/HUD/DialogueManager")
	
	if not is_predator_placement_complete and _is_objective_complete(objectives[0]):
		dialogue_manager.start_section("Main1 (After 15 placed)")
		is_predator_placement_complete = true

	if not is_weapon_placement_complete and _is_objective_complete(objectives[1]):
		dialogue_manager.start_section("Main2 (After weapon placed)")
		is_weapon_placement_complete = true

	if not is_kill_predators_complete and _is_objective_complete(objectives[2]) \
	and _is_objective_complete(objectives[3]) and _is_objective_complete(objectives[4]):
		$Experimenter.disable_placement()
		$AIController.set_is_peaceful(true)
		if enemies_score < SCORE_THRESHOLD:
			dialogue_manager.start_section("Complete - Easy")
		else:
			dialogue_manager.start_section("Complete - Hard")
		is_kill_predators_complete = true


func _on_Experimenter_place_item(item_type, _source_location):
	if item_type in score_map:
		enemies_score += score_map[item_type]


func _on_Islander_die():
	var islander = get_node("Objects/Props/Islander")
	var experimenter = get_node("Experimenter")
	experimenter.set_follow_target(islander, true)
	experimenter.disable_controls()
	is_islander_dead = true
	get_node("HUDLayer/HUD/DialogueManager").stop()
	get_node("HUDLayer/HUD/GameOver").start()


func _on_GameOver_finish():
	get_node("AnimationPlayer").play("fade_out")
