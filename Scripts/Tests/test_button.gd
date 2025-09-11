extends Button


func _on_button_down() -> void:
	Waves.stop_spawning_and_clear_enemies()


func _on_button_button_down() -> void:
	Waves.begin()
