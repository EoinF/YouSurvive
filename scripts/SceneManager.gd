extends Node

var constants

var RESOLUTIONS = [
	Vector2(950, 560),
	Vector2(1900, 1080),
	Vector2(2850, 1640),
	Vector2(3800, 2160),
]

onready var viewport = get_viewport()

var current_scene = null
var current_attempt = 0

var scenes_order = {
	"Experimenter": 
		["Intro", "Day1", "Night1", "Day2", "Night2", "Day3", "Night3", "Day4"],
	"Islander": 
		["Day1", "Day2", "Day3", "Day4"]
}
func _ready():
	constants = preload("res://scripts/constants.gd").new()
# warning-ignore:return_value_discarded
	get_tree().connect("screen_resized", self, "_screen_resized")
	
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)
	set_pause_mode(Node.PAUSE_MODE_PROCESS)


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
	if is_pause_pressed and current_scene.get_name() != "MainMenu":
		pause_game()


func pause_game():
	var is_paused = self.get_tree().paused
	self.get_tree().paused = not is_paused
	
	if is_paused:
		PauseMenu.hide()
	else:
		PauseMenu.show()


func load_main_menu():
	call_deferred("load_scene", "res://scenes/MainMenu/MainMenu.tscn")


func load_scene(path):
	# It is now safe to remove the current scene
	current_scene.free()

	# Load the new scene.
	var s = ResourceLoader.load(path)

	# Instance the new scene.
	current_scene = s.instance()

	# Add it to the active scene, as child of root.
	get_tree().root.add_child(current_scene)

	# Optionally, to make it compatible with the SceneTree.change_scene() API.
	get_tree().current_scene = current_scene


func get_scene_path(current_chapter, current_level):
	return "res://scenes/Levels/%s/%s/%s.tscn" % \
	 	[current_chapter, current_level, current_level]


func continue_game():
	var save_data = SaveManager.save_data
	
	var scene_path = get_scene_path(save_data["current_chapter"],save_data["current_level"])
	current_attempt = save_data["current_attempt"]
	call_deferred("load_scene", scene_path)


func load_next_level(experiment_data=null):
	var save_data = SaveManager.save_data
	var current_chapter = save_data["current_chapter"]
	var current_level = save_data["current_level"]
	var current_level_index = scenes_order[current_chapter]\
		.find(current_level)
		
	var next_chapter = current_chapter
	
	if (current_level_index == scenes_order[next_chapter].size() - 1):
		current_level_index = 0
		next_chapter = "Islander" if next_chapter == "Experimenter" else "Experimenter"
	else:
		current_level_index += 1
	
	var next_level = scenes_order[next_chapter][current_level_index]
	var scene_path = get_scene_path(next_chapter, next_level)
	
	SaveManager.save_game(next_level, next_chapter, experiment_data, current_level)
	
	if next_chapter != current_chapter:
		load_main_menu()
		return
	call_deferred("load_scene", scene_path)


func restart_level():
	current_attempt += 1
	SaveManager.save_attempt_number(current_attempt)
	continue_game()
	
