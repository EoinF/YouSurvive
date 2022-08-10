extends Area2D

signal collide


func _on_SeaRock_body_entered(body):
	emit_signal("collide")
