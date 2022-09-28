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

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "fade out":
		get_node("Tip").visible = false
		return
	var next_animation_name = "Flash" if is_active else "fade out"
	get_node("AnimationPlayer").play(next_animation_name)


func _on_Experimenter_place_item(_item_type, _source_location):
	is_active = false
