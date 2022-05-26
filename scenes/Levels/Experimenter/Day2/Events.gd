extends Node


func _on_DialogueManager_trigger_event(event_name):
	call(event_name)


func enable_controls():
	get_owner().get_node("Experimenter").enable_controls()


func gift_stone():
	get_owner().get_node("Experimenter").pick_up_item("stone", 1)


func gift_stick():
	get_owner().get_node("Experimenter").pick_up_item("stick", 1)
	get_owner().get_node("Day2Objectives").set_objective_active("place_weapon")


func gift_crabs():
	get_owner().get_node("Experimenter").pick_up_item("crab", 25)


func gift_porcupines():
	get_owner().get_node("Experimenter").pick_up_item("porcupine", 25)


func gift_boars():
	get_owner().get_node("Experimenter").pick_up_item("boar", 25)
	get_owner().get_node("Day2Objectives").set_objective_active("place_predators")


func enable_ai():
	var ai_controller = get_owner().get_node("IslanderAIController")
	ai_controller.add_collection_goal("stone", 1)
	ai_controller.add_collection_goal("stick", 1)
	ai_controller.add_kill_goal("crab", 99999)
	ai_controller.add_kill_goal("porcupine", 99999)
	ai_controller.add_kill_goal("boar", 99999)
	ai_controller.is_paused = false
	get_owner().get_node("Day2Objectives").set_objective_active("kill_predators", true)
	get_owner().get_node("AIController").enable_ai()
