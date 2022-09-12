extends KinematicBody2D

signal dies(node)
signal struggle

var direction = Vector2.ZERO
var velocity = Vector2.ZERO
var _death_cooldown = -1
var _is_dying = false
var min_idle_time = 0.2
var scale_idle_time = 3.5
var wandering_scale = 4000

var object_type = "shark"


export var CHASE_SPEED = 9 * 1000
export var SPEED = 3 * 1000
export var ATTACK_SPEED = 12 * 1000
export var DEATH_COOLDOWN = 1.0
export var HEALTH = 3


func get_position():
	return global_position


func get_resting_position():
	return get_position()


func get_height():
	return $Hurtbox/Shape.shape.height


func is_alive():
	return HEALTH > 0


func idle():
	pass
	

func get_wander_target():
	var rand_sign = ((randi() % 2) * 2) - 1
	var rand_x = 2 * randf() - 1
	var rand_y = 2 * randf() - 1
	var scale = 4000
	var x = rand_sign * scale / (rand_x * rand_x)
	var y = rand_sign * scale / (rand_y * rand_y)
	return global_position + Vector2(x, y)


func move(x, y):
	if not _is_dying:
		direction = Vector2(x, y).normalized()
		velocity = Vector2(direction.x * SPEED, direction.y * SPEED)
		
		$AnimatedSprite.flip_h = x < 0


func struggle(anchor_node: Node2D, _direction: Vector2):
	if not _is_dying:
		$StruggleEffect.start(anchor_node, _direction)


func stop_struggling():
	$StruggleEffect.stop()


func _process(delta):
	if _is_dying:
		_death_cooldown -= delta
		self.modulate = Color.transparent.linear_interpolate(Color.white, _death_cooldown / DEATH_COOLDOWN)
		if _death_cooldown < 0:
			queue_free()


func _physics_process(delta):
	move_and_slide(velocity * delta)
	
	velocity = Vector2.ZERO


func _on_Hurtbox_area_entered(area):
	if _is_dying or area.is_in_group("AI") or not area.is_in_group("Attack"):
		return
		
	HEALTH -= area.attack_power
	get_node("HurtSound").play()
	if (HEALTH <= 0):
		_die()


func _die():
	emit_signal("dies", self)
	_death_cooldown = DEATH_COOLDOWN
	_is_dying = true
	
	$StruggleEffect.stop()
	get_node("AnimatedSprite").stop()
	get_node("AttackArea/Shape").set_deferred("disabled", true)


func _on_StruggleEffect_finish_iteration():
	emit_signal("struggle")
