extends Node2D

signal sees_islander
signal inventory_slot_change(inventory_slot)
signal place_item(item_type, source_location)

export var CAMERA_MOVE_SPEED = 1000
# Use the following node as a reference point for placing props
export var RELATIVE_POSITION_NODE_PATH: NodePath = "../Objects/Props"

var experiment_data = []
var current_time = 0.0

class InventorySlot:
	var node_key: String
	var amount: int
	var item_type: String


var item_type_to_slot = {}

var is_controls_enabled = false


func get_experiment_data():
	return experiment_data


func enable_controls():
	get_node("ItemPlacementTool").enable_item_placement()
	is_controls_enabled = true
	

func disable_controls():
	disable_placement()
	is_controls_enabled = false


func disable_placement():
	get_node("ItemPlacementTool").disable_item_placement()


func reset_timer():
	current_time = 0.0


func move(deltaVector: Vector2):
	if not is_controls_enabled:
		return
	var translate = deltaVector * CAMERA_MOVE_SPEED
	var camera = get_node("Camera")
	var newX = camera.global_position.x + translate.x
	var newY = camera.global_position.y + translate.y
	
	if newX < camera.limit_left:
		translate.x += camera.limit_left - newX
	elif newX > camera.limit_right:
		translate.x -= newX - camera.limit_right
	if newY < camera.limit_top:
		translate.y += camera.limit_top - newY
	elif newY > camera.limit_bottom:
		translate.y -= newY - camera.limit_bottom
	
	camera.translate(translate)


func focus_target(_target: Node2D):
	if is_controls_enabled:
		var camera = get_node("Camera")
		camera.translate(_target.position - camera.position)


func set_follow_target(_target, _is_following):
	get_node("Camera").set_follow_target(_target, _is_following)


func set_is_following(_is_following):
	get_node("Camera").set_is_following(_is_following)


func pick_up_item(_item_type, _amount):
	if _item_type in item_type_to_slot:
		item_type_to_slot[_item_type].amount += _amount
	else:
		var node_key = str(item_type_to_slot.size() + 1)
		item_type_to_slot[_item_type] = InventorySlot.new()
		item_type_to_slot[_item_type].node_key = node_key
		item_type_to_slot[_item_type].amount = _amount
		item_type_to_slot[_item_type].item_type = _item_type
		
	emit_signal("inventory_slot_change", item_type_to_slot[_item_type])

	var placement_tool = get_node("ItemPlacementTool")
	if placement_tool.selected_item_type == null:
		placement_tool.set_item_type(_item_type)


func _process(delta):
	current_time += delta


func _on_ItemPlacementTool_place_item(_item_type, _location):
	if item_type_to_slot[_item_type].amount > 0:
		item_type_to_slot[_item_type].amount -= 1
		if item_type_to_slot[_item_type].amount == 0:
			get_node("ItemPlacementTool").set_item_type(null)
		emit_signal("inventory_slot_change", item_type_to_slot[_item_type])
		
		var relative_node = get_node(RELATIVE_POSITION_NODE_PATH)
		var relative_location = _location - relative_node.global_position
		emit_signal("place_item", _item_type, relative_location)
		
		experiment_data.push_back({
			"action_type": "place_item",
			"current_time": current_time,
			"location": {
				"x": relative_location.x, "y": relative_location.y
			},
			"item_type": _item_type
		})


func _on_MainContainer_mouse_entered():
	get_node("ItemPlacementTool")._on_MainContainer_mouse_entered()


func _on_MainContainer_mouse_exited():
	get_node("ItemPlacementTool")._on_MainContainer_mouse_exited()


func _on_VisionDetectionArea_body_entered(body):
	if body.is_in_group("Islander"):
		emit_signal("sees_islander")


func _on_HUD_set_active_item(item_type):
	get_node("ItemPlacementTool").set_item_type(item_type)

