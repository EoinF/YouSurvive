extends Node

signal finish_event

func trigger():
	after_complete()
	emit_signal("finish_event")


func after_complete():
	var experimenter = get_owner().get_node("Experimenter")
	var islander = get_owner().get_node("Objects/Props/Islander")
	var ai_controller = get_owner().get_node("IslanderAIController")
	ai_controller.add_collection_goal("stone", 1)
	ai_controller.add_kill_goal("crab", 99999)
