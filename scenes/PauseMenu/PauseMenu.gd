extends CanvasLayer

signal resume_pressed
signal main_menu_pressed


func hide():
	$Panel.visible = false


func show():
	$Panel.visible = true


func _on_MainMenu_pressed():
	emit_signal("main_menu_pressed")


func _on_Resume_pressed():
	emit_signal("resume_pressed")


func _on_ExitGame_pressed():
	get_tree().quit()
