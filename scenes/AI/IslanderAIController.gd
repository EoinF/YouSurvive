extends "res://scripts/goals.gd"

export var MIN_IDLE_DURATION = 0.0
export var MAX_IDLE_DURATION = 0.0
export var EXPLORATION_NODES_PATH: NodePath = "ExplorationNodes"
export var ISLANDER_PATH: NodePath = "../Objects/Props/Islander"
export var PATHFINDER_PATH: NodePath = "../Pathfinder"

var NEW_OBJECT_RECOGNISE_TIME = 0.5
var STEERING_TIMEOUT_SECONDS = 2.5
var INVESTIGATE_TIMEOUT_SECONDS = 6
var RAFT_ERROR_MARGIN = 10

var goals = []
var current_goal = null

var current_direction: Vector2 = Vector2.ZERO
var exploration_nodes = []
var current_move_path = []
var current_exploration_target: Node = null
var current_target: Node = null
var current_enemy: Node = null

var objects_in_view_unrecognised = {}
var objects_in_view = {}
var seen_targets = {}

var is_paused = true
var idle_timeout = -1.0
var pathfinder_offset: Vector2
var raft: Node2D
var desired_raft_y
var steering_direction = 0
var steering_timeout = -1
var investigate_timeout = -1

var rand = RandomNumberGenerator.new()


func _ready():
	rand.randomize()
	goals.push_back(IdleGoal.new())
	goals.push_back(DodgeGoal.new("boar"))
	goals.push_back(DodgeGoal.new("porcupine"))
	goals.push_back(DodgeGoal.new("crab"))
	current_goal = goals[0]
	
	var exploration_nodes_parent = get_node(EXPLORATION_NODES_PATH)
	if exploration_nodes_parent == null:
		return
	exploration_nodes = exploration_nodes_parent.get_children()
	exploration_nodes.shuffle()


func get_pathfinder_offset():
	 return get_node(PATHFINDER_PATH).global_position / 16


func add_kill_goal(target_type, limit):
	goals.push_back(LocateGoal.new(
		target_type,
		limit
	))
	goals.push_back(KillGoal.new(
		target_type, limit
	))


func add_steer_goal(raft_node):
	raft = raft_node
	goals.push_back(SteerGoal.new("sea_rock", raft_node))


func on_update_current_move_path():
	get_node("DebugPathMap").set_path(current_move_path)


func add_collection_goal(target_type, limit):
	goals.push_back(LocateGoal.new(
		target_type,
		limit
	))
	goals.push_back(CollectGoal.new(
		target_type,
		limit
	))


func add_investigation_goal(target_type):
	goals.push_back(InvestigateGoal.new(
		target_type
	))


