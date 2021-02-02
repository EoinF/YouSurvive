extends Node

signal finish_scene

var player_name: String


func set_player_name(name: String):
	player_name = name
	get_node("HUD/DialogueContainer/MainDialogue1").set_variables({
		"player_name": player_name
	})


func _ready():
	get_node("HUD/DialogueContainer/MainDialogue1").start()


func _process(delta):
	_process_movement_input(delta)


func _process_movement_input(delta):
	var experimenter = get_node("Experimenter")
	var x = 0
	var y = 0
	
	var islander = get_node("Objects/Props/Islander")
	if Input.is_action_pressed('center_camera'):
		experimenter.focus_target(islander)
	
	if Input.is_action_pressed('ui_left'):
		x -= 1
	if Input.is_action_pressed('ui_right'):
		x += 1
	if Input.is_action_pressed('ui_up'):
		y -= 1
	if Input.is_action_pressed('ui_down'):
		y += 1

	if (x != 0 or y != 0):
		var deltaVector = Vector2(x, y).normalized() * delta
		
		experimenter.move(deltaVector)

