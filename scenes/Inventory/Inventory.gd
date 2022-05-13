extends Control

signal use_item(item_type)
signal set_active_item(item_type)

var active_slot = "1"


func _ready():
	get_node(active_slot).set_active(true)


func update_inventory_slot(inventory_slot):
	get_node(inventory_slot.node_key).set_item_type(inventory_slot.item_type)
	get_node(inventory_slot.node_key).set_amount(inventory_slot.amount)


func set_active_item_slot(node_key):
	get_node(active_slot).set_active(false)
	get_node(node_key).set_active(true)
	active_slot = node_key
	emit_signal("set_active_item", get_node(active_slot).item_type)


func use_active_item():
	var item_type = get_node(active_slot).item_type
	emit_signal("use_item", item_type)



func _on_click_item(node_key):
	set_active_item_slot(node_key)
