extends Control

var is_first_time = true

var objective_label_scene = preload("res://scenes/UIMessages/ObjectiveLabel.tscn")

func set_objectives(_objectives: Array):
	for index in _objectives.size():
		if is_first_time:
			visible = true
			var new_node = objective_label_scene.instance()
			new_node.set_name(str(index + 1))
			get_node("MarginContainer/GridContainer").add_child(new_node)
			new_node.set_objective_display(new_node, _objectives[index])
		else:
			var label = get_node("MarginContainer/GridContainer/" + str(index + 1))
			label.set_objective_display(label, _objectives[index])
	is_first_time = false
