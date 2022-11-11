extends CanvasLayer

signal finish_scene

export var BACK_BUTTON_TEXT = "Back"


func lighten():
	$Panel.modulate = Color.white


func darken():
	$Panel.modulate = Color("bec8e7")


func show(should_fade_in = false):
	$"Panel/MarginContainer/Back Button".text = BACK_BUTTON_TEXT
	if should_fade_in:
		$AnimationPlayer.play("fadeIn")
	else:
		$Panel.visible = true


func hide():
	$Panel.visible = false


func _on_Back_Button_pressed():
	emit_signal("finish_scene")
