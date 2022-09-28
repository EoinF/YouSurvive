extends Control


func set_objectives(_objectives: Array):
	var amount_visible = 0
	# Temporarily hide to trigger automatic resizing
	self.visible = false
	
	for index in _objectives.size():
		if _objectives[index].is_visible:
			amount_visible += 1
		var label = get_node("MarginContainer/GridContainer/" + str(index + 1))
		label.set_objective_display(label, _objectives[index])
			
	self.visible = amount_visible > 0
