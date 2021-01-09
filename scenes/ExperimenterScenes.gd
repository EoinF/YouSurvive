extends Node

var player_name: String = "test"

func load_intro():
	var scene_placeholder = get_node("Intro")
	scene_placeholder.replace_by_instance()
	get_node("Intro").connect("finish_scene", self, "_on_Intro_finish_scene")


func load_day1():
	var scene_placeholder = get_node("Day1")
	scene_placeholder.replace_by_instance()
	get_node("Day1").set_player_name(player_name)
	get_node("Day1").connect("finish_scene", self, "_on_Day1_finish_scene")

func _on_Intro_finish_scene(_player_name):
	player_name = _player_name
	
	print("on intro finish scene", player_name)
	
	load_day1()
	get_node("Intro").queue_free()
	
