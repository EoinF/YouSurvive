extends Node

var rand = RandomNumberGenerator.new()
var is_playing = false
var is_left_foot = true

var sound_weighting = ["1", "1", "1", "2", "2", "2", "3"]

func _ready():
	if get_owner() == null:
		start()


func start():
	if is_playing:
		return
	is_playing = true
	play_sound()
	get_node("NextSoundTimer").start()


func stop():
	is_playing = false

func play_sound():
	is_left_foot = not is_left_foot
	var prefix = "Left" if is_left_foot else "Right"
	var index = rand.randi_range(0, len(sound_weighting) - 1)
	var sound = get_node(prefix + sound_weighting[index])
	sound.play()


func _on_NextSoundTimer_timeout():
	if not is_playing:
		get_node("NextSoundTimer").stop()
		return
	play_sound()
