extends Node2D

var rand: RandomNumberGenerator

# Called when the node enters the scene tree for the first time.
func _ready():
	rand = RandomNumberGenerator.new()
	rand.randomize()
	start_timer(5.0, 20.0)
	
	
func play_next():
	var next_index = rand.randi_range(1,3)
	get_node("Grunt" + str(next_index)).play()
	start_timer(1.0, 15.0)


func start_timer(min_time, max_time):
	var cooldown_timer = get_node("Cooldown")
	cooldown_timer.wait_time = rand.randf_range(min_time, max_time)
	cooldown_timer.start()


func _on_Cooldown_timeout():
	play_next()
