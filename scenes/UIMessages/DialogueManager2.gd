extends Control

signal finish_dialogue(section_name)
signal trigger_event(event_name)

var LABEL_MARGIN_X = 24

var highlight_info
var final_text
var current_length

var config = {
	"letter_delay": 0.01,
	"x_pct": 0.5,
	"y_pct": 0.5,
	"foreground": "default",
	"background": "default",
	"is_full_screen": false
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


func _on_DialogueManager_resized():
	if not config["is_full_screen"]:
		return
	
	$Button.rect_position = Vector2(0, 0)
	$Button.rect_size.x = self.rect_size.x
	$Button.rect_size.y = self.rect_size.y
	$Button/LabelContainer/Label.rect_size.x = self.rect_size.x
	$Button/LabelContainer/Label.rect_position.y = self.rect_size.y / 2


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


func _set_label_text(text: String):
	if highlight_info != null and highlight_info.begin < len(text):
		var opening_tag =  "[color=yellow][wave amp=20 freq=3]"
		var closing_tag = "[/wave][/color]"
		var before_highlight = text.substr(0, highlight_info.begin)
		var highlighted_text = text.substr(highlight_info.begin, highlight_info.end - highlight_info.begin)
		var after_highlight = text.substr(highlight_info.end)
		text = before_highlight + opening_tag + highlighted_text + closing_tag + after_highlight
	
	var flashing_cursor = ""
	if len(text) == len(final_text):
		flashing_cursor = "  [wave amp=15 freq=10]>[/wave]"
	$Button/LabelContainer/Label.bbcode_text = "[center]%s%s[/center]" % [text, flashing_cursor]

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
			if "is_full_screen" in current_node:
				config["is_full_screen"] = current_node["is_full_screen"]
				_on_DialogueManager_resized()
			_next_node()
		elif current_node["type"] == "text":
			current_length = 0
			final_text = _apply_variables(current_node["content"])
			
			if "highlight" in current_node:
				highlight_info = current_node["highlight"]
			else:
				highlight_info = null
				
			if "timeout" in current_node:
				$NodeTimer.start(current_node["timeout"])
			
			var label = get_node("Button/LabelContainer/Label")
			label.modulate = FOREGROUND_MAP[config["foreground"]]
			# Use the hidden label to calculate the text area
			# as the rich text label automatically wraps to new lines
			var text_area = $Button/LabelContainer/HiddenLabel.get_font("Regular").get_string_size(final_text + " ▼")
			var background = get_node("Button/LabelContainer")
			background.color = BACKGROUND_MAP[config["background"]]

			if not config["is_full_screen"]:
				var button = $Button
				label.rect_size.x = text_area.x + LABEL_MARGIN_X * 2
				button.rect_size.x = text_area.x + LABEL_MARGIN_X * 2
				button.rect_position.x = (rect_size.x - background.rect_size.x) * config["x_pct"]
				button.rect_position.y = (rect_size.y - background.rect_size.y) * config["y_pct"]
			
			label.bbcode_text = ""
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
		if final_text[current_length] != ' ':
			get_node("LetterSound").play()
		current_length += 1
		_set_label_text(final_text.substr(0, current_length))
	else:
		get_node("LetterTimer").stop()


func _on_Button_pressed():
	if not visible:
		return
	get_node("LetterTimer").stop()
	if current_length < len(final_text):
		current_length = len(final_text)
		_set_label_text(final_text)
	else:
		_next_node()


func _on_NodeTimer_timeout():
	get_node("LetterTimer").stop()
	_next_node()
