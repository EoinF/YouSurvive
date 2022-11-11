extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func locate(context, ai_node):
	if context.current_target == null:
		if context.current_exploration_target == null:
			context.current_exploration_target = context._get_next_exploration_node()
			
		context.current_target = context.current_exploration_target
		context.current_move_path = context._get_quickest_path_to(ai_node.global_position, context.current_target.get_resting_position())
		context.on_update_current_move_path()
	var current_tile = Vector2(floor(ai_node.global_position.x / 16), floor(ai_node.global_position.y / 16))
		
	while len(context.current_move_path) != 0 and \
		current_tile.distance_to(context.get_pathfinder_offset() + context.current_move_path[0]) <= 1.0:
		context.current_move_path.pop_front()
		
	context.on_update_current_move_path()
	if len(context.current_move_path) == 0:
		context.idle_timeout = context.rand.randf_range(context.MIN_IDLE_DURATION, context.MAX_IDLE_DURATION)
		context.current_direction = Vector2.ZERO
		context.current_exploration_target = context._get_next_exploration_node()
		context.current_target = context.current_exploration_target
		context.current_move_path = context._get_quickest_path_to(ai_node.global_position, context.current_target.get_resting_position())
		context.on_update_current_move_path()
	else:
		var next_tile = context.current_move_path[0]
		context.current_direction = (context.get_pathfinder_offset() + next_tile - current_tile).normalized()


func collect(context, ai_node):
	if context.current_target == null or context.current_target.object_type != context.current_goal.target:
		var new_target = context._get_closest_target_of_type(context.current_goal.target)
		context._set_current_target(new_target)
		return
	
	if not context.current_target.get_instance_id() in context.objects_in_view[context.current_goal.target]:
		var closest_target = context._get_closest_target_of_type(context.current_goal.target)
		if closest_target != context.current_target:
			context._set_current_target(closest_target)
			return
	
	
	var current_tile = Vector2(floor(ai_node.global_position.x / 16), floor(ai_node.global_position.y / 16))
	
	if context.current_target != null:
		while len(context.current_move_path) != 0 and current_tile.distance_to(context.current_move_path[0]) <= 1.0:
			context.current_move_path.pop_front()
		
		context.on_update_current_move_path()
		if len(context.current_move_path) == 0:
			if context.current_target.has_method("interact"):
				context.current_target.interact()
			ai_node.pick_up_item(context.current_target.object_type)
			var index = context.seen_targets[context.current_target.object_type].find(context.current_target)
			context.seen_targets[context.current_target.object_type].remove(index)
			context.current_target = null
		else:
			var next_tile = context.current_move_path[0]
			context.current_direction = (context.get_pathfinder_offset() + next_tile - current_tile).normalized()


func dodge_enemy(context, ai_node):
	var ai_node_position = ai_node.global_position
	
	var closest_enemy = context._get_closest_enemy_in_path(context.current_goal.target)
	
	if context.current_enemy == null or not context.current_enemy.is_alive() or closest_enemy.global_position.distance_to(ai_node_position) < 20:
		context.current_enemy = closest_enemy
		var direction_to_target = context.current_enemy.global_position - ai_node_position
		var dodge_left = Vector2(-direction_to_target.y, direction_to_target.x)
		var dodge_right = Vector2(direction_to_target.y, -direction_to_target.x)
		
		var path_left: Array = context._get_path_in_direction_of(dodge_left).slice(0, 8)
		var path_right: Array = context._get_path_in_direction_of(dodge_right).slice(0, 8)
		
		var chosen_path = path_left if len(path_left) > len(path_right) else path_right
		if len(chosen_path) <= 2:
			chosen_path = context._get_path_in_direction_of(-direction_to_target).slice(0, 8)
		var path_back_to_destination = context._get_quickest_path_to(chosen_path.back() * 16, context.current_move_path.back() * 16)
		context.current_move_path = chosen_path + path_back_to_destination
		context.on_update_current_move_path()
	else:
		var current_tile = Vector2(floor(ai_node_position.x / 16), floor(ai_node_position.y / 16))
		
		while len(context.current_move_path) != 0 and \
		current_tile.distance_to(context.current_move_path[0] + context.get_pathfinder_offset()) <= 1.0:
			context.current_move_path.pop_front()
			
		context.on_update_current_move_path()
		if len(context.current_move_path) > 0:
			var next_tile = context.current_move_path[0]
			context.current_direction = (context.get_pathfinder_offset() + next_tile - current_tile).normalized()