func _process(delta):
	if is_paused:
		return
		
	# Objects take time to be recognised for the AI
	# This prevents them from instantly reacting
	# because of balance considerations for when the
	# player has to control the islander instead
	for object_type in objects_in_view_unrecognised.keys():
		var objects_of_type = objects_in_view_unrecognised[object_type]
		for object_id in objects_of_type.keys():
			var object = objects_of_type[object_id]
			# Special case for sharks since they're unreachable
			# until very close to the raft anyway
			if object_type == "shark":
				if object["node"].is_struggling:
					objects_of_type.erase(object_id)
					objects_in_view[object_type][object_id] = object["node"]
				continue
				
			object["time_remaining"] -= delta
			if object["time_remaining"] <= 0:
				objects_of_type.erase(object_id)
				objects_in_view[object_type][object_id] = object["node"]
	
	$DebugPathMap.position = get_node(PATHFINDER_PATH).global_position
		
	var islander = get_node(ISLANDER_PATH)
	var owner_context = {
		inventory = islander.item_type_to_slot,
		objects_in_view = objects_in_view,
		seen_targets = seen_targets,
		islander_position = islander.global_position,
		current_direction = current_direction,
		next_move_node = current_move_path.front() if len(current_move_path) > 0 else null,
		idle_timeout = idle_timeout,
		steering_timeout = steering_timeout,
		steering_direction = steering_direction,
		investigate_timeout = investigate_timeout
	}
	
	var current_priority = current_goal.get_priority(owner_context)
	for goal in goals:
		var next_priority = goal.get_priority(owner_context)
		if next_priority > current_priority:
			current_goal = goal
			current_priority = next_priority
	
	if current_goal.goal_type == GoalTypes.IDLE:
		current_direction = Vector2.ZERO
		idle_timeout -= delta
	else:
		idle_timeout = -1
		
	if steering_timeout > 0:
		steering_timeout -= delta
	
	match current_goal.goal_type:
		GoalTypes.KILL_ENEMY:
			$Behaviours.kill_enemy(self, islander)
		GoalTypes.DODGE_ENEMY:
			$Behaviours.dodge_enemy(self, islander)
		GoalTypes.LOCATE:
			$Behaviours.locate(self, islander)
		GoalTypes.COLLECT:
			$Behaviours.collect(self, islander)
		GoalTypes.STEER_RAFT:
			$Behaviours.steer_raft(self, islander)
		GoalTypes.INVESTIGATE:
			$Behaviours.investigate(self, islander)
	
	
	if current_goal.goal_type != GoalTypes.DODGE_ENEMY and current_goal.goal_type != GoalTypes.KILL_ENEMY:
		current_enemy = null
	
	if current_direction.length() > 0:
		islander.move(current_direction.x, current_direction.y)


func _get_closest_enemy_in_path(target_type):
	if len(current_move_path) == 0:
		return null
	var islander_position = get_node(ISLANDER_PATH).global_position
	var target_position = current_move_path[0] * 16.0
	var direction_to_target = (target_position - islander_position).normalized()
		
	var closest_node = null
	var distance_to_closest = INF
	for node in objects_in_view[target_type].values():
		if node.is_alive():
			var enemy_position = node.global_position
			var direction_to_enemy = (enemy_position - islander_position).normalized()
		
			var angle_between_directions = acos(direction_to_enemy.dot(direction_to_target))
			if angle_between_directions < PI / 4.0:
				var distance_to_current = islander_position.distance_to(enemy_position)
				if distance_to_closest > distance_to_current:
					closest_node = node
					distance_to_closest = distance_to_current
	return closest_node


func _get_closest_target_of_type(target_type, default_node = null):
	var islander_position = get_node(ISLANDER_PATH).global_position
	var closest_node = default_node
	var distance_to_closest = INF
	for node in objects_in_view[target_type].values():
		# Skip dead targets
		if node.has_method("is_alive") and not node.is_alive():
			continue

		var distance_to_current = islander_position.distance_to(node.global_position)
		if distance_to_closest > distance_to_current:
			closest_node = node
			distance_to_closest = distance_to_current
			
	for i in range(len(seen_targets[target_type]) - 1, -1, -1):
		var node = seen_targets[target_type][i]
		
		# Skip dead targets
		if not is_instance_valid(node) or (node.has_method("is_alive") and not node.is_alive()):
			seen_targets[target_type].remove(i)
			continue

		var distance_to_current = islander_position.distance_to(node.global_position)
		if distance_to_closest > distance_to_current:
			closest_node = node
			distance_to_closest = distance_to_current
	return closest_node


func _get_next_exploration_node():
	var islander_position = get_node(ISLANDER_PATH).global_position
	var best_h_score = INF
	var best_node_index = 0
	# Only take from the first few nodes to avoid re-exploring the same ones
	# so frequently
# warning-ignore:integer_division
	var exploration_nodes_cap = len(exploration_nodes) / 4
	for index in range(0, exploration_nodes_cap):
		var node = exploration_nodes[index]
		var distance_score = islander_position.distance_to(node.global_position)
		var h_score = distance_score + (index * index * 20)
		if h_score < best_h_score:
			best_h_score = h_score
			best_node_index = index
	
	# Take the best node and move it to the back to deprioritize it
	var best_node = exploration_nodes[best_node_index]
	exploration_nodes.remove(best_node_index)
	exploration_nodes.push_back(best_node)
	return best_node


