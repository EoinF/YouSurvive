tool
extends Node

signal finish_event

export var NEXT_NODE_DELAY = 0
export var DISABLED = false

func _get_configuration_warning():
	if get_owner() != null:
		var child_count = get_child_count()
		if child_count == 0:
			return "You must add a child with node with a script attached"
		elif child_count > 1:
			return "Only 1 child node allowed"
		elif not get_child(0).has_method("trigger"):
			return "Method named \"trigger\" is required on the child node"
		elif not get_child(0).has_signal("finish_event"):
			return "Child must emit a \"finish_event\" signal"
	return ""


func _on_finish_event():
	emit_signal("finish_event")
	

func trigger():
	var child = get_child(0)
	child.connect("finish_event", self, "_on_finish_event")
	child.trigger()

