extends Node2D

signal health_change(new_amount)
signal y_change(amount)
signal start_sinking
signal finish_sinking

export var MAX_HEALTH = 100
var health
var is_alive = true

var LOW_HEALTH_BREAKPOINT = 30
var STEER_SPEED = 2.5
var TILE_SIZE = 16
var SINKING_DURATION_SECONDS = 2.0

var original_position: Vector2

var steering_weight = 0 setget set_steering_weight
var is_steering_enabled = true

var bodies_top = {}
var bodies_bottom = {}
var steering_direction = 0

func set_steering_weight(new_value):
	steering_weight = new_value
	if new_value > 0:
		steering_direction = 1
	elif new_value < 0:
		steering_direction = -1
	else:
		steering_direction = 0


func enable_steering():
	is_steering_enabled = true


func disable_steering():
	is_steering_enabled = false


func get_x_left():
	return self.global_position.x + \
		$LocalPosition/HealthyTilemap.get_used_rect().position.x * TILE_SIZE


func get_x_right():
	return get_x_left() + \
		TILE_SIZE * $LocalPosition/HealthyTilemap.get_used_rect().size.x


func get_y_top():
	return self.global_position.y + \
		$LocalPosition/HealthyTilemap.get_used_rect().position.y * TILE_SIZE


func get_y_bottom():
	return get_y_top() + \
		TILE_SIZE * $LocalPosition/HealthyTilemap.get_used_rect().size.y


func reset():
	self.position = original_position


func _ready():
	randomize()
	health = MAX_HEALTH
	if get_owner() == null:
		create_damaged_tilemap()
	original_position = position


func _process(delta):
	if not is_alive or not is_steering_enabled:
		$LocalPosition.rotation_degrees = 0
		return
	
	emit_signal("y_change", steering_weight * STEER_SPEED * delta)
	$LocalPosition.rotation_degrees = steering_weight * 0.1


# Called when the node enters the scene tree for the first time.
func hit(damage = 1):
	if not is_alive or $HitCooldown.time_left > 0:
		return
	
	$LocalPosition/ShakeEffect.start()
	$HitSound.play()
	$HitCooldown.start()
	
	var old_health = health
	health -= damage
	emit_signal("health_change", health)
	if old_health >= LOW_HEALTH_BREAKPOINT and health < LOW_HEALTH_BREAKPOINT:
		create_damaged_tilemap()
	if health <= 0:
		die()


func die():
	is_alive = false
	$ColourTween.interpolate_property(self, "modulate", Color.white, Color(0, 0, 1, 0), SINKING_DURATION_SECONDS)
	$ColourTween.start()
	emit_signal("start_sinking")


func create_damaged_tilemap():
	var damaged_tile_type = 8
	var damaged_tile_map: TileMap = $LocalPosition/DamagedTilemap
	var healthy_tile_map: TileMap = $LocalPosition/HealthyTilemap
	healthy_tile_map.visible = false
	damaged_tile_map.visible = true
	for cell in healthy_tile_map.get_used_cells():
		damaged_tile_map.set_cellv(cell, damaged_tile_type)
	
	# Apply autotile properties to all cells
	damaged_tile_map.update_bitmask_region()


func add_child_prop(prop):
	add_child(prop)


func _on_SteeringAreaTop_body_entered(body: Node2D):
	var id = body.get_instance_id()
	if bodies_top.has(id) or not body.has_method("get_weight"):
		return
		
	steering_weight -= body.get_weight()
	bodies_top[id] = body


func _on_SteeringAreaTop_body_exited(body: Node2D):
	var id = body.get_instance_id()
	if not bodies_top.has(id) or not body.has_method("get_weight"):
		return
		
	steering_weight += body.get_weight()
	bodies_top.erase(id)


func _on_SteeringAreaBottom_body_entered(body):
	var id = body.get_instance_id()
	if bodies_bottom.has(id) or not body.has_method("get_weight"):
		return
		
	steering_weight += body.get_weight()
	bodies_bottom[id] = body


func _on_SteeringAreaBottom_body_exited(body):
	var id = body.get_instance_id()
	if not bodies_bottom.has(id) or not body.has_method("get_weight"):
		return
		
	steering_weight -= body.get_weight()
	bodies_bottom.erase(id)


func _on_ColourTween_tween_all_completed():
	emit_signal("finish_sinking")


func _on_SeaProps_hit_raft(damage_amount):
	hit(damage_amount)

