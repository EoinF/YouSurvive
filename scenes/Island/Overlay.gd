tool
extends ColorRect

export(float, 0.0, 1.0) var INTENSITY = 0.0 setget set_intensity


func set_intensity(new_intensity):
	INTENSITY = new_intensity
	self.material.set_shader_param("intensity", INTENSITY)


func _enter_tree():
	set_intensity(INTENSITY)
