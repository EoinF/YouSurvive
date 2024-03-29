extends Control

signal finish_scene(player_name)

var player_name = ""

func _ready():
	get_node("DialogueManager").start_section("Main1")


func _on_DialogueManager_finish_dialogue(section_name):
	if section_name == "Main1":
		get_node("Name Entry").visible = true
	elif section_name == "Outro":
		SaveManager.save_player_name(player_name)
		SceneManager.load_next_level(null)


func _on_Name_Entry_text_entered(text: String):
	get_node("Name Entry").visible = false
	var manager = get_node("DialogueManager")
	player_name = text.strip_edges()
	if len(player_name) == 0:
		player_name = "nameless one"
		manager.start_section("Nameless")
		return
		
	manager.set_variables({
		"player_name": player_name
	})
	if player_name.to_lower() == "durme":
		manager.start_section("Remembered")
		return
		
	manager.start_section("Named")


func _on_Credits_finish_scene():
	SaveManager.save_player_name(player_name)
	SceneManager.load_next_level(null)


func _on_AnimationPlayer_animation_finished(anim_name):
	$Credits.show(true)
