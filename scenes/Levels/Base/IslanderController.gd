extends Node

export var ISLANDER_NODE_PATH = "Objects/Props/Islander"

var nearby_interaction_items = []
var current_interaction_item = null

var is_controls_enabled = true


func enable_controls():
	is_controls_enabled = true


func disable_controls():
	is_controls_enabled = false


func _process(delta):
	if is_controls_enabled:
		_process_movement_input(delta)
		_process_interaction_input(delta)
		_process_attack_input(delta)
		_process_inventory_item_input()


func _process_movement_input(delta):
	var islander = get_owner().get_node(ISLANDER_NODE_PATH)
	var x = 0
	var y = 0
	
	if Input.is_action_pressed('ui_left'):
		x -= 1
	if Input.is_action_pressed('ui_right'):
		x += 1
	if Input.is_action_pressed('ui_up'):
		y -= 1
	if Input.is_action_pressed('ui_down'):
		y += 1

	if (x != 0 or y != 0):
		var deltaVector = Vector2(x, y).normalized() * delta
		islander.move(deltaVector.x, deltaVector.y)


func _process_interaction_input(_delta):
	if current_interaction_item != null \
	and Input.is_action_just_released('interact') \
	and current_interaction_item.is_usable:
		current_interaction_item.interact()
		get_owner().get_node(ISLANDER_NODE_PATH).pick_up_item(current_interaction_item.object_type)


func _process_attack_input(_delta):
	var islander = get_owner().get_node(ISLANDER_NODE_PATH)
	if Input.is_action_just_released('attack') and not islander.is_attacking():
		islander.attack()


func _process_inventory_item_input():
	if Input.is_action_just_released('use_item_1'):
		get_owner().get_node("HUDLayer/HUD/Inventory").set_active_item_slot("1")
	elif Input.is_action_just_released('use_item_2'):
		get_owner().get_node("HUDLayer/HUD/Inventory").set_active_item_slot("2")
	elif Input.is_action_just_released('use_item_3'):
		get_owner().get_node("HUDLayer/HUD/Inventory").set_active_item_slot("3")
	elif Input.is_action_just_released('use_item'):
		get_owner().get_node("HUDLayer/HUD/Inventory").use_active_item()


func _on_PlayerInteraction_area_entered(area):
	var interaction_item = area.get_parent()
	if (interaction_item.is_in_group("Collectable")):
		var screen_position = area.get_global_transform_with_canvas().get_origin()
		var x = screen_position.x + area.get_child(0).shape.radius / 2
		var y = screen_position.y + 20
		nearby_interaction_items.append(interaction_item)
		current_interaction_item = interaction_item
		_show_interaction_item_tooltip(current_interaction_item, x, y)


func _on_PlayerInteraction_area_exited(area):
	if get_owner() == null:
		return
	var interaction_item = area.get_parent()
	var tooltip_container = get_owner().get_node("HUDLayer/TooltipContainer")
	var interaction_item_index = nearby_interaction_items.find(interaction_item)
	if interaction_item_index != -1:
		nearby_interaction_items.remove(interaction_item_index)
	if nearby_interaction_items.size() > 0:
		current_interaction_item = nearby_interaction_items.back()
		var x = tooltip_container.rect_position.x
		var y = tooltip_container.rect_position.y
		_show_interaction_item_tooltip(current_interaction_item, x, y)
	else:
		current_interaction_item = null
		tooltip_container.visible = false


func _show_interaction_item_tooltip(interaction_item, x, y):
	var tooltip_container = get_owner().get_node("HUDLayer/TooltipContainer")
	if (interaction_item.is_in_group("Collectable")):
		tooltip_container.activate("Press 'E' to pick up the " + interaction_item.display_name, x, y)
	else:
		tooltip_container.visible = false
