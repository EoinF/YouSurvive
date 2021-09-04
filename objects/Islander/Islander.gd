extends KinematicBody2D

signal use_coconut_without_rock
signal inventory_slot_change(inventory_slot)
signal stamina_change(stamina)
signal throw_stone(position, direction)

export var SPEED = 8 * 1000
export var STAMINA = 25
export var SPEED_WHILE_TIRED = 8 * 1000

var object_type = "islander"

var walking_timeout = 0
func is_attacking():
	return get_node("AttackPivotPoint/AttackAnimation").is_playing()

var velocity = Vector2.ZERO
var direction = Vector2.DOWN
var attack_direction = Vector2.DOWN
var active_sprite_state = "Stand"
var active_sprite_direction = "Down"
var _is_hurting = false


class InventorySlot:
	var node_key: String
	var amount: int
	var item_type: String

var item_type_to_slot = {}
var unused_keys = ["1", "2", "3"]
var stamina: int

var on_finished_emote_ref: FuncRef


func is_colliding():
	return test_move(transform, velocity.normalized())


func _ready():
	set_stamina(STAMINA)

func _process(_delta):
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
	walking_timeout = 10
	direction = Vector2(x, y).normalized()
	
	if (stamina <= 25):
		velocity.x = direction.x * SPEED_WHILE_TIRED
		velocity.y = direction.y * SPEED_WHILE_TIRED
	else:
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


func throw_stone(x, y):
	# First, face the direction to throw, then throw the stone
	move(x, y)
	_use_stone()


func attack(_x = 0, _y = 0):
	get_node("AttackPivotPoint/AttackAnimation/AttackArea/Shape").disabled = false
	var attack_animation = get_node("AttackPivotPoint/AttackAnimation")
	if(not attack_animation.is_playing()):
		get_node("AttackPivotPoint").rotation = atan2(direction.y, direction.x) - PI / 2
	attack_animation.visible = true
	attack_animation.set_frame(0)
	attack_animation.play()
	attack_direction = direction 
	_update_active_sprite("Run", active_sprite_direction)
	walking_timeout = 40


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
	print("starting emote")
	on_finished_emote_ref = on_finished
	get_node("TargetFoundEmote").visible = true
	get_node("EmoteTimer").start()


func _update_active_sprite(new_sprite_state, new_sprite_direction):
	if (new_sprite_direction != ""):
		active_sprite_direction = new_sprite_direction
		active_sprite_state = new_sprite_state
		get_node("CharacterAnimations").animation = active_sprite_state + "_" + active_sprite_direction
	else:
		print("invalid sprite direction")


func _physics_process(delta):
	move_and_slide(velocity * delta)
	velocity = Vector2.ZERO


func _on_AttackAnimation_animation_finished():
	get_node("AttackPivotPoint/AttackAnimation/AttackArea/Shape").disabled = true
	var attack_animation = get_node("AttackPivotPoint/AttackAnimation")
	attack_animation.visible = false
	attack_animation.stop()


func set_stamina(new_stamina):
	stamina = new_stamina
	emit_signal("stamina_change", stamina)
	
	if stamina <= 50:
		get_node("AttackPivotPoint/AttackAnimation").scale.x = 0.5
		get_node("AttackPivotPoint/AttackAnimation").scale.y = 0.5
		get_node("AttackPivotPoint/AttackAnimation/AttackArea").attack_power = 0
	else:
		get_node("AttackPivotPoint/AttackAnimation").scale.x = 1.0
		get_node("AttackPivotPoint/AttackAnimation").scale.y = 1.0
		get_node("AttackPivotPoint/AttackAnimation/AttackArea").attack_power = 2


func _on_StaminaTimer_timeout():
	set_stamina(stamina - 1)


func _use_coconut():
	for item_type in item_type_to_slot.keys():
		if item_type == "rock" and item_type_to_slot[item_type].amount > 0:
			set_stamina(stamina + 20)
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


func _on_Hurtbox_area_entered(area):
	if not _is_hurting and area.is_in_group("Attack") \
	and not area.is_in_group("Islander") \
	and not area.is_in_group("Stone"):
		set_stamina(stamina - 10)
		self.modulate = Color.lightpink
		_is_hurting = true
		get_node("HurtCooldown").start()


func _on_HurtTimer_timeout():
	self.modulate = Color.white
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
