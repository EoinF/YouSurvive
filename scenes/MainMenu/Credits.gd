extends CanvasLayer

signal finish_scene


func show():
	$Panel.visible = true


func hide():
	$Panel.visible = false


func _on_Back_Button_pressed():
	emit_signal("finish_scene")
