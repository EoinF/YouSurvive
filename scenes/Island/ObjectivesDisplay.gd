extends Control


func set_objectives(objectives: Array):
	var string_array = PoolStringArray()
	for objective in objectives:
		string_array.push_back(objective.description)
	var text = "-  " + string_array.join("\n-  ")
	get_node("RichTextLabel").bbcode_text = text
