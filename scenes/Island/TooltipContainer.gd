extends Control


func activate(text, x, y):
	var tooltip = get_node("Background/Tooltip")
	tooltip.text = text
	var text_area = tooltip.get_font("normal_font").get_string_size(tooltip.text)
	var background = get_node("Background")
	background.rect_size.x = text_area.x + 10
	visible = true
	rect_position.x = x
	rect_position.y = y
