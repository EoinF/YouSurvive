extends Node


func _on_MainMenu_start_new_game():
	get_node("ExperimenterScenes").load_scene("Day1")
	remove_child(get_node("MainMenu"))


func _on_MainMenu_start_intro():
	get_node("ExperimenterScenes").load_intro()
	remove_child(get_node("MainMenu"))


func _on_ExperimenterScenes_finish_scenes(save_data):
	get_node("IslanderScenes").load_scene("Day1", save_data)


func _on_IslanderScenes_finish_scenes():
	get_node("ExperimenterScenes").load_intro()


func _on_MainMenu_continue_game(save_data):
	var chapter_scenes
	if save_data["current_chapter"] == "Experimenter":
		chapter_scenes = get_node("ExperimenterScenes")
	else:
		chapter_scenes = get_node("IslanderScenes")
	
	chapter_scenes.load_scene(save_data["current_level"], save_data)

	remove_child(get_node("MainMenu"))
