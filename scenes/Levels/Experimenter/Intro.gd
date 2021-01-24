extends Control

signal finish_scene(player_name)

var player_name = ""

func _ready():
	get_node("MainDialogue1").start()


func _on_MainDialogue1_finish_dialogue():
	get_node("Name Entry").visible = true


func _on_Name_Entry_text_entered(text: String):
	get_node("Name Entry").visible = false
	player_name = text.strip_edges()
	if len(player_name) == 0:
		get_node("NamelessDialogue").start()
	else:
		get_node("NamedDialogue").set_variables({
			"player_name": player_name
		})
		get_node("NamedDialogue").start()


func _on_MainDialogue2_finish_dialogue():
	emit_signal("finish_scene", player_name)


func _on_NamelessDialogue_finish_dialogue():
	player_name = "nameless one"
	get_node("MainDialogue2").start()


func _on_NamedDialogue_finish_dialogue():
	get_node("MainDialogue2").start()
