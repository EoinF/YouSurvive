extends TileMap


# Called when the node enters the scene tree for the first time.
func hit():
	$ShakeEffect.start()
	$HitSound.play()

