extends KinematicBody2D

signal use_coconut_without_rock
signal inventory_slot_change(inventory_slot)
signal health_change(health)
signal die
signal throw_stone(position, direction)

export var SPEED = 8 * 1000
export var IS_IMMUNE_TO_STONE = true
export var MAX_HEALTH = 1000
export var FOOTSTEPS_VOLUME_OFFSET = 0

var object_type = "islander"

var rand = RandomNumberGenerator.new()

var walking_timeout = 0
var attack_ready = true

func is_attacking():
	return get_node("AttackPivotPoint/AttackAnimation").is_playing()


var velocity = Vector2.ZERO
var direction = Vector2.DOWN
var attack_direction = Vector2.DOWN
var active_sprite_state = "Stand"
var active_sprite_direction = "Down"
var _is_hurting = false
var health = MAX_HEALTH
var is_alive = true


class InventorySlot:
	var node_key: String
	var amount: int
	var item_type: String

var item_type_to_slot = {}
var unused_keys = ["1", "2", "3"]

var on_finished_emote_ref: FuncRef

var _is_colliding = false

func is_colliding():
	var return_value = _is_colliding
	_is_colliding = false
	return return_value


func will_collide():
	return test_move(transform, Vector2.ZERO)
	

func _ready():
	get_node("WalkEffect").set_volume_offset(FOOTSTEPS_VOLUME_OFFSET)
	set_health(MAX_HEALTH)
	is_alive = true


func _process(_delta):
	velocity = Vector2.ZERO
	if not is_alive:
		return
	
	if (active_sprite_state == "Run"):
		if (walking_timeout < 0):
			_update_active_sprite("Stand", active_sprite_direction)
		else:
			walking_timeout -= 1
	
	var attack_animation = get_node("AttackPivotPoint/AttackAnimation")
	if attack_animation.is_playing() and velocity.length_squared() == 0:
		var t = attack_animation.frames.get_frame_count("default") / float(attack_animation.frame + 1)
		velocity = 15 * t * attack_direction


func move(x, y):
	if not is_alive:
		return
	walking_timeout = 10
	direction = Vector2(x, y).normalized()
	
	velocity.x = direction.x * SPEED
	velocity.y = direction.y * SPEED
	
	var directionVertical = ""
	var directionHorizontal = ""
	if (velocity.y < 0):
		directionVertical = "Up"
	elif (velocity.y > 0):
		directionVertical = "Down"
	if (velocity.x < 0):
		directionHorizontal = "Left"
	elif (velocity.x > 0):
		directionHorizontal = "Right"
	
	_update_active_sprite("Run", directionVertical + directionHorizontal)
	get_node("WalkEffect").start()
	


func throw_stone(x, y):
	# First, face the direction to throw, then throw the stone
	move(x, y)
	_use_stone()


func attack(_x = 0, _y = 0):
	if not attack_ready or not is_alive:
		return
	
	attack_ready = false
	get_node("AttackPivotPoint/AttackAnimation/AttackArea/Shape").disabled = false
	var attack_animation = get_node("AttackPivotPoint/AttackAnimation")
	get_node("AttackPivotPoint").rotation = atan2(direction.y, direction.x) - PI / 2
	attack_animation.visible = true
	attack_animation.set_frame(0)
	attack_animation.play()
	var sound_index = rand.randi_range(1, 2)
	get_node("StickAttack" + str(sound_index)).play()
	
	attack_direction = direction
	_update_active_sprite("Run", active_sprite_direction)
	walking_timeout = 20


func pick_up_item(item_type):
	if item_type in item_type_to_slot:
		item_type_to_slot[item_type].amount += 1
	else:
		var node_key = unused_keys.pop_front()
		item_type_to_slot[item_type] = InventorySlot.new()
		item_type_to_slot[item_type].node_key = node_key
		item_type_to_slot[item_type].amount = 1
		item_type_to_slot[item_type].item_type = item_type
		
	emit_signal("inventory_slot_change", item_type_to_slot[item_type])


func start_target_spotted_emote(on_finished: FuncRef):
	on_finished_emote_ref = on_finished
	get_node("TargetFoundEmote").visible = true
	get_node("EmoteTimer").start()


func _update_active_sprite(new_sprite_state, new_sprite_direction):
	if new_sprite_state == "Stand":
		get_node("WalkEffect").stop()
	
	if new_sprite_direction != "":
		active_sprite_direction = new_sprite_direction
		active_sprite_state = new_sprite_state
		get_node("CharacterAnimations").animation = active_sprite_state + "_" + active_sprite_direction
	else:
		print("invalid sprite direction")


func _physics_process(delta):
	move_and_slide(velocity * delta)
	_is_colliding = get_slide_count() > 0


func _on_AttackAnimation_animation_finished():
	get_node("AttackPivotPoint/AttackAnimation/AttackArea/Shape").disabled = true
	var attack_animation = get_node("AttackPivotPoint/AttackAnimation")
	attack_animation.visible = false
	attack_animation.stop()
	get_node("AttackCooldown").start()


func set_health(new_health):
	if not is_alive:
		return
	health = min(new_health, MAX_HEALTH)
	if health <= 0:
		is_alive = false
		health = 0
		_update_active_sprite("Stand", active_sprite_direction)
		emit_signal("die")
	emit_signal("health_change", health)


func _use_coconut():
	for item_type in item_type_to_slot.keys():
		if item_type == "rock" and item_type_to_slot[item_type].amount > 0:
			set_health(health + 3)
			var inventory_slot = item_type_to_slot["coconut"]
			inventory_slot.amount -= 1
			
			emit_signal("inventory_slot_change", inventory_slot)
			return

	emit_signal("use_coconut_without_rock")


func _use_stone():
	var inventory_slot = item_type_to_slot["stone"]
	if inventory_slot.amount > 0:
		inventory_slot.amount -= 1
		
		emit_signal("inventory_slot_change", inventory_slot)
		emit_signal("throw_stone", position, direction)


func has_item(item_type):
	return item_type_to_slot.has(item_type)


func _on_Hurtbox_area_entered(area):
	if not _is_hurting and area.is_in_group("Attack") \
	and not area.is_in_group("Islander") \
	and (not IS_IMMUNE_TO_STONE or not area.is_in_group("Stone")):
		set_health(health - 100 * area.attack_power)
		get_node("CharacterAnimations").modulate = Color.red
		_is_hurting = true
		get_node("HurtCooldown").start()


func _on_AttackCooldown_timeout():
	attack_ready = true


func _on_HurtTimer_timeout():
	get_node("CharacterAnimations").modulate = Color.white
	_is_hurting = false


func _on_EmoteTimer_timeout():
	get_node("TargetFoundEmote").visible = false
	on_finished_emote_ref.call_func()


func _on_HUD_use_item(item_type):
	match item_type:
		"stone":
			_use_stone()
		"coconut":
			_use_coconut()
		"stick":
			attack()


func _on_AttackArea_area_entered(area):
	if area.get_owner().is_in_group("Islander"):
		return
	
	get_node("StickHit").play()
	
