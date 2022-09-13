extends Node2D

signal collide

export var IS_SHARK_SPRITE = false
var object_type = "sea_rock"


func _on_Area_body_entered(_body):
	emit_signal("collide")


func activate():
	visible = true
	$Area/CollisionShape2D.set_deferred("disabled", false)


func deactivate():
	visible = false
	$Area/CollisionShape2D.set_deferred("disabled", true)


func get_height():
	return $Area/CollisionShape2D.shape.radius * 2


func _ready():
	$Sprite.visible = not IS_SHARK_SPRITE
	$SharkSprite.visible = IS_SHARK_SPRITE
