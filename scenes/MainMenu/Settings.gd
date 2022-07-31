extends Control

signal finish_scene


func _on_MainVolumeSlider_value_changed(value):
	set_volume(0, value)


func _on_MusicVolumeSlider_value_changed(value):
	set_volume(1, value)


func _on_SfxVolumeSlider_value_changed(value):
	set_volume(2, value)


func set_volume(index, pct):
	AudioServer.set_bus_volume_db(index, linear2db(pct))
	AudioServer.set_bus_mute(index, pct == 0)


func _on_Back_Button_pressed():
	emit_signal("finish_scene")
