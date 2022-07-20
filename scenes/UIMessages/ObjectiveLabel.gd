extends Label

func set_objective_display(objective_node, objective):
	visible = objective["is_visible"]
	modulate = Color.green if objective["is_complete"] else Color.white
	text = "- " + objective["description"]
