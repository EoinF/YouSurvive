extends Node2D

var health = 100
var LOW_HEALTH_BREAKPOINT = 30

var partially_damaged

var steering_weight = 0

var bodies_top = {}
var bodies_bottom = {}

func _ready():
	randomize()
	if get_owner() == null:
		create_damaged_tilemap()

func _process(delta):
	self.position.y += steering_weight * 1 * delta
	
	$LocalPosition.rotation_degrees = steering_weight * 0.2


# Called when the node enters the scene tree for the first time.
func hit():
	if $HitCooldown.time_left > 0:
		return
	
	$LocalPosition/ShakeEffect.start()
	$HitSound.play()
	$HitCooldown.start()
	
	health -= 1
	if health == LOW_HEALTH_BREAKPOINT:
		create_damaged_tilemap()


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
