extends Node

enum AIState {
	IDLE
	WANDER
	CHASE
}


class AINode:
	var state
	var node: Node
	var state_timeout: float
	var target: Vector2
	func _init(_node):
		node = _node
		state = AIState.IDLE
		state_timeout = 0.0
		target = Vector2.ZERO
		
	func set_state(next_state):
		match(next_state):
			AIState.IDLE:
				state_timeout = randf() * 2.5
			AIState.WANDER:
				state_timeout = 1.0
			_:
				state_timeout = 0.0
		
		state = next_state


var ai_nodes = []

func _ready():
	for prop in get_parent().get_node("Props").get_children():
		if prop.is_in_group("AI"):
			ai_nodes.append(AINode.new(prop))


func _process(delta):
	for i in range(ai_nodes.size() - 1, -1, -1):
		var ai_node = ai_nodes[i]
		if ai_node.node == null:
			ai_nodes.remove(i)
		else:
			var islander_position = get_parent().get_node("Props/Islander").global_position
			var direction_to_player = islander_position - ai_node.node.global_position
			
			if direction_to_player.length() < 100:
				ai_node.set_state(AIState.CHASE)
				ai_node.state_timeout = 0
			
			match(ai_node.state):
				AIState.IDLE:
					if (ai_node.state_timeout > 0):
						ai_node.state_timeout -= delta
					else:
						var rand_x = randf()
						ai_node.target = ai_node.node.global_position + Vector2(-20 + randf() * 40, -20 + randf() * 40)
						ai_node.set_state(AIState.WANDER)
				AIState.WANDER:
					if (ai_node.state_timeout < 0) or ai_node.target.distance_to(ai_node.node.global_position) < 2:
							ai_node.set_state(AIState.IDLE)
					else:
						ai_node.state_timeout -= delta
						var diff = ai_node.target - ai_node.node.global_position
						ai_node.node.move(diff.x, diff.y) 
				AIState.CHASE:
					if direction_to_player.length() < 30:
						ai_node.node.attack(direction_to_player.x, direction_to_player.y)
					elif direction_to_player.length() < 150:
						ai_node.node.move(direction_to_player.x, direction_to_player.y)
					else:
						ai_node.set_state(AIState.IDLE)

