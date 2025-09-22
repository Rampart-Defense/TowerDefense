extends Control
var can_pause = true

func resume() -> void:
	get_tree().paused = false
	visible = false  # hide pause menu

func pause() -> void:
	get_tree().paused = true
	visible = true   # show pause menu

func _ready() -> void:
	visible = false  # start hidden
		# Instantiate (create an instance of) the scene

func _process(_delta: float) -> void:
	if can_pause:
		if Input.is_action_just_pressed("Pause"):
			TowerUpgradeManager.close_all_tower_upgrade_menus()
			TowersNode.delete_temporary_towers()
			if get_tree().paused:
				resume()
			else:
				pause()

func _on_resume_pressed() -> void:
	resume()

func _on_exit_pressed() -> void:
	TowersNode.delete_bought_towers()
	get_tree().paused = false # Unpause the game tree
	Waves.stop_spawning_and_clear_enemies()

	get_tree().change_scene_to_file("res://Scenes/Menus/main_menu.tscn")
	
