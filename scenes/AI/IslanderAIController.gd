extends "res://scripts/goals.gd"

signal target_spotted

var goals = []
var current_goal = IdleGoal.new()

var exploration_nodes = []
var current_move_path = []
var current_target: Node = null
var objects_in_view = {}
var is_paused = false

func _ready():
	exploration_nodes = get_node("ExplorationNodes").get_children()
	exploration_nodes.shuffle()

func add_collection_goal(target_type, limit):
	goals.push_back(LocateGoal.new(
		target_type,
		10
	))
	goals.push_back(CollectGoal.new(
		target_type,
		10
	))


func _process(delta):
	if is_paused:
		return

	var owner_context = {
		objects_in_view = objects_in_view
	}
	
	var previous_goal = current_goal
	var current_priority = current_goal.get_priority(owner_context)
	for goal in goals:
		var next_priority = goal.get_priority(owner_context)
		if next_priority > current_priority:
			current_goal = goal
			current_priority = next_priority
	
	
	match current_goal.goal_type:
		GoalTypes.LOCATE:
			locate()
		GoalTypes.COLLECT:
			collect(previous_goal, current_goal)


func locate():
	if current_target == null:
		current_target = _get_next_exploration_node()
		current_move_path = _get_quickest_path_to(current_target)
	
	var islander = get_parent().get_node("Objects/Props/Islander")
	var current_tile = Vector2(floor(islander.global_position.x / 16), floor(islander.global_position.y / 16))
		
	while len(current_move_path) != 0 and current_tile.distance_to(current_move_path[0]) <= 1.0:
		current_move_path.pop_front()
		
	if len(current_move_path) == 0:
		current_target = _get_next_exploration_node()
		current_move_path = _get_quickest_path_to(current_target)
	else:
		var next_tile = current_move_path[0]
		var direction = next_tile - current_tile
		
		islander.move(direction.x, direction.y)


func collect(previous_goal: Goal, current_goal: Goal):
	if current_target == null or current_target.object_type != current_goal.target:
		current_target = _get_closest_target_of_type(current_goal.target)
		current_move_path = _get_quickest_path_to(current_target)
		_start_new_target_animation()
		return

	var islander = get_parent().get_node("Objects/Props/Islander")
	var current_tile = Vector2(floor(islander.global_position.x / 16), floor(islander.global_position.y / 16))
	
	if current_target != null:
		while len(current_move_path) != 0 and current_tile.distance_to(current_move_path[0]) <= 1.0:
			current_move_path.pop_front()
	
		if len(current_move_path) == 0:
			if current_target.has_method("interact"):
				current_target.interact()
			islander.pick_up_item(current_target.object_type)
			current_target = null
		else:
			var next_tile = current_move_path[0]
			var direction = next_tile - current_tile
			
			islander.move(direction.x, direction.y)


func _get_closest_target_of_type(target_type):
	var islander_position = get_parent().get_node("Objects/Props/Islander").global_position
	var closest_node = null
	var distance_to_closest = INF
	for node in objects_in_view[target_type].values():
		var distance_to_current = islander_position.distance_to(node.global_position)
		if distance_to_closest > distance_to_current:
			closest_node = node
			distance_to_closest = distance_to_current
	return closest_node


func _get_next_exploration_node():
	var islander_position = get_parent().get_node("Objects/Props/Islander").global_position
	var best_h_score = INF
	var best_node_index = 0
	for index in range(0, len(exploration_nodes)):
		var node = exploration_nodes[index]
		var distance_score = islander_position.distance_to(node.global_position)
		var h_score = distance_score + (index * index * 50)
		if h_score < best_h_score:
			best_h_score = h_score
			best_node_index = index
	
	var best_node = exploration_nodes[best_node_index]
	exploration_nodes.remove(best_node_index)
	exploration_nodes.push_back(best_node)
	return best_node


func _get_quickest_path_to(node):
	var islander_position = get_owner().get_node("Objects/Props/Islander").global_position
	var pathfinder = get_owner().get_node("Pathfinder")
	return pathfinder.get_quickest_path_to(islander_position, node.global_position)


func _on_IslanderVisionSensor_area_entered(area):
	var object_node = area.get_parent()
	if not object_node.object_type in objects_in_view:
		objects_in_view[object_node.object_type] = {}
	objects_in_view[object_node.object_type][object_node.get_instance_id()] = object_node


func _on_IslanderVisionSensor_area_exited(area):
	var object_node = area.get_parent()
	objects_in_view[object_node.object_type].erase(area.get_parent().get_instance_id())


func _start_new_target_animation():
	var islander = get_owner().get_node("Objects/Props/Islander")
	var current_position: Vector2 = islander.global_position
	var target_position: Vector2 = current_target.global_position
	var direction = (target_position - current_position).normalized()
	if abs(direction.x) < 0.2:
		direction.x = 0
	if abs(direction.y) < 0.2:
		direction.y = 0
	islander.move(direction.x, direction.y)
	
	is_paused = true
	islander.start_target_spotted_emote(funcref(self, "_on_finish_animation"))


func _on_finish_animation():
	is_paused = false
