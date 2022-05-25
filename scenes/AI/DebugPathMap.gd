extends TileMap


func _ready():
	if get_owner() == null:
		set_path([
			Vector2(10, 10),
			Vector2(10, 11),
			Vector2(10, 12),
			Vector2(11, 12),
			Vector2(12, 12),
			Vector2(13, 12),
			Vector2(14, 12),
			Vector2(14, 11),
			Vector2(14, 10),
			Vector2(14, 9),
			Vector2(14, 8),
			Vector2(13, 8),
			Vector2(12, 8),
			Vector2(11, 8),
			Vector2(10, 8),
			Vector2(9, 8),
			Vector2(8, 8),
			Vector2(7, 7),
			Vector2(6, 6),
			Vector2(7, 5),
			Vector2(8, 4),
			Vector2(8, 3),
			Vector2(9, 4),
			Vector2(10, 5),
			Vector2(9, 6),
		])


func set_path(path):
	clear()
	var direction = 0
	for i in range(len(path) - 1):
		var current = path[i]
		var next = path[i + 1]
		if current == next:
			continue
		direction = get_direction_tile_index(current, next)
		set_cellv(current, direction)
	if len(path) > 0:
		set_cellv(path.back(), direction)


func get_direction_tile_index(from: Vector2, to: Vector2):
	var x = to.x - from.x
	var y = to.y - from.y
	
	if x == 0 and y < 0:
		return 0
	elif x == 0 and y > 0:
		return 1
	elif x < 0 and y == 0:
		return 2
	elif x > 0 and y == 0:
		return 3
	elif x > 0 and y < 0:
		return 4
	elif x > 0 and y > 0:
		return 5
	elif x < 0 and y < 0:
		return 6
	elif x < 0 and y > 0:
		return 7
	
	
	
