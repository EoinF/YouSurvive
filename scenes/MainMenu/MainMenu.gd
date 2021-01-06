extends Control

signal start_new_game
signal start_intro


func _on_NewGame_pressed():
	emit_signal("start_new_game")


func _on_Intro_pressed():
	emit_signal("start_intro")
