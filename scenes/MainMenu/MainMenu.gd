extends CanvasLayer

signal continue_game(save_data)
signal start_credits
signal start_settings
signal on_load_save_data(save_data)

var save_data
var constants

var DEFAULT_SAVE_DATA = {
	"current_chapter": "Experimenter",
	"current_level":"Intro",
	"volume": {
		"0": 0.5,
		"1": 0.5,
		"2": 0.5
	}
}

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
	constants = preload("res://scripts/constants.gd").new()
	is_active = true
	
	var save_file = File.new()
	if save_file.file_exists(constants.SAVE_FILE_LOCATION):
		save_file.open(constants.SAVE_FILE_LOCATION, File.READ)
		save_data = parse_json(save_file.get_as_text())
		save_file.close()
	else:
		save_data = DEFAULT_SAVE_DATA
	
	emit_signal("on_load_save_data", save_data)
	
	$CanvasModulate/HintLabel.modulate.a = 0


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "fadeOut":
		emit_signal("continue_game", save_data)
	

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


func _on_Settings_change_volume(index, amount):
	save_data["volume"][str(index)] = amount
	var save_file = File.new()
	save_file.open(constants.SAVE_FILE_LOCATION, File.WRITE)
	save_file.store_string(to_json(save_data))
	save_file.close()
