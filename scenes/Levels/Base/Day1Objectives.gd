extends Node

signal objectives_updated(objectives)

var OBJECTIVE_COLLECT_BRANCHES_KEY = "OBJECTIVE_COLLECT_BRANCH"
var OBJECTIVE_FIND_YOURSELF_KEY = "OBJECTIVE_FIND_YOURSELF"
var OBJECTIVE_COLLECT_BRANCHES_TEMPLATE = "Collect branches (%d/%d)"

var branches_collected = 0
var branches_required = 10

var objectives = [
	{
		"description": "find yourself",
		"key": OBJECTIVE_FIND_YOURSELF_KEY,
		"is_visible": true,
		"is_complete": false
	},
	{
		"description": OBJECTIVE_COLLECT_BRANCHES_TEMPLATE % [branches_collected, branches_required],
		"key": OBJECTIVE_COLLECT_BRANCHES_KEY,
		"is_visible": false,
		"is_complete": false
	}
]

func _ready():
	emit_signal("objectives_updated", objectives)
	

func _on_Islander_inventory_slot_change(inventory_slot):
	if inventory_slot.item_type == "branch":
		branches_collected = inventory_slot.amount

		if branches_collected == branches_required:
			objectives[1]["is_complete"] = true
		emit_signal("objectives_updated", objectives)
