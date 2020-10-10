extends Node


func _on_MainMenu_start_new_game():
	var scene = load("res:///scenes/Island/Island.tscn")
	add_child(scene.instance())
	
	remove_child(get_node("MainMenu"))
