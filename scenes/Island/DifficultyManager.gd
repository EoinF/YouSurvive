extends Node


export var ISLANDER_NODE_PATH: NodePath = "../Objects/Props/Islander"
export var AI_NODE_PATH: NodePath = "../AIController"
var MAX_ATTEMPT = 5


# Maps the attempt number to a max health for the islander
var HEALTH_AMOUNTS = {
	1: 100,
	2: 110,
	3: 120,
	4: 140,
	5: 175
}

# Maps the attempt number to a max move speed for the AI
var SPEED_AMOUNTS = {
	1: 1.0,
	2: 0.95,
	3: 0.9,
	4: 0.85,
	5: 0.8
}


func adjust_difficulty(value):
	var attempt_number = min(int(value), MAX_ATTEMPT)
	
	var islander = get_node(ISLANDER_NODE_PATH)
	islander.set_max_health_scaling(HEALTH_AMOUNTS[attempt_number])
	
	var ai_manager = get_node(AI_NODE_PATH)
	ai_manager.set_speed_scaling(SPEED_AMOUNTS[attempt_number])
