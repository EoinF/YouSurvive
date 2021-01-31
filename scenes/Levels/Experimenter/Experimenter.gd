extends Node2D

signal inventory_slot_change(inventory_slot)

export var CAMERA_MOVE_SPEED = 1000

class InventorySlot:
	var node_key: String
	var amount: int
	var item_type: String


var item_type_to_slot = {}
var unused_keys = ["1", "2", "3"]

var is_controls_enabled = false


func enable_controls():
	is_controls_enabled = true
	

func disable_controls():
	is_controls_enabled = false


func move(deltaVector: Vector2):
	if is_controls_enabled:
		var camera = get_node("Camera")
		var newX = camera.position.x + deltaVector.x
		var newY = camera.position.y + deltaVector.y
		
		if newX < camera.limit_left:
			deltaVector.x += camera.limit_left - newX
		elif newX > camera.limit_right:
			deltaVector.x -= newX - camera.limit_right
		if newY < camera.limit_top:
			deltaVector.y += camera.limit_top - newY
		elif newY > camera.limit_bottom:
			deltaVector.y -= newY - camera.limit_bottom
			
		camera.translate(deltaVector * CAMERA_MOVE_SPEED)


func focus_target(target: Node2D):
	var camera = get_node("Camera")
	camera.translate(target.position - camera.position)


func set_follow_target(target, is_following):
	get_node("Camera").set_follow_target(target, is_following)


func set_is_following(is_following):
	get_node("Camera").set_is_following(is_following)


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
	if is_controls_enabled and item_type_to_slot[item_type].amount > 0:
		get_node("ItemPlacementTool").toggle_item_placement(item_type)


func _on_ItemPlacementTool_place_item(item_type, location):
	if item_type_to_slot[item_type].amount > 0:
		item_type_to_slot[item_type].amount -= 1
		if item_type_to_slot[item_type].amount == 0:
			get_node("ItemPlacementTool").disable_item_placement()
		emit_signal("inventory_slot_change", item_type_to_slot[item_type])


func _on_ExperimenterInventory_use_item(item_type):
	use_item(item_type)
