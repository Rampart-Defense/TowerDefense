extends Control

@onready var map_list = $ScrollContainer/CenterContainer/GridContainer

var maps = {
	"testscene1": "res://Scenes/Test/test_scene.tscn",
	"testscene2": "res://Scenes/Test/testscene_2.tscn",
	"testscene3": "res://Scenes/Test/test_scene_3.tscn",
	"testscene4": "res://Scenes/Test/test_scene_3.tscn",
	"testscene5": "res://Scenes/Test/test_scene_3.tscn",
	"testscene6": "res://Scenes/Test/test_scene_3.tscn",
	"testscene7": "res://Scenes/Test/test_scene_3.tscn",
}

func _ready():
	var button_size = Vector2(200, 200)
	# Iterate through our data source
	for map_name in maps:
		var button = Button.new()
		button.text = map_name
		
		button.custom_minimum_size = button_size
		
		# Connect the button's "pressed" signal to a function
		button.pressed.connect(_on_map_button_pressed.bind(maps[map_name]))
		
		# Add the new button to our GridContainer
		map_list.add_child(button)

func _on_map_button_pressed(map_path):
	# This function is now generic and can handle any map
	GlobalUi.get_node("PauseMenu").can_pause = true
	get_tree().change_scene_to_file(map_path)


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Menus/main_menu.tscn")
