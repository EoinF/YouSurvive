extends Node

signal objectives_updated(objectives)
signal objective_completed(objective_key)

var OBJECTIVE_COLLECT_BRANCHES_KEY = "OBJECTIVE_COLLECT_BRANCH"
var OBJECTIVE_COLLECT_BRANCHES_TEMPLATE = "Collect branches (%d/%d)"

var branches_collected = 0
var branches_required = 10

func _ready():
	emit_signal("objectives_updated", _get_objectives())


func _get_objectives():
	return [
		OBJECTIVE_COLLECT_BRANCHES_TEMPLATE % [branches_collected, branches_required]
	]
	

func _on_Islander_inventory_slot_change(inventory_slot):
	if inventory_slot.item_type == "branch":
		branches_collected = inventory_slot.amount
		emit_signal("objectives_updated", _get_objectives())

		if branches_collected == branches_required:
			emit_signal("objective_completed", OBJECTIVE_COLLECT_BRANCHES_KEY)
