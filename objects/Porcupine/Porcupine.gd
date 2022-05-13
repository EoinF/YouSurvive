extends KinematicBody2D

var object_type = "porcupine"

signal dies(node)

var EASE_OUT = 3

var direction = Vector2.ZERO
var velocity = Vector2.ZERO
var _death_cooldown = -1
var min_idle_time = 0.1
var scale_idle_time = 2.4
var wandering_scale = 8000

enum State {
	IDLE
	PRE_ATTACK
	ATTACKING
	COOLDOWN
	HURTING
	DYING
	DEAD
}


var _state = State.IDLE
var is_flipped = false

export var CHASE_SPEED = 6 * 1000
export var SPEED = 5 * 1000
export var ATTACK_SPEED = 5 * 1000
export var DEATH_COOLDOWN = 1.0
export var HEALTH = 2


func get_position():
	return global_position
	
	
func get_resting_position():
	return get_position()


func is_alive():
	return HEALTH > 0


func get_wander_target():
	var rand_sign = ((randi() % 2) * 2) - 1
	var rand_x = 2 * randf() - 1
	var rand_y = 2 * randf() - 1
	var _scale = 10000
	var x = rand_sign * _scale / (rand_x * rand_x)
	var y = rand_sign * _scale / (rand_y * rand_y)
	return global_position + Vector2(x, y)


func _turn_if_needed(x, is_reversed=false):
	var is_facing_left = is_flipped != is_reversed
	
	if x > 0 and is_facing_left or x < 0 and not is_facing_left:
		is_flipped = not is_flipped
		apply_scale(Vector2(-1, 1))


func idle():
	var animated_sprite = get_node("AnimatedSprite")
	if animated_sprite.animation != "default":
		animated_sprite.animation = "default"


func move(x, y):
	if not _state == State.IDLE:
		return

	direction = Vector2(x, y).normalized()
	velocity = Vector2(direction.x * SPEED, direction.y * SPEED)
	
	_turn_if_needed(x)


func attack(x, y):
	if not _state == State.IDLE:
		return
	direction = Vector2(x, y).normalized()
	get_node("PreAttackTimer").start()
	
	_state = State.PRE_ATTACK
	_turn_if_needed(x, true)
	var animated_sprite = get_node("AnimatedSprite")
	animated_sprite.animation = "default"
	animated_sprite.play()


func _process(delta):
	if _state == State.DEAD and _death_cooldown != -1:
		_death_cooldown -= delta
		self.modulate = Color.transparent.linear_interpolate(Color.white, _death_cooldown / DEATH_COOLDOWN)
		if _death_cooldown < 0:
			queue_free()



func _physics_process(delta):
	if _state == State.ATTACKING:
		velocity = Vector2(direction.x * ATTACK_SPEED, direction.y * ATTACK_SPEED)
	
	move_and_slide(velocity * delta)
	
	velocity = Vector2.ZERO


func _on_PreAttackTimer_timeout():
	var animated_sprite = get_node("AnimatedSprite")
	animated_sprite.animation = "attacking"
	animated_sprite.play()
	var spikes_sprite = get_node("SpikesSprite")
	spikes_sprite.visible = true
	spikes_sprite.frame = 0
	spikes_sprite.play()
	get_node("AttackTimer").start()
	get_node("AttackArea/Shape").disabled = false
	_state = State.ATTACKING


func _on_AttackTimer_timeout():
	_state = State.COOLDOWN
	get_node("AnimatedSprite").animation = "default"
	get_node("AttackCooldown").start()
	get_node("AttackArea/Shape").disabled = true


func _on_AttackCooldown_timeout():
	_state = State.IDLE


func _on_Hurtbox_area_entered(area):
	if not _state in [State.DYING, State.DEAD, State.HURTING] and not area.is_in_group("AI") and area.is_in_group("Attack"):
		HEALTH -= area.attack_power
		
		if HEALTH <= 0:
			_die()
		else:
			get_node("AnimatedSprite").animation = "hurting"
			get_node("AttackArea/Shape").set_deferred("disabled", false)
			get_node("AnimatedSprite").play()
			_state = State.HURTING
			get_node("AttackTimer").stop()
			get_node("PreAttackTimer").stop()
			get_node("HurtCooldown").start()


func _on_HurtCooldown_timeout():
	_state = State.IDLE


func _die():
	get_node("AnimatedSprite").animation = "death"
	get_node("AnimatedSprite").play()
	get_node("AttackCooldown").stop()
	get_node("AttackTimer").stop()
	get_node("PreAttackTimer").stop()
	get_node("AttackArea/Shape").set_deferred("disabled", true)
	_state = State.DYING


func _on_AnimatedSprite_animation_finished():
	var animated_sprite = get_node("AnimatedSprite")
	if animated_sprite.animation == "death":
		_death_cooldown = DEATH_COOLDOWN
		_state = State.DEAD
		emit_signal("dies", self)

