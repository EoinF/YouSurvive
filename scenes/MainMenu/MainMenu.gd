extends CanvasLayer

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
		save_file.close()
	
	get_node("HintLabel").modulate.a = 0


func _on_NewGame_pressed():
	get_node("AnimationPlayer").stop()
	get_node("AnimationPlayer").play("fadeLabel")
	var new_game_panel = get_node("Panel/NewGame")
	new_game_panel.modulate.a -= 0.30
	
	if new_game_panel.modulate.a < 0.1:
		new_game_panel.disabled = true
		new_game_panel.visible = false


func _on_Intro_pressed():
	emit_signal("start_intro")


func _on_ContinueGame_pressed():
	emit_signal("continue_game", save_data)
