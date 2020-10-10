extends Node2D


func activate(text, x, y):
	var tooltip = get_node("Tooltip")
	tooltip.text = text
	var text_area = tooltip.get_font("normal_font").get_string_size(tooltip.text)
	var background = get_node("Background")
	background.scale.x = text_area.x + 10
	visible = true
	position.x = x
	position.y = y
	
	background.position.x = background.scale.x / 2
	background.position.y = background.scale.y / 2
