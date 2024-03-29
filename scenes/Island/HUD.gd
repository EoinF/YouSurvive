extends Control

signal use_item(item_type)
signal set_active_item(item_type)

var _message_use_coconut_without_rock = "You need a rock to break open the coconut"

export var INVENTORY_TYPE = "Islander"


func _ready():
	if INVENTORY_TYPE == "Islander":
		get_node("Inventory").visible = true
		get_node("ExperimenterInventory").visible = false
	elif INVENTORY_TYPE == "Experimenter":
		get_node("Inventory").visible = false
		get_node("ExperimenterInventory").visible = true


func _on_Islander_use_coconut_without_rock():
	get_node("AlertMessage").show_alert(_message_use_coconut_without_rock)
	

func _on_Islander_inventory_slot_change(inventory_slot):
	get_node("Inventory").update_inventory_slot(inventory_slot)
	

func _on_Experimenter_inventory_slot_change(inventory_slot):
	get_node("ExperimenterInventory").update_inventory_slot(inventory_slot)


func _on_objectives_updated(objectives):
	get_node("ObjectivesDisplay").set_objectives(objectives)


func _on_Inventory_use_item(item_type):
	emit_signal("use_item", item_type)


func _on_Islander_health_change(health):
	get_node("HealthBar").set_health(health)


func _on_ExperimenterInventory_set_active_item(item_type):
	emit_signal("set_active_item", item_type)
