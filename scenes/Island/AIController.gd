extends Node

export var ISLANDER_PATH: NodePath = "../Objects/Props/Islander"

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
				state_timeout = node.min_idle_time + randf() * node.scale_idle_time
			AIState.WANDER:
				state_timeout = 1.0
			_:
				state_timeout = 0.0
		
		state = next_state


var ai_nodes = []
var is_ai_enabled = true
var is_peaceful = false
var speed_scaling = 1.0


func set_speed_scaling(new_scaling):
	speed_scaling = new_scaling
	for ai_node in ai_nodes:
		ai_node.node.set_speed_scaling(new_scaling)


func set_is_peaceful(new_value):
	is_peaceful = new_value


func disable_ai():
	is_ai_enabled = false
	
	
func enable_ai():
	is_ai_enabled = true


func _ready():
	for prop in get_owner().get_node("Objects/Props").get_children():
		if prop.is_in_group("AI") and not prop.is_in_group("Sea"):
			ai_nodes.append(AINode.new(prop))


func _process(delta):
	if not is_ai_enabled:
		return
	for i in range(ai_nodes.size() - 1, -1, -1):
		var ai_node = ai_nodes[i]
		if not is_instance_valid(ai_node.node):
			ai_nodes.remove(i)
		else:
			var islander_position = get_node(ISLANDER_PATH).global_position
			var direction_to_player = islander_position - ai_node.node.get_position()
			
			if direction_to_player.length() < 200:
				ai_node.set_state(AIState.CHASE)
				ai_node.state_timeout = 0
			
			if is_peaceful and ai_node.state == AIState.CHASE:
				ai_node.set_state(AIState.IDLE)
			
			match(ai_node.state):
				AIState.IDLE:
					if (ai_node.state_timeout > 0):
						ai_node.state_timeout -= delta
						ai_node.node.idle()
					else:
						ai_node.target = ai_node.node.get_wander_target()
						ai_node.set_state(AIState.WANDER)
				AIState.WANDER:
					if (ai_node.state_timeout < 0) or ai_node.target.distance_to(ai_node.node.get_position()) < 2:
							ai_node.set_state(AIState.IDLE)
					else:
						ai_node.state_timeout -= delta
						var diff = ai_node.target - ai_node.node.get_position()
						ai_node.node.move(diff.x, diff.y)
				AIState.CHASE:
					if direction_to_player.length() < 70:
						ai_node.node.attack(direction_to_player.x, direction_to_player.y)
					elif direction_to_player.length() < 250:
						ai_node.node.move(direction_to_player.x, direction_to_player.y)
					else:
						ai_node.set_state(AIState.IDLE)


func _on_Props_prop_added(prop):
	if prop.is_in_group("AI") and not prop.is_in_group("Sea"):
		ai_nodes.append(AINode.new(prop))
		prop.set_speed_scaling(speed_scaling)
