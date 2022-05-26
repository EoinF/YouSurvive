extends Node

signal objectives_updated(objectives)

var OBJECTIVE_COLLECT_BRANCHES_TEMPLATE = "Collect branches (%d/%d)"

var is_locate_islander_active = false
var is_collect_branches_active = false

var is_islander_found = false
var branches_collected = 0
var branches_required = 10

func _get_objectives():
	return [
		{
			"description": "locate the test subject",
			"is_visible": is_locate_islander_active,
			"is_complete": is_islander_found
		},
		{
			"description": OBJECTIVE_COLLECT_BRANCHES_TEMPLATE % [branches_collected, branches_required],
			"is_visible": is_collect_branches_active,
			"is_complete": branches_collected >= branches_required
		}
	]

func _ready():
	emit_signal("objectives_updated", _get_objectives())


func _on_Islander_inventory_slot_change(inventory_slot):
	if inventory_slot.item_type == "branch":
		branches_collected = inventory_slot.amount

		emit_signal("objectives_updated", _get_objectives())


func set_objective_active(type, is_active):
	if type == "locate_islander":
		is_locate_islander_active = is_active
	if type == "collect_branches":
		is_collect_branches_active = is_active
	call_deferred("emit_signal", "objectives_updated", _get_objectives())


func _on_Experimenter_sees_islander():
	if not is_islander_found:
		is_islander_found = true
		emit_signal("objectives_updated", _get_objectives())