func _get_path_in_direction_of(direction: Vector2, destination = null):
	var islander_position = get_node(ISLANDER_PATH).global_position
	var pathfinder = get_node(PATHFINDER_PATH)
	var max_distance = islander_position.distance_to(destination) if destination != null else 200
	return pathfinder.get_path_in_direction_of(islander_position, direction, max_distance)


func _get_quickest_path_to(from: Vector2, to: Vector2):
	var pathfinder = get_node(PATHFINDER_PATH)
	return pathfinder.get_quickest_path_to(from, to)


func _on_IslanderVisionSensor_body_entered(body):
	if not "object_type" in body:
		return
		
	if not body.object_type in objects_in_view:
		objects_in_view[body.object_type] = {}
		objects_in_view_unrecognised[body.object_type] = {}
		seen_targets[body.object_type] = []
	objects_in_view_unrecognised[body.object_type][body.get_instance_id()] = {
		"time_remaining": NEW_OBJECT_RECOGNISE_TIME,
		"node": body
	}


func _on_IslanderVisionSensor_body_exited(body):
	if not "object_type" in body:
		return
		
	objects_in_view[body.object_type].erase(body.get_instance_id())
	objects_in_view_unrecognised[body.object_type].erase(body.get_instance_id())


func _on_IslanderVisionSensor_area_entered(area):
	var object_node = area.get_parent()
	if not "object_type" in object_node:
		return
	if not object_node.object_type in objects_in_view:
		objects_in_view[object_node.object_type] = {}
		objects_in_view_unrecognised[object_node.object_type] = {}
		seen_targets[object_node.object_type] = []
	
	objects_in_view_unrecognised[object_node.object_type][object_node.get_instance_id()] = {
		"time_remaining": NEW_OBJECT_RECOGNISE_TIME,
		"node": object_node
	}


func _on_IslanderVisionSensor_area_exited(area):
	var object_node = area.get_parent()
	if not "object_type" in object_node:
		return
	
	var area_id = area.get_parent().get_instance_id()
	objects_in_view[object_node.object_type].erase(area_id)
	objects_in_view_unrecognised[object_node.object_type].erase(area_id)


func _start_new_target_animation(target):
	current_direction = Vector2.ZERO
	var islander = get_node(ISLANDER_PATH)
	
	# Skip the animation if the islander is the one that put the target there
	if target.has_method("get_owner_instance_id") and target.get_owner_instance_id() == islander.get_instance_id():
		return
	
	var current_position: Vector2 = islander.global_position
	var target_position: Vector2 = target.global_position
	var direction = (target_position - current_position).normalized()
	if abs(direction.x) < 0.2:
		direction.x = 0
	if abs(direction.y) < 0.2:
		direction.y = 0
	islander.move(direction.x, direction.y)
	
	
	is_paused = true
	islander.start_target_spotted_emote(funcref(self, "_on_finish_animation"))


func _set_current_kill_target(new_target):
	current_enemy = new_target
	if not current_goal.target in seen_targets:
		seen_targets[current_goal.target] = []
	if not current_enemy in seen_targets[current_goal.target]:
		seen_targets[current_goal.target].push_back(current_enemy)


func _set_current_target(new_target):
	var islander = get_node(ISLANDER_PATH)
	current_target = new_target
	current_move_path = _get_quickest_path_to(islander.global_position, current_target.get_resting_position())
	on_update_current_move_path()
	
	if not current_goal.target in seen_targets:
		seen_targets[current_goal.target] = []
	if not current_target in seen_targets[current_goal.target]:
		seen_targets[current_goal.target].push_back(current_target)
		_start_new_target_animation(current_target)


func _on_finish_animation():
	is_paused = false
