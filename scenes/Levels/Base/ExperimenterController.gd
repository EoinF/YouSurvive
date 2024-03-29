extends Node


export var ISLANDER_PATH: NodePath = "../Objects/Props/Islander"

func _process(delta):
	_process_movement_input(delta)
	_process_inventory_item_input()


func _process_movement_input(delta):
	var experimenter = get_owner().get_node("Experimenter")
	var x = 0
	var y = 0
	
	var islander = get_node(ISLANDER_PATH)
	if Input.is_action_just_released('center_camera'):
		experimenter.focus_target(islander)
	
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
		
		experimenter.move(deltaVector)

func _process_inventory_item_input():
	var inventory = get_owner().get_node("HUDLayer/HUD/ExperimenterInventory")
	if Input.is_action_just_released('use_item_1'):
		inventory.set_active_item_slot("1")
	elif Input.is_action_just_released('use_item_2'):
		inventory.set_active_item_slot("2")
	elif Input.is_action_just_released('use_item_3'):
		inventory.set_active_item_slot("3")
