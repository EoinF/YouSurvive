extends Node

signal objectives_updated(objectives)

var OBJECTIVE_COLLECT_BRANCHES_TEMPLATE = "Collect branches (%d/%d)"

var is_islander_found = false
var branches_collected = 0
var branches_required = 10

func _get_objectives():
	return [
		{
			"description": "locate the test subject",
			"is_visible": true,
			"is_complete": is_islander_found
		},
		{
			"description": OBJECTIVE_COLLECT_BRANCHES_TEMPLATE % [branches_collected, branches_required],
			"is_visible": is_islander_found,
			"is_complete": branches_collected >= branches_required
		}
	]

func _ready():
	emit_signal("objectives_updated", _get_objectives())


func _on_Islander_inventory_slot_change(inventory_slot):
	if inventory_slot.item_type == "branch":
		branches_collected = inventory_slot.amount

		emit_signal("objectives_updated", _get_objectives())


func _on_Experimenter_sees_islander():
	if not is_islander_found:
		is_islander_found = true
		emit_signal("objectives_updated", _get_objectives())
