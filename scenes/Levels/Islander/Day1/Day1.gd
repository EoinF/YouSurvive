extends Node2D

signal finish_scene

var is_collect_branches_complete = false
var is_islander_dead = false

var IS_DEBUG_ACTIVE = false


func _fade_out():
	$AnimationPlayer.play("fade_out")


func _ready():
	get_node("Day1Objectives").set_objective_active("collect_branches", true)
	
	if IS_DEBUG_ACTIVE:
		var test_file = File.new()
		
		test_file.open("utils/test_data.json", File.READ)
		var test_data = parse_json(test_file.get_as_text())
		test_file.close()
		set_experiment_data(test_data["Day1"])


func set_experiment_data(_data):
	get_node("ExperimentReplay").set_experiment_data(_data)


func _on_Day1Objectives_objectives_updated(objectives):
	if not is_collect_branches_complete and objectives[1]["is_complete"]:
		is_collect_branches_complete = true
		get_node("HUDLayer/HUD/DialogueManager").start_section("Main")
		get_node("MusicLoop").stop()


func _on_DialogueManager_finish_dialogue(section_name):
	if section_name == "Main":
		_fade_out()


func _on_Islander_die():
	get_node("AnimationPlayer").play("fade_out")
	is_islander_dead = true


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "fade_out":
		if is_islander_dead:
			get_tree().change_scene("res://scenes/Levels/Islander/Day1/Day1.tscn")
		else:
			emit_signal("finish_scene")
			queue_free()
