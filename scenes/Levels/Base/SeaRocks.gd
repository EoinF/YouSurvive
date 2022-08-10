extends YSort

var SPEED = 20
var ROCK_DAMAGE = 5


func _ready():
	for rock in get_children():
		rock.connect("collide", self, "_on_rock_collide", [rock])


func _process(delta):
	self.position.x -= delta * SPEED


func _on_rock_collide(rock):
	get_owner().get_node("Objects/Props/Raft").hit(ROCK_DAMAGE)
	rock.queue_free()
