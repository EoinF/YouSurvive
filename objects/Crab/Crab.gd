extends KinematicBody2D

var direction = Vector2.ZERO
var velocity = Vector2.ZERO
var _death_cooldown = -1
var _is_dying = false

var object_type = "crab"

enum AttackPhase {
	IDLE
	PRE_ATTACK
	ATTACKING
	COOLDOWN
}


var _attack_phase = AttackPhase.IDLE

export var CHASE_SPEED = 9 * 1000
export var SPEED = 2 * 1000
export var ATTACK_SPEED = 12 * 1000
export var DEATH_COOLDOWN = 1.0
export var HEALTH = 1

func get_resting_position():
	return global_position
	

func move(x, y):
	if not _is_dying and _attack_phase == AttackPhase.IDLE:
		direction = Vector2(x, y).normalized()
		velocity = Vector2(direction.x * SPEED, direction.y * SPEED)

func attack(x, y):
	if not _is_dying and _attack_phase == AttackPhase.IDLE:
		direction = Vector2(x, y).normalized()
		var animated_sprite = get_node("AnimatedSprite")
		animated_sprite.stop()
		animated_sprite.frame = 0
		
		get_node("PreAttackTimer").start()
		
		_attack_phase = AttackPhase.PRE_ATTACK


func _process(delta):
	if _is_dying:
		_death_cooldown -= delta
		self.modulate = Color.transparent.linear_interpolate(Color.white, _death_cooldown / DEATH_COOLDOWN)
		if _death_cooldown < 0:
			queue_free()


func _physics_process(delta):
	if _attack_phase == AttackPhase.ATTACKING:
		velocity = Vector2(direction.x * ATTACK_SPEED, direction.y * ATTACK_SPEED)
		
	move_and_slide(velocity * delta)
	
	velocity = Vector2.ZERO


func _on_PreAttackTimer_timeout():
	var animated_sprite = get_node("AnimatedSprite")
	animated_sprite.animation = "attacking"
	animated_sprite.play()
	get_node("AttackTimer").start()
	get_node("AttackArea/Shape").disabled = false
	_attack_phase = AttackPhase.ATTACKING


func _on_AttackTimer_timeout():
	_attack_phase = AttackPhase.COOLDOWN
	get_node("AnimatedSprite").animation = "default"
	get_node("AttackCooldown").start()
	get_node("AttackArea/Shape").disabled = true


func _on_AttackCooldown_timeout():
	_attack_phase = AttackPhase.IDLE


func _on_Hurtbox_area_entered(area):
	if not _is_dying and not area.is_in_group("Crab") and area.is_in_group("Attack"):
		HEALTH -= area.attack_power
		if (HEALTH == 0):
			_die()


func _die():
	_death_cooldown = DEATH_COOLDOWN
	_is_dying = true
	get_node("AnimatedSprite").stop()
	get_node("AttackCooldown").stop()
	get_node("AttackTimer").stop()
	get_node("PreAttackTimer").stop()
	get_node("AttackArea/Shape").disabled = true
	_attack_phase = AttackPhase.IDLE
