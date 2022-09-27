extends Node

signal continue_game
signal start_credits
signal start_settings

var is_active
var is_dark = false

var menu_background_scene

func _ready():
	is_active = true
	$HUD/Control/Panel/HintLabel.modulate.a = 0
	menu_background_scene = preload("res://scenes/MainMenu/MenuBackground.tscn")


func darken():
	is_dark = true
	$AnimationPlayer.play("darken")


func show():
	is_active = true
	$Background/CanvasModulate.color = Color.white
	$Background/CanvasModulate.visible = true
	$HUD/Control.visible = true
	$HUD/Control.modulate = Color.white
	$MusicLoop.play()
	$MusicLoop.set_volume_db(-12)
	var scene_instance = menu_background_scene.instance()
	$Background/CanvasModulate.add_child(scene_instance)
	$Background/CanvasModulate.move_child(scene_instance, 0)


func hide():
	is_active = false
	$Background/CanvasModulate.visible = false
	$HUD/Control.visible = false
	$MusicLoop.stop()
	$Background/CanvasModulate.remove_child($Background/CanvasModulate/MenuBackground)


func remove_new_game():
	var new_game_panel = $HUD/Control/Panel/CenterContainer/Grid/NewGame
	new_game_panel.disabled = true
	new_game_panel.visible = false


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "fadeOut" or anim_name == "fadeOut - dark":
		emit_signal("continue_game")
	

func _on_NewGame_pressed():
	$AnimationPlayer.stop()
	$AnimationPlayer.play("fadeLabel")
	var new_game_panel = $HUD/Control/Panel/CenterContainer/Grid/NewGame
	new_game_panel.modulate.a -= 0.30
	
	if new_game_panel.modulate.a < 0.1:
		new_game_panel.disabled = true
		new_game_panel.visible = false


func _on_ContinueGame_pressed():
	var animation_name = "fadeOut - dark" if is_dark else "fadeOut"
	$AnimationPlayer.play(animation_name)


func _on_Credits_pressed():
	emit_signal("start_credits")


func _on_Settings_pressed():
	emit_signal("start_settings")


func _on_Exit_pressed():
	get_tree().quit()
