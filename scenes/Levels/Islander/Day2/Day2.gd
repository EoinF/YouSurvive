extends Node2D

signal finish_scene
signal place_item(_item_type, _location)

var experiment_data
var current_time = 0.0
var current_action = null

func _ready():
	get_node("Day2Objectives").set_objective_active("place_weapon", true)
	get_node("Day2Objectives").set_objective_active("place_predators", true)
	get_node("AIController").enable_ai()
	
	# Run this only if scene is run standalone
	if get_owner() == null:
		var test_file = File.new()
		
		test_file.open("utils/test_data.json", File.READ)
		var test_data = parse_json(test_file.get_as_text())
		test_file.close()
		set_experiment_data(test_data["Day2"])


func set_experiment_data(_data):
	get_node("ExperimentReplay").set_experiment_data(_data)


func _on_Day2Objectives_objectives_updated(objectives):
	# wait for objectives to be visible first, 
	# otherwise this will retrigger in groups of 3.
	# This is left as an example of how not to use signals in Godot.
	# the objectives should ideally be initialised in one go to avoid
	# triggering multiple events at once.
	var objectives_ready = objectives[0]["is_visible"] and objectives[1]["is_visible"]
	if objectives_ready and (not objectives[0]["is_complete"] or not objectives[1]["is_complete"]):
		get_node("ExperimentReplay").call_deferred("trigger_next_action")
