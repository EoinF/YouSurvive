extends Node2D

signal place_item(item_type, location)

var placement_item_type

var bodies_entered = {}
var is_mouse_in_game_scene = false

func _process(delta):
	if placement_item_type != null and is_mouse_in_game_scene:
		self.position = get_global_mouse_position()
	
		if bodies_entered.empty() and Input.is_action_just_released("left_click"):
			emit_signal("place_item", placement_item_type, position)

func toggle_item_placement(item_type):
	if item_type == placement_item_type:
		disable_item_placement()
	else:
		placement_item_type = item_type
		get_node("Sprites/" + item_type).visible = true


func disable_item_placement():
	get_node("Sprites/" + placement_item_type).visible = false
	placement_item_type = null


func _on_PlacementSensor_body_entered(body):
	bodies_entered[body.get_instance_id()] = body
	self.modulate = Color.red


func _on_PlacementSensor_body_exited(body):
	bodies_entered.erase(body.get_instance_id())
	if bodies_entered.empty():
		self.modulate = Color.white


func _on_MainContainer_mouse_entered():
	self.visible = true
	is_mouse_in_game_scene = true


func _on_MainContainer_mouse_exited():
	self.visible = false
	is_mouse_in_game_scene = false
