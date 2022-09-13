extends YSort

signal prop_added(node)
signal enemy_killed(node)
signal enemy_struggle

export var CUSTOM_LAND_PROPS_PATH: NodePath = "."
export var CUSTOM_SEA_PROPS_PATH: NodePath = "."

var sea_item_types = ["shark", "sea_rock"]

var scene_map = {
	"branch": preload("res://objects/CollectableItems/Branch.tscn"),
	"coconut": preload("res://objects/CollectableItems/Coconut.tscn"),
	"stone": preload("res://objects/CollectableItems/Stone.tscn"),
	"stick": preload("res://objects/CollectableItems/Stick.tscn"),
	"crab": preload("res://objects/Crab/Crab.tscn"),
	"boar": preload("res://objects/Boar/Boar.tscn"),
	"porcupine": preload("res://objects/Porcupine/Porcupine.tscn"),
	"shark": preload("res://objects/Shark/Shark.tscn"),
	"sea_rock": preload("res://objects/Rock/SeaRock.tscn")
}

func _ready():
	for child in get_children():
		if child.is_in_group("Tree"):
			child.connect("spawn_item", self, "_spawn_item_falling")
		
		if child.is_in_group("AI"):
			child.connect("dies", self, "_on_enemy_dies")
			
		if child.is_in_group("Sea"):
			child.connect("struggle", self, "_on_enemy_struggle")


func _add_prop(destination_node, prop, source_position, owner_instance_id):
	prop.position = source_position - destination_node.global_position
	if prop.has_node("CollectableItem"):
		prop.get_node("CollectableItem").set_owner_instance_id(owner_instance_id)
	destination_node.add_child_prop(prop)

	if prop.is_in_group("AI"):
		prop.connect("dies", self, "_on_enemy_dies")
		
	if prop.is_in_group("Sea"):
		prop.connect("struggle", self, "_on_enemy_struggle")

	emit_signal("prop_added", prop)


func _add_falling_prop(destination_node, prop, source_position):
	var deltaX = 10 + randi() % 10
	deltaX *= sign(randf() - 0.5)
	var deltaY = 10 + randi() % 10
	deltaY *= sign(randf() - 0.5)
	var destination_position = source_position - destination_node.global_position
	var to = Vector2(destination_position.x + deltaX, destination_position.y + deltaY)
	var from = Vector2(to.x, destination_position.y - 30)
	var collectable = prop.get_node("CollectableItem")
	collectable.drop_item(from, to)
	destination_node.call_deferred("add_child", prop)
	emit_signal("prop_added", prop)


func _spawn_item_falling(item_type, source_position):
	var scene_instance = scene_map[item_type].instance()
	var destination_node = get_node(CUSTOM_SEA_PROPS_PATH) if \
		item_type in sea_item_types else get_node(CUSTOM_LAND_PROPS_PATH)
	_add_falling_prop(destination_node, scene_instance, source_position)


func _spawn_item(item_type, source_position, owner_instance_id = null):
	var scene_instance = scene_map[item_type].instance()
	
	var destination_node = get_node(CUSTOM_SEA_PROPS_PATH) if \
		item_type in sea_item_types else get_node(CUSTOM_LAND_PROPS_PATH)
	_add_prop(destination_node, scene_instance, source_position, owner_instance_id)


func add_child_prop(prop):
	add_child(prop)


func _on_Projectiles_spawn_item(item_type, source_position, owner_instance_id):
	_spawn_item(item_type, source_position, owner_instance_id)


func _on_place_item(item_type, source_position):
	_spawn_item(item_type, source_position)


func _on_enemy_dies(node):
	emit_signal("enemy_killed", node)


func _on_enemy_struggle():
	emit_signal("enemy_struggle")
