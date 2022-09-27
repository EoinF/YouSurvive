extends Node


func _on_DialogueManager_trigger_event(event_name):
	call(event_name)


func enable_controls():
	get_owner().get_node("Experimenter").enable_controls()


func add_collection_goal():
	get_owner().get_node("Day3Objectives").set_objective_active("collect_items")
	get_owner().get_node("ObjectivesTimer").start()


func gift_branches():
	get_owner().get_node("Experimenter").pick_up_item("branch", 5)


func gift_crabs():
	get_owner().get_node("Experimenter").pick_up_item("crab", 25)
	get_owner().get_node("Experimenter").pick_up_item("boar", 25)
	get_owner().get_node("Experimenter").reset_timer()


func enable_ai():
	var ai_controller = get_owner().get_node("IslanderAIController")
	ai_controller.add_collection_goal("coconut", 10)
	ai_controller.add_collection_goal("branch", 10)
	ai_controller.is_paused = false
	get_owner().get_node("AIController").enable_ai()
