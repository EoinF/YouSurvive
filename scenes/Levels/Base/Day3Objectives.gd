extends Node

signal objectives_updated(objectives)

var OBJECTIVE_COLLECT_COCONUTS_KEY = "OBJECTIVE_COLLECT_COCONUTS"
var OBJECTIVE_COLLECT_COCONUTS_TEMPLATE = "Collect coconuts (%d/%d)"

var current_coconuts = 0
var required_coconuts = 10

var is_objective_1_complete = false

func _ready():
	emit_signal("objectives_updated", _get_objectives())


func _get_objectives():
	var objective1 = {}
	objective1["description"] = OBJECTIVE_COLLECT_COCONUTS_TEMPLATE % [current_coconuts, required_coconuts]
	objective1["key"] = OBJECTIVE_COLLECT_COCONUTS_KEY
	objective1["is_complete"] = is_objective_1_complete
	return [objective1]


func _on_Islander_inventory_slot_change(inventory_slot):
	if inventory_slot.item_type == "coconut":
		current_coconuts = inventory_slot.amount

		if current_coconuts == required_coconuts:
			is_objective_1_complete = true
		emit_signal("objectives_updated", _get_objectives())
