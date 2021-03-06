extends Control

signal finish_dialogue

var final_text
var current_length
var next_wait_time

var children
var node_index

var variables: Dictionary


func start():
	children = get_children()
	current_length = 0
	final_text = ""
	node_index = -1
	_next_node()


func set_variables(_variables: Dictionary):
	variables = _variables


func _apply_variables(text):
	return text.format(variables)


func _is_active_dialogue_node(node):
	return (
		(node.is_in_group("Dialogue") or node.is_in_group("Event"))
		and not node.DISABLED
	)


func _next_node():
	node_index += 1
	while (node_index < len(children)
		and not _is_active_dialogue_node(children[node_index])):
		node_index += 1
		
	visible = false
		
	if node_index >= len(children):
		emit_signal("finish_dialogue")
	else:
		var current_node = children[node_index]
		
		if current_node.is_in_group("Dialogue"):
			current_length = 0
			final_text = _apply_variables(current_node.MESSAGE)
			next_wait_time = current_node.NEXT_NODE_DELAY
			
			var label = get_node("Button/LabelContainer/Label")
			label.text = ""
			label.modulate = current_node.TEXT_COLOUR
			var text_area = label.get_font("normal_font").get_string_size(final_text)
			var background = get_node("Button/LabelContainer")
			background.color = current_node.BACKGROUND_COLOUR

			var button = get_node("Button")
			button.rect_size.x = text_area.x + 40
			button.rect_position.x = (rect_size.x - background.rect_size.x) * current_node.X_POSITION_PERCENT
			button.rect_position.y = (rect_size.y - background.rect_size.y) * current_node.Y_POSITION_PERCENT
			
			visible = true
			var letter_timer = get_node("LetterTimer")
			letter_timer.set_wait_time(current_node.NEXT_LETTER_DELAY)
			letter_timer.start()
		else:
			current_node.connect("finish_event", self, "_on_event_complete")
			next_wait_time = current_node.NEXT_NODE_DELAY
			current_node.trigger()


func _on_LetterTimer_timeout():
	if (current_length < len(final_text)):
		current_length += 1
		get_node("Button/LabelContainer/Label").text = final_text.substr(0, current_length)
	else:
		get_node("LetterTimer").stop()
		_start_next_node_timer()


func _on_event_complete():
	print("complete event")
	children[node_index].disconnect("finish_event", self, "_on_event_complete")
	_start_next_node_timer()


func _start_next_node_timer():
	var next_node_timer = get_node("NextNodeTimer")
	if next_wait_time > 0:
		next_node_timer.set_wait_time(next_wait_time)
		next_node_timer.start()
	else:
		_next_node()


func _on_NextNodeTimer_timeout():
	_next_node()


func _on_Button_pressed():
	print("button was pressed")
	if visible:
		get_node("NextNodeTimer").stop()
		_next_node()
