extends Node

signal finish_event

func trigger():
	var owner = get_owner()
	owner.get_node("Experimenter").pick_up_item("branch", 10)
	owner.get_node("AnimationPlayer").play("highlight_inventory")
	emit_signal("finish_event")
