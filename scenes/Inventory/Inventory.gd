extends Control

signal use_item(item_type)
signal set_active_item(item_type)

var inventory_item_scene = preload("res://scenes/Inventory/InventoryItem.tscn")

var active_slot = null


func update_inventory_slot(inventory_slot):
	var item_node
	var grid = get_node("GridContainer")
	if not grid.has_node(inventory_slot.node_key):
		item_node = inventory_item_scene.instance()
		grid.call_deferred("add_child", item_node)
		item_node.set_name(inventory_slot.node_key)
		item_node.connect("click_item", self, "_on_click_item", [inventory_slot.node_key])
	else:
		item_node = grid.get_node(inventory_slot.node_key)

	item_node.set_item_type(inventory_slot.item_type)
	item_node.set_amount(inventory_slot.amount)
	if active_slot == null:
		set_active_item_slot(inventory_slot.node_key)


func set_active_item_slot(node_key):
	var grid = get_node("GridContainer")
	if not grid.has_node(node_key):
		return
	
	if active_slot != null:
		grid.get_node(active_slot).set_active(false)
	
	var item_type = grid.get_node(node_key).item_type
	if item_type != "<empty>":
		grid.get_node(node_key).set_active(true)
		active_slot = node_key
		emit_signal("set_active_item", item_type)


func use_active_item():
	if active_slot == null:
		return
	var grid = get_node("GridContainer")
	var item_type = grid.get_node(active_slot).item_type
	if item_type != "<empty>":
		emit_signal("use_item", item_type)


func _on_click_item(node_key):
	set_active_item_slot(node_key)
