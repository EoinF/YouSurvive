extends Node2D


func _ready():
	get_node("AIController").disable_ai()
	var experimenter = get_node("Experimenter")
	var islander = get_node("Objects/Props/Islander")
	var ai_controller = get_node("IslanderAIController")
	ai_controller.add_collection_goal("stone", 1)
	ai_controller.add_kill_goal("crab", 99999)
	experimenter.pick_up_item("crab", 50)
	experimenter.pick_up_item("stone", 3)

