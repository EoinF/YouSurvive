extends Node2D

signal finish_scene
signal place_item(_item_type, _location)

var experiment_data

var current_time = 0.0
var current_action = null

func _ready():
	# Run this only if scene is run standalone
	if get_owner() == null:
		var test_file = File.new()
		
		test_file.open("utils/test_data.json", File.READ)
		var test_data = parse_json(test_file.get_as_text())
		test_file.close()
		set_experiment_data(test_data["Day1"])

func _process(delta):
	current_time += delta
	
	if current_action != null:
		if current_action["current_time"] < current_time:
	#		if experiment_data[0]["action_type"] == "place_item":
			var location = Vector2(current_action["location"].x, current_action["location"].y)
			emit_signal("place_item", current_action["item_type"], location)
			experiment_data.pop_front()
			if len(experiment_data) > 0:
				current_action = experiment_data[0]
			else:
				current_action = null


func set_experiment_data(_experiment_data):
	experiment_data = _experiment_data
	if len(experiment_data) > 0:
		current_action = experiment_data[0]


func _on_Day1Objectives_objectives_updated(objectives):
	var is_complete = true
	for objective in objectives:
		if not objective["is_complete"]:
			is_complete = false
			break
	
	if is_complete:
		emit_signal("finish_scene")
		queue_free()
