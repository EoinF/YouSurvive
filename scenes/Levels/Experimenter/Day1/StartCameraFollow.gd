extends Node

signal finish_event

func trigger():
	var experimenter = get_owner().get_node("Experimenter")
	var islander = get_owner().get_node("Objects/Props/Islander")
	var ai_controller = get_owner().get_node("IslanderAIController")
	experimenter.set_follow_target(islander, true)
	ai_controller.add_collection_goal("branch", 10)
	ai_controller.is_paused = false
	emit_signal("finish_event")

