extends Node

var is_active
var is_dark = false

var menu_background_scene

func _ready():
	is_active = true
	$HUD/Control/Panel/HintLabel.modulate.a = 0
	menu_background_scene = preload("res://scenes/MainMenu/MenuBackground.tscn")
	
	var save_data = SaveManager.save_data
	if save_data["current_chapter"] == "Islander":
		$MainMenu.darken()


func darken():
	is_dark = true
	$AnimationPlayer.play("darken")
	
	for child in get_children():
		if child.is_in_group("MainMenuScreen"):
			child.darken()


func remove_new_game():
	var new_game_panel = $HUD/Control/Panel/CenterContainer/Grid/NewGame
	new_game_panel.disabled = true
	new_game_panel.visible = false


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "fadeOut" or anim_name == "fadeOut - dark":
		SceneManager.continue_game()
	

func _on_NewGame_pressed():
	$AnimationPlayer.stop()
	$AnimationPlayer.play("fadeLabel")
	var new_game_panel = $HUD/Control/Panel/CenterContainer/Grid/NewGame
	new_game_panel.modulate.a -= 0.30
	
	if new_game_panel.modulate.a < 0.1:
		new_game_panel.disabled = true
		new_game_panel.visible = false


func _on_ContinueGame_pressed():
	for button in $HUD/Control/Panel/CenterContainer/Grid.get_children():
		button.disabled = true
	var animation_name = "fadeOut - dark" if is_dark else "fadeOut"
	$AnimationPlayer.play(animation_name)


func _on_Credits_pressed():
	$Credits.show()


func _on_Settings_pressed():
	$Settings.show()


func _on_Exit_pressed():
	get_tree().quit()


func _on_Settings_finish_scene():
	$Settings.hide()


func _on_Credits_finish_scene():
	$Credits.hide()
