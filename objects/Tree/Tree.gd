extends StaticBody2D

export var COCONUT_DROPS = 0
export var BRANCH_DROPS = 1
export var STONE_DROPS = 0

var object_type = "tree"

signal spawn_item(item_type, source_position)

var item_drops = []
var is_hittable = true

func _ready():
	for _i in range(0, COCONUT_DROPS):
		item_drops.append("coconut")
	for _i in range(0, BRANCH_DROPS):
		item_drops.append("branch")
	for _i in range(0, STONE_DROPS):
		item_drops.append("stone")


func hit():
	var cooldown_timer = get_node("InteractionCooldown")
	is_hittable = false
	
	get_node("ShakeEffect").start()
	get_node("HitSound").play()
	
	if (cooldown_timer.is_stopped()):
		get_node("Sprite").modulate = Color.gray
		
		if len(item_drops) > 0:
			var index = randi() % len(item_drops)
			emit_signal("spawn_item", item_drops[index], global_position)
			item_drops.remove(index)
		
		cooldown_timer.start()


func _on_InteractionCooldown_timeout():
	is_hittable = true
	if len(item_drops) > 0:
		get_node("Sprite").modulate = Color.white


func _on_InteractionArea_area_entered(area):
	if area.is_in_group("Attack") and area.can_knock_coconuts_from_trees:
		hit()
