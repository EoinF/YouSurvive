extends Node

signal objectives_updated(objectives)

var num_crabs_placed = 0
var num_porcupines_placed = 0
var num_boars_placed = 0

var num_crabs_killed = 0
var num_porcupines_killed = 0
var num_boars_killed = 0

var num_weapons_placed = 0

var is_objective_active = {}

func _num_predators_placed():
	return num_crabs_placed + num_porcupines_placed + num_boars_placed

var NUM_PREDATORS_REQUIRED = 15

var is_predator_placement_active = false
var is_weapon_placement_active = false
var is_kill_mode_active = false


func _ready():
	emit_signal("objectives_updated", _get_objectives())


func add_objective(type):
	if type == "place_predators":
		is_predator_placement_active = true
	if type == "place_weapon":
		is_weapon_placement_active = true
	if type == "kill_predators":
		is_kill_mode_active = true
	emit_signal("objectives_updated", _get_objectives())


func _get_objectives():
	return [
		{
			"description": "Place predators (%d/%d)" % [_num_predators_placed(), NUM_PREDATORS_REQUIRED],
			"is_complete": is_predator_placement_active and _num_predators_placed() >= NUM_PREDATORS_REQUIRED,
			"is_visible": is_predator_placement_active
		},
		{
			"description": "Place weapon (%d/1)" % [num_weapons_placed],
			"is_complete": is_weapon_placement_active and num_weapons_placed >= 1,
			"is_visible": is_weapon_placement_active
		},
		{
			"description": "Kill crabs (%d/%d)" % [num_crabs_killed, num_crabs_placed],
			"is_complete": is_kill_mode_active and num_crabs_killed == num_crabs_placed,
			"is_visible": is_kill_mode_active and num_crabs_placed > 0
		},
		{
			"description": "Kill porcupines (%d/%d)" % [num_porcupines_killed, num_porcupines_placed],
			"is_complete": is_kill_mode_active and num_porcupines_killed == num_porcupines_placed,
			"is_visible": is_kill_mode_active and num_porcupines_placed > 0
		},
		{
			"description": "Kill boars (%d/%d)" % [num_boars_killed, num_boars_placed],
			"is_complete": is_kill_mode_active and num_boars_killed == num_boars_placed,
			"is_visible": is_kill_mode_active and num_boars_placed > 0
		}
	]


func _on_Props_enemy_killed(node):
	if node.object_type == "crab":
		num_crabs_killed += 1
	elif node.object_type == "porcupine":
		num_porcupines_killed += 1
	elif node.object_type == "boar":
		num_boars_killed += 1
	emit_signal("objectives_updated", _get_objectives())


func _on_Experimenter_place_item(item_type, _source_location):
	if item_type == "crab":
		num_crabs_placed += 1
	elif item_type == "porcupine":
		num_porcupines_placed += 1
	elif item_type == "boar":
		num_boars_placed += 1
	elif item_type in ["stick", "stone"]:
		num_weapons_placed += 1
	emit_signal("objectives_updated", _get_objectives())

