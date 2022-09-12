extends Control

signal change_volume(index, amount)
signal finish_scene

var constants

func set_data(save_data):
	var container = $Panel/MarginContainer/GridContainer/GridContainer
	
	var main = container.get_node("GridContainer/MainVolumeSlider")
	var music = container.get_node("GridContainer2/MusicVolumeSlider")
	var sfx = container.get_node("GridContainer3/SfxVolumeSlider")
	
	main.value = save_data["volume"]["0"]
	set_volume(0, main.value)
	music.value = save_data["volume"]["1"]
	set_volume(1, music.value)
	sfx.value = save_data["volume"]["2"]
	set_volume(2, sfx.value)


func _on_MainVolumeSlider_value_changed(value):
	set_volume(0, value)


func _on_MusicVolumeSlider_value_changed(value):
	set_volume(1, value)


func _on_SfxVolumeSlider_value_changed(value):
	set_volume(2, value)


func set_volume(index, pct):
	AudioServer.set_bus_volume_db(index, linear2db(pct))
	AudioServer.set_bus_mute(index, pct == 0)
	
	emit_signal("change_volume", index, pct)
	

func _on_Back_Button_pressed():
	emit_signal("finish_scene")
