extends Node2D


var is_tree_shown = false
var is_crab_shown = false

var crab_spawn_position: Vector2
var items_spawned = 0

func _enter_tree():
	$Objects.color = Color.black


func _ready():
	var crab = get_node("Objects/Props/Crab")
	crab_spawn_position = crab.global_position
	crab.global_position = Vector2(-999999, 0)
	get_node("AnimationPlayer").play("ShowIslander")
	get_node("IslanderController").disable_controls()
	$Particles2D.emitting = false


func set_attempt_number(_attempt_number):
	pass


func _on_StartingArea_body_exited(body):
	if not is_tree_shown and body.is_in_group("Islander"):
		is_tree_shown = true
		get_node("AnimationPlayer").queue("ShowTree")


func _on_TreeArea_body_entered(body):
	if not is_crab_shown and body.is_in_group("Islander"):
		is_crab_shown = true
		get_node("Objects/Props/Crab").global_position = crab_spawn_position
		get_node("AnimationPlayer").queue("SpawnAndShowCrab")


func _on_Tree_spawn_item(_item_type, _source_position):
	items_spawned += 1
	if items_spawned == 3:
		get_node("AnimationPlayer").queue("RainCoconuts")
		get_node("IslanderController").disable_controls()
		get_node("AIController").disable_ai()


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "ShowIslander":
		get_node("IslanderController").enable_controls()
		
	if anim_name == "RainCoconuts":
		SceneManager.load_next_level()
