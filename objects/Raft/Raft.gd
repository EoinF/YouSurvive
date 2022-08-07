extends Node2D

var health = 100
var LOW_HEALTH_BREAKPOINT = 30

var partially_damaged

func _ready():
	randomize()
	if get_owner() == null:
		create_damaged_tilemap()


# Called when the node enters the scene tree for the first time.
func hit():
	if $HitCooldown.time_left > 0:
		return
	
	$ShakeEffect.start()
	$HitSound.play()
	$HitCooldown.start()
	
	health -= 1
	if health == LOW_HEALTH_BREAKPOINT:
		create_damaged_tilemap()


func create_damaged_tilemap():
	var damaged_tile_type = 8
	var damaged_tile_map: TileMap = $DamagedTilemap
	$HealthyTilemap.visible = false
	damaged_tile_map.visible = true
	for cell in $HealthyTilemap.get_used_cells():
		damaged_tile_map.set_cellv(cell, damaged_tile_type)
	
	# Apply autotile properties to all cells
	damaged_tile_map.update_bitmask_region()
