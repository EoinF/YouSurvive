extends Node

signal finish_scenes
signal scene_loaded(scene, current_attempt)
signal save_game(level_name, chapter_name, new_experiment_data, experiment_level_name)

var BASE_PATH = "res://scenes/Levels/Experimenter/"

var save_data


func save_game(level_name, experiment_level_name = null, new_experiment_data = null, chapter_name = "Experimenter"):
	emit_signal("save_game", level_name, chapter_name, new_experiment_data, experiment_level_name)


func reload_scene(scene_name, current_attempt):
	get_node(scene_name).free()
	load_scene(scene_name, current_attempt)


func load_scene(scene_name, current_attempt = 1):
	var new_scene = _instance_scene(scene_name)
	
	if new_scene.has_method("set_player_name"):
		new_scene.set_player_name(save_data.player_name)
	new_scene.set_attempt_number(current_attempt)

	new_scene.connect("finish_scene", self, "_on_" + scene_name + "_finish_scene")
	new_scene.connect("restart_scene", self, "reload_scene", [scene_name, current_attempt + 1], CONNECT_DEFERRED)
	emit_signal("scene_loaded", new_scene, current_attempt)


func load_intro():
	var scene_placeholder = get_node("Intro")
	scene_placeholder.replace_by_instance()
# warning-ignore:return_value_discarded
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
	save_game("Night3", "Day3", experiment_data)
	load_scene("Night3")


func _on_Night3_finish_scene():
	save_game("Day4")
	load_scene("Day4")


func _on_Day4_finish_scene(experiment_data):
	save_game("Day1", "Day4", experiment_data, "Islander")
	emit_signal("finish_scenes")


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
