extends StaticBody2D

signal spawn_item(item_type, source_position)

var is_hittable = true

func hit():
	var cooldown_timer = get_node("InteractionCooldown")
	is_hittable = false
	
	get_node("ShakeEffect").start()
	
	if (cooldown_timer.is_stopped()):
		cooldown_timer.start()
		get_node("Sprite").modulate = Color.gray
		
		if randi() % 3 == 1:
			print("spawn branch")
			emit_signal("spawn_item", "Branch", global_position)
		if randi() % 5 == 1:
			print("spawn coconut")
			emit_signal("spawn_item", "Coconut", global_position)


func _on_InteractionCooldown_timeout():
	is_hittable = true
	get_node("Sprite").modulate = Color.white


func _on_InteractionArea_area_entered(area):
	if (area.is_in_group("Attack")):
		hit()
