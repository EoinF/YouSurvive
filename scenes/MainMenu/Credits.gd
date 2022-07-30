extends Control

signal finish_scene


func _on_Back_Button_pressed():
	emit_signal("finish_scene")
