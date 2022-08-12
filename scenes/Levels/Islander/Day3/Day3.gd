extends Node2D

signal finish_scene

var is_islander_dead = false

func _ready():
	get_node("Day3Objectives").set_objective_active("collect_items", true)
	get_node("AIController").enable_ai()
	
	# Run this only if scene is run standalone
	if get_owner() == null:
		var test_file = File.new()
		
		test_file.open("utils/test_data.json", File.READ)
		var test_data = parse_json(test_file.get_as_text())
		test_file.close()
		set_experiment_data(test_data["Day3"])


func set_experiment_data(_data):
	get_node("ExperimentReplay").set_experiment_data(_data)


func _on_Day3Objectives_objectives_updated(objectives):
	if objectives[0]["is_complete"] and objectives[1]["is_complete"]:
		get_node("HUDLayer/HUD/DialogueManager").start_section("Main")


func _on_DialogueManager_finish_dialogue(section_name):
	if section_name == "Main":
		$AnimationPlayer.play("fade_out")


func _on_Islander_die():
	get_node("AnimationPlayer").play("fade_out")
	is_islander_dead = true


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "fade_out":
		if is_islander_dead:
			get_tree().change_scene("res://scenes/Levels/Islander/Day3/Day3.tscn")
		else:
			emit_signal("finish_scene")
			queue_free()
