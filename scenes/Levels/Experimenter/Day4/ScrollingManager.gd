extends Node

var original_y

func _ready():
	var sea_tilemap = get_owner().get_node("Objects/GroundTiles")
	original_y = sea_tilemap.position.y


func _on_Raft_y_change(amount):
	# Move in the opposite direction to the raft (relative movement)
	var y_delta = -amount
	var sea_tilemap = get_owner().get_node("Objects/GroundTiles")
	sea_tilemap.position.y += y_delta
	while sea_tilemap.position.y > original_y + 16:
		sea_tilemap.position.y -= 16
	
	var sea_rocks = get_owner().get_node("Objects/Props/SeaRocks")
	sea_rocks.position.y += y_delta
