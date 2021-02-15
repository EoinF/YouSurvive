extends Node

signal objectives_updated(objectives)

var OBJECTIVE_COLLECT_BRANCHES_KEY = "OBJECTIVE_COLLECT_BRANCH"
var OBJECTIVE_COLLECT_BRANCHES_TEMPLATE = "Collect branches (%d/%d)"

var is_objective_1_complete = false

var branches_collected = 0
var branches_required = 10

func _ready():
	emit_signal("objectives_updated", _get_objectives())


func _get_objectives():
	var objective1 = {}
	objective1["description"] = OBJECTIVE_COLLECT_BRANCHES_TEMPLATE % [branches_collected, branches_required]
	objective1["key"] = OBJECTIVE_COLLECT_BRANCHES_KEY
	objective1["is_complete"] = is_objective_1_complete
	return [objective1]
	

func _on_Islander_inventory_slot_change(inventory_slot):
	if inventory_slot.item_type == "branch":
		branches_collected = inventory_slot.amount

		if branches_collected == branches_required:
			is_objective_1_complete = true
		emit_signal("objectives_updated", _get_objectives())
