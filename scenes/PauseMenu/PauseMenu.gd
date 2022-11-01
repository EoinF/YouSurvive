extends CanvasLayer


func hide():
	$Panel.visible = false


func show():
	$Panel.visible = true


func _on_MainMenu_pressed():
	SceneManager.pause_game()
	SceneManager.load_main_menu()


func _on_Resume_pressed():
	SceneManager.pause_game()


func _on_ExitGame_pressed():
	get_tree().quit()
