extends Panel
@export var tower = preload("res://Scenes/Towers/archery_tower.tscn")
@export var price: int = 200
var preview_tower: Node2D = null

var main_camera: Camera2D = null


func _on_gui_input(event: InputEvent) -> void:
	_handle_shopkeeping(event)
	

func _handle_shopkeeping(event):
	
	if not main_camera:
		if GlobalCamera and is_instance_valid(GlobalCamera):
			main_camera = GlobalCamera.camera
		else:
			print("Error: GlobalCamera singleton not found!")
			return # Exit the function if the camera is not available.
	
	if event is InputEventMouseButton and event.button_mask == 1: #1 = hiiren vasen näppäin pohjassa
		if PlayerStats.get_money() >= price and preview_tower == null:
			TowersNode.delete_temporary_towers()
			preview_tower = tower.instantiate()
			preview_tower.add_to_group("temp")
			var viewport_mouse_position = get_viewport().get_mouse_position()
			var world_mouse_position = main_camera.get_canvas_transform().affine_inverse() * viewport_mouse_position
			preview_tower.global_position = world_mouse_position
			var ysortter = TowersNode.get_ysorter()
			if ysortter != null:
				ysortter.add_child(preview_tower)
				preview_tower.placing_tower = true
				preview_tower.modulate = Color(1,1,1,0.7) # semi-transparent while dragging
				preview_tower.get_node("RangeArea").visible = true
			else: 
				print("map needs a node in group ysortter")
	if event is InputEventMouseMotion and event.button_mask == 1 and  PlayerStats.get_money() >= price:
	
		if preview_tower:
			var viewport_mouse_position = get_viewport().get_mouse_position()
			var world_mouse_position = main_camera.get_canvas_transform().affine_inverse() * viewport_mouse_position
			preview_tower.global_position = world_mouse_position
			if preview_tower.can_place():
				# valid spot → white-ish
				preview_tower.modulate = Color(1, 1, 1, 0.7)
				print("this is a good spot maybe...")
			else:
				# invalid spot → red tint
				preview_tower.modulate = Color(1, 0.3, 0.3, 0.7)
				print("not there")
	if event is InputEventMouseButton and event.button_mask == 0:
		if preview_tower:
			if preview_tower.can_place():
			# Finalize placement
				PlayerStats.spend_money(price)
				preview_tower.get_node("RangeArea").visible = false
				preview_tower.modulate = Color(1,1,1,1) # full color
				preview_tower.placing_tower = false
				preview_tower.remove_from_group("temp")
				preview_tower = null
				print("Tower placed!")
			else:
				print('Cant place there. aborting.')
				
		TowersNode.delete_temporary_towers()
		print("clickup")
