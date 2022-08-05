extends Node

enum GoalTypes {
	IDLE
	LOCATE
	COLLECT
	DODGE_ENEMY
	KILL_ENEMY
	WANDER
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
	
	func get_priority(_owner_context):
		if _owner_context.num_exploration_nodes == 0:
			return -1
		if (not target in _owner_context.inventory) or (_owner_context.inventory[target].amount < limit):
			return 1
		return 0


class CollectGoal extends Goal:
	func _init(_target, _limit).(_target, _limit):
		self.goal_type = GoalTypes.COLLECT
	
	func get_priority(_owner_context):
		var is_limit_reached = (target in _owner_context.inventory) and (_owner_context.inventory[target].amount >= limit)
		if not is_limit_reached \
			and target in _owner_context.objects_in_view \
			and len(_owner_context.objects_in_view[target]) > 0:
			for object in _owner_context.objects_in_view[target].values():
				if object.global_position.distance_to(_owner_context.islander_position) < 30:
					return 4
			return 2
		
		return -1


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
		return -1


class WanderGoal extends Goal:
	func _init().(null, null):
		self.goal_type = GoalTypes.WANDER
	
	func get_priority(_owner_context):
		if _owner_context.wander_timeout > 0:
			return 1
		return -1
