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
	islander_ai.add_steer_goal(owner.get_node("Objects/Props/Raft"))
	owner.get_node("AIController").enable_ai()
	owner.get_node("SeaAIController").enable_ai()
	islander_ai.is_paused = false
	
	var sea_props = owner.get_node("Objects/Props/SeaProps")
	sea_props.reset()
	for sea_prop in sea_props.get_children():
		sea_prop.activate()
		
	owner.get_node("AnimationPlayer").play("fade_in_music")
	owner.get_node("Objects/ScrollingManager").start()
	owner.get_node("Objects/Props/Raft").reset()
	
	get_owner().get_node("Experimenter").reset_timer()


func gift_items():
	var owner = get_owner()
	owner.get_node("Experimenter").pick_up_item("shark", 99)
	owner.get_node("Experimenter").pick_up_item("crab", 99)
	owner.get_node("Experimenter").pick_up_item("sea_rock", 99)
	owner.get_node("Objects/Props/Raft/Islander").pick_up_item("stick")
