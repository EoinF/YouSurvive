extends Node2D


func _on_Props_enemy_struggle():
	$Objects/Props/Raft.hit()


func set_experiment_data(_data):
	experiment_data = _data
	get_node("ExperimentReplay").set_experiment_data(_data)
