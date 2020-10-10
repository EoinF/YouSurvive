extends Popup


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func show_alert(message_text):
	var label = get_node("Label")
	label.text = message_text
	var text_area = label.get_font("normal_font").get_string_size(label.text)
	get_node("Background").scale.x = text_area.x + 10
	visible = true

	popup(Rect2(300, 300, 300, 300))
	get_node("AutoHideTimer").start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_AutoHideTimer_timeout():
	hide()
