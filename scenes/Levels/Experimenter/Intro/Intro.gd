extends Control

signal finish_scene(player_name)

var player_name = ""

func _ready():
	get_node("DialogueManager").start_section("Main1")


func set_attempt_number(_attempt_number):
	pass
	

func _on_DialogueManager_finish_dialogue(section_name):
	if section_name == "Main1":
		get_node("Name Entry").visible = true
	elif section_name == "Outro":
		emit_signal("finish_scene", player_name)
		queue_free()


func _on_Name_Entry_text_entered(text: String):
	get_node("Name Entry").visible = false
	var manager = get_node("DialogueManager")
	player_name = text.strip_edges()
	if len(player_name) == 0:
		player_name = "nameless one"
		manager.start_section("Nameless")
	else:
		manager.set_variables({
			"player_name": player_name
		})
		manager.start_section("Named")


