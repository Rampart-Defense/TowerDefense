extends Control

# References to UI nodes in the Difficulty Selection scene
@onready var map_image = $MapImage as TextureRect
@onready var map_name_label = $MapNameLabel as Label

@onready var easy_button: TextureButton = $HBoxContainer/EasyButton
@onready var medium_button: TextureButton = $HBoxContainer/MediumButton
@onready var hard_button: TextureButton = $HBoxContainer/HardButton

const CUSTOM_FONT = preload("res://Art/VisualArt/UI/Fonts/Varnished.ttf")

# Variable to hold the map path retrieved from GameManager
var selected_map_scene_path: String

func _ready():
	GlobalUi.get_node("PauseMenu").hide()
	GlobalUi.get_node("PauseMenu").can_pause = false
	GlobalUi.get_node("SidePanel").hide_all()
	GlobalUi.get_node("StatsDisplay").hide()
	GlobalCamera.change_zoom_for_menu()
	# Retrieve the stored data from the global GameManager

	var name = GameManager.selected_map_name
	var icon_path = GameManager.selected_map_icon_path
	self.selected_map_scene_path = GameManager.selected_map_scene_path
	
	# --- Display the Map Image and Name ---
	map_name_label.text = name
	map_name_label.add_theme_font_override("font", CUSTOM_FONT)
	map_image.texture = load(icon_path) # Load and display the image
	
	# --- Connect Difficulty Buttons ---
	easy_button.pressed.connect(_on_difficulty_selected.bind("EASY"))
	medium_button.pressed.connect(_on_difficulty_selected.bind("MEDIUM"))
	hard_button.pressed.connect(_on_difficulty_selected.bind("HARD"))
	
	# Optional: Clear the global data now that we've used it
	GameManager.selected_map_name = ""
	GameManager.selected_map_icon_path = ""


# Function called when any difficulty button is pressed
func _on_difficulty_selected(difficulty: String):
	SoundManager.get_node("buttonpress").play()
	
	# 1. Start the game with the chosen difficulty
	PlayerStats.start_game(difficulty)
	
	# 2. Set up the necessary UI/Game state
	GlobalUi.get_node("PauseMenu").can_pause = true
	GlobalUi.get_node("PauseButton").visible = true
	GlobalUi.get_node("SidePanel").show_all()
	if GlobalUi.get_node("SidePanel").is_hidden:
		GlobalUi.get_node("SidePanel").show_side_panel()
	GlobalUi.get_node("StatsDisplay").show()
	GlobalCamera.change_zoom_for_map()
	# 3. Load the selected map scene
	get_tree().change_scene_to_file(selected_map_scene_path)


func _on_button_pressed() -> void:
	SoundManager.get_node("buttonpress").play()
	get_tree().change_scene_to_file("res://Scenes/Menus/mapselection_menu.tscn")
