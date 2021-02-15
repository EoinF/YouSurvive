extends CanvasLayer

signal start_new_game
signal start_intro
signal continue_game(save_data)

var save_data

var constants

func _ready():
	constants = preload("res://scripts/constants.gd").new()
	
	var save_file = File.new()
	if save_file.file_exists(constants.SAVE_FILE_LOCATION):
		save_file.open(constants.SAVE_FILE_LOCATION, File.READ)
		save_data = parse_json(save_file.get_as_text())
		get_node("Panel/ContinueGame").visible = true


func _on_NewGame_pressed():
	emit_signal("start_new_game")


func _on_Intro_pressed():
	emit_signal("start_intro")


func _on_ContinueGame_pressed():
	emit_signal("continue_game", save_data)
