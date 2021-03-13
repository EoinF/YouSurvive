extends Node2D

signal spawn_item(item_type, original_position, owner_instance_id)

var rock_scene = preload("res://objects/Projectiles/StoneProjectile.tscn")


func _on_Islander_throw_stone(position, direction):
	var islander = get_owner().get_node("Objects/Props/Islander")
	var rock_prop = rock_scene.instance()
	var projectile = rock_prop.get_node("Projectile")
	projectile.set_owner_instance_id(islander.get_instance_id())
	projectile.launch_item(position + (projectile.direction * 20), direction.normalized())
	add_child(rock_prop)
	
	projectile.connect("finish_launching", self, "_finish_launching")


func _finish_launching(node):
	emit_signal("spawn_item", node.spawned_object_type, node.global_position, node.get_owner_instance_id())
	node.queue_free()
