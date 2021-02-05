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
	
	func _init(target, limit):
		self.target = target
		self.limit = limit
		
	func get_priority(owner_context):
		return 0


class IdleGoal extends Goal:
	func _init().(null, null):
		self.goal_type = GoalTypes.IDLE
	
	func get_priority(owner_context):
		return -1


class LocateGoal extends Goal:
	func _init(target, limit).(target, limit):
		self.goal_type = GoalTypes.LOCATE
	
	func get_priority(owner_context):
		return 1


class CollectGoal extends Goal:
	func _init(target, limit).(target, limit):
		self.goal_type = GoalTypes.COLLECT
	
	func get_priority(owner_context):
		if target in owner_context.objects_in_view and len(owner_context.objects_in_view[target]) > 0:
			return 2
		else:
			return 0
