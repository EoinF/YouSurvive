tool
extends TileMap

export var TILEMAP_NODE_PATH: NodePath = "" setget set_tilemap_node_path
export var OBJECTS_NODE_PATH: NodePath = "" setget set_objects_node_path


func set_tilemap_node_path(new_path):
	var old_path = TILEMAP_NODE_PATH
	TILEMAP_NODE_PATH = new_path

	if(get_owner() != null and old_path != new_path):
		generate_base_nav_tiles()
		generate_static_body_nav_tiles()

func set_objects_node_path(new_path):
	var old_path = OBJECTS_NODE_PATH
	OBJECTS_NODE_PATH = new_path

	if(get_owner() != null and old_path != new_path):
		generate_static_body_nav_tiles()


func _get_all_static_bodies(root: Node):
	var current_nodes = []
	for child in root.get_children():
		if (child.get_class() == "StaticBody2D"):
			current_nodes.append(child)
		current_nodes += _get_all_static_bodies(child)

	return current_nodes


func _get_collision_nodes(static_bodies: Array):
	var collision_nodes = []
	for body in static_bodies:
		for child in body.get_children():
			if child.get_class() == "CollisionShape2D":
				collision_nodes.append(child)
	return collision_nodes


func generate_base_nav_tiles():
	if get_owner() != null:
		var tilemap = get_node(TILEMAP_NODE_PATH)
		if tilemap != null and tilemap.get_class() == "TileMap":
			var tileset: TileSet = tilemap.get_tileset()
			for tile_position in tilemap.get_used_cells():
				var tile_type = tilemap.get_cellv(tile_position)
				var tile_name = tileset.tile_get_name(tile_type)
				
				if tile_name == "sea":
					set_cell(tile_position.x, tile_position.y, 1)
				else:
					set_cell(tile_position.x, tile_position.y, 0)


func generate_static_body_nav_tiles():
	var objects_node = get_node(OBJECTS_NODE_PATH)
	if objects_node != null:
		var static_bodies = _get_all_static_bodies(objects_node)
		var all_collision_nodes = _get_collision_nodes(static_bodies)
		for node in all_collision_nodes:
			var shape: Shape2D = node.get_shape()
			if shape.get_class() == "CapsuleShape2D":
				var radius = min(shape.radius, shape.height)
				var min_tile_x = floor((node.global_position.x - radius) / 16.0)
				var min_tile_y = floor((node.global_position.y - radius) / 16.0)
				var max_tile_x = min_tile_x + ceil(radius / 16.0)
				var max_tile_y = min_tile_y + ceil(radius / 16.0)
				
				for i in range(min_tile_x, max_tile_x + 1):
					for j in range(min_tile_y, max_tile_y + 1):
						set_cell(i, j, 1)


func get_quickest_path_to(_from, _to):
	var from = _from - self.global_position
	var to = _to - self.global_position
	var tile_from = Vector2(floor(from.x / 16), floor(from.y / 16))
	var tile_to = Vector2(floor(to.x / 16), floor(to.y / 16))
	
	#
	# Ensure the destination isn't on a blocked tile
	#
	if (get_cellv(tile_to) == 1):
		if (get_cell(tile_to.x + 1, tile_to.y) == 0):
			tile_to.x += 1
		elif (get_cell(tile_to.x - 1, tile_to.y) == 0):
			tile_to.x -= 1
		elif (get_cell(tile_to.x, tile_to.y + 1) == 0):
			tile_to.y += 1
		elif (get_cell(tile_to.x, tile_to.y - 1) == 0):
			tile_to.y -= 1
	
	if (get_cellv(tile_to) == 1):
		return []
	
	var start_node = { 'location': tile_from, 'g_cost': 0, 'f_cost': h(tile_from, tile_to), 'parent': null }
	return a_star([start_node], tile_to)


func get_path_in_direction_of(origin: Vector2, direction: Vector2, max_distance = 300):
	var current = Vector2(origin)
	var valid_destination = Vector2(origin)
	
	var direction_normalized = direction.normalized() * 16
	current += direction_normalized
	
	while current.distance_to(origin) < max_distance:
		var tileX = floor(current.x / 16)
		var tileY = floor(current.y / 16)
		if get_cell(tileX, tileY) == 0:
			valid_destination = current
		else:
			break
		current += direction_normalized
	return get_quickest_path_to(origin, valid_destination)


func vector_hash(vec: Vector2):
	return vec.x + (vec.y * get_used_rect().size.x)


func a_star(frontier: Array, destination: Vector2):
	# Optimisation to avoid expanding the same nodes too many times
	var explored_nodes = {}
	
	while not frontier.empty() and frontier[0].location != destination:
		var current = frontier.pop_front()
		for next_node in get_surrounding_nodes(current):
			if get_cellv(next_node.location) == 0:
				var location_key = vector_hash(next_node.location)
				var g_cost = next_node.g_cost
				
				# Avoid re-exploring nodes, unless we found a shorter route to it
				if !explored_nodes.has(location_key) or \
				explored_nodes[location_key] > g_cost:
					var h_cost = h(next_node.location, destination)
					next_node.f_cost = g_cost + h_cost
					append_by_priority(frontier, next_node)
					explored_nodes[location_key] = g_cost

	if frontier.empty():
		return []
	
	var path = []
	var current_node = frontier[0]
	while(current_node != null):
		path.push_front(current_node.location)
		current_node = current_node.parent
	return path


func get_surrounding_nodes(current_node):
	var x = current_node.location.x
	var y = current_node.location.y
	var new_cost = current_node.g_cost + 1
	var surrounding_nodes = [{
		'location': Vector2(x - 1, y),
		'g_cost': new_cost,
		'parent': current_node
	},
	{
		'location': Vector2(x + 1, y),
		'g_cost': new_cost,
		'parent': current_node
	},
	{
		'location': Vector2(x, y - 1),
		'g_cost': new_cost,
		'parent': current_node
	},
	{
		'location': Vector2(x, y + 1),
		'g_cost': new_cost,
		'parent': current_node
	}]
	return surrounding_nodes


func append_by_priority(priority_list: Array, new_node):
	var index_to_insert = binary_search(priority_list, new_node.f_cost)
	priority_list.insert(index_to_insert, new_node)


func binary_search(list, target_cost):
	var left_margin = 0
	var right_margin = len(list)
	var index = int(len(list) / 2.0)
	while(left_margin < right_margin and list[index].f_cost != target_cost):
		if list[index].f_cost < target_cost:
			left_margin = index + 1
		else:
			right_margin = index
		index = (left_margin + right_margin) / 2
	
	return index


func h(a, b):
	# Manhattan distance
	return abs(a.x - b.x) + abs(a.y - b.y)
