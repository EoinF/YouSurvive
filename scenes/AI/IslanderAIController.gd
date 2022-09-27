extends "res://scripts/goals.gd"

export var MIN_IDLE_DURATION = 0.0
export var MAX_IDLE_DURATION = 0.0
export var EXPLORATION_NODES_PATH: NodePath = "ExplorationNodes"
export var ISLANDER_PATH: NodePath = "../Objects/Props/Islander"
export var PATHFINDER_PATH: NodePath = "../Pathfinder"

var NEW_OBJECT_RECOGNISE_TIME = 0.5
var STEERING_TIMEOUT_SECONDS = 2.5
var RAFT_ERROR_MARGIN = 10

var goals = []
var current_goal = null

var current_direction: Vector2 = Vector2.ZERO
var exploration_nodes = []
var current_move_path = []
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
		steering_direction = steering_direction
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
			kill_enemy()
		GoalTypes.DODGE_ENEMY:
			dodge_enemy()
		GoalTypes.LOCATE:
			locate()
		GoalTypes.COLLECT:
			collect()
		GoalTypes.STEER_RAFT:
			steer_raft()
	
	
	if current_goal.goal_type != GoalTypes.DODGE_ENEMY and current_goal.goal_type != GoalTypes.KILL_ENEMY:
		current_enemy = null
	
	if current_direction.length() > 0:
		islander.move(current_direction.x, current_direction.y)


func locate():
	var islander = get_node(ISLANDER_PATH)
	if current_target == null:
		current_target = _get_next_exploration_node()
		current_move_path = _get_quickest_path_to(islander.global_position, current_target.get_resting_position())
		on_update_current_move_path()
	var current_tile = Vector2(floor(islander.global_position.x / 16), floor(islander.global_position.y / 16))
		
	while len(current_move_path) != 0 and \
		current_tile.distance_to(get_pathfinder_offset() + current_move_path[0]) <= 1.0:
		current_move_path.pop_front()
		
	on_update_current_move_path()
	if len(current_move_path) == 0:
		idle_timeout = rand.randf_range(MIN_IDLE_DURATION, MAX_IDLE_DURATION)
		current_direction = Vector2.ZERO
		current_target = _get_next_exploration_node()
		current_move_path = _get_quickest_path_to(islander.global_position, current_target.get_resting_position())
		on_update_current_move_path()
	else:
		var next_tile = current_move_path[0]
		current_direction = (get_pathfinder_offset() + next_tile - current_tile).normalized()


func collect():
	var islander = get_node(ISLANDER_PATH)
	
	if current_target == null or current_target.object_type != current_goal.target:
		var new_target = _get_closest_target_of_type(current_goal.target)
		_set_current_target(new_target)
		return
	
	if not current_target.get_instance_id() in objects_in_view[current_goal.target]:
		var closest_target = _get_closest_target_of_type(current_goal.target)
		if closest_target != current_target:
			_set_current_target(closest_target)
			return
	
	
	var current_tile = Vector2(floor(islander.global_position.x / 16), floor(islander.global_position.y / 16))
	
	if current_target != null:
		while len(current_move_path) != 0 and current_tile.distance_to(current_move_path[0]) <= 1.0:
			current_move_path.pop_front()
		
		on_update_current_move_path()
		if len(current_move_path) == 0:
			if current_target.has_method("interact"):
				current_target.interact()
			islander.pick_up_item(current_target.object_type)
			var index = seen_targets[current_target.object_type].find(current_target)
			seen_targets[current_target.object_type].remove(index)
			current_target = null
		else:
			var next_tile = current_move_path[0]
			current_direction = (get_pathfinder_offset() + next_tile - current_tile).normalized()


func dodge_enemy():
	var islander_position = get_node(ISLANDER_PATH).global_position
	
	var closest_enemy = _get_closest_enemy_in_path(current_goal.target)
	
	if current_enemy == null or not current_enemy.is_alive() or closest_enemy.global_position.distance_to(islander_position) < 20:
		current_enemy = closest_enemy
		var direction_to_target = current_enemy.global_position - islander_position
		var dodge_left = Vector2(-direction_to_target.y, direction_to_target.x)
		var dodge_right = Vector2(direction_to_target.y, -direction_to_target.x)
		
		var path_left: Array = _get_path_in_direction_of(dodge_left).slice(0, 8)
		var path_right: Array = _get_path_in_direction_of(dodge_right).slice(0, 8)
		
		var chosen_path = path_left if len(path_left) > len(path_right) else path_right
		if len(chosen_path) <= 2:
			chosen_path = _get_path_in_direction_of(-direction_to_target).slice(0, 8)
		var path_back_to_destination = _get_quickest_path_to(chosen_path.back() * 16, current_move_path.back() * 16)
		current_move_path = chosen_path + path_back_to_destination
		on_update_current_move_path()
	else:
		var current_tile = Vector2(floor(islander_position.x / 16), floor(islander_position.y / 16))
		
		while len(current_move_path) != 0 and \
		current_tile.distance_to(current_move_path[0] + get_pathfinder_offset()) <= 1.0:
			current_move_path.pop_front()
			
		on_update_current_move_path()
		if len(current_move_path) > 0:
			var next_tile = current_move_path[0]
			current_direction = (get_pathfinder_offset() + next_tile - current_tile).normalized()


