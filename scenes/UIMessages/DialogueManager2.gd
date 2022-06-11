extends Control

signal finish_dialogue(section_name)
signal trigger_event(event_name)

var final_text
var current_length

var config = {
	"letter_delay": 0.01,
	"x_pct": 0.5,
	"y_pct": 0.5,
	"foreground": "default",
	"background": "default"
}

var section_name
var node_index

var variables: Dictionary
var is_playing = true
var is_started = false

var FOREGROUND_MAP = {
	"default": Color("#09c691"),
	"pink": Color("#da2c6d")
}

var BACKGROUND_MAP = {
	"default": Color("#e31d1d1d"),
	"black": Color.black
}

export(String, FILE, "*.json") var DIALOGUE_FILE
var data

# Called when the node enters the scene tree for the first time.
func _ready():
	assert(DIALOGUE_FILE != "", "Error: No dialogue file selected!")
		
	var file = File.new()
	file.open(DIALOGUE_FILE, File.READ)
	data = parse_json(file.get_as_text())



func _process(_delta):
	if is_started and Input.is_action_just_released("skip_dialogue"):
		_on_Button_pressed()


func start_section(_section_name):
	self.section_name = _section_name
	current_length = 0
	final_text = ""
	node_index = -1
	is_playing = true
	is_started = true
	visible = true
	_next_node()


func stop():
	visible = false
	is_playing = false
	is_started = false
	get_node("LetterTimer").stop()
	
	

func set_variables(_variables: Dictionary):
	variables = _variables


func _apply_variables(text):
	return text.format(variables)


func _next_node():
	node_index += 1
		
	if node_index >= len(data[section_name]):
		visible = false
		emit_signal("finish_dialogue", section_name)
	else:
		var current_node = data[section_name][node_index]
		
		if current_node["type"] == "config":
			if "x" in current_node:
				config["x_pct"] = current_node["x"]
			if "y" in current_node:
				config["y_pct"] = current_node["y"]
			if "foreground" in current_node:
				config["foreground"] = current_node["foreground"]
			if "background" in current_node:
				config["background"] = current_node["background"]
			if "node_delay" in current_node:
				config["node_delay"] = current_node["node_delay"]
			if "letter_delay" in current_node:
				config["letter_delay"] = current_node["letter_delay"]
				var letter_timer = get_node("LetterTimer")
				letter_timer.set_wait_time(config["letter_delay"])
			_next_node()
		elif current_node["type"] == "text":
			current_length = 0
			final_text = _apply_variables(current_node["content"])
			
			var label = get_node("Button/LabelContainer/Label")
			label.modulate = FOREGROUND_MAP[config["foreground"]]
			var text_area = label.get_font("normal_font").get_string_size(final_text)
			var background = get_node("Button/LabelContainer")
			background.color = BACKGROUND_MAP[config["background"]]

			var button = get_node("Button")
			button.rect_size.x = text_area.x + 40
			button.rect_position.x = (rect_size.x - background.rect_size.x) * config["x_pct"]
			button.rect_position.y = (rect_size.y - background.rect_size.y) * config["y_pct"]
			
			label.text = ""
			var letter_timer = get_node("LetterTimer")
			letter_timer.start()
		elif current_node["type"] == "link_to":
			start_section(current_node["section_name"])
		elif current_node["type"] == "event":
			emit_signal("trigger_event", current_node["event_name"])
			_next_node()
		else:
			push_error("Unknown node type %s" % [current_node["type"]])


func _on_LetterTimer_timeout():
	if (current_length < len(final_text)):
		current_length += 1
		get_node("Button/LabelContainer/Label").text = final_text.substr(0, current_length)
	else:
		get_node("LetterTimer").stop()


func _on_Button_pressed():
	if visible:
		get_node("LetterTimer").stop()
		if current_length < len(final_text):
			current_length = len(final_text)
			get_node("Button/LabelContainer/Label").text = final_text
		else:
			_next_node()
