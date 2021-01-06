extends Popup


func show_alert(message_text):
	var label = get_node("LabelContainer/Label")
	label.text = message_text
	var text_area = label.get_font("normal_font").get_string_size(label.text)
	var background = get_node("LabelContainer")
	background.rect_size.x = text_area.x + 10
	visible = true

	popup(Rect2(300, 300, 300, 300))
	get_node("AutoHideTimer").start()


func _on_AutoHideTimer_timeout():
	hide()
