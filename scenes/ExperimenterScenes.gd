extends Node

signal finish_scenes


var DEFAULT_SAVE_DATA = {
	"player_name": "test"
}

var save_data = DEFAULT_SAVE_DATA
var constants

func _ready():
	constants = preload("res://scripts/constants.gd").new()


func save_game(current_level, experiment_level = null, new_experiment_data = null):
	var save_file = File.new()
	save_file.open(constants.SAVE_FILE_LOCATION, File.WRITE)
	
	save_data["current_chapter"] = "Experimenter"
	save_data["current_level"] = current_level
	
	if new_experiment_data != null and experiment_level != null:
		save_data[experiment_level] = new_experiment_data
	
	save_file.store_string(to_json(save_data))
	save_file.close()


func load_scene(scene_name, _save_data = null):
	if _save_data != null:
		save_data = _save_data

	var scene_placeholder = get_node(scene_name)
	scene_placeholder.replace_by_instance()
	
	get_node(scene_name).set_player_name(save_data.player_name)
	print("starting experimenter scene " + "_on_" + scene_name + "finish_scene")
	get_node(scene_name).connect("finish_scene", self, "_on_" + scene_name + "_finish_scene")


func load_intro():
	var scene_placeholder = get_node("Intro")
	scene_placeholder.replace_by_instance()
	get_node("Intro").connect("finish_scene", self, "_on_Intro_finish_scene")


func _on_Intro_finish_scene(_player_name):
	save_data.player_name = _player_name
	
	save_game("Day1")
	load_scene("Day1")


func _on_Day1_finish_scene(experiment_data):
	save_game("Night1", "Day1", experiment_data)
	load_scene("Night1")


func _on_Night1_finish_scene():
	save_game("Day2")
	load_scene("Day2")
	
	
func _on_Day2_finish_scene(experiment_data):
	save_game("Night2", "Day2", experiment_data)
	load_scene("Night2")


func _on_Night2_finish_scene():
	save_game("Day3")
	load_scene("Day3")


func _on_Day3_finish_scene(experiment_data):
	save_game("Outro", "Day3", experiment_data)
	load_scene("Outro")
