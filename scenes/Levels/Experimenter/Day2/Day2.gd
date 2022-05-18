extends Node2D


func set_player_name(player_name):
	get_node("HUDLayer/HUD/DialogueManager").set_variables({
		"player_name": player_name
	})


func _ready():
	get_node("AIController").disable_ai()
	_fade_in()


func _fade_in():
	var animation_player = get_node("AnimationPlayer")
	animation_player.play("fade")


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "fade":
		get_node("HUDLayer/HUD/DialogueManager").start_section("Intro")


func _on_DialogueManager_finish_dialogue(section_name):
	if section_name == "Outro":
		var experiment_data = get_node("Experimenter").get_experiment_data()
		emit_signal("finish_scene", experiment_data)
		queue_free()

