extends Node2D

signal finish_scene

var is_collect_branches_complete = false

func _ready():
	get_node("Day1Objectives").set_objective_active("collect_branches", true)
	
	# Run this only if scene is run standalone
	if get_owner() == null:
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
		emit_signal("finish_scene")
		queue_free()


func _on_Islander_die():
	get_node("AnimationPlayer").play("fade_out")


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "fade_out":
		get_tree().reload_current_scene()
