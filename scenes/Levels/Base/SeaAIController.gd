extends Node

enum AIState {
	FINDING_TARGET
	APPROACHING
	STRUGGLING
	WANDER
}


class SeaAINode:
	var state
	var node: Node
	var target: Node2D
	var wander_target: Vector2
	func _init(_node):
		node = _node
		state = AIState.FINDING_TARGET
		target = null
		
	func set_state(next_state):
		state = next_state
		
	func distance_to_target():
		return target.global_position.distance_to(node.global_position)


var ai_nodes = []
var is_ai_enabled = true


func disable_ai():
	is_ai_enabled = false
	
	
func enable_ai():
	is_ai_enabled = true


func _ready():
	for prop in get_owner().get_node("Objects/Props/SeaProps").get_children():
		if prop.is_in_group("AI") and prop.is_in_group("Sea"):
			ai_nodes.append(SeaAINode.new(prop))


func _process(_delta):
	if not is_ai_enabled:
		return
	for i in range(ai_nodes.size() - 1, -1, -1):
		var ai_node = ai_nodes[i]
		if ai_node.node == null:
			ai_nodes.remove(i)
			return
			
		match(ai_node.state):
			AIState.FINDING_TARGET:
				var attack_nodes = get_owner().get_node("Objects/Props/Raft/AttackNodes").get_children()
				
				var best_node_index = 0
				var closest_distance = 9999999
				for index in range(0, len(attack_nodes)):
					var node = attack_nodes[index]
					var distance = ai_node.node.global_position.distance_to(node.global_position)
					if distance < closest_distance:
						best_node_index = index
						closest_distance = distance
				ai_node.target = attack_nodes[best_node_index]
				ai_node.set_state(AIState.APPROACHING)
			AIState.APPROACHING:
				var direction = ai_node.target.global_position - ai_node.node.global_position
				if ai_node.distance_to_target() < 5:
					ai_node.set_state(AIState.STRUGGLING)
					ai_node.node.struggle(ai_node.target, direction)
					return
				ai_node.node.move(direction.x, direction.y)
			AIState.STRUGGLING:
				pass
			AIState.WANDER:
				if ai_node.wander_target.distance_to(ai_node.node.get_position()) < 5:
					ai_node.wander_target = ai_node.node.get_wander_target()
				else:
					var diff = ai_node.wander_target - ai_node.node.get_position()
					ai_node.node.wander(diff.x, diff.y)


func _on_Props_prop_added(prop):
	if prop.is_in_group("AI") and prop.is_in_group("Sea"):
		ai_nodes.append(SeaAINode.new(prop))


func _on_Raft_start_sinking():
	for ai_node in ai_nodes:
		ai_node.set_state(AIState.WANDER)
		ai_node.node.stop_struggling()
		ai_node.wander_target = ai_node.node.get_wander_target()
