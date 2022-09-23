extends Node

signal finish_scenes
signal scene_loaded(scene, current_attempt)
signal save_game(level_name, chapter_name)

var save_data
var constants

var BASE_PATH = "res://scenes/Levels/Islander/"


func _ready():
	constants = preload("res://scripts/constants.gd").new()


func save_game(level_name, chapter_name = "Islander"):
	emit_signal("save_game", level_name, chapter_name)


func _on_Day1_finish_scene():
	save_game("Day2")
	load_scene("Day2")
	
	
func _on_Day2_finish_scene():
	save_game("Day3")
	load_scene("Day3")

	
func _on_Day3_finish_scene():
	save_game("Day4")
	load_scene("Day4")


func _on_Day4_finish_scene():
	save_game("Intro", "Experimenter")
	emit_signal("finish_scenes")


func load_scene(scene_name, current_attempt = 1):
	var new_scene = _instance_scene(scene_name)
	
	new_scene.set_experiment_data(save_data[scene_name])
	new_scene.set_attempt_number(current_attempt)
	
	new_scene.connect("finish_scene", self, "_on_" + scene_name + "_finish_scene")
	new_scene.connect("restart_scene", self, "load_scene", [scene_name, current_attempt + 1])
	emit_signal("scene_loaded", new_scene, current_attempt)


func _instance_scene(scene_name):
	if not has_node(scene_name):
		var scene_file = load(BASE_PATH + scene_name + "/" + scene_name + ".tscn")
		var scene = scene_file.instance()
		add_child(scene)
		return scene
		
	var scene_placeholder = get_node(scene_name)
	scene_placeholder.replace_by_instance()
	return get_node(scene_name)


func set_save_data(_save_data):
	save_data = _save_data
