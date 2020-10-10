extends Control

var _message_use_coconut_without_rock = "You need a rock to break open the coconut"


func _on_Islander_use_coconut_without_rock():
	get_node("AlertMessage").show_alert(_message_use_coconut_without_rock)
	

func _on_Islander_inventory_slot_change(inventory_slot):
	get_node("Inventory").update_inventory_slot(inventory_slot)


func _on_Islander_stamina_change(stamina):
	get_node("StaminaBar/ProgressBar").value = stamina
