extends YSort

signal hit_raft(damage_amount)

export var LOOP_DISTANCE_X = -1
export var LOOP_DISTANCE_Y = 0
export var SHOULD_LOOP_Y = true
export var SHOULD_RESET_ON_HIT = false

var ROCK_DAMAGE = 4
var starting_position
var is_raft_alive = true


func move(x_delta, y_delta):
	position.x += x_delta
	position.y += y_delta
	
	var diff = position - starting_position
	if LOOP_DISTANCE_X > 0 and abs(diff.x) >= LOOP_DISTANCE_X:
		position.x = starting_position.x

	var limit_y = get_viewport_rect().size.y + LOOP_DISTANCE_Y
	for child in get_children():
		var child_height = child.get_height()
		if child.global_position.y + child_height < -LOOP_DISTANCE_Y:
			child.position.y += limit_y + LOOP_DISTANCE_Y
		elif child.global_position.y > limit_y:
			child.position.y -= limit_y + LOOP_DISTANCE_Y


func _ready():
	starting_position = position
	for prop in get_children():
		if prop.object_type == "sea_rock":
			prop.connect("collide", self, "_on_rock_collide", [prop])


func add_child_prop(prop):
	if prop.object_type == "sea_rock":
		prop.connect("collide", self, "_on_rock_collide", [prop])
	add_child(prop)


func _on_rock_collide(rock):
	if not is_raft_alive:
		return
	emit_signal("hit_raft", ROCK_DAMAGE)
	rock.queue_free()
	if SHOULD_RESET_ON_HIT:
		reset()


func reset():
	position = starting_position


func _on_Raft_finish_sinking():
	is_raft_alive = false
