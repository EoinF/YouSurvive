extends Node


signal objectives_updated(objectives)

var OBJECTIVE_RELEASE_COCONUTS_KEY = "OBJECTIVE_COLLECT_BRANCH"
var OBJECTIVE_RELEASE_COCONUTS_TEMPLATE = PoolStringArray([
	"[tornado radius=2 freq=3][color=red]dfaalaag ple maalaag[/color][/tornado]"
]).join(" ")

var is_objective_1_complete = false

func _ready():
	emit_signal("objectives_updated", _get_objectives())


func _get_objectives():
	var objective1 = {
		"description": OBJECTIVE_RELEASE_COCONUTS_TEMPLATE, 
		"key": OBJECTIVE_RELEASE_COCONUTS_KEY,
		"is_complete": is_objective_1_complete,
		"is_visible": true
	}
	return [objective1]
