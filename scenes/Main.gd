extends Node


func _load_from_placeholder(node_path):
	var scene_placeholder = get_node(node_path)
	scene_placeholder.replace_by_instance()

func _on_MainMenu_start_new_game():
	_load_from_placeholder("ExperimenterScenes/Day1")
	remove_child(get_node("MainMenu"))


func _on_MainMenu_start_intro():
	_load_from_placeholder("ExperimenterScenes/Intro")
	remove_child(get_node("MainMenu"))
