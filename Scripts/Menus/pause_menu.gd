extends Control
var can_pause = true

@onready var options_menu: Control = $OptionsMenu
@onready var pause_menu: PanelContainer = $PanelContainer
@onready var pause_button: TextureButton = $"../PauseButton"

func resume() -> void:
	get_tree().paused = false
	visible = false  # hide pause menu
	GlobalUi.get_node("SidePanel").show_shop()

func pause() -> void:
	get_tree().paused = true
	visible = true   # show pause menu

func _ready() -> void:
	visible = false  # start hidden
		# Instantiate (create an instance of) the scene
	options_menu.visible = false
	options_menu.connect("back_pressed", Callable(self, "_on_options_back"))
	
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
	SoundManager.get_node("buttonpress").play()
	var sound_node = SoundManager.get_node("buttonpress")
	resume()

func _on_exit_pressed() -> void:
	SoundManager.get_node("buttonpress").play()
	pause_button.visible = false
	var sound_node = SoundManager.get_node("buttonpress")
	GlobalCamera.change_zoom_for_menu()
	TowersNode.delete_bought_towers()
	get_tree().paused = false # Unpause the game tree
	Waves.stop_spawning_and_clear_enemies()
	
	get_tree().change_scene_to_file("res://Scenes/Menus/main_menu.tscn")
	

func _on_options_pressed() -> void:
	SoundManager.get_node("buttonpress").play()
	options_menu.visible = true
	pause_menu.visible = false
	
func _on_options_back() -> void:
	SoundManager.get_node("buttonpress").play()
	options_menu.visible = false
	pause_menu.visible = true

func _on_pause_button_pressed() -> void:
	pause()
	SoundManager.get_node("buttonpress").play()
