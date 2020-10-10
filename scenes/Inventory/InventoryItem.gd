extends Control

signal use_item

var item_type = "<empty>"


func set_amount(amount):
	get_node("Amount").set_text(str(amount))
	get_node("Button").visible = amount > 0


func set_item_type(new_item_type):
	get_node("Amount").set_text("1")
	get_node("Button").visible = true
	item_type = new_item_type
	get_node("SpriteContainer/" + item_type).visible = true


func _on_Button_pressed():
	emit_signal("use_item")
