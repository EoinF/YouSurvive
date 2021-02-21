extends Node

signal finish_event

func trigger():
	var experimenter = get_owner().get_node("Experimenter")
	experimenter.enable_controls()
	experimenter.set_is_following(false)
	emit_signal("finish_event")
