extends CanvasLayer

func _ready():
	GlobalCamera.change_zoom_for_map()

func _on_newgame_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Menus/mapselection_menu.tscn")
	get_tree().paused = false
	SoundManager.get_node("buttonpress").play()
	queue_free()

func _on_backtomenu_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Menus/main_menu.tscn")
	get_tree().paused = false
	SoundManager.get_node("buttonpress").play()
	queue_free()
