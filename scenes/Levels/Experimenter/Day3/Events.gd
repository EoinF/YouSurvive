extends Node



func _on_DialogueManager_trigger_event(event_name):
	call(event_name)


func enable_controls():
	get_owner().get_node("Experimenter").enable_controls()


func add_collection_goal():
	get_owner().get_node("Day3Objectives").set_objective_active("collect_items")


func gift_crabs():
	get_owner().get_node("Experimenter").pick_up_item("crab", 25)
