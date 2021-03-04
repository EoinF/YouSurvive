extends Node

signal finish_scenes

var save_data


func load_day1(save_data):
	var scene_placeholder = get_node("Day1")
	scene_placeholder.replace_by_instance()
	get_node("Day1").connect("finish_scene", self, "_on_Day1_finish_scene")

func _on_Day1_finish_scene():
	print("on islander day1 finish scene")
	
	emit_signal("finish_scenes")


func load_scene(scene_name, _save_data = null):
	if _save_data != null:
		save_data = _save_data

	var scene_placeholder = get_node(scene_name)
	scene_placeholder.replace_by_instance()
	get_node(scene_name).connect("finish_scene", self, "_on_" + scene_name + "finish_scene")
	get_node(scene_name).set_experiment_data(save_data[scene_name])
