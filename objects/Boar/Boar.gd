extends KinematicBody2D

var object_type = "boar"

signal dies(node)

var EASE_OUT = 3

var direction = Vector2.ZERO
var velocity = Vector2.ZERO
var _death_cooldown = -1
var min_idle_time = 2
var scale_idle_time = 3.5
var wandering_scale = 8000
var speed_scaling = 1.0

enum State {
	IDLE
	PRE_ATTACK
	ATTACKING
	SLIDING
	COOLDOWN
	HURTING
	DYING
	DEAD
}


var _state = State.IDLE
var is_flipped = false
var SLIDE_DURATION = 0
var slide_timeout = 0

export var CHASE_SPEED = 9 * 1000
export var SPEED = 7 * 1000
export var ATTACK_SPEED = 15 * 1000
export var DEATH_COOLDOWN = 1.0
export var HEALTH = 4


func get_position():
	return global_position


func get_resting_position():
	return get_position()


func is_alive():
	return HEALTH > 0


func set_speed_scaling(new_scaling):
	speed_scaling = new_scaling


var MIN_WANDER_DISTANCE = 500
var MAX_WANDER_DISTANCE = 1000

func get_wander_target():
	var random_direction = Vector2(1, 0).rotated(randf() * PI * 2.0)
	var random_distance = rand_range(MIN_WANDER_DISTANCE, MAX_WANDER_DISTANCE)
	return global_position + random_direction * random_distance


func _ready():
	SLIDE_DURATION = get_node("PostAttackTimer").wait_time


func _turn_if_needed(x):
	var animated_sprite = get_node("AnimatedSprite")
	if x > 0 and is_flipped or x < 0 and not is_flipped:
		is_flipped = not is_flipped
		animated_sprite.animation = "turning"
		animated_sprite.play()
		animated_sprite.flip_h = is_flipped
		return true
	return false


func idle():
	var animated_sprite = get_node("AnimatedSprite")
	if animated_sprite.animation != "default":
		animated_sprite.animation = "default"


func move(x, y):
	if not _state == State.IDLE:
		return
	direction = Vector2(x, y).normalized()
	velocity = direction * SPEED
	
	if _turn_if_needed(x):
		return
	var animated_sprite = get_node("AnimatedSprite")
	if not animated_sprite.animation in ["running", "turning"]:
		animated_sprite.animation = "running"
		animated_sprite.play()


func attack(x, y):
	if not _state == State.IDLE:
		return
	direction = Vector2(x, y).normalized()
	get_node("PreAttackTimer").start()
	
	_state = State.PRE_ATTACK
	if _turn_if_needed(x):
		return
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
		var speed = ATTACK_SPEED if get_node("AnimatedSprite").animation != "turning" else SPEED
		velocity = Vector2(direction.x * speed, direction.y * speed)
	if _state == State.SLIDING:
		slide_timeout -= delta
		
		# should probably use a tween function instead of this
		var easing_value = ease(slide_timeout / SLIDE_DURATION, EASE_OUT)
		velocity = Vector2(direction.x * ATTACK_SPEED, direction.y * ATTACK_SPEED) * easing_value
	
# warning-ignore:return_value_discarded
	move_and_slide(velocity * delta * speed_scaling)
	velocity = Vector2.ZERO


func _on_PreAttackTimer_timeout():
	var animated_sprite = get_node("AnimatedSprite")
	animated_sprite.animation = "running"
	animated_sprite.play()
	get_node("SlideSound").play()
	get_node("AttackTimer").start()
	get_node("AttackArea/Shape").disabled = false
	_state = State.ATTACKING


func _on_AttackTimer_timeout():
	_state = State.SLIDING
	slide_timeout = SLIDE_DURATION
	get_node("AnimatedSprite").animation = "sliding"
	get_node("SlideStop").play()
	get_node("AnimatedSprite").play()
	get_node("PostAttackTimer").start()
	get_node("AttackArea/Shape").disabled = true


func _on_PostAttackTimer_timeout():
	_state = State.COOLDOWN
	get_node("AnimatedSprite").animation = "default"
	get_node("AttackCooldown").start()


func _on_AttackCooldown_timeout():
	_state = State.IDLE


func _on_Hurtbox_area_entered(area):
	if _state in [State.DYING, State.DEAD, State.HURTING] or area.is_in_group("AI") or not area.is_in_group("Attack"):
		return
		
	HEALTH -= area.attack_power
	get_node("HurtSound").play()
	
	if HEALTH <= 0:
		_die()
	else:
		get_node("AnimatedSprite").animation = "hurting"
		get_node("AnimatedSprite").play()
		_state = State.HURTING
		get_node("AttackTimer").stop()
		get_node("PreAttackTimer").stop()
		get_node("PostAttackTimer").stop()
		get_node("HurtCooldown").start()
			
func _on_HurtCooldown_timeout():
	_state = State.IDLE


func _die():
	get_node("AnimatedSprite").animation = "death"
	get_node("AnimatedSprite").play()
	get_node("AttackCooldown").stop()
	get_node("AttackTimer").stop()
	get_node("PreAttackTimer").stop()
	get_node("PostAttackTimer").stop()
	get_node("AttackArea/Shape").set_deferred("disabled", true)
	_state = State.DYING


func _on_AnimatedSprite_animation_finished():
	var animated_sprite = get_node("AnimatedSprite")
	if animated_sprite.animation == "turning":
		animated_sprite.animation = "running"
		animated_sprite.play()
	if animated_sprite.animation == "death":
		_death_cooldown = DEATH_COOLDOWN
		_state = State.DEAD
		emit_signal("dies", self)
	

