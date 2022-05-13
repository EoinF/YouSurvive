extends Node

signal objectives_updated(objectives)

var crabs_killed = 0
var total_crabs = 0

var is_objective_1_complete = false

var selected_enemy_type = "crab"

func _ready():
	var props = get_owner().get_node("Objects/Props").get_children()
	for prop in props:
		if "object_type" in prop and prop.object_type == "crab":
			total_crabs += 1
	emit_signal("objectives_updated", _get_objectives())


func _get_objectives():
	return [
		{
		"description": "Place %ss (%d/%d)" % [selected_enemy_type, crabs_killed, total_crabs],
		"is_complete": crabs_killed == total_crabs,
		"is_visible": false
		},
		{
		"description": "Eliminate the %ss (%d/%d)" % [selected_enemy_type, crabs_killed, total_crabs],
		"is_complete": crabs_killed == total_crabs,
		"is_visible": false
		}
	]


func _on_Props_prop_added(node):
	if node.is_in_group("AI") and node.object_type == "crab":
		total_crabs += 1
		emit_signal("objectives_updated", _get_objectives())


func _on_Props_crab_killed(node):
	crabs_killed += 1
	if crabs_killed == total_crabs:
		is_objective_1_complete = true
	emit_signal("objectives_updated", _get_objectives())

