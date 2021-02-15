extends Node

signal objectives_updated(objectives)
signal objective_completed(objective_key)

var OBJECTIVE_REFILL_STAMINA_KEY = "OBJECTIVE_REFILL_STAMINA"
var OBJECTIVE_REFILL_STAMINA_TEMPLATE = "Eat coconuts (stamina %d / %d)"

var current_stamina
var required_stamina = 100

func _ready():
	emit_signal("objectives_updated", _get_objectives())


func _get_objectives():
	return [
		OBJECTIVE_REFILL_STAMINA_TEMPLATE % [current_stamina, required_stamina]
	]


func _on_Islander_stamina_change(stamina):
	current_stamina = stamina
	emit_signal("objectives_updated", _get_objectives())
	
	if current_stamina >= required_stamina:
		emit_signal("objectives_completed", OBJECTIVE_REFILL_STAMINA_KEY)
