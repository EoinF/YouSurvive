extends Node

enum GoalTypes {
	IDLE
	LOCATE
	COLLECT
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
		return -1


class LocateGoal extends Goal:
	func _init(_target, _limit).(_target, _limit):
		self.goal_type = GoalTypes.LOCATE
	
	func get_priority(_owner_context):
		return 1


class CollectGoal extends Goal:
	func _init(_target, _limit).(_target, _limit):
		self.goal_type = GoalTypes.COLLECT
	
	func get_priority(_owner_context):
		if target in _owner_context.objects_in_view and len(_owner_context.objects_in_view[target]) > 0:
			return 2
		else:
			return 0

