extends CanvasLayer

signal finish_scene


func lighten():
	$Panel.modulate = Color.white


func darken():
	$Panel.modulate = Color("bec8e7")


func show():
	$Panel.visible = true


func hide():
	$Panel.visible = false


func _ready():
	var container = $Panel/MarginContainer/GridContainer/GridContainer
	var save_data = SaveManager.save_data
	
	var main = container.get_node("GridContainer/MainVolumeSlider")
	var music = container.get_node("GridContainer2/MusicVolumeSlider")
	var sfx = container.get_node("GridContainer3/SfxVolumeSlider")
	
	main.value = save_data["volume"]["0"]
	set_volume(0, main.value, false)
	music.value = save_data["volume"]["1"]
	set_volume(1, music.value, false)
	sfx.value = save_data["volume"]["2"]
	set_volume(2, sfx.value, false)
	OS.window_fullscreen = save_data["is_fullscreen"]
	container.get_node("CheckButton").pressed = OS.window_fullscreen



func _on_MainVolumeSlider_value_changed(value):
	set_volume(0, value)


func _on_MusicVolumeSlider_value_changed(value):
	set_volume(1, value)


func _on_SfxVolumeSlider_value_changed(value):
	set_volume(2, value)


func set_volume(index, pct, should_save=true):
	AudioServer.set_bus_volume_db(index, linear2db(pct))
	AudioServer.set_bus_mute(index, pct == 0)
	
	if should_save:
		SaveManager.save_volume(index, pct)
	

func _on_Back_Button_pressed():
	emit_signal("finish_scene")


func _on_CheckButton_pressed():
	var container = $Panel/MarginContainer/GridContainer/GridContainer
	OS.window_fullscreen = container.get_node("CheckButton").pressed
	SaveManager.save_fullscreen(OS.window_fullscreen)


