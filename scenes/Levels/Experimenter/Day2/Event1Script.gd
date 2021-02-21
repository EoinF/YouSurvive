extends Node

signal finish_event

func trigger():
	get_owner().get_node("Experimenter").pick_up_item("crab", 50)
	emit_signal("finish_event")
