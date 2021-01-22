extends Control


func set_objectives(objectives: Array):
	var string_array = PoolStringArray(objectives)
	var text = "-  " + string_array.join("\n-  ")
	get_node("RichTextLabel").set_text(text)
