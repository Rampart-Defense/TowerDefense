extends Control

@onready var map_list = $ScrollContainer/CenterContainer/GridContainer
const CUSTOM_FONT = preload("res://Art/VisualArt/UI/Fonts/Varnished.ttf")
var maps = {
	"Frostbite Fields": {
		"path": "res://Scenes/Maps/frostbite_fields.tscn",
		"icon": "res://Art/VisualArt/UI/Menus/Mapselection/map_preview/frostbite_fields.png"
	},
	"Scorched Sands": {
		"path": "res://Scenes/Maps/scorched_sands.tscn",
		"icon": "res://Art/VisualArt/UI/Menus/Mapselection/map_preview/scorched_sands.png"
	},
	"Oasis": {
		"path": "res://Scenes/Maps/oasis.tscn",
		"icon": "res://Art/VisualArt/UI/Menus/Mapselection/map_preview/oasis.png"
	},
	"Nature's Edge": {
		"path": "res://Scenes/Maps/natures_edge.tscn",
		"icon": "res://Art/VisualArt/UI/Menus/Mapselection/map_preview/natures_edge.png"
	},
	"Amber Fall": {
		"path": "res://Scenes/Maps/amber_fall.tscn",
		"icon": "res://Art/VisualArt/UI/Menus/Mapselection/map_preview/amber_fall.png"
	},
	"Crossroads of Doom": {
		"path": "res://Scenes/Maps/crossroads_of_doom.tscn",
		"icon": "res://Art/VisualArt/UI/Menus/Mapselection/map_preview/crossroads_of_doom.png"
	},
	"Crystal Caverns": {
		"path": "res://Scenes/Maps/crystal_caverns.tscn",
		"icon": "res://Art/VisualArt/UI/Menus/Mapselection/map_preview/crystal_caverns.png"
	},
}

func _ready():
	GlobalUi.get_node("PauseMenu").hide()
	GlobalUi.get_node("PauseMenu").can_pause = false
	GlobalUi.get_node("SidePanel").hide_all()
	GlobalUi.get_node("StatsDisplay").hide()
	GlobalCamera.change_zoom_for_menu()
	
	var button_size = Vector2(200, 200)
	# Iterate through our data source
	for map_name in maps:
		var map_data = maps[map_name] # Get the map's dictionary (path and icon)

		var button = Button.new()
		button.text = map_name
		
		button.add_theme_font_override("font", CUSTOM_FONT)
		# button.icon = load(map_data.icon) 
		# button.expand_icon = true
		
		button.custom_minimum_size = button_size
		
		button.pressed.connect(_on_map_button_pressed.bind(map_name, map_data))
		
		# Add the new button to our GridContainer
		map_list.add_child(button)

func _on_map_button_pressed(map_name, map_data):
	SoundManager.get_node("buttonpress").play()
	
	# 1. Store the selected map data in the global GameManager
	GameManager.selected_map_name = map_name
	GameManager.selected_map_scene_path = map_data.path
	GameManager.selected_map_icon_path = map_data.icon
	
	get_tree().change_scene_to_file("res://Scenes/Menus/difficulty_selection.tscn")

func _on_button_pressed() -> void:
	SoundManager.get_node("buttonpress").play()
	get_tree().change_scene_to_file("res://Scenes/Menus/main_menu.tscn")
