extends Node


func _on_DialogueManager_trigger_event(event_name):
	call(event_name)
	

func enable_controls():
	var owner = get_owner()
	owner.get_node("Experimenter").enable_controls()


func gift_items():
	var owner = get_owner()
	owner.get_node("Experimenter").pick_up_item("shark", 99)
	owner.get_node("Experimenter").pick_up_item("stick", 1)
	owner.get_node("Experimenter").pick_up_item("stone", 1)
	owner.get_node("Experimenter").pick_up_item("crab", 99)
	
	
