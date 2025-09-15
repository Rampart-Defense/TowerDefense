extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#piilota ja estä "pause" käyttö
	GlobalUi.get_node("PauseMenu").visible = false
	GlobalUi.get_node("PauseMenu").can_pause = false
	GlobalUi.get_node("TowerShop").hide_shop()
	GlobalUi.get_node("StatsDisplay").visible = false


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Menus/mapselection_menu.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
