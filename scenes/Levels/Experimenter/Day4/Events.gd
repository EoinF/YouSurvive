extends Node


func _on_DialogueManager_trigger_event(event_name):
	call(event_name)
	

func enable_controls():
	var owner = get_owner()
	owner.get_node("Experimenter").enable_controls()
	var islander_ai = owner.get_node("IslanderAIController")
	islander_ai.add_collection_goal("stick", 1)
	islander_ai.add_collection_goal("stone", 1)
	islander_ai.add_kill_goal("crab", 999)
	islander_ai.add_kill_goal("shark", 999)


func gift_items():
	var owner = get_owner()
	owner.get_node("Experimenter").pick_up_item("shark", 99)
	owner.get_node("Objects/Props/Raft/Islander").pick_up_item("stick")
	owner.get_node("Experimenter").pick_up_item("crab", 99)
	
	
