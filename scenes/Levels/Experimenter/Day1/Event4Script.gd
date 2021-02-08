extends Node

signal finish_event

func trigger():
	get_owner().get_node("Experimenter").enable_controls()
	emit_signal("finish_event")
