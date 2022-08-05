extends TileMap


# Called when the node enters the scene tree for the first time.
func hit():
	if $HitCooldown.time_left > 0:
		return
	$ShakeEffect.start()
	$HitSound.play()
	$HitCooldown.start()
