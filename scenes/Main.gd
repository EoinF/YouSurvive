extends Node


func _on_MainMenu_start_new_game():
	get_node("ExperimenterScenes").load_day1()
	remove_child(get_node("MainMenu"))


func _on_MainMenu_start_intro():
	get_node("ExperimenterScenes").load_intro()
	remove_child(get_node("MainMenu"))