func kill_enemy():
	var islander = get_node(ISLANDER_PATH)
	if islander.is_attacking():
		return
	var islander_position = islander.global_position
	
	var closest_enemy = _get_closest_target_of_type(current_goal.target, current_enemy)
	var distance_to_closest_enemy = islander_position.distance_to(closest_enemy.global_position)
	var half_distance_along_path = len(current_move_path) * 16 / 2.0
	
	if current_enemy == null or \
		not current_enemy.is_alive() or \
		(current_enemy != closest_enemy and distance_to_closest_enemy < half_distance_along_path):
		_set_current_kill_target(closest_enemy)
		current_move_path = _get_quickest_path_to(islander_position, current_enemy.global_position)
		if current_move_path == null:
			return
			
		on_update_current_move_path()
	else:
		var direction_to_target = current_enemy.global_position - islander_position
		if direction_to_target.length() < 100:
			if islander.has_item("stick") and direction_to_target.length() < 25:
				islander.attack(direction_to_target.x, direction_to_target.y)
				return
			if islander.has_item("stone"):
				# ensure there is a clear path to the enemy with nothing blocking it
				# so the stone will actually reach it
				var straight_path_to_enemy = _get_path_in_direction_of(direction_to_target, current_enemy.global_position)
				
				if (straight_path_to_enemy.back() * 16).distance_to(current_enemy.global_position) <= 16:
					islander.throw_stone(direction_to_target.x, direction_to_target.y)
					return
	
	var current_tile = Vector2(floor(islander_position.x / 16), floor(islander_position.y / 16))

	while len(current_move_path) != 0 and \
		current_tile.distance_to(current_move_path[0] + get_pathfinder_offset()) <= 1.0:
		current_move_path.pop_front()
		
	on_update_current_move_path()
	if len(current_move_path) > 0:
		var next_tile = current_move_path[0]
		current_direction = (get_pathfinder_offset() + next_tile - current_tile).normalized()
	else:
		current_move_path = _get_quickest_path_to(islander_position, current_enemy.global_position)
		on_update_current_move_path()


func steer_raft():
	var islander_position = get_node(ISLANDER_PATH).global_position
	if steering_direction != 0:
		if raft.steering_direction != steering_direction:
			var current_tile = Vector2(floor(islander_position.x / 16), floor(islander_position.y / 16))
			
			while len(current_move_path) != 0 and \
				current_tile.distance_to(current_move_path[0] + get_pathfinder_offset()) <= 1.0:
				current_move_path.pop_front()
			on_update_current_move_path()
				
			if current_move_path.empty():
				steering_direction = 0
				idle_timeout = 0.2
				return
			
			var next_tile = current_move_path[0]
			current_direction = (get_pathfinder_offset() + next_tile - current_tile).normalized()
			return
		current_direction = Vector2.ZERO
		return
		
	if steering_timeout > 0:
		return
	
	var raft_top = raft.get_y_top() - RAFT_ERROR_MARGIN
	var raft_bottom = raft.get_y_bottom() + RAFT_ERROR_MARGIN
	var raft_left = raft.get_x_left()
	var raft_right = raft.get_x_right()
	
	# Find the closest obstacle
	var obstacles: Array = objects_in_view["sea_rock"].values()
	var closest_obstacle = null
	var obstacles_left = []
	var obstacles_right = []
	for obstacle in obstacles:
		var obstacle_x = int(obstacle.global_position.x)
		var obstacle_y = int(obstacle.global_position.y)
		if obstacle_y < raft_top:
			if obstacle_x > raft_left and obstacle_x < raft_right:
				obstacles_left.append(obstacle)
			continue
		if obstacle_y > raft_bottom:
			if obstacle_x > raft_left and obstacle_x < raft_right:
				obstacles_right.append(obstacle)
			continue
		if closest_obstacle == null or closest_obstacle.global_position.x > obstacle_x:
			closest_obstacle = obstacle
	
	if closest_obstacle == null:
		return
	
	var obstacle_y = int(closest_obstacle.global_position.y)
	var distance_up = raft_bottom - obstacle_y
	var distance_down = obstacle_y - raft_top
	
	# Figure out which obstacles would be hit by moving
	var up_penalty = 0
	for obstacle in obstacles_left:
		if raft_top - (distance_up + RAFT_ERROR_MARGIN) < int(obstacle.global_position.y):
			up_penalty += 1
	var down_penalty = 0
	for obstacle in obstacles_right:
		if raft_bottom + (distance_down + RAFT_ERROR_MARGIN) > int(obstacle.global_position.y):
			down_penalty += 1
	
	# If moving up/down results in more collisions then don't move at all
	if up_penalty > 1 and down_penalty > 1:
		steering_timeout = STEERING_TIMEOUT_SECONDS
		return
	
	var should_go_up = up_penalty < down_penalty
	if up_penalty == down_penalty:
		should_go_up = distance_up < distance_down
	
	if should_go_up:
		desired_raft_y = raft_top - distance_up
		steering_direction = -1
		current_move_path = _get_quickest_path_to(islander_position, raft.get_node("SteerLeftNode").global_position)
	else:
		desired_raft_y = raft_top + distance_down
		steering_direction = +1
		current_move_path = _get_quickest_path_to(islander_position, raft.get_node("SteerRightNode").global_position)
	
	steering_timeout = STEERING_TIMEOUT_SECONDS


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
		if node == null or (node.has_method("is_alive") and not node.is_alive()):
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
	for index in range(0, len(exploration_nodes)):
		var node = exploration_nodes[index]
		var distance_score = islander_position.distance_to(node.global_position)
		var h_score = distance_score + (index * index * 50)
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
