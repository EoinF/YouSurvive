extends Node


func _on_ExperimenterScenes_finish_scenes(save_data):
	var islander_scenes = get_node("IslanderScenes")
	islander_scenes.save_game("Day1")
	islander_scenes.load_scene("Day1", save_data)


func _on_IslanderScenes_finish_scenes():
	get_node("ExperimenterScenes").load_intro()


func _on_MainMenu_continue_game(save_data):
	var chapter_scenes
	if save_data["current_chapter"] == "Experimenter":
		chapter_scenes = get_node("ExperimenterScenes")
	else:
		chapter_scenes = get_node("IslanderScenes")
	
	chapter_scenes.load_scene(save_data["current_level"], save_data)


func _on_MainMenu_start_credits():
	get_node("MainMenu/Credits").visible = true


func _on_Credits_finish_scene():
	get_node("MainMenu/Credits").visible = false


func _on_MainMenu_start_settings():
	get_node("MainMenu/Settings").visible = true


func _on_Settings_finish_scene():
	get_node("MainMenu/Settings").visible = false
