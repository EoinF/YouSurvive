extends Node

signal finish_event

func trigger():
	get_owner().enable_controls()
	emit_signal("finish_event")
