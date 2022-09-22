extends Node2D

func pause():
	$BeachLoop.stop()
	$SeaAIController.disable_ai()
	
	
func resume():
	#$Objects.position = Vector2.ZERO
	$BeachLoop.play()
	$SeaAIController.enable_ai()
