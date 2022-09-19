extends Node

signal load_initial_data(save_data)

var DEFAULT_SAVE_DATA = {
	"current_chapter": "Experimenter",
	"current_level":"Intro",
	"current_attempt": 1,
	"volume": {
		"0": 0.5,
		"1": 0.5,
		"2": 0.5
	},
	"is_fullscreen": true
}
var constants

var save_data


# Called when the node enters the scene tree for the first time.
func _ready():
	constants = preload("res://scripts/constants.gd").new()
	var save_file = File.new()
	if save_file.file_exists(constants.SAVE_FILE_LOCATION):
		save_file.open(constants.SAVE_FILE_LOCATION, File.READ)
		save_data = parse_json(save_file.get_as_text())
		save_file.close()
	else:
		save_data = DEFAULT_SAVE_DATA
	emit_signal("load_initial_data", save_data)


func get_save_data():
	return save_data


func save_game(level_name, chapter_name, new_experiment_data = null, experiment_level_name = null):
	save_data["current_level"] = level_name
	save_data["current_chapter"] = chapter_name
	if experiment_level_name != null:
		save_data[experiment_level_name] = new_experiment_data
	save_data["current_attempt"] = 1
	
	
	var save_file = File.new()
	save_file.open(constants.SAVE_FILE_LOCATION, File.WRITE)
	save_file.store_string(to_json(save_data))
	save_file.close()

func save_attempt_number(new_number):
	save_data["current_attempt"] = new_number
	var save_file = File.new()
	save_file.open(constants.SAVE_FILE_LOCATION, File.WRITE)
	save_file.store_string(to_json(save_data))
	save_file.close()


func _on_Settings_change_volume(index, amount):
	save_data["volume"][str(index)] = amount
	var save_file = File.new()
	save_file.open(constants.SAVE_FILE_LOCATION, File.WRITE)
	save_file.store_string(to_json(save_data))
	save_file.close()


func _on_Settings_set_fullscreen(new_value):
	save_data["is_fullscreen"] = new_value
	var save_file = File.new()
	save_file.open(constants.SAVE_FILE_LOCATION, File.WRITE)
	save_file.store_string(to_json(save_data))
	save_file.close()



func _on_IslanderScenes_save_game(level_name, chapter_name):
	save_game(level_name, chapter_name)


func _on_ExperimenterScenes_save_game(level_name, chapter_name, new_experiment_data, experiment_level_name):
	save_game(level_name, chapter_name, new_experiment_data, experiment_level_name)


func _on_ExperimenterScenes_scene_loaded(_scene, current_attempt):
	save_attempt_number(current_attempt)


func _on_IslanderScenes_scene_loaded(_scene, current_attempt):
	save_attempt_number(current_attempt)
