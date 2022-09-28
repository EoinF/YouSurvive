extends CanvasLayer

signal finish_scene

export var BACK_BUTTON_TEXT = "Back"


func show():
	$"Panel/MarginContainer/Back Button".text = BACK_BUTTON_TEXT
	$Panel.visible = true


func hide():
	$Panel.visible = false


func _on_Back_Button_pressed():
	emit_signal("finish_scene")
