extends Control

var is_first_time = true

func set_objectives(_objectives: Array):
	for index in _objectives.size():
		if is_first_time:
			visible = true
			var new_node = Label.new()
			new_node.set_name(str(index + 1))
			get_node("MarginContainer/GridContainer").call_deferred("add_child", new_node)
			_set_objective_display(new_node, _objectives[index])
		else:
			var label = get_node("MarginContainer/GridContainer/" + str(index + 1))
			for child in get_node("MarginContainer/GridContainer").get_children():
				print (child.get_name())
			print(label)
			_set_objective_display(label, _objectives[index])
	is_first_time = false

func _set_objective_display(objective_node, objective):
	objective_node.visible = objective["is_visible"]
	objective_node.modulate = Color.green if objective["is_complete"] else Color.white
	objective_node.text = "- " + objective["description"]
