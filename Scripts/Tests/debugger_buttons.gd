extends Control

@onready var fps_label = $Label

func _process(_delta: float) -> void:
	fps_label.text = "FPS: %d" % Engine.get_frames_per_second()

func _on_stop_waves_button_button_down() -> void:
	Waves.stop_spawning_and_clear_enemies()


func _on_start_waves_button_button_down() -> void:
	Waves.begin()


func _on_hard_stats_button_down() -> void:
	PlayerStats.start_game("HARD")


func _on_reset_player_stats_button_down() -> void:
	PlayerStats.set_money(0)
	PlayerStats.set_points(0)
	PlayerStats.set_current_health(PlayerStats.get_max_health())


func _on_free_money_button_down() -> void:
	PlayerStats.add_money(20000)


func _on_lose_button_down() -> void:
	PlayerStats.die()


func _on_win_button_down() -> void:
	PlayerStats._handle_victory()
