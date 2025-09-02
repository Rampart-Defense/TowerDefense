extends Control


func resume() -> void:
	get_tree().paused = false
	visible = false  # hide pause menu

func pause() -> void:
	get_tree().paused = true
	visible = true   # show pause menu

func _ready() -> void:
	visible = false  # start hidden
		# Instantiate (create an instance of) the scene

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Pause"):
		if get_tree().paused:
			resume()
		else:
			pause()

func _on_resume_pressed() -> void:
	resume()

func _on_exit_pressed() -> void:
	get_tree().paused = false # Unpause the game tree
	get_tree().change_scene_to_file("res://Scenes/Menus/main_menu.tscn")
	
