extends Node2D

var is_collect_coconuts_complete = false
var enemies_score = 0


var hard_score_breakpoint = 70

var score_map = {
	"crab": 2,
	"boar": 3,
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


func _ready():
	get_node("HUDLayer/HUD/DialogueManager").start_section("Intro")
	#_fade_in()


func _fade_in():
	var animation_player = get_node("AnimationPlayer")
	animation_player.play("fade")


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "fade":
		get_node("HUDLayer/HUD/DialogueManager").start_section("Intro")


func _on_DialogueManager_finish_dialogue(section_name):
	if section_name == "Outro":
		var experiment_data = get_node("Experimenter").get_experiment_data()
		emit_signal("finish_scene", experiment_data)
		queue_free()


func _on_Day3Objectives_objectives_updated(objectives):
	if not is_collect_coconuts_complete and objectives[0].is_complete:
		is_collect_coconuts_complete = true
		get_node("HUDLayer/HUD/DialogueManager").start_section("Coconuts collected")
		
	if objectives[0].is_complete and objectives[1].is_complete:
		if calculate_score() >= hard_score_breakpoint:
			get_node("HUDLayer/HUD/DialogueManager").start_section("Complete - Hard")
		else:
			get_node("HUDLayer/HUD/DialogueManager").start_section("Complete - Easy")


func _on_Experimenter_place_item(item_type, _source_location):
	if item_type in score_map:
		enemies_score += score_map[item_type]
