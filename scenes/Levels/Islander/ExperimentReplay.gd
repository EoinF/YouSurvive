extends Node

signal place_item(_item_type, _location)

var experiment_data: Array

var current_time = 0.0
var current_action = null

func _process(delta):
	current_time += delta
	
	if current_action != null:
		if current_action["current_time"] < current_time:
			trigger_next_action()


func trigger_next_action():
	if current_action != null:
		var location = Vector2(current_action["location"].x, current_action["location"].y)
		call_deferred("emit_signal", "place_item", current_action["item_type"], location)
		experiment_data.pop_front()
		if len(experiment_data) > 0:
			current_action = experiment_data[0]
		else:
			current_action = null


func set_experiment_data(_experiment_data):
	experiment_data = _experiment_data
	if len(experiment_data) > 0:
		current_action = experiment_data[0]


func is_finished():
	return experiment_data.empty()
