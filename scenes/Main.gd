extends Node

var active_scene: Node

var constants

var RESOLUTIONS = [
	Vector2(950, 560),
	Vector2(1900, 1080),
	Vector2(2850, 1640),
	Vector2(3800, 2160),
]

onready var viewport = get_viewport()

func _ready():
	constants = preload("res://scripts/constants.gd").new()
# warning-ignore:return_value_discarded
	get_tree().connect("screen_resized", self, "_screen_resized")
	var save_data = SaveManager.save_data
	if save_data["current_chapter"] == "Islander":
		$MainMenu.darken()


func _screen_resized():
	var window_size = OS.get_real_window_size()
	
	var highest_resolution = RESOLUTIONS[0]
	for resolution in RESOLUTIONS.slice(1, len(RESOLUTIONS) - 1):
		if resolution.x <= window_size.x and resolution.y <= window_size.y:
			highest_resolution = resolution
	
	var viewport_offset = (OS.window_size - highest_resolution) / 2
	viewport.set_attach_to_screen_rect(Rect2(viewport_offset, highest_resolution))


func _process(_delta):
	var is_pause_pressed = Input.is_action_just_pressed("toggle_pause")
	if is_pause_pressed and not $MainMenu.is_active:
		pause_game()


func pause_game():
	var is_paused = self.get_tree().paused
	self.get_tree().paused = not is_paused
	
	if is_paused:
		$PauseMenu.hide()
	else:
		$PauseMenu.show()


func _on_ExperimenterScenes_finish_scenes():
	$MainMenu.show()
	$MainMenu.remove_new_game()
	$MainMenu.darken()
	active_scene.queue_free()
	active_scene = null


func _on_IslanderScenes_finish_scenes():
	$MainMenu.show()
	$MainMenu.remove_new_game()
	active_scene.queue_free()
	active_scene = null


func _on_MainMenu_continue_game():
	var save_data = get_node("/root").save_data
	var chapter_scenes
	if save_data["current_chapter"] == "Experimenter":
		chapter_scenes = get_node("ExperimenterScenes")
	else:
		chapter_scenes = get_node("IslanderScenes")
	
	chapter_scenes.set_save_data(save_data)
	chapter_scenes.load_scene(save_data["current_level"], save_data["current_attempt"])
	$MainMenu.hide()


func _on_MainMenu_start_credits():
	$MainMenu/Credits.show()


func _on_Credits_finish_scene():
	$MainMenu/Credits.hide()


func _on_MainMenu_start_settings():
	$MainMenu/Settings.show()


func _on_Settings_finish_scene():
	$MainMenu/Settings.hide()


func _on_PauseMenu_main_menu_pressed():
	get_tree().paused = false
	$PauseMenu.hide()
	$MainMenu.show()
	active_scene.queue_free()
	active_scene = null


func _on_PauseMenu_resume_pressed():
	get_tree().paused = false
	$PauseMenu.hide()


func _on_ExperimenterScenes_scene_loaded(scene, _attempt_number):
	active_scene = scene


func _on_IslanderScenes_scene_loaded(scene, _attempt_number):
	active_scene = scene
