extends Node2D

var is_islander_dead = false
var is_collect_coconuts_complete = false
var enemies_score = 0

var hard_score_breakpoint = 70

var score_map = {
	"crab": 2,
	"boar": 3,
	"branch": -1,
}

var max_time = 180.0 # 3 minutes
var max_time_score = 40

func calculate_score():
	var timer = get_node("ObjectivesTimer")
	var time_elapsed = timer.wait_time - timer.time_left
	var _score = ceil((time_elapsed / max_time) * 40)
	var capped_time_score = min(_score, max_time_score)
	return capped_time_score + enemies_score


func set_player_name(player_name):
	get_node("HUDLayer/HUD/DialogueManager").set_variables({
		"player_name": player_name
	})


func set_attempt_number(attempt_number):
	$DifficultyManager.adjust_difficulty(attempt_number)


func _ready():
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


func _on_Day3Objectives_objectives_updated(objectives):
	if not is_collect_coconuts_complete and objectives[0].is_complete:
		is_collect_coconuts_complete = true
		get_node("HUDLayer/HUD/DialogueManager").start_section("Coconuts collected")
		
	if objectives[0].is_complete and objectives[1].is_complete:
		on_objectives_complete()


func on_objectives_complete():
	$Experimenter.disable_placement()
	$AIController.set_is_peaceful(true)
	if calculate_score() >= hard_score_breakpoint:
		get_node("HUDLayer/HUD/DialogueManager").start_section("Complete - Hard")
	else:
		get_node("HUDLayer/HUD/DialogueManager").start_section("Complete - Easy")


func _on_Experimenter_place_item(item_type, _source_location):
	if item_type in score_map:
		enemies_score += score_map[item_type]


func _on_GameOver_finish():
	get_node("AnimationPlayer").play("fade_out")


func _on_Islander_die():
	var islander = get_node("Objects/Props/Islander")
	$Experimenter.set_follow_target(islander, true)
	$Experimenter.disable_controls()
	is_islander_dead = true
	get_node("HUDLayer/HUD/DialogueManager").stop()
	get_node("HUDLayer/HUD/GameOver").start()
