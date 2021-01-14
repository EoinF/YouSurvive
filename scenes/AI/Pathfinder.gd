tool
extends TileMap

export var TILEMAP_NODE_PATH = "" setget set_tilemap_node_path
export var OBJECTS_NODE_PATH = "" setget set_objects_node_path

var all_object_nodes = []


func set_tilemap_node_path(new_path):
	var old_path = TILEMAP_NODE_PATH
	TILEMAP_NODE_PATH = new_path

	if(old_path != new_path):
		generate_nav_tiles()

func set_objects_node_path(new_path):
	var old_path = OBJECTS_NODE_PATH
	OBJECTS_NODE_PATH = new_path
	
	#if (get_owner() != null):
	#	var objects_node = get_parent().get_node(OBJECTS_NODE_PATH)
	#	if (objects_node != null):
	#		var static_bodies = get_all_static_bodys(objects_node)
	#		var all_collision_nodes = get_all_collision_nodes(static_bodies)
	#		
	#		for x in all_collision_nodes:
	#			print(x.get_name())
	
	if(old_path != new_path):
		generate_nav_tiles()


func get_all_static_bodys(root: Node):
	var current_nodes = []
	for child in root.get_children():
		if (child.get_class() == "StaticBody2D"):
			current_nodes.append(child)
		current_nodes += get_all_static_bodys(child)

	return current_nodes


func get_all_collision_nodes(static_bodies: Array):
	var collision_nodes = []
	for body in static_bodies:
		for child in body.get_children():
			if child.get_class() == "CollisionShape2D":
				collision_nodes.append(child)
	return collision_nodes


func generate_nav_tiles():
	if get_owner() != null:
		var tilemap = get_parent().get_node(TILEMAP_NODE_PATH)
		if tilemap != null and tilemap.get_class() == "TileMap":
			var tileset = tilemap.get_tileset()
			for tile_position in tilemap.get_used_cells():
				var tileType = tilemap.get_cellv(tile_position)
				var shape = tileset.tile_get_shape(tileType, 0)
				
				if shape != null:
					set_cell(tile_position.x, tile_position.y, 1)
				else:
					#for node in all_object_nodes:
					#	var object_shape = node.get_shape()
					#	if (object_shape != null):
					#		set_cell(tile_position.x, tile_position.y, 1)
					set_cell(tile_position.x, tile_position.y, 0)


func get_quickest_path_to(from, to):
	var tile_from = Vector2(floor(from.x / 16), floor(from.y / 16))
	var tile_to = Vector2(floor(to.x / 16), floor(to.y / 16))
	
	print("Getting path from " + str(tile_from) + " to " + str(tile_to))
	
	var start_node = { 'location': tile_from, 'g_cost': 0, 'f_cost': h(tile_from, tile_to), 'path': [] }
	return a_star([start_node], tile_to)

func a_star(frontier: Array, destination: Vector2):
	while frontier[0].location != destination:
		var current = frontier.pop_front()
		for next_node in get_surrounding_nodes(current):
			if get_cellv(next_node.location) == 0:
				var g_cost = next_node.g_cost
				var h_cost = h(next_node.location, destination)
				next_node.f_cost = g_cost + h_cost
				frontier = append_by_priority(frontier, next_node)

	return frontier[0].path


func get_surrounding_nodes(current_node):
	var x = current_node.location.x
	var y = current_node.location.y
	var new_cost = current_node.g_cost + 1
	var surrounding_nodes = [{
		'location': Vector2(x - 1, y),
		'g_cost': new_cost,
		'path': current_node.path + [Vector2(x - 1, y)]
	},
	{
		'location': Vector2(x + 1, y),
		'g_cost': new_cost,
		'path': current_node.path + [Vector2(x + 1, y)]
	},
	{
		'location': Vector2(x, y - 1),
		'g_cost': new_cost,
		'path': current_node.path + [Vector2(x, y - 1)]
	},
	{
		'location': Vector2(x, y + 1),
		'g_cost': new_cost,
		'path': current_node.path + [Vector2(x, y + 1)]
	}]
	return surrounding_nodes


func append_by_priority(priority_list: Array, new_node):
	var index_to_insert = 0
	for i in range(0, len(priority_list)):
		var node = priority_list[i]
		if node.location == new_node.location:
			if new_node.f_cost < node.f_cost:
				priority_list[i] = new_node
				return
		if new_node.f_cost > node.f_cost:
			index_to_insert = i
			# Don't break here because we need to check for an already existing node
	priority_list.insert(index_to_insert, new_node)
	return priority_list


func h(a, b):
	# Manhattan distance
	return abs(a.x - b.x) + abs(a.y - b.y)
