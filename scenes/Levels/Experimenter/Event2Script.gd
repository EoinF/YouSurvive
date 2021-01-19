extends Node

signal finish_event

func trigger():
	stop_following()
	activate_object_placement_mode()
	emit_signal("finish_event")

func stop_following():
	var camera = get_owner().get_node("Camera")
	camera.set_is_following(false)

func activate_object_placement_mode():
	pass
