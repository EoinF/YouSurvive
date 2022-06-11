extends Node2D

signal place_item(item_type, location)

var selected_item_type

var bodies_entered = {}
var is_mouse_in_game_scene = false
var _is_enabled = false
var is_blocked = false
var is_placing = false
var is_physics_processed = false
var physics_ticks = 0


func _process(_delta):
	if not _is_enabled or selected_item_type == null or not is_mouse_in_game_scene:
		return
	
	if not is_placing:
		self.position = get_global_mouse_position()
	
	if is_blocked:
		is_placing = false
		return
	
	if physics_ticks >= 5:
		emit_signal("place_item", selected_item_type, position)
		is_placing = false
		physics_ticks = 0
		return
	
	if Input.is_action_just_released("left_click"):
		is_placing = true

# Hacky workaround to ensure items aren't placed in illegal areas
# because the collision detection has a delay
func _physics_process(_delta):
	if is_placing:
		physics_ticks += 1
	else:
		physics_ticks = 0

func enable_item_placement():
	_is_enabled = true
	if selected_item_type != null:
		get_node("Sprites/" + selected_item_type).visible = true
		get_node("CircleSprite").visible = true


func disable_item_placement():
	_is_enabled = false
	if selected_item_type != null:
		get_node("Sprites/" + selected_item_type).visible = false
		get_node("CircleSprite").visible = false


func set_item_type(item_type):
	if selected_item_type != null:
		get_node("Sprites/" + selected_item_type).visible = false
		get_node("CircleSprite").visible = false
	selected_item_type = item_type
	if item_type != null and _is_enabled:
		get_node("Sprites/" + item_type).visible = true
		get_node("CircleSprite").visible = true


func _on_PlacementSensor_body_entered(body):
	bodies_entered[body.get_instance_id()] = body
	is_blocked = true
	self.modulate = Color.red


func _on_PlacementSensor_body_exited(body):
	bodies_entered.erase(body.get_instance_id())
	if bodies_entered.empty():
		is_blocked = false
		self.modulate = Color.white


func _on_MainContainer_mouse_entered():
	self.visible = true
	is_mouse_in_game_scene = true


func _on_MainContainer_mouse_exited():
	self.visible = false
	is_mouse_in_game_scene = false
