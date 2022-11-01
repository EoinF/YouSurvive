extends Node


func _on_DialogueManager_trigger_event(event_name):
	call(event_name)


func enable_controls():
	var owner = get_owner()
	owner.get_node("Experimenter").enable_controls(false)
	owner.get_node("Day1Objectives").set_objective_active("locate_islander", true)
	owner.get_node("HUDLayer/HUD/MovementTutorial").activate()


func start_camera_follow():
	var experimenter = owner.get_node("Experimenter")
	var islander = owner.get_node("Objects/Props/Islander")
	var ai_controller = owner.get_node("IslanderAIController")
	experimenter.set_follow_target(islander, true)
	ai_controller.add_collection_goal("branch", 10)
	ai_controller.is_paused = false


func gift_branches():
	var owner = get_owner()
	owner.get_node("Experimenter").pick_up_item("branch", 10)
	owner.get_node("Day1Objectives").set_objective_active("locate_islander", false)
	owner.get_node("Day1Objectives").set_objective_active("collect_branches", true)
	owner.get_node("AnimationPlayer").play("highlight_inventory")


func stop_camera_follow():
	var experimenter = get_owner().get_node("Experimenter")
	owner.get_node("HUDLayer/HUD/PlacementTutorial").activate()
	
	experimenter.enable_placement()
	experimenter.reset_timer()
	experimenter.set_is_following(false)
