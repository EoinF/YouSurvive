tool
extends ColorRect

export(float, 0.0, 1.0) var INTENSITY = 0.0 setget set_intensity


func set_intensity(new_intensity):
	INTENSITY = new_intensity
	self.material.set_shader_param("intensity", INTENSITY)


func _enter_tree():
	set_intensity(INTENSITY)


func _on_Ghost_health_change(health):
	print(health)
	if health > 300:
		set_intensity(0)
	else:
		set_intensity(0.2 + 0.3 * max(0, (350 - health) / 350.0))
