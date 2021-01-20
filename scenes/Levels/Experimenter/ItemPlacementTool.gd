extends Node2D

var placement_item_type

var bodies_entered = {}

func toggle_item_placement(item_type):
	if item_type == placement_item_type:
		placement_item_type = null
	else:
		placement_item_type = item_type


func _on_PlacementSensor_body_entered(body):
	bodies_entered[body.get_instance_id()] = body
	get_node("Cursor").modulate = Color.red


func _on_PlacementSensor_body_exited(body):
	bodies_entered.erase(body.get_instance_id())
	if bodies_entered.size() == 0:
		get_node("Cursor").modulate = Color.green

