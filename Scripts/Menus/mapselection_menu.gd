extends Control

@onready var map_list = $ScrollContainer/CenterContainer/GridContainer
const CUSTOM_FONT = preload("res://Art/VisualArt/UI/Fonts/Varnished.ttf")

var current_filter_mode: String = ""

var maps = {
	"Frostbite Fields": {
		"path": "res://Scenes/Maps/frostbite_fields.tscn",
		"icon": "res://Art/VisualArt/UI/Menus/Mapselection/map_preview/frostbite_fields.png",
		"mode": "easy"
	},
	"Scorched Sands": {
		"path": "res://Scenes/Maps/scorched_sands.tscn",
		"icon": "res://Art/VisualArt/UI/Menus/Mapselection/map_preview/scorched_sands.png",
		"mode": "medium"
	},
	"Oasis": {
		"path": "res://Scenes/Maps/oasis.tscn",
		"icon": "res://Art/VisualArt/UI/Menus/Mapselection/map_preview/oasis.png",
		"mode": "medium"
	},
	"Nature's Edge": {
		"path": "res://Scenes/Maps/natures_edge.tscn",
		"icon": "res://Art/VisualArt/UI/Menus/Mapselection/map_preview/natures_edge.png",
		"mode": "easy"
	},
	"Amber Fall": {
		"path": "res://Scenes/Maps/amber_fall.tscn",
		"icon": "res://Art/VisualArt/UI/Menus/Mapselection/map_preview/amber_fall.png",
		"mode": "hard"
	},
	"Crossroads of Doom": {
		"path": "res://Scenes/Maps/crossroads_of_doom.tscn",
		"icon": "res://Art/VisualArt/UI/Menus/Mapselection/map_preview/crossroads_of_doom.png",
		"mode": "hard"
	},
	"Crystal Caverns": {
		"path": "res://Scenes/Maps/crystal_caverns.tscn",
		"icon": "res://Art/VisualArt/UI/Menus/Mapselection/map_preview/crystal_caverns.png",
		"mode": "easy"
	},
}

func _ready():
	GlobalUi.get_node("PauseMenu").hide()
	GlobalUi.get_node("PauseMenu").can_pause = false
	GlobalUi.get_node("SidePanel").hide_all()
	GlobalUi.get_node("StatsDisplay").hide()
	GlobalCamera.change_zoom_for_menu()
	
	var entry_size = Vector2(250, 165)
	var label_height = 20
	var button_size = Vector2(entry_size.x, entry_size.y - label_height)
	
	for map_name in maps:
		var map_data = maps[map_name]

		var map_entry = VBoxContainer.new()
		map_entry.alignment = BoxContainer.ALIGNMENT_CENTER
		map_entry.custom_minimum_size = entry_size
		map_entry.set_meta("map_mode", map_data.mode) 
		
		var name_label = Label.new()
		name_label.text = map_name
		name_label.add_theme_font_override("font", CUSTOM_FONT)
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		name_label.custom_minimum_size = Vector2(entry_size.x, label_height)
		
		var button = Button.new()
		
		button.icon = load(map_data.icon)
		button.expand_icon = true
		
		button.custom_minimum_size = button_size
		
		button.pressed.connect(_on_map_button_pressed.bind(map_name, map_data))
		
		map_entry.add_child(name_label)
		map_entry.add_child(button)
		
		map_list.add_child(map_entry)


func filter_maps(selected_mode: String):
	SoundManager.get_node("buttonpress").play()
	
	var mode_to_apply = selected_mode
	
	if current_filter_mode == selected_mode:
		mode_to_apply = ""
		
	current_filter_mode = mode_to_apply
	
	for map_entry in map_list.get_children():
		if map_entry.has_meta("map_mode"):
			var map_mode = map_entry.get_meta("map_mode")
			
			if current_filter_mode == "":
				map_entry.show()
			elif map_mode == current_filter_mode:
				map_entry.show()
			else:
				map_entry.hide()


func _on_filter_easy_button_pressed() -> void:
	filter_maps("easy")


func _on_filter_medium_button_pressed() -> void:
	filter_maps("medium")


func _on_filter_hard_button_pressed() -> void:
	filter_maps("hard")

func _on_map_button_pressed(map_name, map_data):
	SoundManager.get_node("buttonpress").play()
	
	GameManager.selected_map_name = map_name
	GameManager.selected_map_scene_path = map_data.path
	GameManager.selected_map_icon_path = map_data.icon
	
	get_tree().change_scene_to_file("res://Scenes/Menus/difficulty_selection.tscn")

func _on_button_pressed() -> void:
	SoundManager.get_node("buttonpress").play()
	get_tree().change_scene_to_file("res://Scenes/Menus/main_menu.tscn")
