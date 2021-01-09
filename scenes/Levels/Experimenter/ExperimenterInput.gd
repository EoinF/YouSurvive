extends Node

signal finish_scene

var CAMERA_MOVE_SPEED = 1000
var player_name: String

func set_player_name(name: String):
	player_name = name
	get_node("MainDialogue/1").set_variables({
		"player_name": player_name
	})


func _ready():
	get_node("AnimationPlayer").play("fade")
	get_node("Camera").set_follow_target(get_node("Objects/Props/Islander"), true)


func _process(delta):
	_process_movement_input(delta)


func _process_movement_input(delta):
	var camera: Camera2D = get_node("Camera")
	var x = 0
	var y = 0
	
	var islander = get_node("Objects/Props/Islander")
	if Input.is_action_pressed('center_camera'):
		camera.translate(islander.position - camera.position)
	
	if Input.is_action_pressed('ui_left'):
		x -= 1
	if Input.is_action_pressed('ui_right'):
		x += 1
	if Input.is_action_pressed('ui_up'):
		y -= 1
	if Input.is_action_pressed('ui_down'):
		y += 1

	if (x != 0 or y != 0):
		var deltaVector = Vector2(x, y).normalized() * delta * CAMERA_MOVE_SPEED
		
		var newX = camera.position.x + deltaVector.x
		var newY = camera.position.y + deltaVector.y
		
		if newX < camera.limit_left:
			deltaVector.x += camera.limit_left - newX
		elif newX > camera.limit_right:
			deltaVector.x -= newX - camera.limit_right
		if newY < camera.limit_top:
			deltaVector.y += camera.limit_top - newY
		elif newY > camera.limit_bottom:
			deltaVector.y -= newY - camera.limit_bottom
		
		camera.translate(deltaVector)


func _on_AnimationPlayer_animation_finished(anim_name):
	get_node("MainDialogue/1").start()


func _on_MainDialogue_1_finish_dialogue():
	get_node("Camera").set_is_following(false)
