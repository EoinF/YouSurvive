extends Node

signal finish_event

func trigger():
	stop_following()
	emit_signal("finish_event")

func stop_following():
	var experimenter = get_owner().get_node("Experimenter")
	experimenter.set_is_following(false)
