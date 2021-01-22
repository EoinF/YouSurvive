extends YSort

var scene_map = {
	"branch": preload("res://objects/CollectableItems/Branch.tscn"),
	"coconut": preload("res://objects/CollectableItems/Coconut.tscn"),
	"stone": preload("res://objects/CollectableItems/Stone.tscn")
}

func _ready():
	for child in get_children():
		# If it's an in-game tree, check if there are items to spawn
		if child.is_in_group("Tree"):
			child.connect("spawn_item", self, "_spawn_item_falling")


func _add_prop(prop, source_position):
	var collectable = prop.get_node("CollectableItem")
	collectable.position = source_position
	add_child(prop)


func _add_falling_prop(prop, source_position):
	var deltaX = 10 + randi() % 10
	deltaX *= sign(randf() - 0.5)
	var deltaY = 10 + randi() % 10
	deltaY *= sign(randf() - 0.5)
	var to = Vector2(source_position.x + deltaX, source_position.y + deltaY)
	var from = Vector2(to.x, source_position.y - 30)
	var collectable = prop.get_node("CollectableItem")
	collectable.drop_item(from, to)
	add_child(prop)


func _spawn_item_falling(item_type, source_position):
	var scene_instance = scene_map[item_type].instance()
	_add_falling_prop(scene_instance, source_position)


func _spawn_item(item_type, source_position):
	var scene_instance = scene_map[item_type].instance()
	_add_prop(scene_instance, source_position)



func _on_Projectiles_spawn_item(item_type, source_position):
	print("spawn item: " + item_type)
	print(source_position)
	_spawn_item(item_type, source_position)


func _on_ItemPlacementTool_place_item(item_type, source_position):
	_spawn_item(item_type, source_position)
