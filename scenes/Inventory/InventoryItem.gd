extends Control

signal click_item

var item_type = "<empty>"
var is_active = false


func set_amount(amount):
	get_node("Button/Amount").set_text(str(amount))
	get_node("Button").visible = amount > 0


func set_item_type(new_item_type):
	get_node("Button/Amount").set_text("1")
	get_node("Button").visible = true
	item_type = new_item_type
	get_node("Button/SpriteContainer/" + item_type).visible = true


func set_active(_is_active):
	is_active = _is_active
	if is_active:
		self.modulate = Color.yellow
	else:
		self.modulate = Color.white


func _on_Button_pressed():
	emit_signal("click_item")
