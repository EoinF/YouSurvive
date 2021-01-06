extends Control

signal text_entered(text)

export var LABEL_TEXT = ""


func _ready():
	get_node("Label").text = LABEL_TEXT


func _on_ButtonOk_pressed():
	emit_signal("text_entered", get_node("TextEdit").text)
