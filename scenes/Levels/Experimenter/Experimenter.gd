extends Node2D

signal inventory_slot_change(inventory_slot)


class InventorySlot:
	var node_key: String
	var amount: int
	var item_type: String


var item_type_to_slot = {}
var unused_keys = ["1", "2", "3"]


func pick_up_item(item_type, amount):
	if item_type in item_type_to_slot:
		item_type_to_slot[item_type].amount += amount
	else:
		var node_key = unused_keys.pop_front()
		item_type_to_slot[item_type] = InventorySlot.new()
		item_type_to_slot[item_type].node_key = node_key
		item_type_to_slot[item_type].amount = amount
		item_type_to_slot[item_type].item_type = item_type
		
	emit_signal("inventory_slot_change", item_type_to_slot[item_type])

func use_item(item_type):
	if item_type_to_slot[item_type].amount > 0:
		get_node("ItemPlacementTool").toggle_item_placement(item_type)


func on_ItemPlacementTool_place_item(item_type):
	item_type_to_slot[item_type].amount -= 1
	if item_type_to_slot[item_type].amount == 0:
		get_node("ItemPlacementTool").disable_item_placement()

