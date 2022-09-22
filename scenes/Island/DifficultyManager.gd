extends Node


export var ISLANDER_NODE_PATH: NodePath = "../Objects/Props/Islander"
export var AI_NODE_PATH: NodePath = "../AIController"
export var SEA_AI_NODE_PATH: NodePath = "../SeaAIController"
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

# Maps the attempt number to a max move speed for the sea AI
var SEA_SPEED_AMOUNTS = {
	1: 1.0,
	2: 0.95,
	3: 0.9,
	4: 0.85,
	5: 0.8
}

# Maps the attempt number to a max vision distance for the AI
#var VISION_AMOUNTS = {
#	1: 1.0,
#	2: 1.0,
#	3: 1.0,
#	4: 1.0,
#	5: 1.0
#}


func adjust_difficulty(value):
	var attempt_number = min(int(value), MAX_ATTEMPT)
	
	var islander = get_node(ISLANDER_NODE_PATH)
	islander.set_max_health_scaling(HEALTH_AMOUNTS[attempt_number])
	
	var ai_manager = get_node(AI_NODE_PATH)
	ai_manager.set_speed_scaling(SPEED_AMOUNTS[attempt_number])
	
	var sea_ai_manager = get_node(SEA_AI_NODE_PATH)
	if sea_ai_manager != null:
		sea_ai_manager.set_speed_scaling(SEA_SPEED_AMOUNTS[attempt_number])
