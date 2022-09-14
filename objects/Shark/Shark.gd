extends KinematicBody2D

signal dies(node)
signal struggle

var direction = Vector2.ZERO
var velocity = Vector2.ZERO
var _death_cooldown = -1
var _is_dying = false
var min_idle_time = 0.2
var scale_idle_time = 3.5

var object_type = "shark"


export var SPEED = 4 * 1000
export var WANDER_SPEED = 2 * 1000
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


var MIN_WANDER_DISTANCE = 60
var MAX_WANDER_DISTANCE = 250

func get_wander_target():
	var random_direction = Vector2(1, 0).rotated(randf() * PI * 2.0)
	var random_distance = rand_range(MIN_WANDER_DISTANCE, MAX_WANDER_DISTANCE)
	return global_position + random_direction * random_distance


func move(x, y, speed = SPEED):
	if not _is_dying:
		direction = Vector2(x, y).normalized()
		velocity = direction * speed
		
		$AnimatedSprite.flip_h = x < 0
		
func wander(x, y):
	move(x, y , WANDER_SPEED)


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
# warning-ignore:return_value_discarded
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
