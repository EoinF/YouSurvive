extends StaticBody2D

export var COCONUT_DROPS = 0
export var BRANCH_DROPS = 1

var object_type = "tree"

signal spawn_item(item_type, source_position)

var item_drops = []
var is_hittable = true

func _ready():
	for _i in range(0, COCONUT_DROPS):
		item_drops.append("coconut")
	for _i in range(0, BRANCH_DROPS):
		item_drops.append("branch")


func hit():
	var cooldown_timer = get_node("InteractionCooldown")
	is_hittable = false
	
	get_node("ShakeEffect").start()
	
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
	if area.is_in_group("Attack") and area.attack_power > 1:
		hit()
