extends Control

signal use_item(item_type)

func update_inventory_slot(inventory_slot):
	get_node(inventory_slot.node_key).set_item_type(inventory_slot.item_type)
	get_node(inventory_slot.node_key).set_amount(inventory_slot.amount)

	
func _on_use_item_1():
	use_item_x("1")


func _on_use_item_2():
	use_item_x("2")


func _on_use_item_3():
	use_item_x("3")


func use_item_x(node_key):
	var item_type = get_node(node_key).item_type
	print("use item", item_type)
	emit_signal("use_item", item_type)

