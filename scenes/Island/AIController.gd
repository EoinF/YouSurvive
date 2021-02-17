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
				state_timeout = 0.2 + randf() * 3.5
			AIState.WANDER:
				state_timeout = 1.0
			_:
				state_timeout = 0.0
		
		state = next_state


var ai_nodes = []
var is_ai_enabled = true


func disable_ai():
	is_ai_enabled = false
	
	
func enable_ai():
	is_ai_enabled = true


func _ready():
	for prop in get_parent().get_node("Objects/Props").get_children():
		if prop.is_in_group("AI"):
			ai_nodes.append(AINode.new(prop))


func _process(delta):
	if not is_ai_enabled:
		return
	for i in range(ai_nodes.size() - 1, -1, -1):
		var ai_node = ai_nodes[i]
		if ai_node.node == null:
			ai_nodes.remove(i)
		else:
			var islander_position = get_parent().get_node("Objects/Props/Islander").global_position
			var direction_to_player = islander_position - ai_node.node.global_position
			
			if direction_to_player.length() < 200:
				ai_node.set_state(AIState.CHASE)
				ai_node.state_timeout = 0
			
			match(ai_node.state):
				AIState.IDLE:
					if (ai_node.state_timeout > 0):
						ai_node.state_timeout -= delta
					else:
						var rand_sign = ((randi() % 2) * 2) - 1
						var rand_x = 2 * randf()
						var rand_y = 2 * randf() - 1
						var scale = 5000
						var x = rand_sign * scale / (rand_x * rand_x)
						var y = rand_sign * scale / (rand_y * rand_y)
						ai_node.target = ai_node.node.global_position + Vector2(x, y)
						ai_node.set_state(AIState.WANDER)
				AIState.WANDER:
					if (ai_node.state_timeout < 0) or ai_node.target.distance_to(ai_node.node.global_position) < 2:
							ai_node.set_state(AIState.IDLE)
					else:
						ai_node.state_timeout -= delta
						var diff = ai_node.target - ai_node.node.global_position
						ai_node.node.move(diff.x, diff.y)
				AIState.CHASE:
					if direction_to_player.length() < 70:
						ai_node.node.attack(direction_to_player.x, direction_to_player.y)
					elif direction_to_player.length() < 250:
						ai_node.node.move(direction_to_player.x, direction_to_player.y)
					else:
						ai_node.set_state(AIState.IDLE)

