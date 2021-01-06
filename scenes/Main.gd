extends Node


func _on_MainMenu_start_new_game():
	var scene = load("res:///scenes/Levels/Day1.tscn")
	add_child(scene.instance())
	
	remove_child(get_node("MainMenu"))


func _on_MainMenu_start_intro():
	var scene = load("res:///scenes/Levels/Intro.tscn")
	add_child(scene.instance())
	
	remove_child(get_node("MainMenu"))
