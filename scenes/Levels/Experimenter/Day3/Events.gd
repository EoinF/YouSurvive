extends Node



func _on_DialogueManager_trigger_event(event_name):
	call(event_name)


func gift_crabs():
	get_owner().get_node("Experimenter").pick_up_item("crab", 25)
