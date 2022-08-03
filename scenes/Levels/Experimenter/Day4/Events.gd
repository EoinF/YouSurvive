extends Node


func _on_DialogueManager_trigger_event(event_name):
	call(event_name)
	

func gift_weapons():
	print("gift weapons")
	var owner = get_owner()
	owner.get_node("Experimenter").pick_up_item("stick", 1)
	owner.get_node("Experimenter").pick_up_item("stone", 1)


func gift_sharks():
	var owner = get_owner()
	owner.get_node("Experimenter").pick_up_item("shark", 99)
	
	
func gift_crabs():
	var owner = get_owner()
	owner.get_node("Experimenter").pick_up_item("crab", 99)
	
