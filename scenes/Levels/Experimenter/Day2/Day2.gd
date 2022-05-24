extends Node2D


func set_player_name(player_name):
	get_node("HUDLayer/HUD/DialogueManager").set_variables({
		"player_name": player_name
	})


func _ready():
	get_node("AIController").disable_ai()
	get_node("HUDLayer/HUD/DialogueManager").start_section("Intro")
#	_fade_in()


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


func _on_Day2Objectives_objectives_updated(objectives):
	var dialogue_manager = get_node("HUDLayer/HUD/DialogueManager")
	
	if not is_predator_placement_complete \
	and objectives[0].is_complete and objectives[0].is_visible:
		dialogue_manager.start_section("Main1 (After 15 placed)")
		is_predator_placement_complete = true

	if not is_weapon_placement_complete \
	and objectives[1].is_complete and objectives[1].is_visible:
		dialogue_manager.start_section("Main2 (After weapon placed)")
		is_weapon_placement_complete = true

	if not is_kill_predators_complete \
	and objectives[2].is_complete and objectives[2].is_visible \
	and objectives[3].is_complete and objectives[3].is_visible \
	and objectives[4].is_complete and objectives[4].is_visible:
		if enemies_score < SCORE_THRESHOLD:
			dialogue_manager.start_section("Complete - Easy")
		else:
			dialogue_manager.start_section("Complete - Hard")
		is_kill_predators_complete = true


func _on_Experimenter_place_item(item_type, _source_location):
	if item_type in score_map:
		enemies_score += score_map[item_type]
