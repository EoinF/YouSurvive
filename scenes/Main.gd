extends Node

var active_scene


func _process(delta):
	var pause_pressed = Input.is_action_just_pressed("toggle_pause")
	if not pause_pressed or $MainMenu.is_active:
		return
		
	var is_paused = self.get_tree().paused
	self.get_tree().paused = not is_paused
	
	if is_paused:
		$PauseMenu.hide()
	else:
		$PauseMenu.show()


func _on_ExperimenterScenes_finish_scenes():
	$MainMenu.show()
	$MainMenu.remove_new_game()
	active_scene.queue_free()
	active_scene = null


func _on_IslanderScenes_finish_scenes():
	get_node("ExperimenterScenes").load_intro()


func _on_MainMenu_continue_game(save_data):
	var chapter_scenes
	if save_data["current_chapter"] == "Experimenter":
		chapter_scenes = get_node("ExperimenterScenes")
	else:
		chapter_scenes = get_node("IslanderScenes")
	
	chapter_scenes.load_scene(save_data["current_level"], save_data)
	$MainMenu.hide()


func _on_MainMenu_start_credits():
	get_node("MainMenu/Credits").visible = true


func _on_Credits_finish_scene():
	get_node("MainMenu/Credits").visible = false


func _on_MainMenu_start_settings():
	$MainMenu/Settings.visible = true


func _on_Settings_finish_scene():
	get_node("MainMenu/Settings").visible = false


func _on_PauseMenu_main_menu_pressed():
	get_tree().paused = false
	$PauseMenu.hide()
	$MainMenu.show()
	active_scene.queue_free()
	active_scene = null


func _on_PauseMenu_resume_pressed():
	get_tree().paused = false
	$PauseMenu.hide()


func _on_IslanderScenes_set_active_scene(scene):
	active_scene = scene


func _on_ExperimenterScenes_set_active_scene(scene):
	active_scene = scene


func _on_MainMenu_on_load_save_data(save_data):
	$MainMenu/Settings.set_data(save_data)
