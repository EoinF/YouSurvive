extends Node2D

var rand: RandomNumberGenerator

# Called when the node enters the scene tree for the first time.
func _ready():
	rand = RandomNumberGenerator.new()
	rand.randomize()
	play_next()
	
	
func play_next():
	var next_index = rand.randi_range(1,3)
	get_node("Grunt" + str(next_index)).play()
	
	var cooldown_timer = get_node("Cooldown")
	cooldown_timer.wait_time = rand.randf_range(1.0, 15.0)
	cooldown_timer.start()


func _on_Cooldown_timeout():
	play_next()
