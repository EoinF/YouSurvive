extends CanvasLayer

signal continue_game
signal start_credits
signal start_settings

var is_active


func show():
	is_active = true
	$CanvasModulate.color = Color.white
	$CanvasModulate.visible = true
	$CanvasModulate/MusicLoop.play()
	$CanvasModulate/MusicLoop.set_volume_db(-12)
	$CanvasModulate/MenuBackground.resume()


func hide():
	is_active = false
	$CanvasModulate.visible = false
	$CanvasModulate/MusicLoop.stop()
	$CanvasModulate/MenuBackground.pause()


func remove_new_game():
	var new_game_panel = $CanvasModulate/Control/Panel/CenterContainer/Grid/NewGame
	new_game_panel.disabled = true
	new_game_panel.visible = false


func _ready():
	is_active = true
	
	$CanvasModulate/HintLabel.modulate.a = 0


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "fadeOut":
		emit_signal("continue_game")
	

func _on_NewGame_pressed():
	$CanvasModulate/AnimationPlayer.stop()
	$CanvasModulate/AnimationPlayer.play("fadeLabel")
	var new_game_panel = $CanvasModulate/Control/Panel/CenterContainer/Grid/NewGame
	new_game_panel.modulate.a -= 0.30
	
	if new_game_panel.modulate.a < 0.1:
		new_game_panel.disabled = true
		new_game_panel.visible = false


func _on_ContinueGame_pressed():
	$CanvasModulate/AnimationPlayer.play("fadeOut")


func _on_Credits_pressed():
	emit_signal("start_credits")


func _on_Settings_pressed():
	emit_signal("start_settings")


func _on_Exit_pressed():
	get_tree().quit()
