extends Node

signal finish_scenes


var DEFAULT_SAVE_DATA = {
	"player_name": "test"
}

var save_data
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

func load_scene(scene_name, _save_data = null):
	if _save_data != null:
		save_data = _save_data

	var scene_placeholder = get_node(scene_name)
	scene_placeholder.replace_by_instance()
	get_node(scene_name).set_player_name(save_data.player_name)
	get_node(scene_name).connect("finish_scene", self, "_on_" + scene_name + "finish_scene")

func load_intro():
	print("loading intro scene")
	var scene_placeholder = get_node("Intro")
	scene_placeholder.replace_by_instance()
	get_node("Intro").connect("finish_scene", self, "_on_Intro_finish_scene")


func _on_Intro_finish_scene(_player_name):
	save_data.player_name = _player_name
	
	save_game("Day1")
	load_scene("Day1")


func _on_Day1_finish_scene(experiment_data):
	var save_file = File.new()
	save_file.open(constants.SAVE_FILE_LOCATION, File.WRITE)
	
	save_data["current_chapter"] = "Islander"
	save_data["current_level"] = "Day1"
	
	save_data["Day1"] = experiment_data
	
	save_file.store_string(to_json(save_data))
	emit_signal("finish_scenes", save_data)
	
#	load_scene("Night1")
	#save_game("Night1", "Day1", experiment_data)


func _on_Night1_finish_scene():
	save_game("Day1")
	load_scene("Day2")
	
	
func _on_Day2_finish_scene():
	print("TODO: On finish day 2 scene")
