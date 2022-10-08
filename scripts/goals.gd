extends Node

enum GoalTypes {
	IDLE
	LOCATE
	COLLECT
	DODGE_ENEMY
	KILL_ENEMY
	STEER_RAFT
}

class Goal:
	var goal_type
	var target
	var limit
	
	func _init(_target, _limit):
		self.target = _target
		self.limit = _limit
		
	func get_priority(_owner_context):
		return 0


class IdleGoal extends Goal:
	func _init().(null, null):
		self.goal_type = GoalTypes.IDLE
	
	func get_priority(_owner_context):
		return 0


class LocateGoal extends Goal:
	func _init(_target, _limit).(_target, _limit):
		self.goal_type = GoalTypes.LOCATE
		
	func is_in_view(object_dict, type):
		return object_dict.has(type) \
			and not object_dict[type].empty()
	
	func get_priority(_owner_context):
		if _owner_context.idle_timeout > 0:
			# Avoid idling in the face of enemies
			if not is_in_view(_owner_context.objects_in_view, "crab") and \
				not is_in_view(_owner_context.objects_in_view, "shark") and \
				not is_in_view(_owner_context.objects_in_view, "boar") and \
				not is_in_view(_owner_context.objects_in_view, "porcupine"):
				return -1
		if (not target in _owner_context.inventory) or (_owner_context.inventory[target].amount < limit):
			return 1
		return -1


class CollectGoal extends Goal:
	func _init(_target, _limit).(_target, _limit):
		self.goal_type = GoalTypes.COLLECT
	
	func get_priority(_owner_context):
		var is_limit_reached = (target in _owner_context.inventory) and (_owner_context.inventory[target].amount >= limit)
		var is_target_visible = target in _owner_context.objects_in_view \
			and len(_owner_context.objects_in_view[target]) > 0
		var is_targets_previously_seen = target in _owner_context.seen_targets \
			and len(_owner_context.seen_targets[target]) > 0
		var has_known_target = is_target_visible or is_targets_previously_seen
		if is_limit_reached or not has_known_target:
			return -1
		for object in _owner_context.objects_in_view[target].values():
			if object.global_position.distance_to(_owner_context.islander_position) < 30:
				return 4
		return 2


class DodgeGoal extends Goal:
	func _init(_target).(_target, 0):
		self.goal_type = GoalTypes.DODGE_ENEMY
		
	func get_priority(_owner_context):
		if target in _owner_context.objects_in_view and _owner_context.next_move_node != null:
			var target_position = _owner_context.next_move_node * 16.0
			var direction_to_target = (target_position - _owner_context.islander_position).normalized()
	
			for object in _owner_context.objects_in_view[target].values():
				if object.has_method("is_alive") and object.is_alive() \
				and object.global_position.distance_to(_owner_context.islander_position) < 70:
					var direction_to_enemy = (object.global_position - _owner_context.islander_position).normalized()
					
					var angle_between_directions = acos(direction_to_enemy.dot(direction_to_target))
					if angle_between_directions < PI / 4.0:
						return 3
		
		return -1


class KillGoal extends Goal:
	func _init(_target, _limit).(_target, _limit):
		self.goal_type = GoalTypes.KILL_ENEMY
		
	func get_priority(_owner_context):
		var has_stone = "stone" in _owner_context.inventory \
			and _owner_context.inventory["stone"].amount > 0
		var has_stick = "stick" in _owner_context.inventory \
			and _owner_context.inventory["stick"].amount > 0
			
		var has_weapon = has_stone or has_stick
		if has_weapon and target in _owner_context.objects_in_view:
			for object in _owner_context.objects_in_view[target].values():
				if object.has_method("is_alive") and object.is_alive():
					return 5
		
		if has_weapon and target in _owner_context.seen_targets:
			for object in _owner_context.seen_targets[target]:
				if is_instance_valid(object) and object.has_method("is_alive") and object.is_alive():
					return 5
		return -1


class SteerGoal extends Goal:
	var ERROR_MARGIN = 10
	var raft: Node2D
	func _init(_target_to_avoid, _raft_node).(_target_to_avoid, 0):
		self.goal_type = GoalTypes.STEER_RAFT
		self.raft = _raft_node
		
	func get_priority(_owner_context):
		if not target in _owner_context.objects_in_view:
			return -1
		if _owner_context.steering_direction == 0 and _owner_context.steering_timeout > 0:
			return -1
		
		var raft_top = raft.get_y_top() - ERROR_MARGIN
		var raft_bottom = raft.get_y_bottom() + ERROR_MARGIN
		
		for object in _owner_context.objects_in_view[target].values():
			var obstacle_y_top = object.global_position.y
			var obstacle_y_bottom = object.global_position.y + object.get_height()
			if obstacle_y_bottom > raft_top and obstacle_y_top < raft_bottom:
				return 4
		return -1
