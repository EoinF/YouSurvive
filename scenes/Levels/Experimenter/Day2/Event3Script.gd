extends Node

signal finish_event

func trigger():
	emit_signal("finish_event")
