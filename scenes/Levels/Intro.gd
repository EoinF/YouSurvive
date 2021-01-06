extends Control

var player_name = ""

func _ready():
	get_node("Dialogue1").start()


func _on_Dialogue1_finish_dialogue():
	get_node("Name Entry").visible = true


func _on_Name_Entry_text_entered(text):
	player_name = text
	get_node("Name Entry").visible = false
	get_node("Dialogue2").set_variables({
		"player_name": player_name
	})
	get_node("Dialogue2").start()
