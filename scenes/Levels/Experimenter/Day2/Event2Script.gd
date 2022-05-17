extends Node

signal finish_event

func trigger():
	get_owner().get_node("Experimenter").pick_up_item("stick", 25)
	get_owner().get_node("Experimenter").pick_up_item("porcupine", 25)
	get_owner().get_node("Experimenter").pick_up_item("boar", 25)
	emit_signal("finish_event")
