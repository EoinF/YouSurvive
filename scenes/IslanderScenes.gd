extends Node

signal finish_scenes

var save_data
var constants

func _ready():
	constants = preload("res://scripts/constants.gd").new()

func save_game(current_level):
	var save_file = File.new()
	save_file.open(constants.SAVE_FILE_LOCATION, File.WRITE)
	
	save_data["current_chapter"] = "Islander"
	save_data["current_level"] = current_level
	
	save_file.store_string(to_json(save_data))
	save_file.close()

func _on_Day1_finish_scene():
	save_game("Day2")
	load_scene("Day2")
	
	
func _on_Day2_finish_scene():
	save_game("Day3")
	load_scene("Day3")

	
func _on_Day3_finish_scene():
	save_game("Outro")
	load_scene("Outro")


func load_scene(scene_name, _save_data = null):
	if _save_data != null:
		save_data = _save_data

	var scene_placeholder = get_node(scene_name)
	scene_placeholder.replace_by_instance()
	get_node(scene_name).connect("finish_scene", self, "_on_" + scene_name + "_finish_scene")
	get_node(scene_name).set_experiment_data(save_data[scene_name])
