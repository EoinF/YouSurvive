extends Node2D


func pause():
	$BeachLoop.stop()
	$SeaAIController.disable_ai()
	
	
func resume():
	$BeachLoop.play()
	$SeaAIController.enable_ai()
