extends Node

signal edge_reached
signal finish

var is_finished = false
var is_at_edge = false
var RAFT_SPEED = 20
var sea_tilemap_original_position: Vector2


func _ready():
	var sea_tilemap = get_owner().get_node("Objects/GroundTiles")
	sea_tilemap_original_position = sea_tilemap.position


func _on_Raft_y_change(amount):
	# Move in the opposite direction to the raft (relative movement)
	var y_delta = -amount
	var sea_tilemap = get_owner().get_node("Objects/GroundTiles")
	sea_tilemap.position.y += y_delta
	while sea_tilemap.position.y < sea_tilemap_original_position.y - 16:
		sea_tilemap.position.y += 16
	
	var sea_rocks = get_owner().get_node("Objects/Props/SeaRocks")
	sea_rocks.position.y += y_delta


func _process(delta):
	var diff_x = delta * RAFT_SPEED
	var raft = get_owner().get_node("Objects/Props/Raft")
	
	if is_finished:
		return
	
	if is_at_edge:
		raft.position.x += diff_x
		
		if $SceneEdge.position.x < raft.get_x_left():
			emit_signal("finish")
			is_finished = true
		return
	
	var sea_tilemap = get_owner().get_node("Objects/GroundTiles")
	var sea_rocks = get_owner().get_node("Objects/Props/SeaRocks")
	sea_rocks.position.x -= diff_x
	sea_tilemap.position.x -= diff_x
	while sea_tilemap.position.x < sea_tilemap_original_position.x - 16:
		sea_tilemap.position.x += 16
		
	$ScrollEdge.position.x -= diff_x
	if $ScrollEdge.global_position.x < raft.get_x_left():
		is_at_edge = true
		emit_signal("edge_reached")
	
	
	

