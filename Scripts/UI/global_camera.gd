extends Node2D

@onready var camera = $Camera2D



func change_zoom_for_map():
	camera.position = Vector2(705,320)
	camera.zoom = Vector2(0.82, 1)
	pass
	
func change_zoom_for_menu():
	camera.position = Vector2(576,320)
	camera.zoom = Vector2(1,1)
