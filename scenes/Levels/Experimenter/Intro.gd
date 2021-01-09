extends Control

signal finish_scene(player_name)

var player_name = ""

func _ready():
	get_node("MainDialogue/1").start()


func _on_Dialogue1_finish_dialogue():
	get_node("Name Entry").visible = true


func _on_Name_Entry_text_entered(text: String):
	get_node("Name Entry").visible = false
	player_name = text.strip_edges()
	if len(player_name) == 0:
		get_node("NamelessDialogue/1").start()
	else:
		get_node("MainDialogue/2").set_variables({
			"player_name": player_name
		})
		get_node("MainDialogue/2").start()


func _on_NamelessDialogue_1_finish_dialogue():
	_finish_scene()


func _on_MainDialogue_2_finish_dialogue():
	_finish_scene()


func _finish_scene():
	emit_signal("finish_scene", player_name)

