extends Node

signal finish_scenes

func load_day1(save_data):
	var scene_placeholder = get_node("Day1")
	scene_placeholder.replace_by_instance()
	get_node("Day1").connect("finish_scene", self, "_on_Day1_finish_scene")
	get_node("Day1").set_experiment_data(save_data["Day1"])

func _on_Day1_finish_scene():
	print("on islander day1 finish scene")
	
	emit_signal("finish_scenes")

