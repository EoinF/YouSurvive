extends Node2D

signal collide

var object_type = "sea_rock"

func _on_Area_body_entered(body):
	emit_signal("collide")

	
func get_height():
	return $Area/CollisionShape2D.shape.radius * 2
