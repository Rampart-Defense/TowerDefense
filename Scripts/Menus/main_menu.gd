extends Control

@onready var options_menu: Control = $OptionsMenu
@onready var button_manager: VBoxContainer = $Button_manager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#piilota ja estä "pause" käyttö
	GlobalUi.get_node("PauseMenu").hide()
	GlobalUi.get_node("PauseMenu").can_pause = false
	GlobalUi.get_node("SidePanel").hide_all()
	GlobalUi.get_node("StatsDisplay").hide()
	GlobalUi.get_node("SidePanelButton").hide()
	GlobalCamera.change_zoom_for_menu()
	button_manager.visible = true
	options_menu.visible = false
	options_menu.connect("back_pressed", Callable(self, "_on_options_back"))

func _on_play_pressed() -> void:
	SoundManager.get_node("buttonpress").play()
	get_tree().change_scene_to_file("res://Scenes/Menus/mapselection_menu.tscn")
	
func _on_quit_pressed() -> void:
	var sound_node = SoundManager.get_node("buttonpress")
	sound_node.play()
	await sound_node.finished
	get_tree().quit()

func _on_options_pressed() -> void:
	SoundManager.get_node("buttonpress").play()
	button_manager.visible = false
	options_menu.visible = true

func _on_options_back() -> void:
	SoundManager.get_node("buttonpress").play()
	options_menu.visible = false
	button_manager.visible = true
