extends Control

signal finish_dialogue

var final_text
var current_length
var next_wait_time

var children
var node_index

var variables: Dictionary


func start():
	visible = true
	children = get_children()
	current_length = 0
	final_text = ""
	node_index = -1
	_next_node()
	
func set_variables(_variables: Dictionary):
	variables = _variables
	
func _apply_variables(text):
	return text.format(variables)
	
func _next_node():
	node_index += 1
	while(node_index < len(children) and !children[node_index].is_in_group("Dialogue")):
		node_index += 1
		
	if node_index >= len(children):
		visible = false
		emit_signal("finish_dialogue")
	else:
		var current_node = children[node_index]
		current_length = 0
		final_text = _apply_variables(current_node.MESSAGE)
		next_wait_time = current_node.NEXT_NODE_DELAY
		
		var label = get_node("LabelContainer/Label")
		label.text = ""
		label.modulate = current_node.TEXT_COLOUR
		var text_area = label.get_font("normal_font").get_string_size(final_text)
		var background = get_node("LabelContainer")
		background.color = current_node.BACKGROUND_COLOUR
		background.rect_size.x = text_area.x + 40
		
		background.rect_position.x = (rect_size.x - background.rect_size.x) * current_node.X_POSITION_PERCENT
		background.rect_position.y = (rect_size.y - background.rect_size.y) * current_node.Y_POSITION_PERCENT
		
		get_node("LetterTimer").start()


func _on_LetterTimer_timeout():
	if (current_length < len(final_text)):
		current_length += 1
		get_node("LabelContainer/Label").text = final_text.substr(0, current_length)
	else:
		get_node("LetterTimer").stop()
		var next_node_timer = get_node("NextNodeTimer")
		next_node_timer.wait_time = next_wait_time
		next_node_timer.start()


func _on_NextNodeTimer_timeout():
	_next_node()
