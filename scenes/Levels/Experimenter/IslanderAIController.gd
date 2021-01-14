extends Node

enum GoalTypes {
	COLLECT
	IDLE
}

class Goal:
	var goal_type
	var target
	var limit


var current_goal = {
	goal_type = GoalTypes.COLLECT,
	target = "branch",
	limit = 10
}

var current_move_path = []

var current_target: Node = null

var objects_in_view = []

# Called when the node enters the scene tree for the first time.
func _ready():
	print(current_goal)

var searched = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match current_goal.goal_type:
		GoalTypes.IDLE:
			pass
		GoalTypes.COLLECT:
			if current_target == null:
				current_target = _get_closest_target_of_type(current_goal.target)
				if (current_target == null):
					pass
				else:
					print("locked on to a target: ", current_target.get_parent().get_name())

			if current_target != null:
				if len(current_move_path) == 0:
					print("finding quickest path to: ", current_target.get_parent().get_name())
					current_move_path = _get_quickest_path_to(current_target)
					print("path is", current_move_path)
					searched = true
				else:
					var islander = get_parent().get_node("Objects/Props/Islander")
					var current_tile = Vector2(floor(islander.global_position.x / 16), floor(islander.global_position.y / 16))
					
					while len(current_move_path) != 0 and current_tile.distance_to(current_move_path[0]) <= 1.0:
						current_move_path.pop_front()
						
					if len(current_move_path) == 0:
						current_target.interact()
						islander.pick_up_item(current_target.item_type)
						current_target = null
					else:
						var next_tile = current_move_path[0]
						var direction = next_tile - current_tile
						
						islander.move(direction.x, direction.y)
					
				

func _get_closest_target_of_type(target_type):
	var islander_position = get_parent().get_node("Objects/Props/Islander").global_position
	var closest_node = null
	var distance_to_closest = INF
	for node in objects_in_view:
		if (node.is_in_group(target_type)):
			var distance_to_current = islander_position.distance_to(node.global_position)
			if distance_to_closest > distance_to_current:
				closest_node = node
				distance_to_closest = distance_to_current
	return closest_node


func _get_quickest_path_to(node):
	var islander_position = get_parent().get_node("Objects/Props/Islander").global_position
	var pathfinder = get_parent().get_node("Pathfinder")
	return pathfinder.get_quickest_path_to(islander_position, node.global_position)


func _on_IslanderVisionSensor_area_entered(area):
	objects_in_view.append(area.get_parent())


func _on_IslanderVisionSensor_area_exited(area):
	objects_in_view.remove(objects_in_view.find(area.get_parent()))
