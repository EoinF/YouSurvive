extends Node

signal objectives_updated(objectives)

var OBJECTIVE_KILL_CRABS_KEY = "OBJECTIVE_KILL_CRABS"
var OBJECTIVE_KILL_CRABS_TEMPLATE = "Eliminate the crabs (%d/%d)"

var crabs_killed = 0
var total_crabs = 0

var is_objective_1_complete = false

func _ready():
	var props = get_owner().get_node("Objects/Props").get_children()
	for prop in props:
		if "object_type" in prop and prop.object_type == "crab":
			total_crabs += 1
	emit_signal("objectives_updated", _get_objectives())


func _get_objectives():
	var objective1 = {}
	objective1["description"] = OBJECTIVE_KILL_CRABS_TEMPLATE % [crabs_killed, total_crabs]
	objective1["key"] = OBJECTIVE_KILL_CRABS_KEY
	objective1["is_complete"] = is_objective_1_complete
	return [objective1]


func _on_Islander_inventory_slot_change(inventory_slot):
	emit_signal("objectives_updated", _get_objectives())
