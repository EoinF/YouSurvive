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
	objective1["is_visible"] = true
	return [objective1]


func _on_Props_prop_added(node):
	if node.is_in_group("AI") and node.object_type == "crab":
		total_crabs += 1
		emit_signal("objectives_updated", _get_objectives())


func _on_Props_crab_killed(node):
	crabs_killed += 1
	if crabs_killed == total_crabs:
		is_objective_1_complete = true
	emit_signal("objectives_updated", _get_objectives())

