extends Node


export var ISLANDER_NODE_PATH: NodePath = "."
export var ISLANDER_HEALTH_HUD_NODE_PATH: NodePath = "."
export var AI_NODE_PATH: NodePath = "."
export var SEA_AI_NODE_PATH: NodePath = "."
var MAX_ATTEMPT = 5


# Maps the attempt number to a max health for the islander
var HEALTH_AMOUNTS = {
	1: 100,
	2: 120,
	3: 140,
	4: 160,
	5: 200
}

# Maps the attempt number to a max move speed for the AI
var SPEED_AMOUNTS = {
	1: 1.0,
	2: 0.1,
	3: 1.0,
	4: 1.0,
	5: 1.0
}

# Maps the attempt number to a max move speed for the sea AI
var SEA_SPEED_AMOUNTS = {
	1: 1.0,
	2: 1.0,
	3: 1.0,
	4: 1.0,
	5: 1.0
}

# Maps the attempt number to a max vision distance for the AI
var VISION_AMOUNTS = {
	1: 1.0,
	2: 1.0,
	3: 1.0,
	4: 1.0,
	5: 1.0
}


func set_attempt_number(value):
	var attempt_number = min(value, MAX_ATTEMPT)
	var islander = get_node(ISLANDER_NODE_PATH)
	islander.set_max_health(HEALTH_AMOUNTS[value])
	var ai_manager = get_node(AI_NODE_PATH)
	ai_manager.set_speed_scaling(SPEED_AMOUNTS[value])
	var sea_ai_manager = get_node(AI_NODE_PATH)
	sea_ai_manager.set_speed_scaling(SEA_SPEED_AMOUNTS[value])
