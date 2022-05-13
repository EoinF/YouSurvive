extends Node

signal objectives_updated(objectives)

var OBJECTIVE_COLLECT_BRANCHES_TEMPLATE = "Collect branches (%d/%d)"

var branches_collected = 0
var branches_required = 10

func _get_objectives():
	return [
		{
			"description": "find yourself",
			"is_visible": true,
			"is_complete": false
		},
		{
			"description": OBJECTIVE_COLLECT_BRANCHES_TEMPLATE % [branches_collected, branches_required],
			"is_visible": false,
			"is_complete": branches_collected == branches_required
		}
	]

func _ready():
	emit_signal("objectives_updated", _get_objectives())
	

func _on_Islander_inventory_slot_change(inventory_slot):
	if inventory_slot.item_type == "branch":
		branches_collected = inventory_slot.amount

		emit_signal("objectives_updated", _get_objectives())
