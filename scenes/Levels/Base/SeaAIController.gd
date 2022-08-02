extends Node

enum AIState {
	FINDING_TARGET
	APPROACHING
	ATTACKING
}


class SeaAINode:
	var state
	var node: Node
	var target: Vector2
	func _init(_node):
		node = _node
		state = AIState.FINDING_TARGET
		target = Vector2.ZERO
		
	func set_state(next_state):
		state = next_state


var ai_nodes = []
var is_ai_enabled = true


func disable_ai():
	is_ai_enabled = false
	
	
func enable_ai():
	is_ai_enabled = true


func _ready():
	for prop in get_owner().get_node("Objects/Props").get_children():
		if prop.is_in_group("AI") and prop.is_in_group("Sea"):
			ai_nodes.append(SeaAINode.new(prop))


func _process(delta):
	if not is_ai_enabled:
		return
	for i in range(ai_nodes.size() - 1, -1, -1):
		var ai_node = ai_nodes[i]
		if ai_node.node == null:
			ai_nodes.remove(i)
			return
			
		match(ai_node.state):
			AIState.FINDING_TARGET:
				var attack_nodes = $AttackNodes.get_children()
				
				var best_node_index = 0
				var closest_distance = 9999999
				for index in range(0, len(attack_nodes)):
					var node = attack_nodes[index]
					var distance = ai_node.node.global_position.distance_to(node.global_position)
					if distance < closest_distance:
						best_node_index = index
						closest_distance = distance
				ai_node.target = attack_nodes[best_node_index].global_position
				var direction = ai_node.target - ai_node.node.global_position
				ai_node.set_state(AIState.APPROACHING)
			AIState.APPROACHING:
				if ai_node.target.distance_to(ai_node.node.global_position) < 5:
					ai_node.set_state(AIState.ATTACKING)
					return
				var direction = ai_node.target - ai_node.node.global_position
				ai_node.node.move(direction.x, direction.y)
			AIState.ATTACKING:
				# TODO: attack
				pass


func _on_Props_prop_added(prop):
	if prop.is_in_group("AI") and prop.is_in_group("Sea"):
		ai_nodes.append(SeaAINode.new(prop))
