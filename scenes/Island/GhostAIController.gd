extends Node

var DESIRED_DISTANCE_FROM_PLAYER = 80


enum AIState {
	IDLE
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
	for prop in get_owner().get_node("Objects/Props").get_children():
		if prop.is_in_group("Ghost"):
			ai_nodes.append(AINode.new(prop))


func _process(delta):
	if not is_ai_enabled:
		return
	for i in range(ai_nodes.size() - 1, -1, -1):
		var ai_node = ai_nodes[i]
		if ai_node.node == null:
			ai_nodes.remove(i)
		else:
			var islander_position = get_owner().get_node("Objects/Props/Islander").global_position
			var ai_position = ai_node.node.global_position
			var direction_to_player = islander_position - ai_position
			
			var direction_to_move
			if direction_to_player.length() < DESIRED_DISTANCE_FROM_PLAYER - 1:
				direction_to_move = -direction_to_player
			elif direction_to_player.length() > DESIRED_DISTANCE_FROM_PLAYER:
				direction_to_move = direction_to_player
			else:
				break
				
			reposition_on_collide_with_wall(direction_to_player, ai_node)
				
			ai_node.node.move(direction_to_move.x, direction_to_move.y)


func reposition_on_collide_with_wall(direction_to_player, ai_node):
	if ai_node.node.is_colliding():
		ai_node.node.global_position += 2 * direction_to_player
		
		if ai_node.node.is_colliding():
			# Rotate 90 degrees
			ai_node.node.global_position -= direction_to_player
			ai_node.node.global_position += Vector2(direction_to_player.y, direction_to_player.x)
		
			if ai_node.node.is_colliding():
				# Rotate 90 degrees the other way
				ai_node.node.global_position -= 2 * Vector2(direction_to_player.y, direction_to_player.x)


func _on_Props_prop_added(prop):
	if prop.is_in_group("Ghost"):
		ai_nodes.append(AINode.new(prop))
