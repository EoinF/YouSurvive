extends Node2D


signal finish_scene

var is_tree_shown = false
var is_crab_shown = false

var crab_spawn_position: Vector2

func _ready():
	var crab = get_node("Objects/Props/Crab")
	crab_spawn_position = crab.global_position
	crab.global_position = Vector2(-999999, 0)
	get_node("AnimationPlayer").play("ShowIslander")
	get_node("IslanderController").disable_controls()


func _on_StartingArea_body_exited(body):
	if not is_tree_shown and body.is_in_group("Islander"):
		is_tree_shown = true
		get_node("AnimationPlayer").queue("ShowTree")


func _on_TreeArea_body_entered(body):
	if not is_crab_shown and body.is_in_group("Islander"):
		is_crab_shown = true
		get_node("Objects/Props/Crab").global_position = crab_spawn_position
		get_node("AnimationPlayer").queue("SpawnAndShowCrab")


func _on_Tree_spawn_item(item_type, source_position):
	get_node("AnimationPlayer").queue("RainCoconuts")
	get_node("IslanderController").disable_controls()
	get_node("AIController").disable_ai()


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "ShowIslander":
		get_node("IslanderController").enable_controls()
		
	if anim_name == "RainCoconuts":
		emit_signal("finish_scene")
		queue_free()

