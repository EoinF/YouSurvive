extends Node

signal objectives_updated(objectives)

var OBJECTIVE_COLLECT_COCONUTS_TEMPLATE = "Collect coconuts (%d/%d)"
var OBJECTIVE_COLLECT_BRANCHES_TEMPLATE = "Collect branches (%d/%d)"

var coconuts_collected = 0
var coconuts_required = 10

var branches_collected = 0
var branches_required = 10

var is_objectives_updated = false
var is_collect_items_active = false

func _process(_delta):
	# We pool together objective updates and emit them all at once
	if is_objectives_updated:
		is_objectives_updated = false
		emit_signal("objectives_updated", _get_objectives())


func _ready():
	is_objectives_updated = true


func set_objective_active(type, is_active = true):
	if type == "collect_items":
		is_collect_items_active = is_active
	is_objectives_updated = true


func _get_objectives():
	return [
		{
			"description": OBJECTIVE_COLLECT_COCONUTS_TEMPLATE % [coconuts_collected, coconuts_required],
			"is_complete": coconuts_collected >= coconuts_required,
			"is_visible": is_collect_items_active
		},{
			"description": OBJECTIVE_COLLECT_BRANCHES_TEMPLATE % [branches_collected, branches_required],
			"is_complete": branches_collected >= branches_required,
			"is_visible": is_collect_items_active
		}
	]


func _on_Islander_inventory_slot_change(inventory_slot):
	if inventory_slot.item_type == "branch":
		branches_collected = inventory_slot.amount
		is_objectives_updated = true
	if inventory_slot.item_type == "coconut":
		coconuts_collected = inventory_slot.amount
		is_objectives_updated = true