func kill_enemy(context, ai_node):
	if ai_node.is_attacking():
		return
	var ai_node_position = ai_node.global_position
	
	var closest_enemy = context._get_closest_target_of_type(context.current_goal.target, context.current_enemy)
	var distance_to_closest_enemy = ai_node_position.distance_to(closest_enemy.global_position)
	var half_distance_along_path = len(context.current_move_path) * 16 / 2.0
	
	if context.current_enemy == null or \
		not context.current_enemy.is_alive() or \
		(context.current_enemy != closest_enemy and distance_to_closest_enemy < half_distance_along_path):
		context._set_current_kill_target(closest_enemy)
		context.current_move_path = context._get_quickest_path_to(ai_node_position, context.current_enemy.global_position)
		if context.current_move_path == null:
			return
			
		context.on_update_current_move_path()
	else:
		var direction_to_target = context.current_enemy.global_position - ai_node_position
		if direction_to_target.length() < 100:
			if ai_node.has_item("stick") and direction_to_target.length() < 25:
				ai_node.attack(direction_to_target.x, direction_to_target.y)
				return
			if ai_node.has_item("stone"):
				# ensure there is a clear path to the enemy with nothing blocking it
				# so the stone will actually reach it
				var straight_path_to_enemy = context._get_path_in_direction_of(direction_to_target, context.current_enemy.global_position)
				
				if (straight_path_to_enemy.back() * 16).distance_to(context.current_enemy.global_position) <= 16:
					ai_node.throw_stone(direction_to_target.x, direction_to_target.y)
					return
	
	var current_tile = Vector2(floor(ai_node_position.x / 16), floor(ai_node_position.y / 16))

	while len(context.current_move_path) != 0 and \
		current_tile.distance_to(context.current_move_path[0] + context.get_pathfinder_offset()) <= 1.0:
		context.current_move_path.pop_front()
		
	context.on_update_current_move_path()
	if len(context.current_move_path) > 0:
		var next_tile = context.current_move_path[0]
		context.current_direction = (context.get_pathfinder_offset() + next_tile - current_tile).normalized()
	else:
		context.current_move_path = context._get_quickest_path_to(ai_node_position, context.current_enemy.global_position)
		context.on_update_current_move_path()


func steer_raft(context, ai_node):
	var raft = context.raft
	var ai_node_position = ai_node.global_position
	if context.steering_direction != 0:
		if context.raft.steering_direction != context.steering_direction:
			var current_tile = Vector2(floor(ai_node_position.x / 16), floor(ai_node_position.y / 16))
			
			while len(context.current_move_path) != 0 and \
				current_tile.distance_to(context.current_move_path[0] + context.get_pathfinder_offset()) <= 1.0:
				context.current_move_path.pop_front()
			context.on_update_current_move_path()
				
			if context.current_move_path.empty():
				context.steering_direction = 0
				context.idle_timeout = 0.2
				return
			
			var next_tile = context.current_move_path[0]
			context.current_direction = (context.get_pathfinder_offset() + next_tile - current_tile).normalized()
			return
		context.current_direction = Vector2.ZERO
		return
		
	if context.steering_timeout > 0:
		return
	
	var raft_top = raft.get_y_top() - context.RAFT_ERROR_MARGIN
	var raft_bottom = raft.get_y_bottom() + context.RAFT_ERROR_MARGIN
	var raft_left = raft.get_x_left()
	var raft_right = raft.get_x_right()
	
	# Find the closest obstacle
	var obstacles: Array = context.objects_in_view["sea_rock"].values()
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
		if raft_top - (distance_up + context.RAFT_ERROR_MARGIN) < int(obstacle.global_position.y):
			up_penalty += 1
	var down_penalty = 0
	for obstacle in obstacles_right:
		if raft_bottom + (distance_down + context.RAFT_ERROR_MARGIN) > int(obstacle.global_position.y):
			down_penalty += 1
	
	# If moving up/down results in more collisions then don't move at all
	if up_penalty > 1 and down_penalty > 1:
		context.steering_timeout = context.STEERING_TIMEOUT_SECONDS
		return
	
	var should_go_up = up_penalty < down_penalty
	if up_penalty == down_penalty:
		should_go_up = distance_up < distance_down
	
	if should_go_up:
		context.desired_raft_y = raft_top - distance_up
		context.steering_direction = -1
		context.current_move_path = context._get_quickest_path_to(ai_node_position, raft.get_node("SteerLeftNode").global_position)
	else:
		context.desired_raft_y = raft_top + distance_down
		context.steering_direction = +1
		context.current_move_path = context._get_quickest_path_to(ai_node_position, raft.get_node("SteerRightNode").global_position)
	
	context.steering_timeout = context.STEERING_TIMEOUT_SECONDS


func investigate(context, ai_node):
	pass
