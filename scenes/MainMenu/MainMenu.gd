extends CanvasLayer

signal continue_game
signal start_credits
signal start_settings

var is_active

var menu_background_scene

func _ready():
	is_active = true
	$Control/Panel/HintLabel.modulate.a = 0
	menu_background_scene = preload("res://scenes/MainMenu/MenuBackground.tscn")


func show():
	is_active = true
	$CanvasModulate.color = Color.white
	$CanvasModulate.visible = true
	$Control.visible = true
	$Control.modulate = Color.white
	$MusicLoop.play()
	$MusicLoop.set_volume_db(-12)
	var scene_instance = menu_background_scene.instance()
	$CanvasModulate.add_child(scene_instance)
	$CanvasModulate.move_child(scene_instance, 0)


func hide():
	is_active = false
	$CanvasModulate.visible = false
	$Control.visible = false
	$MusicLoop.stop()
	$CanvasModulate.remove_child($CanvasModulate/MenuBackground)


func remove_new_game():
	var new_game_panel = $Control/Panel/CenterContainer/Grid/NewGame
	new_game_panel.disabled = true
	new_game_panel.visible = false


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "fadeOut":
		emit_signal("continue_game")
	

func _on_NewGame_pressed():
	$AnimationPlayer.stop()
	$AnimationPlayer.play("fadeLabel")
	var new_game_panel = $Control/Panel/CenterContainer/Grid/NewGame
	new_game_panel.modulate.a -= 0.30
	
	if new_game_panel.modulate.a < 0.1:
		new_game_panel.disabled = true
		new_game_panel.visible = false


func _on_ContinueGame_pressed():
	$AnimationPlayer.play("fadeOut")


func _on_Credits_pressed():
	emit_signal("start_credits")


func _on_Settings_pressed():
	emit_signal("start_settings")


func _on_Exit_pressed():
	get_tree().quit()
