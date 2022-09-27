extends Control

var is_active = false

func _ready():
	get_node("Tip").visible = false
	
	# Activate when this is a standalone scene
	if get_owner() == null:
		activate()


func activate():
	get_node("Tip").visible = true
	get_node("AnimationPlayer").play("Flash")
	is_active = true


func _process(_delta):
	if not is_active:
		return
		
	if Input.is_action_pressed('ui_left') \
	or Input.is_action_pressed('ui_right') \
	or Input.is_action_pressed('ui_up') \
	or Input.is_action_pressed('ui_down'):
		is_active = false


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "fade out":
		get_node("Tip").visible = false
		return
	var next_animation_name = "Flash" if is_active else "fade out"
	get_node("AnimationPlayer").play(next_animation_name)
