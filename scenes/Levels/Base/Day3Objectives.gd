extends Node

signal objectives_updated(objectives)

var OBJECTIVE_COLLECT_COCONUTS_KEY = "OBJECTIVE_COLLECT_COCONUTS"
var OBJECTIVE_COLLECT_COCONUTS_TEMPLATE = "Collect coconuts (%d/%d)"

var OBJECTIVE_COLLECT_BRANCHES_KEY = "OBJECTIVE_COLLECT_BRANCH"
var OBJECTIVE_COLLECT_BRANCHES_TEMPLATE = "Collect branches (%d/%d)"

var is_objective_1_complete = false
var is_objective_2_complete = false

var current_coconuts = 0
var required_coconuts = 10

var branches_collected = 0
var branches_required = 10

func _ready():
	emit_signal("objectives_updated", _get_objectives())


func _get_objectives():
	var objective1 = {
		"description": OBJECTIVE_COLLECT_BRANCHES_TEMPLATE % [branches_collected, branches_required],
		"key": OBJECTIVE_COLLECT_BRANCHES_KEY,
		"is_complete": is_objective_1_complete,
		"is_visible": true
	}
	var objective2 = {
		"description": OBJECTIVE_COLLECT_COCONUTS_TEMPLATE % [current_coconuts, required_coconuts],
		"key": OBJECTIVE_COLLECT_COCONUTS_KEY,
		"is_complete": is_objective_2_complete,
		"is_visible": true
	}
	return [objective1, objective2]
	

func _on_Islander_inventory_slot_change(inventory_slot):
	if inventory_slot.item_type == "branch":
		branches_collected = inventory_slot.amount

		if branches_collected == branches_required:
			is_objective_1_complete = true
		

	if inventory_slot.item_type == "coconut":
		current_coconuts = inventory_slot.amount

		if current_coconuts == required_coconuts:
			is_objective_2_complete = true

	if inventory_slot.item_type == "coconut" or inventory_slot.item_type == "branch":
		emit_signal("objectives_updated", _get_objectives())
