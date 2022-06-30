extends Node

signal complete_objective

var ghosts
var current_ghost

func _ready():
	ghosts = []
	for child in get_owner().get_node("Objects/Props").get_children():
		if child.is_in_group("Ghost"):
			ghosts.append(child)
			child.visible = false
			
	current_ghost = ghosts.pop_front()
	current_ghost.visible = true


func _on_GhostDetectionArea_body_entered(body):
	if body.is_in_group("Ghost"):
		body.queue_free()
		var current_ghost = ghosts.pop_front()
		
		if current_ghost == null:
			emit_signal("complete_objective")
		else:
			current_ghost.visible = true
